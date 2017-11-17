# Dockerfile with set of tools to pack and publish helm charts

Pattern of usage:
* `package-helm-chart.sh "${CHART_PATH}" "${APP_VERSION}" "${HELM_OUTPUT_DIR}"`
* `publish-helm-chart.sh "${HELM_OUTPUT_DIR}" ${HELM_REPO_URL} "${HELM_SSH_KEY}" "${HELM_GIT_REPO_URL}" "${HELM_GIT_BRANCH}"`
