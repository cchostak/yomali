init:
	terraform init
	
dev-plan:
	terraform plan -var-file="dev.tfvars"
	
dev-apply:
	terraform apply -var-file="dev.tfvars"

deploy-dev: init dev-plan dev-apply
	