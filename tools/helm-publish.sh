#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

die () {
    echo >&2 -e "${RED}""$@""${NC}"
    show_usage
    exit 1
}

show_usage () {
    echo >&2 -e "${RED}
#######################################################################################################################
#
#   You have to pass 5 parameters to this script:
#   1. Path to directory with packed helm charts
#   2. Helm repo url (GitHub Pages url) - it will be used in index.yaml
#   3. SSH private key for access GitHub Pages repo to store charts
#   4. GitHub Pages repo url
#   5. GitHub Pages repo branch
#
#   Usage:
#       ./publish-chart.sh helm-release https://test.github.io/test/ SSH_PRIVATE_KEY git@github.com:test/test.git master
########################################################################################################################
${NC}"
}

[ "$#" -eq 5 ] || die "5 arguments required, $# provided"

HELM_CHART_DIRECTORY="${1%/}"
HELM_REPO_URL="${2}"
SSH_PRIVATE_KEY="${3}"
HELM_GIT_REPO_URL="${4}"
HELM_GIT_BRANCH="${5}"
GIT_DIRECTORY=helm-charts-repo

CHART_CANDIDATES=$(find $HELM_CHART_DIRECTORY -maxdepth 1 -type f -name '*.tgz')

if [ $(echo "${CHART_CANDIDATES}" | wc -l ) -ne 1 ]; then
    die "More than 1 helm chart found:\n${CHART_CANDIDATES}"
fi

CHART_NAME=$(basename "${CHART_CANDIDATES}")
echo -e "Helm Chart: ${GREEN}${CHART_NAME}${NC}"

. /tools/ssh-enable.sh "${SSH_PRIVATE_KEY}"

git config --global user.email "deploy-tools@targetprocess.com"
git config --global user.name "Deploy Tools"

git clone -b "${HELM_GIT_BRANCH}" "${HELM_GIT_REPO_URL}" "${GIT_DIRECTORY}"

mv "$CHART_CANDIDATES" "${GIT_DIRECTORY}"

cd "${GIT_DIRECTORY}"

if [ ! -f index.yaml ]; then
    helm repo index --url="${HELM_REPO_URL}" .
else
    helm repo index --merge=index.yaml --url="${HELM_REPO_URL}" .
fi

git add .
git commit -m "Auto-commit $CHART_NAME"
git pull --rebase
git push origin "${HELM_GIT_BRANCH}"
