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
                    aws ec2 create-key-pair --key-name ${params.WORKSPACE}-key --query 'KeyMaterial' --output text --region us-east-1 > ${WORKSPACE}-key.pem
                    chmod 400 /var/lib/jenkins/workspace/BRC-Pipeline/${params.WORKSPACE}-key.pem
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
        
        stage('Delete AWS Key Pair') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                script {
                    sh """
                    aws ec2 delete-key-pair --key-name ${params.WORKSPACE}-key --region us-east-1
                    rm -f /var/lib/jenkins/workspace/BRC-Pipeline/${params.WORKSPACE}-key.pem
                    """
                }
            }
        }

        stage('Deploy the App') {
            when {
                expression { return !params.DESTROY }
            }
            steps {
                echo 'Deploy the App'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory -i inventory_aws_ec2.yml --graph'
                sh """
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    export ANSIBLE_PRIVATE_KEY_FILE="/var/lib/jenkins/workspace/BRC-Pipeline/${params.WORKSPACE}-key.pem"
                    ansible-playbook -i inventory_aws_ec2.yml ${params.WORKSPACE}-playbook.yml
                """
             }
        }
    }
}
