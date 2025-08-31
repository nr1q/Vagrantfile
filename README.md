# Vagrant Web Development Environment

A Vagrant-powered virtual machine for a robust and customizable local web development environment. This box provisions an Ubuntu 22.04 (Jammy Jellyfish) server with a full suite of common development tools, including Apache, multiple PHP versions, MariaDB, MongoDB, Node.js, and more. This project is inspired on [Vaprobash by Chris Fidao](https://github.com/fideloper/Vaprobash)

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your host machine:

1.  **Vagrant** (Latest version) - [https://www.vagrantup.com/downloads](https://www.vagrantup.com/downloads)
2.  **VirtualBox** (Latest version) - [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
3.  **NFS** (For improved shared folder performance)
    *   **macOS:** Built-in and enabled by default.
    *   **Linux:** Install `nfs-kernel-server`.
    *   **Windows:** Requires additional software (e.g., Vagrant WinNFSd plugin).

## 🚀 Quick Start

1.  **Clone or download** this project to your local machine.
2.  **Navigate** to the project directory in your terminal.
3.  **(Optional)** Configure the `Vagrantfile` to your needs (see [Configuration](#-configuration) below).
4.  **Run the virtual machine:**
    ```bash
    vagrant up
    ```
    The first time you run this, it will take a while as it downloads the base box and provisions all the software.

5.  **Access the server:** Once complete, your development site will be available at:
    *   **URL:** `http://vagrant.test` (requires hosts file entry)
    *   **IP:** `http://10.11.100.101`
    *   **Local Port:** `http://localhost:8080` (port-forwarded)

### Updating the Box

After making changes to the `Vagrantfile`, reprovision the box to apply them:
```bash
vagrant reload --provision
```

## ⚙️ Configuration

The `Vagrantfile` is highly configurable. Key settings are defined at the top of the file for easy modification.

### Server Settings

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `hostname` | `"vagrant.test"` | The hostname for the virtual machine. |
| `server_ip` | `"10.11.100.101"` | The private network IP address. |
| `server_cpus` | `"1"` | Number of CPU cores allocated to the VM. |
| `server_memory` | `"1024"` | Amount of RAM (in MB) allocated to the VM. |
| `server_timezone` | `"Mexico/General"` | System timezone. |
| `public_folder` | `"/vagrant"` | The document root inside the VM. |

### Database Settings

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `mariadb_root_password` | `"root"` | Root password for MariaDB. |
| `mariadb_enable_remote` | `"false"` | Enable remote database access. |
| `mongo_version` | `"8.0"` | MongoDB version (`7.0` or `8.0`). |
| `mongo_enable_remote` | `"false"` | Enable remote database access. |

### Language & Tooling Settings

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `php_version` | `"8.3"` | PHP version to install (`8.1`, `8.2`, `8.3`). |
| `php_timezone` | `"America/Mexico_City"` | PHP's default timezone. |
| `nodejs_version` | `"latest"` | Node.js version (`latest` for stable). |
| `github_pat` | `""` | GitHub Personal Access Token for Composer. |
| `composer_packages` | `[]` | Array of global Composer packages to install. |
| `nodejs_packages` | `[]` | Array of global Node.js (npm) packages to install. |

**Example Configuration:**
```ruby
php_version = "8.2"
server_memory = "2048"
server_cpus = "2"
composer_packages = [
  "phpunit/phpunit:^9",
  "squizlabs/php_codesniffer:*"
]
```

## 📦 Included Software

This VM automatically provisions the following:

*   **OS:** Ubuntu 22.04 LTS (Jammy Jellyfish)
*   **Web Server:** Apache 2.4
*   **Database:**
    *   MariaDB 10.6+
    *   MongoDB Community Edition (v7.0 or 8.0)
*   **Languages:**
    *   PHP (8.1, 8.2, or 8.3) with common extensions (curl, gd, mbstring, xml, zip, imagick, etc.)
    *   Node.js (via nvm) and npm
*   **Tools:**
    *   Composer
    *   WP-CLI
    *   Git
    *   Vim (with a customized configuration)
    *   MailCatcher (catch and view emails locally at `http://10.11.100.101:1080`)

## 🔧 Common Vagrant Commands

| Command | Description |
| :--- | :--- |
| `vagrant up` | Starts and provisions the VM. |
| `vagrant halt` | Gracefully shuts down the VM. |
| `vagrant suspend` | Pauses the VM (saves state). |
| `vagrant resume` | Resumes a suspended VM. |
| `vagrant reload` | Restarts the VM and loads new Vagrantfile settings. |
| `vagrant reload --provision` | Restarts and re-runs provisioners. |
| `vagrant ssh` | Opens an SSH shell into the VM. |
| `vagrant destroy` | **Stops and deletes all traces of the VM.** |

## 🐛 Troubleshooting

*   **`Host is already in use` error:** The default host port `8080` might be in use. Change the `host: 8080` value in the `forwarded_port` line in the `Vagrantfile`.
*   **NFS mount issues (macOS):** Ensure your `/etc/exports` file has the correct permissions. Sometimes a reboot or `sudo nfsd restart` helps.
*   **`Vagrant up` hangs on NFS mounting:** Try disabling the NFS sync by changing `type: "nfs"` to `type: "virtualbox"` (though this is much slower).
*   **Composer asks for a GitHub API token:** If you hit rate limits, generate a [GitHub Personal Access Token](https://github.com/settings/tokens) (no scopes needed) and set the `github_pat` variable.

## 📝 Notes

*   The default document root is the `/vagrant` directory, which is synced with your host project directory.
*   MariaDB is only accessible from the VM itself by default. Set `mariadb_enable_remote = "true"` to allow connections from your host machine (e.g., using TablePlus or Sequel Ace).
*   The same applies to MongoDB with the `mongo_enable_remote` setting.
*   MailCatcher is configured to catch all emails sent via PHP's `mail()` function. Access its web interface at `http://10.11.100.101:1080`.
