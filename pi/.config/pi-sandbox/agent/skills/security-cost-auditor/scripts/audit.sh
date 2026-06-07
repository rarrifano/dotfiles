#!/usr/bin/env bash
# security-cost-auditor/scripts/audit.sh
# Performs rapid, lightweight security & cost-efficiency scans on a repository.

set -euo pipefail

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}🛡️  Security & 💰 Cost-Efficiency Audit Script${NC}"
echo -e "${BLUE}==================================================${NC}"

# Target directory defaults to current directory
TARGET_DIR="${1:-.}"
cd "${TARGET_DIR}"

IS_GIT=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IS_GIT=1
fi

echo -e "\n${BLUE}🔎 [1/4] Running Security Scanning (Unignored Risky Files)...${NC}"
# 1. Risky unignored files
risky_patterns=(
    "*.pem" "*.key" "id_rsa" "id_ecdsa" "id_ed25519" "id_dsa"
    ".env" ".env.local" ".env.production" "auth.json"
    "credentials" "service-account.json" "service_account.json"
    "*.p12" "*.pfx" "secrets.yaml"
)

found_risky=0
for pattern in "${risky_patterns[@]}"; do
    # Find files matching pattern, checking if git ignores them (if inside git repo)
    if [ "${IS_GIT}" -eq 1 ]; then
        # git ls-files to see if they are tracked or unignored untracked files
        # We can also check untracked but not ignored: git ls-files --others --exclude-standard
        find_res=$(git ls-files --others --exclude-standard -g "${pattern}" 2>/dev/null || true)
        tracked_res=$(git ls-files -g "${pattern}" 2>/dev/null || true)
        all_res=$(echo -e "${find_res}\n${tracked_res}" | grep -v '^$' | sort -u || true)
    else
        all_res=$(find . -name "${pattern}" -not -path "*/.*" -not -path "*/node_modules/*" 2>/dev/null || true)
    fi

    if [ -n "${all_res}" ]; then
        while IFS= read -r file; do
            if [ -n "${file}" ]; then
                echo -e "${RED}[RISK] Expose Risk:${NC} Unignored or tracked file matching critical pattern: ${YELLOW}${file}${NC}"
                found_risky=1
            fi
        done <<< "${all_res}"
    fi
done

if [ "${found_risky}" -eq 0 ]; then
    echo -e "${GREEN}✓ No critical unignored/tracked secret files detected.${NC}"
fi

echo -e "\n${BLUE}🔎 [2/4] Scanning Files for Exposed Secrets...${NC}"
# Use grep or rg to find high-entropy or recognizable credential strings
# We search tracked files if git, otherwise standard files excluding known huge directories
scan_files() {
    if [ "${IS_GIT}" -eq 1 ]; then
        git ls-files -z 2>/dev/null
    else
        find . -type f -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/venv/*' -not -path '*/.venv/*' -print0 2>/dev/null
    fi
}

secret_rules=(
    # AWS Access Key ID
    "AWS Access Key ID|(?i)A3T[A-Z0-9]{16}|AKIA[0-9A-Z]{16}"
    # Private Keys
    "Private Key|-----BEGIN [A-Z ]*PRIVATE KEY-----"
    # Slack Webhook URL
    "Slack Webhook|https://hooks.slack.com/services/T[A-Z0-9]{8}/B[A-Z0-9]{8}/[A-Za-z0-9]{24}"
    # Generic Secret Assignments
    "Potential Secret|(?i)(password|secret_key|api_key|client_secret|client_key|private_token)\s*[:=]\s*['\"][a-zA-Z0-9_\-\+\/]{16,}['\"]"
    # Google API Key
    "Google API Key|AIza[Sy][a-zA-Z0-9_\-]{35}"
    # GitHub Token
    "GitHub Token|gh[psour]_[a-zA-Z0-9]{36,255}"
    # Database URIs with passwords
    "DB Connection String|(?i)mongodb(\+srv)?://[^:]+:[^@]+@|postgres(ql)?://[^:]+:[^@]+@|mysql://[^:]+:[^@]+@"
)

found_secrets=0
# Build list of files to scan
files_to_scan=$(mktemp)
scan_files > "${files_to_scan}"

# Check if there are actually files to scan
if [ -s "${files_to_scan}" ]; then
    for rule in "${secret_rules[@]}"; do
        label="${rule%%|*}"
        regex="${rule#*|}"

        # We'll use grep -E (or git grep if git is active for faster searches)
        # To handle standard regex across environments, grep -E with -o or -n is highly portable.
        # But we must mask the actual secret to avoid logging it.
        if [ "${IS_GIT}" -eq 1 ]; then
            # Using git grep is extremely fast and respects ignores
            matches=$(git grep -E -n "${regex}" 2>/dev/null || true)
        else
            matches=$(xargs -0 grep -E -H -n "${regex}" < "${files_to_scan}" 2>/dev/null || true)
        fi

        if [ -n "${matches}" ]; then
            while IFS= read -r match; do
                if [ -n "${match}" ]; then
                    # Extract file and line
                    file_line=$(echo "${match}" | cut -d: -f1,2)
                    content=$(echo "${match}" | cut -d: -f3-)
                    # Mask the content to avoid printing actual secrets
                    masked_content=$(echo "${content}" | sed -E 's/([a-zA-Z0-9_\-\+\/]{4})[a-zA-Z0-9_\-\+\/]{8,}([a-zA-Z0-9_\-\+\/]{4})/\1********\2/g')
                    echo -e "${RED}[SECRET] ${label}:${NC} Found in ${YELLOW}${file_line}${NC} -> ${masked_content}"
                    found_secrets=1
                fi
            done <<< "${matches}"
        fi
    done
fi
rm -f "${files_to_scan}"

if [ "${found_secrets}" -eq 0 ]; then
    echo -e "${GREEN}✓ No raw secrets matched standard pattern rules.${NC}"
fi

echo -e "\n${BLUE}🔎 [3/4] Auditing Local Costs & Workspace Bloat...${NC}"
# Cost-efficiency check 1: Large unignored local directories (potential upload/cache/runtime bloat)
bloat_checks=(
    "node_modules" "venv" ".venv" "env" ".terraform" "dist" "build" "target" "out" "bin" "obj" ".serverless" ".next" ".nuxt"
)

found_bloat=0
for dir in "${bloat_checks[@]}"; do
    if [ -d "${dir}" ]; then
        # Check if git is ignoring it
        if [ "${IS_GIT}" -eq 1 ]; then
            # Check if directory is ignored by checking if a sub-file is ignored
            is_ignored=$(git check-ignore "${dir}/" 2>/dev/null || true)
            if [ -z "${is_ignored}" ]; then
                # Not ignored!
                size=$(du -sh "${dir}" 2>/dev/null | cut -f1 || echo "unknown")
                echo -e "${YELLOW}[BLOAT] Unignored heavy directory:${NC} ${YELLOW}${dir}/${NC} is active and not ignored (Size: ${size}). This may bloat cloud builds/deploys!"
                found_bloat=1
            fi
        else
            size=$(du -sh "${dir}" 2>/dev/null | cut -f1 || echo "unknown")
            echo -e "${YELLOW}[BLOAT] Local heavy directory:${NC} ${dir}/ exists (Size: ${size})."
            found_bloat=1
        fi
    fi
done

# Check for exceptionally large files (> 50MB) that are unignored
large_files=""
if [ "${IS_GIT}" -eq 1 ]; then
    # Tracked or untracked unignored large files
    # Check untracked unignored first
    untracked_files=$(git ls-files --others --exclude-standard -z 2>/dev/null | xargs -0 -I {} find {} -maxdepth 0 -size +50M 2>/dev/null || true)
    tracked_files=$(git ls-files -z 2>/dev/null | xargs -0 -I {} find {} -maxdepth 0 -size +50M 2>/dev/null || true)
    large_files=$(echo -e "${untracked_files}\n${tracked_files}" | grep -v '^$' || true)
else
    large_files=$(find . -type f -size +50M -not -path '*/.*' -not -path '*/node_modules/*' 2>/dev/null || true)
fi

if [ -n "${large_files}" ]; then
    while IFS= read -r file; do
        if [ -n "${file}" ]; then
            size=$(du -sh "${file}" 2>/dev/null | cut -f1 || echo "unknown")
            echo -e "${YELLOW}[BLOAT] Large unignored file:${NC} ${file} is ${size}. Big files slow down operations and pipelines!"
            found_bloat=1
        fi
    done <<< "${large_files}"
fi

if [ "${found_bloat}" -eq 0 ]; then
    echo -e "${GREEN}✓ No workspace bloat or unignored caching directories detected.${NC}"
fi

echo -e "\n${BLUE}🔎 [4/4] Auditing Infrastructure & Build Optimizations...${NC}"
# Cost-efficiency check 2: Static Analysis for Cloud Configs & Dockerfiles
found_infra_issues=0

# Dockerfile checks
dockerfiles=$(find . -name "Dockerfile" -not -path "*/node_modules/*" 2>/dev/null || true)
if [ -n "${dockerfiles}" ]; then
    while IFS= read -r df; do
        if [ -n "${df}" ]; then
            # Check for heavy base images
            if grep -E -q "FROM (ubuntu|debian|node|golang|python|ruby|alpine:latest|latest)" "${df}" 2>/dev/null; then
                base_img=$(grep -E "FROM " "${df}" | head -n 1)
                echo -e "${YELLOW}[OPTIMIZATION] Dockerfile Base Image:${NC} ${df} uses a potentially unoptimized base image (${YELLOW}${base_img}${NC}). Consider 'alpine' or 'slim' variants, or pinning to exact SHAs/versions to reduce image size and transfer costs."
                found_infra_issues=1
            fi
            # Check if multi-stage builds are used
            if ! grep -q -i "as " "${df}" && [ "$(grep -c -i "FROM " "${df}")" -lt 2 ]; then
                echo -e "${YELLOW}[OPTIMIZATION] Single-Stage Dockerfile:${NC} ${df} does not seem to use multi-stage builds. Multi-stage builds dramatically reduce final artifact size!"
                found_infra_issues=1
            fi
        fi
    done <<< "${dockerfiles}"
fi

# Terraform checks (Oversized VMs, lack of budget tags)
tf_files=$(find . -name "*.tf" -not -path "*/.*" -not -path "*/.terraform/*" 2>/dev/null || true)
if [ -n "${tf_files}" ]; then
    while IFS= read -r tf; do
        if [ -n "${tf}" ]; then
            # Oversized Instance types in Terraform (e.g. xlarge, metal, double-digit gigabytes)
            oversized=$(grep -E -n "instance_type\s*=\s*['\"][^'\"]*(xlarge|metal|g[0-9]|p[0-9]|c[0-9])[^'\"]*['\"]" "${tf}" 2>/dev/null || true)
            if [ -n "${oversized}" ]; then
                while IFS= read -r line; do
                    echo -e "${YELLOW}[COST] Expensive Instance Type:${NC} ${tf}:${line}. Consider using spot instances, auto-scaling, or down-scaling during non-peak/dev hours!"
                    found_infra_issues=1
                done <<< "${oversized}"
            fi

            # Check if tags / labels are configured (important for cost allocation tracking)
            # Simple heuristic: resource block starts but doesn't contain tag block, or missing tags
            # We can flag it to prompt user consideration.
            if grep -E -q "resource\s+[\"'][a-z0-9_]+[\"']\s+[\"'][a-z0-9_-]+[\"']" "${tf}" 2>/dev/null; then
                # Let's see if tags/labels keyword is in the file
                if ! grep -E -q "tags\s*=\s*\{|labels\s*=\s*\{" "${tf}" 2>/dev/null; then
                    echo -e "${YELLOW}[COST] Untagged Resources:${NC} ${tf} contains resources but does not define 'tags' or 'labels' block. Cost tracking tags are vital for auditing cloud bills."
                    found_infra_issues=1
                fi
            fi
        fi
    done <<< "${tf_files}"
fi

if [ "${found_infra_issues}" -eq 0 ]; then
    echo -e "${GREEN}✓ Infrastructure and container builds look beautifully optimized!${NC}"
fi

echo -e "\n${BLUE}==================================================${NC}"
echo -e "${BLUE}✨ Audit scan complete!${NC}"
echo -e "${BLUE}==================================================${NC}"
