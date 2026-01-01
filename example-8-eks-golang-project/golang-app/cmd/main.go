package main

import (
	"context"
	"fmt"
	responseTemplate "golang-app/template"
	"html/template"
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/iam"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

var (
	s3Client  *s3.Client
	iamClient *iam.Client
)

type S3BucketInfo struct {
	Name         string
	CreationDate string
}

type IAMUserInfo struct {
	UserName   string
	CreateDate string
	Arn        string
}

type IAMRoleInfo struct {
	RoleName   string
	CreateDate string
	Arn        string
}

type PageData struct {
	S3Buckets []S3BucketInfo
	IAMUsers  []IAMUserInfo
	IAMRoles  []IAMRoleInfo
	Error     string
}

func init() {
	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion("ap-south-1"))
	if err != nil {
		log.Fatalf("Failed to load AWS config: %v", err)
	}

	s3Client = s3.NewFromConfig(cfg)
	iamClient = iam.NewFromConfig(cfg)

	log.Println("✓ AWS clients initialized with IRSA credentials")
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status":"healthy","timestamp":"%s"}`, time.Now().Format(time.RFC3339))
}

func readyHandler(w http.ResponseWriter, r *http.Request) {
	if s3Client == nil || iamClient == nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		fmt.Fprintf(w, `{"ready":false}`)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"ready":true}`)
}

func awsDataHandler(w http.ResponseWriter, r *http.Request) {
	pageData := PageData{}
	ctx := context.Background()

	log.Println("Fetching S3 buckets...")
	s3ListOutput, err := s3Client.ListBuckets(ctx, &s3.ListBucketsInput{})
	if err != nil {
		pageData.Error = fmt.Sprintf("Failed to list S3 buckets: %v", err)
		log.Printf("❌ S3 Error: %v", err)
	} else {
		for _, bucket := range s3ListOutput.Buckets {
			pageData.S3Buckets = append(pageData.S3Buckets, S3BucketInfo{
				Name:         *bucket.Name,
				CreationDate: bucket.CreationDate.Format("2006-01-02 15:04:05"),
			})
		}
		log.Printf("✓ Found %d S3 buckets", len(pageData.S3Buckets))
	}

	log.Println("Fetching IAM users...")
	iamListUsers, err := iamClient.ListUsers(ctx, &iam.ListUsersInput{})
	if err != nil {
		pageData.Error = fmt.Sprintf("Failed to list IAM users: %v", err)
		log.Printf("❌ IAM Users Error: %v", err)
	} else {
		for _, user := range iamListUsers.Users {
			pageData.IAMUsers = append(pageData.IAMUsers, IAMUserInfo{
				UserName:   *user.UserName,
				CreateDate: user.CreateDate.Format("2006-01-02 15:04:05"),
				Arn:        *user.Arn,
			})
		}
		log.Printf("✓ Found %d IAM users", len(pageData.IAMUsers))
	}

	log.Println("Fetching IAM Roles...")
	iamListRoles, err := iamClient.ListRoles(ctx, &iam.ListRolesInput{})
	if err != nil {
		pageData.Error = fmt.Sprintf("Failed to list IAM roles: %v", err)
		log.Printf("❌ IAM Roles Error: %v", err)
	} else {
		for _, role := range iamListRoles.Roles {
			pageData.IAMRoles = append(pageData.IAMRoles, IAMRoleInfo{
				RoleName:   *role.RoleName,
				CreateDate: role.CreateDate.Format("2006-01-02 15:04:05"),
				Arn:        *role.Arn,
			})
		}
		log.Printf("✓ Found %d IAM roles", len(pageData.IAMRoles))
	}

	tmpl, err := template.New("aws-dashboard").Parse(responseTemplate.TemplateBody)
	if err != nil {
		http.Error(w, fmt.Sprintf("Template error: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	tmpl.Execute(w, pageData)
}

func main() {
	http.HandleFunc("/", awsDataHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/ready", readyHandler)

	port := ":8080"
	log.Printf("🚀 Server starting on http://0.0.0.0%s", port)
	log.Printf("   Main dashboard:  http://localhost%s/", port)
	log.Printf("   Health check:    http://localhost%s/health", port)
	log.Printf("   Ready probe:     http://localhost%s/ready", port)

	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
