# GajahWeb Server Utilities

This repository contains a collection of utility scripts designed to assist with web server configuration, primarily focusing on Nginx setups for web service deployments.

## Scripts

### `unix/configure_nginx.sh`

This script automates the configuration of Nginx. It takes a root directory and a port number, updates a base Nginx configuration file with these values, and then applies the configuration to the system.

**Usage:**

```bash
./unix/configure_nginx.sh <root_directory> <nginx_port> [--test]
```

-   `<root_directory>`: The web server's root directory.
-   `<nginx_port>`: The port on which Nginx will listen.
-   `--test`: (Optional) Runs Nginx configuration in test mode without applying changes to the system.

**Note:** This script requires `sudo` privileges to modify system Nginx configuration files.

### `unix/switch_port_apache.sh`

This script is a placeholder intended for future implementation related to switching Apache server ports.

## Configuration Files

### `baseconfig/unix/nginx.conf`

This file serves as a base template for the Nginx configuration. The `configure_nginx.sh` script modifies this file by replacing placeholders like `__nginx_port__` and `__rootdir__` with actual values before applying the configuration.
