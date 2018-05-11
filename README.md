# Dockerfile with set of tools to pack and publish helm charts

How to usage:
* `helm-package "${CHART_PATH}" "${APP_VERSION}" "${HELM_OUTPUT_DIR}" --skip-image-tag`
* `helm-publish "${HELM_OUTPUT_DIR}" ${HELM_REPO_URL} "${HELM_SSH_KEY}" "${HELM_GIT_REPO_URL}" "${HELM_GIT_BRANCH}"`
