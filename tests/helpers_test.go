package test

import (
	"context"
	"os"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func getAWSConfig(t *testing.T, region string) aws.Config {
	t.Helper()
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(region))
	if err != nil {
		t.Fatalf("Unable to load AWS config: %v", err)
	}
	return cfg
}

func getRegion(t *testing.T) string {
	t.Helper()
	region := os.Getenv("AWS_REGION")
	if region == "" {
		region = "us-east-1"
	}
	return region
}

func getTerraformWorkingDir(t *testing.T) string {
	t.Helper()
	dir := os.Getenv("TF_WORKING_DIR")
	if dir == "" {
		dir = "../terraform/website"
	}
	return dir
}

func newTerraformOptions(t *testing.T) *terraform.Options {
	t.Helper()
	return &terraform.Options{
		TerraformDir: getTerraformWorkingDir(t),
		NoColor:      true,
	}
}
