# Prerequisites

The cluster was provisioned already in the cloud and you need to
setup your local machine to connect to it.

a) Download and install (with default settings) the following software (64bit
version):

MacOS:

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VSCode](https://code.visualstudio.com/download), vim or any text editor you
  like.

Windows:

- [git bash
  v2.23.0](https://github.com/git-for-windows/git/releases/download/v2.23.0.windows.1/Git-2.23.0-64-bit.exe)
- [VSCode](https://code.visualstudio.com/download),
  [notepad++](https://notepad-plus-plus.org/download) or any text editor you
  like.

Linux:

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VSCode](https://code.visualstudio.com/download), vim or any text editor you
  like.

b) Create a folder with the name `labs` and change the current directory to `labs` folder.

- For Mac/Linux: `cd $HOME/Desktop/labs`
- For Windows run `git-bash` and go to `labs` folder. Ex. `cd /c/Users/<user
  name>/Desktop/labs`

c) Deactivate `autocrlf` for git.

- `git config --global core.autocrlf false`

d) Clone the following git repositories in `labs` folder:

```bash
git clone https://github.com/hlesey/kubeadm-vagrant.git
git clone https://github.com/hlesey/k8s-labs.git
git clone https://github.com/hlesey/phippy.git
```

e) Configure `kubectl` command line tool. The following script needs be executed from `labs` folder:
`./kubeadm-vagrant/src/utils/tools/configure-kubectl.sh`.

f) On your physical machine add the following entries in the hosts file:

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
