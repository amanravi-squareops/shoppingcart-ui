pipeline {
    agent any
    environment {
        // Define timestamp variable at the top-level environment block
        TIMESTAMP = sh(script: "date +'%b-%d-t-%H-%M'", returnStdout: true).trim()
    }
        
    stages {
        stage('kaniko build & push') {
            agent {
                kubernetes {
                    yaml """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                        name: kaniko
                    spec:
                        restartPolicy: Never
                        volumes:
                        - name: kaniko-secret
                          secret:
                            secretName: kaniko-secret
                        containers:
                        - name: kaniko
                          image: gcr.io/kaniko-project/executor:debug
                          command:
                            - /busybox/cat
                          tty: true
                          volumeMounts:
                          - name: kaniko-secret
                            mountPath: /kaniko/.docker
                    """
                }
            }
            steps {
                container('kaniko') {
                    script {
                        // Use TIMESTAMP variable instead of defining a new one
                        sh """
                        git clone -b main https://github.com/amanravi-squareops/shoppingcart-ui
                        /kaniko/executor --dockerfile /Dockerfile \
                        --context=\$(pwd)/shoppingcart-ui \
                        --destination=amanravi12/shoppingcart-ui:build-${BUILD_NUMBER}-${TIMESTAMP}
                        """
                    }
                }
            }
        }
        
        stage('Update values.yaml') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-cre', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        git branch: 'main', 
                            url: "https://${USERNAME}:${PASSWORD}@github.com/amanravi-squareops/springboot-helm.git"
                    }
                    sh '''
                    cd shopping-cart
                    sed -i "s/tag: .*/tag: build-${BUILD_NUMBER}-${TIMESTAMP}/" values.yaml
                    cat values.yaml
                    git config --global user.email "aman.ravi@squareops.com"
                    git config --global user.name "amanravi-squareops"
                    git add values.yaml
                    git commit -m "Update imageTag in values.yaml"
                    git push origin main
                    '''
                }
            }
        }
    }
}
