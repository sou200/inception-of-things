#!/bin/bash

GITLAB_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')
GITLAB_HOST=$(kubectl get ingress gitlab-webservice-default -n gitlab -o jsonpath='{.spec.rules[0].host}')

# Execute a Ruby script inside the pod to create a token for 'root'
if [ ! -f token.txt ]; then
	kubectl exec -it $GITLAB_POD -n gitlab -- gitlab-rails runner "
	token = User.find_by_username('root').personal_access_tokens.create(
  	name: 'automation-toke',
  	scopes: ['api', 'read_repository', 'write_repository'],
  	expires_at: 30.days.from_now
	)
	token.set_token('glpat-ABC123AutomationExample')
	token.save!
	puts token.token
	" > token.txt
fi

TOKEN=$(cat token.txt | tr -d "\r\n")

curl --request POST \
  --header "PRIVATE-TOKEN: $TOKEN" \
  --data "name=test-repo" \
  --data "visibility=public" \
   -k "https://${GITLAB_HOST}/api/v4/projects"

cd /home/dragon/inception-of-things/bonus/configs/IaC-IoT

git init --initial-branch=main
git config --global http.sslVerify false
git remote set-url origin https://root:${TOKEN}@${GITLAB_HOST}/root/test-repo.git
echo https://root:${TOKEN}@${GITLAB_HOST}/root/test-repo.git
git add .
git commit -m "Initial commit"
git push --set-upstream origin main
