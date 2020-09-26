In order to build a new template you need a vagrant cloud token that can be aquired from `https://app.vagrantup.com/settings/security`
Make sure you have `packer` and `vagrant` installed (for macos `brew install packer vagrant`)

To build and upload a new `hlesey/k8s-base` vagrant box run
```bash
VAGRANT_CLOUD_TOKEN=<token> VERSION=<box_version> make box
```

Be aware that if the version already exists in vagrant cloud you will get an error.
This should be solved after https://github.com/hashicorp/packer/issues/9492 will be implemented.
One way to mitigate it is to manually remove the provider for this version from vagrantcloud UI and retry the above make command.
