# Serverless Event-Driven AWS Pipeline (S3 + Lambda + DynamoDB) via Terraform

## Project Overview
This project demonstrates a production-grade, serverless event-driven architecture built entirely using **Terraform (Infrastructure as Code)**. 

When a user uploads a file to an **Amazon S3** bucket, an automated event trigger instantly executes an **AWS Lambda** function written in Python. The function parses the upload metadata and securely writes a log entry into an **Amazon DynamoDB** table.

---

## Architecture Flow
1. **Storage Layer:** User uploads an object to s3-awsproject-1.
2. **Event Trigger:** S3 fires an ObjectCreated event notification.
3. **Compute Layer:** The event invokes an **AWS Lambda** function (S3EventProcessor).
4. **Security & IAM:** The Lambda function operates under a least-privilege IAM execution role attached with basic CloudWatch logging and DynamoDB write permissions.
5. **Database Layer:** Metadata (FileId, BucketName, FileName, FileSize) is permanently recorded in **Amazon DynamoDB** (S3MetadataTable).

---

## Tech Stack Used
* **Cloud Provider:** Amazon Web Services (AWS)
* **Infrastructure as Code:** Terraform
* **Compute:** AWS Lambda (Python 3.11)
* **Storage:** Amazon S3
* **Database:** Amazon DynamoDB
* **Identity & Access Management:** AWS IAM

Challenges Encoutered and TroubleShooting.

1. The Terraform "No Changes" False-Positive
The Error: Initially, when running terraform plan and terraform apply, Terraform outputted: No changes. Your infrastructure matches the configuration.

Root Cause: The configuration files were populated in the code editor, but not saved to disk (Ctrl + S). Terraform reads files directly from the disk, so it saw empty configurations.

The Fix: Verified that all editor tabs were saved, ensuring Terraform could properly evaluate the HCL code.

2. GitHub Push Rejection Due to Large Binaries & State Files
The Error: During the initial git push, GitHub rejected the repository with:error: File .terraform/providers/.../terraform-provider-aws...exe is 685.52 MB; this exceeds GitHub's file size limit of 100.00 MB.

Root Cause: Accidentally tracked local provider binaries (.terraform/), local compilation artifacts (lambda_function.zip), and sensitive local state files (terraform.tfstate) in version control.

The Fix:

Created a strict .gitignore file blocking local provider directories, zips, and .tfstate files.

Cleared the staging cache and purged the heavy files out of Git history using reference updates.

Performed a clean commit and force-pushed only the lightweight infrastructure source code.
---

## Repository Structure
```text
s3-lambda-pipeline/
│
├── main.tf              # Core infrastructure (DynamoDB, IAM, Lambda, S3 Trigger)
├── provider.tf          # AWS Provider & Terraform configuration
├── lambda_function.py   # Python backend logic for processing S3 events
└── .gitignore           # Excludes local state files, binaries, and zips

##Repository Close
git clone [https://github.com/Knowledge25625/aws-s3-lambda-terraform-pipeline.git](https://github.com/Knowledge25625/aws-s3-lambda-terraform-pipeline.git)
