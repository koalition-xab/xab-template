#!/bin/bash
set -e
########## XAB-TEMPLATE: INSTALL SCRIPT FOR LINUX SYSTEMS ##########

########## COLORS & OUTPUT ##########
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; DIM=''; NC=''
fi

info()    { echo -e "${CYAN}  $*${NC}"; }
success() { echo -e "${GREEN}  ✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}  ⚠ $*${NC}"; }
error()   { echo -e "${RED}  ✗ $*${NC}" >&2; }

trap 'stop_spinner 2>/dev/null; echo -e "\n${RED}#################### Install failed :( ####################${NC}"' ERR

########## SPINNER ##########
_spinner_pid=""

start_spinner() {
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local message="$1"
    local i=0
    while true; do
        printf "\r  ${CYAN}%s${NC} %s" "${frames[$i]}" "$message"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done &
    _spinner_pid=$!
}

stop_spinner() {
    if [ -n "$_spinner_pid" ]; then
        kill "$_spinner_pid" 2>/dev/null || true
        wait "$_spinner_pid" 2>/dev/null || true
        printf "\r\033[K"
        _spinner_pid=""
    fi
}

run_with_spinner() {
    local message="$1"; shift
    local tmpfile; tmpfile=$(mktemp)
    start_spinner "$message"
    local exit_code=0
    "$@" >"$tmpfile" 2>&1 || exit_code=$?
    stop_spinner
    if [ "$exit_code" -ne 0 ]; then
        error "$message"
        cat "$tmpfile" >&2
        rm -f "$tmpfile"
        return "$exit_code"
    fi
    success "$message"
    rm -f "$tmpfile"
}

########## VARIABLES ##########
LINK="https://github.com/koalition-xab/xab-template.git"
DESTINATION="$HOME/.local/share/typst/packages/local/xab-template/"
VERSION="1.0.0"
UNINSTALL=false
FORCE=false
YES=false
CHECK=false
REQUIRED_FONTS=("Open Sans" "Montserrat" "STIX Two Math")

########## HELPERS ##########
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -c, --check       Check for updates without installing"
    echo "  -u, --uninstall   Remove the installed template"
    echo "  -f, --force       Remove existing installation and reinstall from scratch"
    echo "  -y, --yes         Non-interactive: answer yes to all prompts"
    echo "  -p, --path DIR    Custom install path (default: $DESTINATION)"
}

confirm() {
    local prompt="$1" default="$2"
    if [ "$YES" = true ]; then return 0; fi
    if [ "$default" = "y" ]; then
        read -rp "  $prompt [Y/n] " response; response="${response:-y}"
    else
        read -rp "  $prompt [y/N] " response; response="${response:-n}"
    fi
    [[ "$response" =~ ^[Yy]$ ]]
}

print_submodule_issues() {
    while IFS= read -r line; do
        local prefix="${line:0:1}"
        local sha="${line:1:40}"
        local path="${line:42}"; path="${path%% *}"
        case "$prefix" in
            -) echo -e "    ${DIM}${path}: not initialised — files are missing${NC}" ;;
            +) local expected
               expected=$(git -C "$TARGET" rev-parse "HEAD:${path}" 2>/dev/null | cut -c1-7 || echo "unknown")
               echo -e "    ${DIM}${path}: wrong commit — got ${sha:0:7}, template expects ${expected}${NC}" ;;
            U) echo -e "    ${DIM}${path}: has unresolved merge conflicts${NC}" ;;
        esac
    done <<< "$1"
}

check_fonts() {
    if ! command -v fc-list &>/dev/null; then
        warn "Cannot check fonts: fc-list not available (install fontconfig)"
        return
    fi
    local families; families=$(fc-list : family 2>/dev/null)
    local missing=()
    for font in "${REQUIRED_FONTS[@]}"; do
        if ! echo "$families" | grep -qi "$font"; then
            missing+=("$font")
        fi
    done
    if [ ${#missing[@]} -eq 0 ]; then
        success "All required fonts are installed"
    else
        warn "Missing required fonts:"
        for font in "${missing[@]}"; do
            echo -e "    ${DIM}• ${font}${NC}"
        done
    fi
}

print_summary() {
    local version
    version=$(git -C "$TARGET" describe --tags --always 2>/dev/null || git -C "$TARGET" rev-parse --short HEAD)
    echo ""
    echo -e "${BOLD}  ──────────────────────────────────────────${NC}"
    echo -e "  Installed to:  ${CYAN}${TARGET}${NC}"
    echo -e "  Version:       ${CYAN}${version}${NC}"
    echo ""
    echo -e "  Add to your typst document:"
    echo -e "  ${DIM}#import \"@local/xab-template:${VERSION}\": *${NC}"
    echo -e "${BOLD}  ──────────────────────────────────────────${NC}"
    echo ""
}

########## ARGUMENT PARSING ##########
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)      usage; exit 0 ;;
        -c|--check)     CHECK=true ;;
        -u|--uninstall) UNINSTALL=true ;;
        -f|--force)     FORCE=true ;;
        -y|--yes)       YES=true ;;
        -p|--path)      DESTINATION="$2/"; shift ;;
        *) error "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

TARGET="${DESTINATION}${VERSION}"

########## SCRIPT ##########
echo ""
echo -e "${BOLD}#################### XAB TEMPLATE INSTALLER ####################${NC}"
echo ""

command -v git &>/dev/null || { error "git is required but not installed."; exit 1; }

if [ "$CHECK" = true ]; then
    if [ ! -d "$TARGET/.git" ]; then
        warn "Not installed — run without --check to install"
        echo ""
        exit 0
    fi
    info "Fetching remote version info..."
    local_sha=$(git -C "$TARGET" rev-parse HEAD)
    remote_sha=$(git ls-remote "$LINK" HEAD | cut -f1)
    [ -z "$remote_sha" ] && { error "Failed to reach remote."; exit 1; }
    submodule_issues=$(git -C "$TARGET" submodule status --recursive | grep -E '^[-+U]' || true)
    echo ""
    echo -e "  Installed: ${BOLD}${local_sha:0:7}${NC}"
    echo -e "  Latest:    ${BOLD}${remote_sha:0:7}${NC}"
    echo ""
    if [ "$remote_sha" != "$local_sha" ]; then
        warn "Update available — run without --check to update"
    fi
    if [ -n "$submodule_issues" ]; then
        warn "Submodule issues detected:"
        print_submodule_issues "$submodule_issues"
    fi
    if [ "$remote_sha" = "$local_sha" ] && [ -z "$submodule_issues" ]; then
        success "Installation complete — everything is up to date"
    fi
    check_fonts
    echo ""
    exit 0
fi

if [ "$UNINSTALL" = true ]; then
    if [ ! -d "$TARGET" ]; then
        warn "No installation found at $TARGET"
        exit 0
    fi
    if confirm "Remove installation at $TARGET?" "n"; then
        rm -rf "$TARGET"
        success "Uninstalled successfully"
    else
        info "Aborted."
    fi
    exit 0
fi

mkdir -p "$DESTINATION"

if [ "$FORCE" = true ] && [ -d "$TARGET" ]; then
    if confirm "Remove existing installation at $TARGET and reinstall?" "n"; then
        rm -rf "$TARGET"
    else
        info "Aborted."
        exit 0
    fi
fi

if [ -d "$TARGET/.git" ]; then
    local_changes=$(git -C "$TARGET" status --porcelain | grep -v '^??' || true)
    submodule_issues=$(git -C "$TARGET" submodule status --recursive | grep -E '^[-+U]' || true)
    local_sha=$(git -C "$TARGET" rev-parse HEAD)
    remote_sha=$(git ls-remote "$LINK" HEAD | cut -f1)
    [ -z "$remote_sha" ] && { error "Failed to reach remote."; exit 1; }
    needs_pull=false
    [ "$local_sha" != "$remote_sha" ] && needs_pull=true

    if [ -z "$local_changes" ] && [ -z "$submodule_issues" ] && [ "$needs_pull" = false ]; then
        success "Already up to date — installation complete (${local_sha:0:7})"
        check_fonts
        echo ""
        exit 0
    fi

    echo ""
    warn "The following issues were found:"
    if [ "$needs_pull" = true ]; then
        echo -e "  ${YELLOW}⚠${NC} Update available: ${BOLD}${local_sha:0:7}${NC} → ${BOLD}${remote_sha:0:7}${NC}"
    fi
    if [ -n "$submodule_issues" ]; then
        echo -e "  ${YELLOW}⚠${NC} Submodule issues:"
        print_submodule_issues "$submodule_issues"
    fi
    if [ -n "$local_changes" ]; then
        echo -e "  ${YELLOW}⚠${NC} Uncommitted local changes:"
        while IFS= read -r line; do
            echo -e "    ${DIM}${line}${NC}"
        done <<< "$local_changes"
    fi
    echo ""
    if ! confirm "Proceed and apply fixes?" "y"; then
        info "Aborted."
        exit 0
    fi

    if [ -n "$local_changes" ]; then
        run_with_spinner "Resetting local changes"   git -C "$TARGET" reset --hard HEAD
    fi
    if [ "$needs_pull" = true ]; then
        run_with_spinner "Pulling latest changes"    git -C "$TARGET" pull --ff-only
    fi
    run_with_spinner "Syncing submodule URLs"        git -C "$TARGET" submodule sync --recursive
    run_with_spinner "Updating submodules"           git -C "$TARGET" submodule update --init --recursive

    new_sha=$(git -C "$TARGET" rev-parse HEAD)
    if [ "$local_sha" != "$new_sha" ]; then
        echo ""
        info "What changed:"
        git -C "$TARGET" log --oneline "${local_sha}..${new_sha}" | while IFS= read -r line; do
            echo -e "  ${DIM}• ${line}${NC}"
        done
    fi
elif [ -d "$TARGET" ]; then
    error "Target path exists but is not a git repository: $TARGET"
    error "Please remove it manually or use --force to reinstall."
    exit 1
else
    echo ""
    info "Template will be installed to $TARGET"
    echo ""
    if ! confirm "Proceed with installation?" "y"; then
        info "Aborted."
        exit 0
    fi
    run_with_spinner "Cloning repository"      git clone "$LINK" "$TARGET"
    run_with_spinner "Initialising submodules" git -C "$TARGET" submodule update --init --recursive
fi

########## FINISH ##########
print_summary
check_fonts
echo -e "${GREEN}#################### All done :) ####################${NC}"
echo ""
