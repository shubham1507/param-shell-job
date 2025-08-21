# Parametrized Shell Job (Jenkins + Bash)

A minimal, parameterized mock deployment driven by Jenkins, using choice/string parameters, conditional steps, post actions, and colored console output.

## Parameters
- `ENV` (`dev|qa|prod`) — which target list to use
- `VERSION` (string) — version label to "deploy"
- `DRY_RUN` (bool) — if true, print actions only
- `CONFIRM_PROD` (bool) — must be true for prod

## Run locally
```bash
cd scripts
ENV=dev VERSION=1.2.3 ./deploy.sh --dry-run
ENV=qa VERSION=2.0.0 ./deploy.sh
CONFIRM=yes ENV=prod VERSION=3.0.0 ./deploy.sh
```

## Jenkins
Use the supplied `Jenkinsfile` with a Pipeline job. Install the **AnsiColor** plugin and enable `ansiColor('xterm')` (already included).
