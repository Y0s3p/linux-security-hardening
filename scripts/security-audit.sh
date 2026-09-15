#!/bin/bash

echo "========================================"
echo " Linux Security Audit"
echo "========================================"
if [ "$EUID" -ne 0 ]; then
    echo "FAIL: Run this script with sudo"
    exit 1
fi

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
INFO_COUNT=0
ALLOWED_PORTS="22"

pass() {
    echo "PASS: $1"
    ((PASS_COUNT++))
}

fail() {
    echo "FAIL: $1"
    ((FAIL_COUNT++))
}

warn() {
    echo "WARN: $1"
    ((WARN_COUNT++))
}

info() {
    echo "INFO: $1"
    ((INFO_COUNT++))
}

check_disabled_service() {
    service="$1"

    enabled=$(systemctl is-enabled "$service" 2>/dev/null)

    if [ "$enabled" = "disabled" ]; then
        pass "$service is disabled"
    else
        fail "$service is enabled"
    fi
}
echo
echo "[+] System"
echo "Hostname: $(hostname)"
echo "Effective user: $(whoami)"
echo "Audit launched by: ${SUDO_USER:-$(whoami)}"
echo
echo "[+] IP Configuration:"
echo "$(ip -br addr)"
echo
echo "[+] Firewall"
if ufw status | grep -q "Status: active"; then
   pass "UFW is active"
else
    fail "UFW is inactive"
fi
echo
echo "[+] Firewall policy"

ufw_policy=$(ufw status verbose)

if echo "$ufw_policy" | grep -q "Default: deny (incoming)"; then
    pass "Default incoming policy is deny"
else
    fail "Default incoming policy is not deny"
fi
echo
echo "[+] SSH configuration"

ssh_config=$(sshd -T)

if echo "$ssh_config" | grep -q "^passwordauthentication no$"; then
    pass "SSH password authentication is disabled"
else
    fail "SSH password authentication is enabled"
fi
if echo "$ssh_config" | grep -q "^maxauthtries 3$"; then
    pass "SSH MaxAuthTries is set to 3"
else
    fail "SSH MaxAuthTries is not set to 3"
fi
if echo "$ssh_config" | grep -q "^permitrootlogin prohibit-password$"; then
    pass "SSH root login is restricted"
else
    fail "SSH root login is not properly restricted"
fi

if echo "$ssh_config" | grep -q "^pubkeyauthentication yes$"; then
    pass "SSH public key authentication is enabled"
else
    fail "SSH public key authentication is disabled"
fi

echo
echo "[+] Network exposure"

exposed_ports=$(ss -ltnH | awk '
    $4 ~ /^0\.0\.0\.0:/ {
        sub(/^0\.0\.0\.0:/, "", $4)
        print $4
    }
    $4 ~ /^\[::\]:/ {
        sub(/^\[::\]:/, "", $4)
        print $4
    }
' | sort -u)

if [ -n "$exposed_ports" ]; then
 info "Externally exposed TCP ports:"

    for port in $exposed_ports; do
        if echo "$ALLOWED_PORTS" | grep -qw "$port"; then
            pass "TCP port $port is allowed"
        else
            fail "Unexpected TCP port $port is exposed"
        fi
    done
else
    pass "No externally exposed TCP ports detected"
fi
echo
echo "[+] Sudo privileges"

sudo_users=$(getent group sudo | cut -d: -f4)

if [ -n "$sudo_users" ]; then
    info "Users in sudo group:"
    echo "$sudo_users"
else
    warn "No users found in sudo group"
fi
echo
echo "[+] Network services"

listening_tcp=$(ss -ltnH)

if [ -n "$listening_tcp" ]; then
    info "TCP listening sockets:"
    echo "$listening_tcp"
else
    pass "No TCP listening sockets detected"
fi
echo
echo "[+] SSH network exposure"

if ss -ltnH | grep -qE '0\.0\.0\.0:22|\\[::\\]:22'; then
    info "SSH is listening on network interfaces"
else
    warn "SSH is not listening on expected network interfaces"
fi
echo
echo "[+] Unnecessary services"

check_disabled_service "ModemManager"
check_disabled_service "multipathd"
check_disabled_service "udisks2"

echo
echo "========================================"
echo " Audit Summary"
echo "========================================"
echo "PASS: $PASS_COUNT"
echo "WARN: $WARN_COUNT"
echo "FAIL: $FAIL_COUNT"
echo "INFO: $INFO_COUNT"

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "Overall status: PASS"
else
    echo "Overall status: FAIL"
fi

echo
echo "========================================"
echo " Audit completed"
echo "========================================"

if [ "$FAIL_COUNT" -eq 0 ]; then
    exit 0
else
    exit 1
fi
