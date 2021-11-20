# Prerequisites

The cluster will be provisioned in the cloud and you need to
setup your local machine to connect to it.
You must have *admin privileges* on your local machine/laptop.
Also you need internet connectivity and *be able to access the internet on the following ports*:

- TCP/30080
- TCP/30443
- TCP/300XX ( where XX represents your birth day :) )
- TCP/6443
- TCP/22

You can use http://portquiz.net:<port number> for testing the egress

Example: http://portquiz.net:30080 tests if 30080/TCP port is opened for egress.
To verify, go to command line and execute:

```bash
❯ curl http://portquiz.net:30080
Port 30080 test successful!
Your IP: 188.25.190.205
```
Do the same for the remaining ports from the above mentioned port list.


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

After that, run the following command to load the new shell configuration: `source ~/.bash_profile` (MacOS or Windows) or `source ~/.profile` (Linux)

If everything went smooth, you should be ready for the trip :) !
