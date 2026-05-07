#!/usr/bin/env bash

set -e

NAMESPACE="gitlab"
REPO_NAME="test-repo"
GITLAB_USER="root"
PROJECT_DIR="/home/dragon/inception-of-things/bonus/configs/IaC-IoT"

TOKEN_FILE=".gitlab_token"
TOKEN_NAME="automation-token"

GIT_EMAIL="root@gitlab.local"
GIT_NAME="root"

echo "Discovering GitLab resources..."

GITLAB_POD=$(
    kubectl get pods -n "$NAMESPACE" \
    -l app=toolbox \
    -o jsonpath='{.items[0].metadata.name}'
)

GITLAB_HOST=$(
    kubectl get ingress gitlab-webservice-default -n "$NAMESPACE" \
    -o jsonpath='{.spec.rules[0].host}'
)

API_URL="https://${GITLAB_HOST}/api/v4"
REPO_URL="https://${GITLAB_USER}:${TOKEN:-}@${GITLAB_HOST}/${GITLAB_USER}/${REPO_NAME}.git"

echo "Ensuring project exists..."

PROJECT_STATUS=$(curl -sk \
    --header "PRIVATE-TOKEN: $TOKEN" \
    --output /dev/null \
    --write-out "%{http_code}" \
    "${API_URL}/projects/${GITLAB_USER}%2F${REPO_NAME}"
)

if [[ "$PROJECT_STATUS" == "404" ]]; then
    curl -sk --request POST \
        --header "PRIVATE-TOKEN: $TOKEN" \
        --data "name=${REPO_NAME}" \
        --data "visibility=public" \
        "${API_URL}/projects"

    echo
    echo "Project created."
else
    echo "Project already exists."
fi

if [[ ! -f "$TOKEN_FILE" ]]; then
    echo "Creating GitLab access token..."

    kubectl exec -n "$NAMESPACE" "$GITLAB_POD" -- \
    gitlab-rails runner "
        user = User.find_by_username('${GITLAB_USER}')

        token = user.personal_access_tokens.create!(
            name: '${TOKEN_NAME}',
            scopes: ['api', 'read_repository', 'write_repository'],
            expires_at: 30.days.from_now
        )

        token.set_token(SecureRandom.hex(20))
        token.save!

        puts token.token
    " > "$TOKEN_FILE"
fi

TOKEN=$(tr -d '\r\n' < "$TOKEN_FILE")
REPO_URL="https://${GITLAB_USER}:${TOKEN:-}@${GITLAB_HOST}/${GITLAB_USER}/${REPO_NAME}.git"

echo "Preparing local repository..."

cd "$PROJECT_DIR"

git init --initial-branch=main

git config user.email "$GIT_EMAIL"
git config user.name "$GIT_NAME"
git config http.sslVerify false

# Create or update origin remote
if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REPO_URL"
else
    git remote add origin "$REPO_URL"
fi

git add .

# Avoid failing if nothing changed
if ! git diff --cached --quiet; then
    git commit -m "Initial commit"
else
    echo "No changes to commit."
fi

git push -u origin main

echo
echo "Repository pushed successfully:"
echo "$REPO_URL"
