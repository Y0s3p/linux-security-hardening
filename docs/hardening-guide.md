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
