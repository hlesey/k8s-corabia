.PHONY: build add_locally box cleanup

VERSION ?= "1.18.2.1"

define metadata
{
  "name": "hlesey/k8s-base",
  "versions": [
	{
	  "version": ${VERSION},
	  "providers": [
		{
		  "name": "virtualbox",
		  "url": "./output/package.box"
		}
	  ]
	}
  ]
}
endef
export metadata

build:
	echo "Building and uploading box to vagrantcloud..."
	packer validate -var version=${VERSION} template.json
	packer build --force -var version=${VERSION} template.json

add_locally:
	echo "Add box locally..."
	vagrant box remove hlesey/k8s-base --box-version ${VERSION} || true
	@echo "$$metadata" > output/metadata.json

	vagrant box add output/metadata.json

cleanup:
	echo "Cleanup..."
	rm -rf ./output

box: build add_locally cleanup
