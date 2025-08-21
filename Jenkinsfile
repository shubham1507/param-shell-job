pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    choice(name: 'ENV', choices: ['dev', 'qa', 'prod'], description: 'Target environment')
    string(name: 'VERSION', defaultValue: '1.0.0', description: 'Artifact/app version')
    booleanParam(name: 'DRY_RUN', defaultValue: true, description: 'Print actions only')
    booleanParam(name: 'CONFIRM_PROD', defaultValue: false, description: 'Confirm production deploy')
  }

  environment {
    // exported for the bash script
    ENVIRONMENT = "${params.ENV}"
    VERSION     = "${params.VERSION}"
    DRY_RUN     = "${params.DRY_RUN}"
    CONFIRM     = "${params.CONFIRM_PROD ? 'yes' : 'no'}"
  }

  stages {
    stage('Prep') {
      steps {
        sh 'chmod +x scripts/*.sh || true'
        echo "ENV=${ENVIRONMENT}, VERSION=${VERSION}, DRY_RUN=${DRY_RUN}, CONFIRM=${CONFIRM}"
      }
    }

    stage('Validate Params') {
      steps {
        script {
          if (params.ENV == 'prod' && !params.CONFIRM_PROD) {
            error "Production requires CONFIRM_PROD=true"
          }
        }
      }
    }

    stage('Deploy (Mock)') {
      steps {
        // No Groovy interpolation inside the shell block; script reads env vars.
        sh '''#!/usr/bin/env bash
set -e
./scripts/deploy.sh
'''
      }
    }
  }

  post {
    always {
      echo "Build finished with status: ${currentBuild.currentResult}"
    }
    success {
      echo '✅ Deployment OK'
      // add emailext/slackSend here if desired
    }
    failure {
      echo '❌ Deployment failed'
      // add emailext/slackSend here if desired
    }
  }
}
