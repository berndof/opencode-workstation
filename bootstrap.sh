#!/usr/bin/env bash
#
# bootstrap.sh — idempotent provisioner for the OpenCode workstation station.
#
# Wires this repository into a HOME directory: agent/memory/command symlinks into
# ~/.config/opencode, the global AGENTS.md session rule, the workstation CLI helpers,
# the desktop launcher, a starter opencode.json, and (when available) the agent-sandbox
# systemd user unit. Re-running is safe.
#
# Usage:
#   ./bootstrap.sh [--help] [--dry-run] [--home <dir>]
#
# Options:
#   --home <dir>   Target HOME directory (default: $HOME). Useful to test safely.
#   --dry-run      Print every action without touching the filesystem.
#   --help         Show this help and exit.
#
# Environment:
#   SBX_REPO       Path to the agent-sandbox checkout that owns the sbx-tunnel unit
#                  (default: $HOME/Workspace/agent-sandbox).
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_HOME="${HOME}"
DRY_RUN=false

usage() {
    sed -n '2,22p' "$0" | sed 's/^#\{1,\} \{0,1\}//'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --home)
            [[ $# -ge 2 ]] || { echo "bootstrap: --home requires a directory" >&2; exit 2; }
            DEST_HOME="$2"
            shift 2
            ;;
        --home=*)
            DEST_HOME="${1#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "bootstrap: unknown option: $1 (try --help)" >&2
            exit 2
            ;;
    esac
done

DEST_HOME="${DEST_HOME/#\~/$HOME}"
OPENCODE_DIR="${DEST_HOME}/.config/opencode"
BIN_DIR="${DEST_HOME}/.local/bin"
APPS_DIR="${DEST_HOME}/.local/share/applications"
SYSTEMD_DIR="${DEST_HOME}/.config/systemd/user"
SBX_REPO="${SBX_REPO:-${DEST_HOME}/Workspace/agent-sandbox}"

ok()   { printf '[ok]   %s\n' "$*"; }
skip() { printf '[skip] %s\n' "$*"; }
warn() { printf '[warn] %s\n' "$*"; }
# did <msg> — for actions performed through run(): honest under --dry-run
did() {
    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry]  would %s\n' "$*"
    else
        printf '[ok]   %s\n' "$*"
    fi
}

# run <cmd...> — execute, or just report under --dry-run
run() {
    if [[ "$DRY_RUN" == true ]]; then
        printf '       $ %s\n' "$*"
        return 0
    fi
    "$@"
}

# link_file <src> <dest> — symlink, replacing an existing symlink, never clobbering a real file
link_file() {
    local src="$1" dest="$2"
    if [[ -L "$dest" ]]; then
        if [[ "$(readlink "$dest")" == "$src" ]]; then
            skip "link already correct: $dest"
            return 0
        fi
        run ln -sfn "$src" "$dest"
        did "relink $dest -> $src"
    elif [[ -e "$dest" ]]; then
        warn "regular file present, NOT overwritten: $dest (move it aside and re-run)"
    else
        run ln -sfn "$src" "$dest"
        did "link $dest -> $src"
    fi
}

# copy_file <src> <dest> <mode> — install a real file, keeping an existing one intact
copy_file() {
    local src="$1" dest="$2" mode="${3:-}"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        if cmp -s "$src" "$dest"; then
            skip "already up to date: $dest"
            return 0
        fi
        warn "regular file present, NOT overwritten: $dest (move it aside and re-run)"
        return 0
    fi
    run mkdir -p "$(dirname "$dest")"
    run install -m "${mode:-644}" "$src" "$dest"
    did "install $dest"
}

echo "==> OpenCode workstation bootstrap"
echo "    repo:        ${REPO_DIR}"
echo "    target HOME: ${DEST_HOME}"
echo "    dry-run:     ${DRY_RUN}"
echo

echo "1. Dependencies"
missing=false
for dep in bash ln curl; do
    if command -v "$dep" >/dev/null 2>&1; then
        ok "found $dep ($(command -v "$dep"))"
    else
        warn "missing required dependency: $dep"
        missing=true
    fi
done
if [[ "$missing" == true ]]; then
    warn "install the missing tools above and re-run; aborting"
    exit 1
fi
echo

echo "2. Config directories and repo symlinks"
run mkdir -p "${OPENCODE_DIR}/agents" "${OPENCODE_DIR}/memory" "${OPENCODE_DIR}/commands"
for sub in agents memory commands; do
    shopt -s nullglob
    for src in "${REPO_DIR}/${sub}/"*.md; do
        link_file "$src" "${OPENCODE_DIR}/${sub}/$(basename "$src")"
    done
    shopt -u nullglob
done
echo

echo "3. Global AGENTS.md session rule"
copy_file "${REPO_DIR}/workstation/AGENTS.md" "${OPENCODE_DIR}/AGENTS.md" 644
echo

echo "4. Workstation CLI helpers and desktop launcher"
shopt -s nullglob
for src in "${REPO_DIR}/workstation/bin/"*; do
    copy_file "$src" "${BIN_DIR}/$(basename "$src")" 700
done
for src in "${REPO_DIR}/workstation/desktop/"*.desktop; do
    copy_file "$src" "${APPS_DIR}/$(basename "$src")" 644
done
shopt -u nullglob
echo

echo "5. opencode.json"
if [[ -e "${OPENCODE_DIR}/opencode.json" ]]; then
    skip "mantido: ${OPENCODE_DIR}/opencode.json (bootstrap never overwrites it)"
else
    copy_file "${REPO_DIR}/templates/opencode.json.example" "${OPENCODE_DIR}/opencode.json" 600
    warn "secrets NOT created — fill in ${OPENCODE_DIR}/.secrets.env (chmod 600),"
    warn "sourced from ~/.bashrc / ~/.zshrc / ~/.profile. See workstation/.secrets.env.example."
fi
echo

echo "6. agent-sandbox systemd user unit"
UNIT_SRC="${SBX_REPO}/local/systemd/sbx-tunnel@.service"
if [[ -f "$UNIT_SRC" ]]; then
    copy_file "$UNIT_SRC" "${SYSTEMD_DIR}/sbx-tunnel@.service" 644
    if command -v systemctl >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == true ]]; then
            printf '       $ systemctl --user daemon-reload\n'
        elif systemctl --user daemon-reload; then
            ok "systemctl --user daemon-reload"
        else
            warn "daemon-reload failed (no user manager?); unit file is installed"
        fi
    else
        warn "systemctl not available; unit installed but not reloaded"
    fi
else
    warn "agent-sandbox unit not found at ${UNIT_SRC} — skipping (set SBX_REPO if it lives elsewhere)"
fi
echo

echo "7. sbx dev daemon health"
if [[ "$DRY_RUN" == true ]]; then
    skip "dry-run: would probe http://127.0.0.1:47110/v1/health"
elif curl -fsS --max-time 3 http://127.0.0.1:47110/v1/health >/dev/null 2>&1; then
    ok "sbx dev: ok"
else
    warn "sbx dev: indisponível (start it later; this never fails the bootstrap)"
fi
echo

echo "==> Done."
