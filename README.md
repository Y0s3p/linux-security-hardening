# Linux Security Hardening Lab

## Objective

This project documents the security hardening and security auditing of an Ubuntu Server used as a cybersecurity laboratory environment.

The main objective is to reduce the server's attack surface, strengthen remote access controls, review exposed services and implement a basic automated security audit.

## Environment

- OS: Ubuntu Server 26.04
- Hostname: `soc-server`
- Network interface: `enp0s3`
- SSH: TCP/22
- Firewall: UFW
- Audit scripting: Bash
- Virtualization: VirtualBox

## Initial Baseline

The server initially had:

- SSH enabled
- UFW inactive
- SSH exposed on TCP/22
- Default Ubuntu services enabled
- No automated security audit

The initial configuration was reviewed before applying security controls.

## Hardening Performed

### Firewall

UFW was enabled with a default-deny policy for incoming connections.

SSH access was explicitly allowed before enabling the firewall to prevent losing remote access.

Final firewall policy:

- Incoming: DENY
- Outgoing: ALLOW
- SSH: TCP/22 allowed

### SSH Hardening

SSH was hardened to reduce the risk of brute-force and password-based attacks.

The following controls were implemented:

- Password authentication disabled
- Public key authentication enabled
- Maximum authentication attempts limited to 3
- Root login restricted
- SSH access performed using an ED25519 public key

The effective SSH configuration was validated using the `sshd -T` command.

The configuration syntax was also validated with the `sshd -t` command.

### User and Sudo Review

The server was reviewed to identify human users and administrative privileges.

The main administrative account is `jose`.

The account belongs to the `sudo` group and is used for administrative operations through `sudo`.

### Service Hardening

Unnecessary services were reviewed and disabled where appropriate.

The following services were disabled:

- `ModemManager`
- `multipathd`
- `udisks2`

The audit checks whether these services are disabled using `systemctl is-enabled`.

### Network Exposure Review

Listening TCP sockets were reviewed using `ss`.

The intended externally exposed TCP port is TCP/22.

Local DNS resolver sockets bound to loopback were not considered external exposure.

## Automated Security Audit

A Bash script was developed to automate the main security checks.

The audit script is located at:

scripts/security-audit.sh

The audit checks:

- Root execution
- Firewall status
- Firewall default incoming policy
- SSH password authentication
- SSH MaxAuthTries
- Root SSH access
- SSH public key authentication
- Externally exposed TCP ports
- Sudo group membership
- Listening TCP sockets
- SSH network exposure
- Disabled unnecessary services

The script reports findings using four severity levels:

- PASS
- WARN
- FAIL
- INFO

The script exits with status 0 when no failures are detected and status 1 when security checks fail.

## Detection Test

A controlled test was performed to verify that the audit script could detect an unexpected network service.

A temporary HTTP server was started on TCP/8080 using Python.

The audit correctly detected the unexpected exposure:

PASS: TCP port 22 is allowed
FAIL: Unexpected TCP port 8080 is exposed

The audit summary reported:

PASS: 10
WARN: 0
FAIL: 1
INFO: 4
Overall status: FAIL

After stopping the temporary HTTP server, the audit was executed again.

The final result returned to:

PASS: 10
WARN: 0
FAIL: 0
INFO: 4
Overall status: PASS

This demonstrates that the audit script can detect an unexpected TCP listener and correctly return to a healthy state after the exposure is removed.

## Final Security State

The final server configuration provides:

- Default-deny inbound firewall policy
- SSH restricted to public key authentication
- Password authentication disabled
- Root SSH access restricted
- Maximum SSH authentication attempts limited to 3
- Unnecessary services disabled
- Network exposure monitored by an automated Bash audit
- Controlled detection testing performed successfully

## Project Structure

linux-security-hardening/
├── README.md
├── docs/
│   └── hardening-guide.md
├── evidence/
└── scripts/
    └── security-audit.sh

## Evidence

The evidence/ directory is intended to contain relevant screenshots, command outputs and other evidence demonstrating the hardening and auditing process.

## Next Steps

Future improvements to this cybersecurity lab may include:

- Centralized log collection
- SIEM integration with Wazuh
- Security event detection and alerting
- Vulnerability assessment
- Incident response exercises
- Detection engineering
- Additional Linux hardening controls

## Skills Demonstrated

- Linux system administration
- Linux security hardening
- SSH security
- Firewall configuration with UFW
- Network exposure analysis
- Service management with systemd
- User and privilege review
- Bash scripting
- Security auditing
- Security validation and testing
- Git and GitHub
