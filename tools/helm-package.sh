#!/bin/sh

RED='\033[0;31m'
NC='\033[0m'

try() {
  "$@" || die "$* failed";
}

die () {
  printf "${RED}%s${NC}\\n" "$*" >&2
  show_usage
  exit 1
}

show_usage () {
  # shellcheck disable=SC2059
  printf "${RED}
##################################################################
#
#   You have to pass 4 parameters to this script:
#   1. Path to directory with helm chart
#   2. Version to tag chart
#   3. Output directory (will be created if not exists)
#   4. -s, --skip-image-tag (optional parameter)
#   5. -u, --update-dependencies (optional parameter)
#
#   Usage:
#       ./package-chart.sh ./helm/test-project 1.0.0 helm-release
##################################################################
${NC}"
}

[ "$#" -ge "3" ] || die "3 or 4 arguments required, $# provided"

CHART_PATH=${1%/}
VERSION=${2}
OUTPUT_PATH=${3%/}
#SKIP_MAGE_TAG=${4}
CHART_NAME=$(basename "${CHART_PATH}")

set -- `getopt -o su --long skip-image-tag,update-dependencies -- "$@"`
while [ ! -z "$1" ]
do
  case "$1" in
    -u|--update-dependencies) UPDATE_DEPENDENCIES=$true;;
    -s|--skip-image-tag) SKIP_MAGE_TAG=$true;;
     *) break;;
  esac
  shift
done

if [ ! -d "${CHART_PATH}" ]; then
  die "Chart directory not found"
fi

yawn set "${CHART_PATH}/Chart.yaml" "version" "${VERSION}"

if ! [ $SKIP_MAGE_TAG ]; then
  # old convention
  yawn set "${CHART_PATH}/values.yaml" "ImageTag" "${VERSION}"
  # new convetion
  yawn set "${CHART_PATH}/values.yaml" "image.tag" "${VERSION}"
fi

if [ $UPDATE_DEPENDENCIES ]; then
  try helm dependency build "${CHART_PATH}"
fi

try helm lint --strict --set fullnameOverride=strict,nameOverride=strict "${CHART_PATH}"
try helm package --save=false "${CHART_PATH}"

if [ ! -d "${OUTPUT_PATH}" ]; then
  mkdir "${OUTPUT_PATH}"
fi

mv "${CHART_NAME}-${VERSION}.tgz" "${OUTPUT_PATH}"
