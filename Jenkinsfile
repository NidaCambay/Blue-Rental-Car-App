pipeline {
    agent any
    parameters {
        choice(name: 'WORKSPACE', choices: ['dev', 'staging', 'prod', 'test'], description: 'Terraform workspace seçiniz')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Kaynakları silmek istiyor musunuz?')
    }
    stages {
        stage('Set Workspace') {
            steps {
                script {
                    sh "terraform workspace select ${params.WORKSPACE} || terraform workspace new ${params.WORKSPACE}"
                }
            }
        }
        stage('Generate AWS Key Pair') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    sh """
                    aws ec2 create-key-pair --key-name ${params.WORKSPACE}-key --query 'KeyMaterial' --output text --region us-east-1 > ${params.WORKSPACE}-key.pem
                    chmod 400 ${params.WORKSPACE}-key.pem
                    """
                }
            }
        }
        stage('Terraform Apply') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                script {
                    sh 'terraform init'
                    sh "terraform apply --auto-approve"
                }
            }
        }
        stage('Terraform Destroy') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                script {
                    sh 'terraform init'
                    sh "terraform destroy --auto-approve"
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: '*.pem', fingerprint: true
            // Eğer ihtiyacınız yoksa pem dosyalarını silmek için uncomment edin
            // sh 'rm -f *.pem'
        }
    }
}
