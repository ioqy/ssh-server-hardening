#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as root."
  exit 1
fi

if ! grep --perl-regexp --silent '^[\s]*Include[\s"]*\/etc\/ssh\/sshd_config.d\/\*.conf[\s"]*$' /etc/ssh/sshd_config; then
  echo Directory "/etc/ssh/sshd_config.d" must be included in config file "/etc/ssh/sshd_config"
  exit 1
fi

installation_options=$(whiptail \
                        --separate-output \
                        --notags \
                        --title "SSH Server Hardening" \
                        --checklist "Options" 20 60 3 \
                        PermitRootLogin "Permit Root Login" off \
                        PasswordAuthentication "Permit Authentication via Password" off \
                        X11Forwarding "Enable X11 Forwarding" no \
                        3>&1 1>&2 2>&3)

if [ $? != 0 ]; then
  exit $?
fi

if [ ! -e "/etc/ssh/sshd_config.d" ]; then
  mkdir /etc/ssh/sshd_config.d
fi

tee "/etc/ssh/sshd_config.d/01_hardening.conf" > /dev/null << EOF
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
PermitEmptyPasswords no
Protocol 2
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
LoginGraceTime 5m
EOF

if [[ $installation_options != *PermitRootLogin* ]]; then
  echo "PermitRootLogin no" >> "/etc/ssh/sshd_config.d/01_hardening.conf"
fi

if [[ $installation_options != *PasswordAuthentication* ]]; then
  echo "PasswordAuthentication no" >> "/etc/ssh/sshd_config.d/01_hardening.conf"
fi

if [[ $installation_options != *X11Forwarding* ]]; then
  echo "X11Forwarding no" >> "/etc/ssh/sshd_config.d/01_hardening.conf"
fi

tee "/usr/local/bin/uninstall-ssh-server-hardening.sh" > /dev/null << EOF
#!/usr/bin/env bash
rm "/etc/ssh/sshd_config.d/01_hardening.conf"
rm "/usr/local/bin/uninstall-ssh-server-hardening.sh"
systemctl restart ssh
EOF

chmod u+x "/usr/local/bin/uninstall-ssh-server-hardening.sh"

systemctl restart ssh

whiptail \
  --title "SSH Server Hardening" \
  --msgbox 'Installation successful!\n\nTo make sure that an SSH connection is still possible, open a second SSH session while leaving this one open.\n\nIf the connection is not working or you want to remove the hardening, execute  "/usr/local/bin/uninstall-ssh-server-hardening.sh" as root.' 15 60
