.PHONY: hr-restart nodes kustomizations helmreleases helmrepositories gitrepositories certificates ingresses pods resources

## Restart all failed Helm Releases
hr-restart:
	@kubectl get hr --all-namespaces | grep False | awk '{print $$2, $$1}' | xargs -L1 bash -c 'flux suspend hr $$0 -n $$1'
	@kubectl get hr --all-namespaces | grep False | awk '{print $$2, $$1}' | xargs -L1 bash -c 'flux resume hr $$0 -n $$1'

## List all the nodes in your cluster
nodes:
	@kubectl get nodes -o wide

## List all the pods in your cluster
pods:
	@kubectl get pods -A

## List all the kustomizations in your cluster
kustomizations:
	@kubectl get kustomizations -A

## List all the helmreleases in your cluster
helmreleases:
	@kubectl get helmreleases -A

## List all the helmrepositories in your cluster
helmrepositories:
	@kubectl get helmrepositories -A

## List all the gitrepositories in your cluster
gitrepositories:
	@kubectl get gitrepositories -A

## List all the certificates in your cluster
certificates:
	@kubectl get certificates -A
	@kubectl get certificaterequests -A

## List all the ingresses in your cluster
ingresses:
	@kubectl get ingress -A

resources: nodes kustomizations helmreleases helmrepositories gitrepositories certificates ingresses pods
