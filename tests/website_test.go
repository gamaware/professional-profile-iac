package test

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/service/acm"
	acmtypes "github.com/aws/aws-sdk-go-v2/service/acm/types"
	"github.com/aws/aws-sdk-go-v2/service/cloudfront"
	"github.com/aws/aws-sdk-go-v2/service/route53"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestWebsiteS3Bucket(t *testing.T) {
	t.Parallel()

	opts := newTerraformOptions(t)
	bucketName := terraform.Output(t, opts, "s3_bucket_name")
	require.NotEmpty(t, bucketName, "s3_bucket_name output should not be empty")

	region := getRegion(t)
	cfg := getAWSConfig(t, region)
	s3Client := s3.NewFromConfig(cfg)

	// Verify public access block — all 4 settings must be true
	pabOutput, err := s3Client.GetPublicAccessBlock(context.TODO(), &s3.GetPublicAccessBlockInput{
		Bucket: &bucketName,
	})
	require.NoError(t, err, "GetPublicAccessBlock should succeed")
	require.NotNil(t, pabOutput, "GetPublicAccessBlock output should not be nil")
	require.NotNil(t, pabOutput.PublicAccessBlockConfiguration, "PublicAccessBlockConfiguration should not be nil")

	pab := pabOutput.PublicAccessBlockConfiguration
	require.NotNil(t, pab.BlockPublicAcls, "BlockPublicAcls should not be nil")
	require.True(t, *pab.BlockPublicAcls, "BlockPublicAcls should be true")

	require.NotNil(t, pab.BlockPublicPolicy, "BlockPublicPolicy should not be nil")
	require.True(t, *pab.BlockPublicPolicy, "BlockPublicPolicy should be true")

	require.NotNil(t, pab.IgnorePublicAcls, "IgnorePublicAcls should not be nil")
	require.True(t, *pab.IgnorePublicAcls, "IgnorePublicAcls should be true")

	require.NotNil(t, pab.RestrictPublicBuckets, "RestrictPublicBuckets should not be nil")
	require.True(t, *pab.RestrictPublicBuckets, "RestrictPublicBuckets should be true")
}

func TestWebsiteCloudFront(t *testing.T) {
	t.Parallel()

	opts := newTerraformOptions(t)
	distributionID := terraform.Output(t, opts, "cloudfront_distribution_id")
	require.NotEmpty(t, distributionID, "cloudfront_distribution_id output should not be empty")

	region := getRegion(t)
	cfg := getAWSConfig(t, region)
	cfClient := cloudfront.NewFromConfig(cfg)

	distOutput, err := cfClient.GetDistribution(context.TODO(), &cloudfront.GetDistributionInput{
		Id: &distributionID,
	})
	require.NoError(t, err, "GetDistribution should succeed")
	require.NotNil(t, distOutput, "GetDistribution output should not be nil")
	require.NotNil(t, distOutput.Distribution, "Distribution should not be nil")
	require.NotNil(t, distOutput.Distribution.DistributionConfig, "DistributionConfig should not be nil")

	distConfig := distOutput.Distribution.DistributionConfig

	// Enabled
	require.NotNil(t, distConfig.Enabled, "Enabled should not be nil")
	require.True(t, *distConfig.Enabled, "Distribution should be enabled")

	// HTTP version
	require.Equal(t, "http2and3", string(distConfig.HttpVersion), "HttpVersion should be http2and3")

	// Default root object
	require.NotNil(t, distConfig.DefaultRootObject, "DefaultRootObject should not be nil")
	require.Equal(t, "index.html", *distConfig.DefaultRootObject, "DefaultRootObject should be index.html")

	// Viewer certificate
	require.NotNil(t, distConfig.ViewerCertificate, "ViewerCertificate should not be nil")
	require.Equal(t, "TLSv1.2_2021", string(distConfig.ViewerCertificate.MinimumProtocolVersion),
		"MinimumProtocolVersion should be TLSv1.2_2021")

	// Default cache behavior
	require.NotNil(t, distConfig.DefaultCacheBehavior, "DefaultCacheBehavior should not be nil")
	require.Equal(t, "redirect-to-https", string(distConfig.DefaultCacheBehavior.ViewerProtocolPolicy),
		"ViewerProtocolPolicy should be redirect-to-https")
	require.NotNil(t, distConfig.DefaultCacheBehavior.Compress, "Compress should not be nil")
	require.True(t, *distConfig.DefaultCacheBehavior.Compress, "Compress should be true")

	// OAC — verify at least one origin has an OAC configured
	require.NotNil(t, distConfig.Origins, "Origins should not be nil")
	require.NotNil(t, distConfig.Origins.Items, "Origins items should not be nil")
	require.Greater(t, len(distConfig.Origins.Items), 0, "Should have at least one origin")
	require.NotNil(t, distConfig.Origins.Items[0].OriginAccessControlId, "OriginAccessControlId should not be nil")
	require.NotEmpty(t, *distConfig.Origins.Items[0].OriginAccessControlId,
		"OriginAccessControlId should not be empty")

	// Custom error responses — must include 403 and 404
	require.NotNil(t, distConfig.CustomErrorResponses, "CustomErrorResponses should not be nil")
	require.NotNil(t, distConfig.CustomErrorResponses.Items, "CustomErrorResponses items should not be nil")

	errorCodes := make(map[int]bool)
	for _, resp := range distConfig.CustomErrorResponses.Items {
		require.NotNil(t, resp.ErrorCode, "ErrorCode should not be nil")
		errorCodes[int(*resp.ErrorCode)] = true
	}
	require.True(t, errorCodes[403], "Should have custom error response for 403")
	require.True(t, errorCodes[404], "Should have custom error response for 404")
}

func TestWebsiteDNS(t *testing.T) {
	t.Parallel()

	region := getRegion(t)
	cfg := getAWSConfig(t, region)
	r53Client := route53.NewFromConfig(cfg)

	opts := newTerraformOptions(t)
	websiteURL := terraform.Output(t, opts, "website_url")
	domainName := strings.TrimPrefix(websiteURL, "https://")

	// Find the hosted zone for the domain
	zonesOutput, err := r53Client.ListHostedZonesByName(context.TODO(), &route53.ListHostedZonesByNameInput{
		DNSName: &domainName,
	})
	require.NoError(t, err, "ListHostedZonesByName should succeed")
	require.NotNil(t, zonesOutput, "ListHostedZonesByName output should not be nil")
	require.Greater(t, len(zonesOutput.HostedZones), 0, "Should find at least one hosted zone")

	// Find the matching zone (hosted zone name has trailing dot)
	var zoneID string
	for _, zone := range zonesOutput.HostedZones {
		if zone.Name == nil || zone.Id == nil {
			continue
		}
		if *zone.Name == domainName+"." {
			zoneID = *zone.Id
			break
		}
	}
	require.NotEmpty(t, zoneID, "Should find hosted zone for "+domainName)

	// List record sets and find the A record
	recordsOutput, err := r53Client.ListResourceRecordSets(context.TODO(), &route53.ListResourceRecordSetsInput{
		HostedZoneId:    &zoneID,
		StartRecordName: &domainName,
		StartRecordType: "A",
		MaxItems:        intPtr(1),
	})
	require.NoError(t, err, "ListResourceRecordSets should succeed")
	require.NotNil(t, recordsOutput, "ListResourceRecordSets output should not be nil")
	require.Greater(t, len(recordsOutput.ResourceRecordSets), 0, "Should find at least one record set")

	record := recordsOutput.ResourceRecordSets[0]
	require.NotNil(t, record.Name, "Record name should not be nil")
	require.Equal(t, domainName+".", *record.Name, "Record name should match domain")
	require.Equal(t, "A", string(record.Type), "Record type should be A")

	// Verify alias target points to CloudFront
	require.NotNil(t, record.AliasTarget, "AliasTarget should not be nil")
	require.NotNil(t, record.AliasTarget.DNSName, "AliasTarget DNSName should not be nil")
	require.True(t, strings.Contains(*record.AliasTarget.DNSName, "cloudfront.net"),
		"AliasTarget should point to CloudFront, got: "+*record.AliasTarget.DNSName)
}

func TestWebsiteCertificate(t *testing.T) {
	t.Parallel()

	// ACM certificates for CloudFront must be in us-east-1
	cfg := getAWSConfig(t, "us-east-1")
	acmClient := acm.NewFromConfig(cfg)

	opts := newTerraformOptions(t)
	websiteURL := terraform.Output(t, opts, "website_url")
	domainName := strings.TrimPrefix(websiteURL, "https://")

	// List certificates and find the one for our domain
	certsOutput, err := acmClient.ListCertificates(context.TODO(), &acm.ListCertificatesInput{
		CertificateStatuses: []acmtypes.CertificateStatus{acmtypes.CertificateStatusIssued},
	})
	require.NoError(t, err, "ListCertificates should succeed")
	require.NotNil(t, certsOutput, "ListCertificates output should not be nil")

	var certARN string
	for _, cert := range certsOutput.CertificateSummaryList {
		if cert.DomainName == nil {
			continue
		}
		if *cert.DomainName == domainName {
			require.NotNil(t, cert.CertificateArn, "Certificate ARN should not be nil for domain: "+domainName)
			certARN = *cert.CertificateArn
			break
		}
	}
	require.NotEmpty(t, certARN, "Should find an issued certificate for "+domainName)

	// Describe the certificate for detailed validation
	descOutput, err := acmClient.DescribeCertificate(context.TODO(), &acm.DescribeCertificateInput{
		CertificateArn: &certARN,
	})
	require.NoError(t, err, "DescribeCertificate should succeed")
	require.NotNil(t, descOutput, "DescribeCertificate output should not be nil")
	require.NotNil(t, descOutput.Certificate, "Certificate should not be nil")

	cert := descOutput.Certificate
	require.Equal(t, acmtypes.CertificateStatusIssued, cert.Status, "Certificate status should be ISSUED")
	require.NotNil(t, cert.DomainName, "Certificate DomainName should not be nil")
	require.Equal(t, domainName, *cert.DomainName, "Certificate domain should match")
}

func TestWebsiteHealth(t *testing.T) {
	t.Parallel()

	opts := newTerraformOptions(t)
	websiteURL := terraform.Output(t, opts, "website_url")
	require.NotEmpty(t, websiteURL, "website_url output should not be empty")

	req, err := http.NewRequestWithContext(context.TODO(), http.MethodGet, websiteURL, nil)
	require.NoError(t, err, "Creating HTTP request should succeed")

	resp, err := http.DefaultClient.Do(req)
	require.NoError(t, err, "HTTP GET should succeed")
	defer resp.Body.Close()

	require.Equal(t, http.StatusOK, resp.StatusCode, "Website should return HTTP 200")

	body, err := io.ReadAll(resp.Body)
	require.NoError(t, err, "Reading response body should succeed")
	require.Greater(t, len(body), 0, "Response body should not be empty")
}

func intPtr(i int32) *int32 {
	return &i
}
