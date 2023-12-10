# Makefile for Your Project

# This Makefile automates tasks for your project. It includes commands for
# setting up your development environment, running tests, linting code, building
# server and client Docker images, and running containers.

# Usage:
#   make <target>
#
# Targets:
#   help            : Display this help message
#   deps            : Install dependencies
#   init            : Initialize configuration files
#   configure       : Run available tests completely isolated with all requied services
#   update-template : Update from the upstream flux-cluster-template repository

# Configuration and variables are defined here.
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PYTHON_BIN = python3
BOOTSTRAP_DIR = $(ROOT_DIR)/bootstrap
KUBERNETES_DIR = $(ROOT_DIR)/kubernetes
KUBECONFIG = $(ROOT_DIR)/kubeconfig
SOPS_AGE_KEY_FILE = $(ROOT_DIR)/age.key
K8S_AUTH_KUBECONFIG = $(ROOT_DIR)/kubeconfig
ANSIBLE_DIR = $(ROOT_DIR)/ansible
ANSIBLE_VARS_ENABLED = "host_group_vars,community.sops.sops"
ANSIBLE_COLLECTIONS_PATH = $(ROOT_DIR)/.venv/galaxy
ANSIBLE_ROLES_PATH = $(ROOT_DIR)/.venv/galaxy/ansible_roles
ANSIBLE_PLAYBOOK_DIR = $(ANSIBLE_DIR)/playbooks
ANSIBLE_INVENTORY_DIR = $(ANSIBLE_DIR)/inventory

export ROOT_DIR KUBECONFIG SOPS_AGE_KEY_FILE PATH VIRTUAL_ENV ANSIBLE_COLLECTIONS_PATH ANSIBLE_ROLES_PATH ANSIBLE_VARS_ENABLED K8S_AUTH_KUBECONFIG

ifndef CI_BUILD

REQUIRE     = awk date git grep ipcalc jq pip
CHK_REQUIRE := $(foreach e,$(REQUIRE), \
	$(if $(shell command -v $(e)),, $(error No <$(e)> in PATH)))
endif

author      := onid3Mon37 <onidemon37@protonmail.com>;
maintainers := onid3Mon37 <onidemon37@protonmail.com>;
version     := 1.0.0;
function    := Deployment of the home k3s cluster


PATH_PKGS ?=

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
BLUE   := $(shell tput -Txterm setaf 4)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=30

.PHONY: all help deps init configure update-template

# 'all' is not explicitly defined as a target, so it displays the help message.
all: help

## Help target displays information about the Makefile.
help:
	@echo ''
	@printf "%0.s-" {1..110}
	@echo ''
	@echo '${YELLOW}Author		: ${GREEN}$(author)${RESET}'
	@echo '${YELLOW}Maintainers	: ${GREEN}$(maintainers)${RESET}'
	@echo '${YELLOW}Version		: ${GREEN}$(version)${RESET}'
	@echo '${YELLOW}Function	: ${GREEN}$(function)${RESET}'
	@printf "%0.s-" {1..110}
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

# ------------------------------------------------------------------------------
# The Makefile contains several other targets for setting up the environment,
# running tests, linting, and managing Docker containers.
$(info Including makefiles)
include .make/dependencies.mk
include .make/cluster.mk
include .make/ansible.mk
include .make/flux.mk

## Create a Python virtual env and install required packages
deps:
	@$(PYTHON_BIN) -m venv .venv
	@.venv/bin/python3 -m pip install --upgrade pip setuptools wheel
	@.venv/bin/python3 -m pip install --upgrade --requirement requirements.txt
	@.venv/bin/ansible-galaxy install --role-file requirements.yaml --force

## Initialize configuration files
init:
	cd $(BOOTSTRAP_DIR) && cp -n vars/addons.sample.yaml vars/addons.yaml
	cd $(BOOTSTRAP_DIR) && cp -n vars/config.sample.yaml vars/config.yaml
	@echo "=== Configuration files copied ==="
	@echo "Proceed with updating the configuration files..."
	@echo "$(BOOTSTRAP_DIR)/vars/config.yaml"
	@echo "$(BOOTSTRAP_DIR)/vars/addons.yaml"
	if [ ! -f "$(BOOTSTRAP_DIR)/vars/addons.yaml" ]; then exit 1; fi
	if [ ! -f "$(BOOTSTRAP_DIR)/vars/config.yaml" ]; then exit 1; fi

## Configure repository from Ansible vars
configure:
	cd $(BOOTSTRAP_DIR) && ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ansible-playbook configure.yaml

SHAFILE = $(ROOT_DIR)/.tasks/.latest-template.sha

## Update from the upstream flux-cluster-template repository
update-template:
	@mkdir -p $(dir $(SHAFILE))
	@touch $(SHAFILE)
	@git remote get-url template >/dev/null 2>&1 || git remote add template git@github.com:onedr0p/flux-cluster-template
	@git fetch --all
	@git cherry-pick --no-commit --allow-empty $$(cat $(SHAFILE))..template/main
	@git ls-remote template HEAD | awk '{ print $$1}' > $(SHAFILE)

# End of Makefile
