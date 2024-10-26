pipeline {
    agent any
    parameters {
        choice(name: 'WORKSPACE', choices: ['dev', 'staging', 'prod', 'test'], description: 'Terraform workspace seçiniz')
    }
    stages {
        stage('Set Workspace') {
            steps {
                script {
                    // Terraform workspace'i set et
                    sh "terraform workspace select ${params.WORKSPACE} || terraform workspace new ${params.WORKSPACE}"
                }
            }
        }
        stage('Generate AWS Key Pair') {
            steps {
                script {
                    // AWS CLI ile özel workspace adına göre key pair oluştur
                    sh """
                    aws ec2 create-key-pair --key-name ${params.WORKSPACE}-key --query 'KeyMaterial' --output text --region us-east-1 > ${params.WORKSPACE}-key.pem
                    chmod 400 ${params.WORKSPACE}-key.pem
                    """
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    // Terraform init ve apply işlemlerini çalıştır
                    sh 'terraform init'
                    sh "terraform apply --auto-approve"
                }
            }
        }
    }
    post {
        always {
            // Son olarak key dosyalarını arşivle veya ihtiyaç yoksa sil
            archiveArtifacts artifacts: '*.pem', fingerprint: true
            // Eğer ihtiyacınız yoksa pem dosyalarını silmek için uncomment edin
            // sh 'rm -f *.pem'
        }
    }
}
