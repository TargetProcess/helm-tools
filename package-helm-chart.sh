#!/bin/sh

RED='\033[0;31m'
NC='\033[0m'

try() {
  "$@" || die "$* failed";
}

die () {
    echo >&2 -e "${RED}""$@""${NC}"
    show_usage
    exit 1
}

show_usage () {
    echo >&2 -e "${RED}
##################################################################
#
#   You have to pass 3 parameters to this script:
#   1. Path to directory with helm chart
#   2. Version to tag chart
#   3. Output directory (will be created if not exists)
#
#   Usage:
#       ./package-chart.sh ./helm/test-project 1.0.0 helm-release
##################################################################
${NC}"
}

[ "$#" -eq 3 ] || die "3 arguments required, $# provided"

CHART_PATH=${1%/}
VERSION=${2}
OUTPUT_PATH=${3%/}
CHART_NAME=$(basename "${CHART_PATH}")

if [ ! -d "${CHART_PATH}" ]; then
  die "Chart directory not found"
fi

yawn set "${CHART_PATH}/Chart.yaml" "version" "${VERSION}"
yawn set "${CHART_PATH}/values.yaml" "ImageTag" "${VERSION}"
yawn set "${CHART_PATH}/values.yaml" "image.tag" "${VERSION}"

try helm lint --strict "${CHART_PATH}"
try helm package --save=false "${CHART_PATH}"

if [ ! -d "${OUTPUT_PATH}" ]; then
  mkdir "${OUTPUT_PATH}"
fi

mv ${CHART_NAME}-${VERSION}.tgz "${OUTPUT_PATH}"
