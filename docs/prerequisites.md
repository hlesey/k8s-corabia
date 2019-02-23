# Prerequisites

You need a physical machine with a at least i5 CPU and 8GB RAM. Lower resources
might work but it is not guaranteed. The Operating system could be
Windows/MacOS/Linux.

a) Download and install (with default settings) the following software (64bit
version):

MacOS:

- [VirtualBox 6.1.6](https://download.virtualbox.org/virtualbox/6.1.6)
- [Oracle VM VirtualBox Extension Pack
  6.1.6](https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack)
- [vagrant v2.2.7](https://releases.hashicorp.com/vagrant/2.2.7/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VSCode](https://code.visualstudio.com/download), vim or any text editor you
  like.

Windows:

- [VirtualBox 6.1.6](https://download.virtualbox.org/virtualbox/6.1.6)
- [Oracle VM VirtualBox Extension Pack
  6.1.6](https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack)
- [vagrant v2.2.7](https://releases.hashicorp.com/vagrant/2.2.7/)
- [git bash
  v2.23.0](https://github.com/git-for-windows/git/releases/download/v2.23.0.windows.1/Git-2.23.0-64-bit.exe)
- [VSCode](https://code.visualstudio.com/download),
  [notepad++](https://notepad-plus-plus.org/download) or any text editor you
  like.

Windows only: In case that HyperV is active, you have to deactivate it in order
to use this setup. More info
[here](https://support.microsoft.com/en-us/help/3204980/virtualization-applications-do-not-work-together-with-hyper-v-device-g)

Linux:

- [VirtualBox 6.1.6](https://download.virtualbox.org/virtualbox/6.1.6)
- [Oracle VM VirtualBox Extension Pack
  6.1.6](https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack)
- [vagrant v2.2.7](https://releases.hashicorp.com/vagrant/2.2.7/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VSCode](https://code.visualstudio.com/download), vim or any text editor you
  like.

b) Create a folder with the name `labs` where you have ~30GB free space on disk.
Change the current directory to `labs` folder.

- For Mac/Linux: `cd $HOME/Desktop/labs`
- For Windows run `git-bash` and go to `labs` folder. Ex. `cd /c/Users/<user
  name>/Desktop/labs`

c) On your physical machine add the following entries in the hosts file:

```bash
192.168.234.100 phippy.local phippy-api.local phippy-ui.local wordpress.local
192.168.234.100 k8s.local prometheus.local hubble-ui.local  myapp.local 
```

- For Linux/Mac: modify the `/etc/hosts` and append the above lines.
- For Windows, go to `kubeadm-vagrant/src/utils/windows/` and run as Administrator (Run
  As Administrator) the `configure-fqdn.bat` script.

To verify this, go to command line and do:

```bash
ping k8s.local
PING k8s.local (192.168.234.100): 56 data bytes
Request timeout for icmp_seq 0
```

If you get response then this setup is OK.

d) Deactivate `autocrlf` for git.

- `git config --global core.autocrlf false`

e) Clone the following git repositories in `labs` folder:

```bash
git clone https://github.com/hlesey/kubeadm-vagrant.git
git clone https://github.com/hlesey/docker-vagrant.git
git clone https://github.com/hlesey/k8s-labs.git
git clone https://github.com/hlesey/phippy.git
```
