# Prerequisites

The cluster will be provisioned in the cloud and you need to
setup your local machine to connect to it.

### 1. You must have *admin privileges* on your local machine/laptop

### 2. Download and install (with default settings) the following software (64bit version)

* MacOS:
  * [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  * [VSCode](https://code.visualstudio.com/download)
* Windows:
  * [git bash v2.56.0](https://github.com/git-for-windows/git/releases/download/v2.56.0.windows.4/Git-2.56.0.4-64-bit.exe)
  * [VSCode](https://code.visualstudio.com/download)
* Linux:
  * [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  * [VSCode](https://code.visualstudio.com/download)

### 3. On your Desktop, create a folder with the name `labs` and change the current directory to `labs` folder

* MacOS/Linux:
  * `cd $HOME/Desktop`
  * `mkdir labs`
  * `cd labs`
* Windows:
  * open `git-bash` app and run the following commands
  * `cd $HOME/Desktop`
  * `mkdir labs`
  * `cd labs`
* Linux:
  * `cd $HOME/Desktop`
  * `mkdir labs`
  * `cd labs`

### 4. Deactivate `autocrlf` for git

* `git config --global core.autocrlf false`

### 5. Clone the following git repositories in your `labs` folder

```bash
git clone https://github.com/hlesey/k8s-corabia.git
git clone https://github.com/hlesey/k8s-labs.git
git clone https://github.com/hlesey/phippy.git
```

### 6. Configure `kubectl` command line tool

The following script needs to be executed from `labs` folder: `./k8s-corabia/src/tools/configure-kubectl.sh`

After that, run the following command to load the new shell configuration:

* MacOS:
  * `source ~/.bash_profile`
* Windows:
  * `source ~/.bash_profile`
* Linux:
  * `source ~/.bashrc`

### 7. You need internet connectivity and *be able to access the internet on the following ports*

* TCP/80 and TCP/443 (applications exposed through the Gateway)
* TCP/300XX ( where XX represents your birth day :) )
* TCP/6443
* TCP/22

You can use `http://open.zorinaq.com:<port number>` for testing the connectivity.
The server listens on all TCP ports and answers with the port number.

Example: <http://open.zorinaq.com:30001> tests if 30001/TCP port is opened for egress.
To verify, open the link in your browser and check if the page says `Yep, port 30001 is open.`

Another way to verify via the command line by executing:

```bash
❯ curl -m 10 http://open.zorinaq.com:30001
Yep, port 30001 is open. <a href="http://blog.zorinaq.com/65k-open-tcp-ports-on-openzorinaqcom/">About...</a>
```

If the command hangs until the timeout or fails with `Connection refused`, the port is blocked by your network (firewall, proxy or VPN).

> **Note:** browsers refuse to open some ports, such as TCP/22 (`ERR_UNSAFE_PORT` in Chrome,
> "This address is restricted" in Firefox), even if your network allows them.
> Test TCP/22 with `curl` from the terminal (git bash on Windows), not from the browser.

Do the same for the remaining ports from the above mentioned ports list.

### 8. If everything went smooth, you should be ready for the trip :)
