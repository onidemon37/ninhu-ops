.PHONY: install_deps_arch install_deps_debian

DEPS_ARCH = age cilium-cli cloudflared flux-bin helm kubectl kubectx kustomize sops stern yq
DEPS_DEBIAN = age cilium-cli cloudflared flux-bin helm kubernetes-cli kustomize sops stern yq

## Install workstation dependencies when using Archlinux
install_deps_arch:
	@yay -Syu --needed $(DEPS_ARCH)

## Install workstation dependencies when using Debian
install_deps_debian:
	@sudo apt-get update && sudo apt-get install -y $(DEPS_DEBIAN)
