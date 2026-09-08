# Linux Security Hardening Lab

## Objective

This project documents the security hardening of an Ubuntu Server.

## Initial baseline

- Ubuntu Server
- SSH enabled
- UFW initially inactive
- SSH exposed on TCP/22

## Hardening performed

### Firewall

UFW was enabled with a default-deny policy for incoming connections.
SSH access was explicitly allowed before enabling the firewall to prevent losing remote access.
