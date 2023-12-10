.PHONY: k3s-prepare k3s-install k3s-rollout-update k3s-nuke k3s-reboot poweroff list ping uptime

## Prepare all the k8s nodes for running k3s
k3s-prepare:
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml $(ANSIBLE_PLAYBOOK_DIR)/cluster-prepare.yaml

## Install k3s on all the k8s nodes
k3s-install:
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml $(ANSIBLE_PLAYBOOK_DIR)/cluster-installation.yaml

## Preform operating system updates and rollout restart the cluster
k3s-rollout-update:
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml $(ANSIBLE_PLAYBOOK_DIR)/cluster-rollout-update.yaml

## Uninstall Kubernetes on the nodes
k3s-nuke:
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml $(ANSIBLE_PLAYBOOK_DIR)/cluster-nuke.yaml

## Reboot all the k8s nodes
k3s-reboot:
	cd $(ANSIBLE_DIR) && ansible-playbook -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml $(ANSIBLE_PLAYBOOK_DIR)/cluster-reboot.yaml

## Shutdown all the k8s nodes
poweroff:
	cd $(ANSIBLE_DIR) && ansible kubernetes -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml -a '/usr/bin/systemctl poweroff' --become

## List all the hosts
list:
	cd $(ANSIBLE_DIR) && ansible all -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml --list-hosts

## Ping all the hosts
ping:
	cd $(ANSIBLE_DIR) && ansible all -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml --one-line -m 'ping'

## Uptime of all the hosts
uptime:
	cd $(ANSIBLE_DIR) && ansible all -i $(ANSIBLE_INVENTORY_DIR)/hosts.yaml --one-line -a 'uptime'
