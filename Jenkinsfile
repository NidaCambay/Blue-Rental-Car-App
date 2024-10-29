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
                    chmod 400 ${WORKSPACE}/${WORKSPACE}-key.pem
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
        
        stage('Deploy the App') {
            steps {
                echo 'Deploy the App'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory -i inventory_aws_ec2.yml --graph'
                sh """
                    ansible-playbook -i ./inventory_aws_ec2.yml ./${WORKSPACE}-playbook.yml
                """
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
