.PHONY: flux-verify flux-install flux-reconcile flux-uninstall

## Verify flux meets the prerequisites
flux-verify:
	@flux check --pre

## Install Flux into your cluster
flux-install: $(SOPS_AGE_KEY_FILE)
	@kubectl apply --kustomize $(KUBERNETES_DIR)/bootstrap
	@cat $(SOPS_AGE_KEY_FILE) | kubectl -n flux-system create secret generic sops-age --from-file=age.agekey=/dev/stdin
	@sops --decrypt $(KUBERNETES_DIR)/flux/vars/cluster-secrets.sops.yaml | kubectl apply -f -
	@sops --decrypt $(KUBERNETES_DIR)/flux/vars/cluster-secrets-user.sops.yaml | kubectl apply -f -
	@kubectl apply -f $(KUBERNETES_DIR)/flux/vars/cluster-settings.yaml
	@kubectl apply -f $(KUBERNETES_DIR)/flux/vars/cluster-settings-user.yaml
	@kubectl apply --kustomize $(KUBERNETES_DIR)/flux/config

$(SOPS_AGE_KEY_FILE):
	@echo "Age key file is not found. Did you forget to create it?"
	@exit 1

## Force update Flux to pull in changes from your Git repository
flux-reconcile:
	@flux reconcile -n flux-system kustomization cluster --with-source

## Uninstall Flux from your cluster
flux-uninstall:
	@kubectl delete --kustomize $(KUBERNETES_DIR)/flux/config
	@kubectl delete -f $(KUBERNETES_DIR)/flux/vars/cluster-settings-user.yaml
	@kubectl delete -f $(KUBERNETES_DIR)/flux/vars/cluster-settings.yaml
	@kubectl delete secret -n flux-system cluster-secrets-user
	@kubectl delete secret -n flux-system cluster-secrets
	@kubectl delete secret -n flux-system sops-age
	@kubectl delete --kustomize $(KUBERNETES_DIR)/bootstrap
