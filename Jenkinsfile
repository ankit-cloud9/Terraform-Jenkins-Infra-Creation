pipeline {

    parameters {
        choice(
            name: 'action',
            choices: ['apply', 'destroy'],
            description: 'Choose Terraform action'
        )
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Skip manual approval?'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION            = 'ap-south-1'
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    agent any

    stages {

        stage('Checkout') {
            steps {
                dir("terraform") {
                    git branch: 'main', url: 'https://github.com/ankit-cloud9/Terraform-Jenkins-Infra-Creation.git'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'cd terraform && terraform init'
            }
        }

        stage('Plan') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                sh 'cd terraform && terraform plan -out=tfplan'
                sh 'cd terraform && terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            when {
                allOf {
                    expression { params.action == 'apply' }
                    expression { !params.autoApprove }
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Apply this Terraform plan?",
                          parameters: [text(name: 'Plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                sh 'cd terraform && terraform apply -input=false tfplan'
            }
        }

        stage('Destroy Approval') {
            when {
                allOf {
                    expression { params.action == 'destroy' }
                    expression { !params.autoApprove }
                }
            }
            steps {
                input message: "Are you sure you want to DESTROY all resources?"
            }
        }

        stage('Destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                sh 'cd terraform && terraform destroy -auto-approve'
            }
        }
    }
}
