VAGRANT_CLOUD_USERNAME ?= mrbarker
VERSION := 1.0.$(shell date +%s)
PUBLISH_OPTIONS := "--force"

.PHONY: install-boxes install-boxes-amd64 install-boxes-i386 install-box-amd64-virtualbox install-box-i386-virtualbox install-box-amd64-vmware install-box-i386-vmware
all: install-boxes

install-boxes: install-boxes-amd64 install-boxes-i386

install-boxes-amd64: install-box-amd64-virtualbox install-box-amd64-vmware

install-boxes-i386: install-box-i386-virtualbox install-box-i386-vmware

install-box-amd64-virtualbox: debian-amd64-virtualbox.box
	vagrant box add -f --name $(VAGRANT_CLOUD_USERNAME)/debian-amd64 --provider virtualbox debian-amd64-virtualbox.box

install-box-i386-virtualbox: debian-i386-virtualbox.box
	vagrant box add -f --name $(VAGRANT_CLOUD_USERNAME)/debian-i386 --provider virtualbox debian-i386-virtualbox.box

install-box-amd64-vmware: debian-amd64-vmware.box
	vagrant box add -f --name $(VAGRANT_CLOUD_USERNAME)/debian-amd64 --provider vmware_desktop debian-amd64-vmware.box

install-box-i386-vmware: debian-i386-vmware.box
	vagrant box add -f --name $(VAGRANT_CLOUD_USERNAME)/debian-i386 --provider vmware_desktop debian-i386-vmware.box

debian-amd64-virtualbox.box: debian-amd64.json http/p *.sh
	PACKER_LOG=1 packer build -force -only virtualbox-iso debian-amd64.json

debian-i386-virtualbox.box: debian-i386.json http/p *.sh
	PACKER_LOG=1 packer build -force -only virtualbox-iso debian-i386.json

debian-amd64-vmware.box: debian-amd64.json http/p *.sh
	PACKER_LOG=1 packer build -force -only vmware-iso debian-amd64.json

debian-i386-vmware.box: debian-i386.json http/p *.sh
	PACKER_LOG=1 packer build -force -only vmware-iso debian-i386.json

.PHONY: publish-boxes publish-boxes-amd64 publish-boxes-i386 publish-box-amd64-virtualbox publish-box-i386-virtualbox publish-box-amd64-vmware publish-box-i386-vmware
publish-boxes: publish-boxes-amd64 publish-boxes-i386

publish-boxes-amd64: publish-box-amd64-virtualbox publish-box-amd64-vmware

publish-boxes-i386: publish-box-i386-virtualbox publish-box-i386-vmware

publish-box-amd64-virtualbox: debian-amd64-virtualbox.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/debian-amd64 $(VERSION) virtualbox ./debian-amd64-virtualbox.box $(PUBLISH_OPTIONS)

publish-box-amd64-vmware: debian-amd64-vmware.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/debian-amd64 $(VERSION) vmware_desktop ./debian-amd64-vmware.box $(PUBLISH_OPTIONS)

publish-box-i386-virtualbox: debian-i386-virtualbox.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/debian-i386 $(VERSION) virtualbox ./debian-i386-virtualbox.box $(PUBLISH_OPTIONS)

publish-box-i386-vmware: debian-i386-vmware.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/debian-i386 $(VERSION) vmware_desktop ./debian-i386-vmware.box $(PUBLISH_OPTIONS)

.PHONY: clean clean-boxes clean-vagrant clean-artifacts
clean: clean-boxes clean-vagrant clean-artifacts

clean-boxes:
	-rm *.box

clean-vagrant:
	-rm -rf .vagrant

clean-artifacts:
	-rm -rf packer_cache

.PHONY: lint packer-validate shfmt
lint: packer-validate shfmt

packer-validate:
	find . -name '*.json' -exec packer validate {} \;

shfmt:
	find . -name '*.sh' -print | xargs shfmt -w -i 4
