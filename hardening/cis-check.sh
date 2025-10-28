#!/usr/bin/env bash
set -Eeuo pipefail
echo "== Quick CIS-like checks =="
echo "- PasswordAuthentication: $(sshd -T | grep -i passwordauthentication || true)"
echo "- PermitRootLogin:        $(sshd -T | grep -i permitrootlogin || true)"
echo "- UFW status:             $(ufw status | head -n1 || true)"
echo "- Unattended-upgrades:    $(systemctl is-enabled unattended-upgrades 2>/dev/null || true)"
echo "- Fail2ban:               $(systemctl is-active fail2ban 2>/dev/null || true)"
echo "- Auditd:                 $(systemctl is-active auditd 2>/dev/null || true)"
