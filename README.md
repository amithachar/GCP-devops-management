# GCP-devops-management


# 1. Create the New Pool
```
gcloud iam workload-identity-pools create "netflix-app-pool" \
    --location="global" \
    --display-name="Netflix Application Pool"
```
# 2. Create the OIDC Provider
### This command includes the Mapping and the Condition for your specific repository path to avoid the error you saw earlier.

```
gcloud iam workload-identity-pools providers create-oidc "gitlab-provider" \
    --location="global" \
    --workload-identity-pool="netflix-app-pool" \
    --issuer-uri="https://gitlab.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.project_path" \
    --attribute-condition="attribute.repository == 'amith99yogesh/netflix-application'"

```
# Bind the Service Account

### This grants permission for your GitLab repo to use your GCP Service Account.

###  Note: You need your Project Number. If you don't have it handy, run:
###  gcloud projects list --filter="projectId:$(gcloud config get-value project)" --format="value(projectNumber)"

```
# Replace PROJECT_NUMBER and YOUR_SA_EMAIL with your actual values
gcloud iam service-accounts add-iam-policy-binding "YOUR_SA_EMAIL" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/netflix-app-pool/attribute.repository/amith99yogesh/netflix-application"
```

### Summary of Values for GitLab
 Once these commands finish, use these values in your .gitlab-ci.yml or GitLab CI/CD Variables:

 Workload Identity Provider: projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/netflix-app-pool/providers/gitlab-provider

 Service Account: YOUR_SA_EMAIL

 Would you like me to generate the full gcloud command for the IAM binding if you give me your Project Number and Service Account email?

# 1. How to find an existing Service Account
### Run this command on your VM to list all available service accounts in your current project:
```
gcloud iam service-accounts list
```
# 2. How to create a new one (Recommended)
### If you want a dedicated account for your Netflix application, run these three commands:

```
gcloud iam service-accounts create "netflix-deployer" \
    --display-name="Netflix App Deployer"
```
# 3 B. Get the full email:

```
# This will output something like netflix-deployer@your-project.iam.gserviceaccount.com
gcloud iam service-accounts list --filter="name:netflix-deployer" --format="value(email)"
```

# C. Grant it permissions (e.g., GKE Admin):

```
# Replace PROJECT_ID with your actual project ID
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:netflix-deployer@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/container.developer"
```

# 3. Use it in the OIDC Binding
### Once you have that email (e.g., netflix-deployer@my-project.iam.gserviceaccount.com), you use it in the final binding command from the previous step:

```
gcloud iam service-accounts add-iam-policy-binding "netflix-deployer@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/netflix-app-pool/attribute.repository/amith99yogesh/netflix-application"
```


# To finish the integration, you need to add two specific variables in GitLab. These allow your pipeline to find the OIDC "bridge" you just built on GCP.

### Go to your GitLab Project > Settings > CI/CD > Variables and add the following:

### 1. The Workload Identity Provider
### This is the full path to the provider you created on your VM.

### Key: GCP_WORKLOAD_IDENTITY_PROVIDER

### Value: projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/netflix-app-pool/providers/gitlab-provider

### (Replace PROJECT_NUMBER with your actual 12-digit GCP project number).

### 2. The Service Account Email
### This is the email of the Service Account that the pipeline will "become" once authenticated.

### Key: GCP_SERVICE_ACCOUNT

### Value: netflix-deployer@project-3a9d1629-f247-457c-ae4.iam.gserviceaccount.com

### (I used your GKE project ID from your history; double-check if this matches your current service account).



