#!/usr/bin/env bash
# Common helpers for colored logging and notifications

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ts() { date +"%Y-%m-%d %H:%M:%S"; }

log_info()   { echo -e "$(ts) ${BLUE}[INFO]${NC}  $*"; }
log_warn()   { echo -e "$(ts) ${YELLOW}[WARN]${NC}  $*"; }
log_success(){ echo -e "$(ts) ${GREEN}[OK]${NC}    $*"; }
log_error()  { echo -e "$(ts) ${RED}[ERROR]${NC} $*"; }

# mock notifier (extend to curl your webhook/email etc.)
notify() {
  local status="$1"; shift
  local msg="$*"
  echo -e "$(ts) ${BOLD}NOTIFY:${NC} [$status] $msg"
}
