# Basic SSH server hardening

### Prerequisites

The default configuration `/etc/ssh/sshd_config` must contain `Include /etc/ssh/sshd_config.d/*.conf`


## Install

```bash
curl -fsSL https://raw.githubusercontent.com/ioqy/ssh-server-hardening/master/install.sh | sudo bash
```

or

```bash
wget -q -O- https://raw.githubusercontent.com/ioqy/ssh-server-hardening/master/install.sh | sudo bash
```

## Uninstall

```bash
sudo "/usr/local/bin/uninstall-ssh-server-hardening.sh"
```
