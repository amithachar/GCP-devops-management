pipeline {
    parameters {
        choice(
            name: 'terraformAction',
            choices: ['apply', 'destroy'],
            description: 'Choose your terraform action'
        )
    }

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('GCP_SA_KEY')   // Service Account JSON
        SNYK_TOKEN = credentials('SNYK_TOKEN')
        PROJECT_ID = "durable-catbird-450018-j4"
    }

    agent any

    stages {

        stage('Checkout') {
            steps {
                script {
                        git url: 'https://github.com/amithachar/GCP-devops-management.git', branch: 'iac'
                }
            }
        }

        stage('Auth to GCP') {
            steps {
                sh '''
                echo "Authenticating to GCP..."
                gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                gcloud config set project $PROJECT_ID
                '''
            }
        }

        stage('Snyk Security Scan') {
            steps {
                sh 'pwd; ./iac-code-scan.sh'
            }
        }

        stage('Plan') {
            steps {
                sh 'pwd;  terraform init'
                sh 'pwd;  terraform plan -out tfplan'
                sh 'pwd;  terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to proceed with the Terraform action?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply or Destroy') {
            when {
                expression {
                    return params.terraformAction == 'apply' || params.terraformAction == 'destroy'
                }
            }
            steps {
                script {
                    if (params.terraformAction == 'apply') {
                        sh 'pwd; terraform apply -input=false tfplan'
                    } else if (params.terraformAction == 'destroy') {
                        sh 'pwd; terraform destroy -auto-approve'
                    }
                }
            }
        }

        stage('Backup-State-To-GCS') {
            steps {
                sh '''
                pwd
                gsutil cp terraform.tfstate gs://private-terraform-statefile-backup/gke/
                '''
            }
        }
    }
}
