#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib.sh"

ENVIRONMENT="${ENVIRONMENT:-${ENV:-dev}}"
VERSION="${VERSION:-1.0.0}"
DRY_RUN="${DRY_RUN:-false}"

usage() {
  cat <<EOF
Usage:
  ENV=dev VERSION=1.2.3 ./deploy.sh [--dry-run]

Env vars (preferred in Jenkins as parameters):
  ENV / ENVIRONMENT   Target environment: dev | qa | prod (default: dev)
  VERSION            Artifact/app version string (e.g., 1.2.3)
  DRY_RUN            If 'true', do not mutate; just print actions

Options:
  --dry-run          Same as DRY_RUN=true
EOF
}

# Parse flags
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) log_warn "Unknown argument: $arg" ;;
  esac
done

TARGETS_FILE="$(cd "${SCRIPT_DIR}/../targets" && pwd)/${ENVIRONMENT}.txt"
if [[ ! -f "$TARGETS_FILE" ]]; then
  log_error "Targets file not found for environment: ${ENVIRONMENT} ($TARGETS_FILE)"
  exit 2
fi

log_info "Starting deployment"
log_info "Environment : ${BOLD}${ENVIRONMENT}${NC}"
log_info "Version     : ${BOLD}${VERSION}${NC}"
log_info "Dry run     : ${BOLD}${DRY_RUN}${NC}"
log_info "Targets file: ${TARGETS_FILE}"

# Conditional: require a simple confirmation for prod unless CONFIRM=yes
if [[ "$ENVIRONMENT" == "prod" ]]; then
  if [[ "${CONFIRM:-no}" != "yes" ]]; then
    log_warn "Production deployment requires CONFIRM=yes"
    notify "blocked" "Prod deploy blocked — missing CONFIRM=yes"
    exit 3
  fi
fi

# Mock artifact fetch
fetch_artifact() {
  local ver="$1"
  log_info "Fetching artifact version ${ver} (mock)"
  $DRY_RUN && return 0
  sleep 1
  log_success "Artifact ${ver} available"
}

# Mock deploy to a target host
deploy_to_host() {
  local host="$1"
  log_info "Deploying version ${VERSION} to ${host}"
  if $DRY_RUN; then
    log_info "[dry-run] Would copy files and restart service on ${host}"
    return 0
  fi
  # Pretend to run remote commands
  sleep 1
  # Simulate a conditional failure for demo if host contains 'bad'
  if [[ "$host" == *"bad"* ]]; then
    log_error "Deployment failed on ${host} (simulated)"
    return 1
  fi
  log_success "Deployment complete on ${host}"
}

# Begin workflow
notify "starting" "Deploy $VERSION to $ENVIRONMENT"

fetch_artifact "$VERSION"

overall_rc=0
while IFS= read -r host; do
  [[ -z "$host" || "$host" =~ ^# ]] && continue
  if ! deploy_to_host "$host"; then
    overall_rc=1
    log_warn "Continuing to next host despite failure on ${host}"
  fi
done < "$TARGETS_FILE"

if [[ $overall_rc -eq 0 ]]; then
  log_success "All hosts deployed successfully"
  notify "success" "Deploy $VERSION to $ENVIRONMENT succeeded"
else
  log_error "One or more hosts failed"
  notify "failure" "Deploy $VERSION to $ENVIRONMENT had failures"
fi

exit $overall_rc
