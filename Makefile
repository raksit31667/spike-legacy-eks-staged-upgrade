.PHONY: init-control-plane
init-control-plane:
	@terraform -chdir=control-plane/terraform init

.PHONY: plan-control-plane
plan-control-plane:
	@terraform -chdir=control-plane/terraform plan

.PHONY: apply-control-plane
apply-control-plane:
	@terraform -chdir=control-plane/terraform apply

.PHONY: destroy-control-plane
destroy-control-plane:
	@terraform -chdir=control-plane/terraform destroy

.PHONY: create-node-group
create-node-group:
	@aws cloudformation create-stack --stack-name ${name} \
  --template-body file://node-group/cloudformation/node-group-launch-template.yaml \
  --parameters file://node-group/cloudformation/parameters.json \
  --capabilities CAPABILITY_AUTO_EXPAND

.PHONY: update-node-group
update-node-group:
	@aws cloudformation update-stack --stack-name ${name} \
  --template-body file://node-group/cloudformation/node-group-launch-template.yaml \
  --parameters file://node-group/cloudformation/parameters.json \
  --capabilities CAPABILITY_AUTO_EXPAND

.PHONY: delete-node-group
delete-node-group:
	@aws cloudformation delete-stack --stack-name ${name}

.PHONY: install-cluster-addons
install-cluster-addons:
	@helm upgrade --install cluster-addons cluster-addons
