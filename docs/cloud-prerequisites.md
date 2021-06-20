# Prerequisites

The cluster will be provisioned in the cloud and you need to
setup your local machine to connect to it.
You must have *admin privileges* on your local machine/laptop.
Also you need internet connectivity and *be able to access the internet on the following ports*:

- TCP/30080
- TCP/30443
- TCP/6443
- TCP/22

a) Download and install (with default settings) the following software (64bit
version):

MacOS:

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VSCode](https://code.visualstudio.com/download)

Windows:

- [git bash
  v2.23.0](https://github.com/git-for-windows/git/releases/download/v2.23.0.windows.1/Git-2.23.0-64-bit.exe)
- [VSCode](https://code.visualstudio.com/download) or
  [notepad++](https://notepad-plus-plus.org/download)

Linux:

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VSCode](https://code.visualstudio.com/download)

b) On your Desktop, create a folder with the name `labs` and change the current directory to `labs` folder.

For Mac/Linux:

- `cd $HOME/Desktop`
- `mkdir labs`
- `cd labs`

For Windows open `git-bash` app and run the following commands:

- `cd $HOME/Desktop`
- `mkdir labs`
- `cd labs`

c) Deactivate `autocrlf` for git.

- `git config --global core.autocrlf false`

d) Clone the following git repositories in your `labs` folder:

```bash
git clone https://github.com/hlesey/kubeadm-vagrant.git
git clone https://github.com/hlesey/k8s-labs.git
git clone https://github.com/hlesey/phippy.git
```

e) Configure `kubectl` command line tool. The following script needs be executed from `labs` folder:
`./kubeadm-vagrant/src/utils/tools/configure-kubectl.sh`.

After that, run the following command to load the new shell configuration: `source ~/.bash_profile`

f) Add the following entries in the hosts file:

```bash
192.168.234.100 phippy.local phippy-api.local phippy-ui.local wordpress.local
192.168.234.100 k8s.local prometheus.local hubble-ui.local  myapp.local 
```

For Linux/Mac: modify the `/etc/hosts` and append the above lines.

For Windows, open Windows explorer, and go to `Desktop/labs/kubeadm-vagrant/src/utils/windows/`, then run as Administrator (Run
  As Administrator) the `configure-fqdn.bat` script.

To verify, go to command line and execute:

```bash
ping k8s.local
PING k8s.local (192.168.234.100): 56 data bytes
Request timeout for icmp_seq 0
```

If you get this response then this setup is OK.
