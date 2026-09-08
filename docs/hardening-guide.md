# Linux Security Hardening Guide

## SSH Hardening

### Initial configuration

The initial SSH configuration allowed password authentication:

- PasswordAuthentication: yes
- PubkeyAuthentication: yes
- MaxAuthTries: 6
- PermitRootLogin: prohibit-password

### Changes implemented

The SSH configuration was hardened by:

- Disabling password authentication.
- Keeping public key authentication enabled.
- Reducing MaxAuthTries from 6 to 3.
- Keeping direct root login restricted.

### Verification

The SSH configuration was validated with:

    sudo sshd -t

The effective configuration was then verified with:

    sudo sshd -T

Final configuration:

- PasswordAuthentication: no
- PubkeyAuthentication: yes
- MaxAuthTries: 3
- PermitRootLogin: prohibit-password

SSH access was tested from a second session after restarting the SSH service, confirming that key-based authentication remained functional.

## 4. Service Hardening

### Objective

The objective of this phase was to reduce the server's attack surface by identifying services that were not required for the intended use of the system.

The server is an Ubuntu Server virtual machine managed remotely through SSH. It does not require modem connectivity, multipath storage or graphical disk management.

### Initial service audit

The initial audit identified 21 active services.

The following services were identified as unnecessary for this environment:

* `ModemManager`: designed to manage mobile broadband devices. No modem hardware is required in this virtual machine.
* `multipathd`: used for multipath storage configurations. The virtual machine uses a single virtual disk and does not require multipath storage.
* `udisks2`: provides disk management functionality primarily useful in desktop-oriented environments. This headless server does not require it.

### Hardening actions

The unnecessary services were stopped and disabled using:

```bash
sudo systemctl disable --now ModemManager
sudo systemctl disable --now multipathd
sudo systemctl disable --now udisks2
```

The packages were not removed. This approach reduces the active attack surface while keeping the system easier to restore if requirements change.

### Verification

After the changes, the number of active services was reduced from 21 to 18.

The following command was used to verify the active services:

```bash
sudo systemctl --type=service --state=running --no-pager
```

Network exposure was also checked using:

```bash
sudo ss -tulpn
```

The verification showed that SSH remains the only externally listening TCP service:

```text
0.0.0.0:22
[::]:22
```

The DNS listeners provided by `systemd-resolved` remain bound to loopback addresses (`127.0.0.x`), and Chrony's NTP socket is also restricted to loopback.

### Services retained

Several services were intentionally kept because they provide functionality required by the server:

* `ssh`: remote administration.
* `chrony`: time synchronization.
* `rsyslog`: system logging.
* `unattended-upgrades`: automatic security updates.
* `systemd-networkd`: network management.
* `systemd-resolved`: system DNS resolution.
* `snapd`: required by installed Snap packages.
* `fwupd`: retained because it is part of the system's firmware-management infrastructure.

### Result

The service-hardening phase reduced unnecessary running services while maintaining the server's required functionality and SSH administration access.

This demonstrates a least-functionality approach: services are only disabled when their functionality is not required by the server's intended role.
