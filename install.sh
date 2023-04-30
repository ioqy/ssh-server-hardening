#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as root."
  exit 1
fi

if ! grep --perl-regexp --silent '^[\s]*Include[\s"]*\/etc\/ssh\/sshd_config.d\/\*.conf[\s"]*$' /etc/ssh/sshd_config; then
  echo Directory "/etc/ssh/sshd_config.d" must be included in config file "/etc/ssh/sshd_config"
  exit 1
fi

if [ ! -e "/etc/ssh/sshd_config.d" ]; then
  mkdir /etc/ssh/sshd_config.d
fi

tee /etc/ssh/sshd_config.d/01_hardening.conf > /dev/null << EOF
PasswordAuthentication no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no

X11Forwarding no

PermitEmptyPasswords no

Protocol 2

ClientAliveInterval 300
ClientAliveCountMax 2

MaxAuthTries 3
LoginGraceTime 5m
EOF

systemctl restart ssh
