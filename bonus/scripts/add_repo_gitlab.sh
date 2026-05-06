#!/bin/bash

GITLAB_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')

# Execute a Ruby script inside the pod to create a token for 'root'
kubectl exec -it $GITLAB_POD -n gitlab -- gitlab-rails runner "
token = User.find_by_username('root').personal_access_tokens.create(
  name: 'automation-token',
  scopes: ['api', 'read_repository', 'write_repository'],
  expires_at: 30.days.from_now
)
token.set_token('glpat-ABC123AutomationExample')
token.save!
puts 'Token Created: ' + token.token
"
