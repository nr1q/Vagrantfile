# -*- mode: ruby -*-
# vi: set ft=ruby :

# Config Settings
resources_url         = "https://nrq.me/scripts/vagrant"

# GitHub Personal Access Token
github_pat            = ""

# Server Configuration

hostname              = "vagrant.test"

# Set a local private network IP address.
# See http://en.wikipedia.org/wiki/Private_network for explanation
# You can use the following IP ranges:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip             = "10.11.100.101"
server_cpus           = "1"     # Cores
server_memory         = "1024"  # MB
server_swap           = "1024"  # Options: false | int (MB) - Guideline: Between one or two times the server_memory

# UTC        for Universal Coordinated Time
# EST        for Eastern Standard Time
# CET        for Central European Time
# US/Central for American Central
# US/Eastern for American Eastern
server_timezone       = "Mexico/General"

# Database Configuration
mariadb_root_password = "root"   # We'll assume user "root"
mariadb_enable_remote = "false"  # remote access enabled when true
mongo_version         = "8.0"    # Options: 7.0 | 8.0
mongo_enable_remote   = "false"  # remote access enabled when true

# Languages and Packages
php_timezone          = "America/Mexico_City" # http://php.net/manual/en/timezones.php
php_version           = "8.3"   # Options: 8.1 | 8.2 | 8.3

# PHP Options
composer_packages     = [       # List any global Composer packages that you want to install
  #"phpunit/phpunit:4.0.*",
  #"codeception/codeception=*",
  #"phpspec/phpspec:2.0.*@dev",
  #"squizlabs/php_codesniffer:1.5.*",
]

# Default web server document root
public_folder         = "/vagrant"

nodejs_version        = "latest"   # By default "latest" will equal the latest stable version
nodejs_packages       = [          # List any global NodeJS packages that you want to install
  #"payload",
  #"gulp",
]

Vagrant.configure("2") do |config|

  # Set server to Ubuntu 20.04
  config.vm.box = "ubuntu/jammy64"

  # Set another Guest Additions
  #config.vbguest.iso_path = "/Users/hein/VirtualBox VMs/VBoxGuestAdditions.iso"
  #config.vbguest.auto_update = false

  # Create a hostname, don't forget to put it to the `hosts` file
  # This will point to the server's default virtual host
  config.vm.hostname = hostname

  # Create a static IP
  config.vm.network "private_network", ip: server_ip
  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  #config.vm.network :forwarded_port, guest: 80, host: 8080

  # Enable agent forwarding over SSH connections
  #config.ssh.forward_agent = true

  # Uncomment this in case of login issues
  #config.ssh.username = "vagrant"
  #config.ssh.password = "vagrant"
  #config.ssh.insert_key = false

  # Use NFS for the shared folder
  config.vm.synced_folder ".", "/vagrant",
    id: "core",
    type: "nfs",
    nfs_udp: false,
    nfs_version: 3, # Version 4 is not supported yet
    mount_options: ['nolock,noatime,actimeo=2,fsc']

  # Replicate local .gitconfig file if it exists
  #if File.file?(File.expand_path("~/.gitconfig"))
  #  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
  #end

  # If using VirtualBox
  config.vm.provider :virtualbox do |vb|

    vb.name = hostname
    vb.cpus = server_cpus
    vb.memory = server_memory

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]

  end


  ####
  # Base Items
  ##########

  # Provision Base Packages
  config.vm.provision "base", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/base.sh", args: [server_swap, server_timezone]


  ####
  # Languages
  ##########

  # Provision PHP
  config.vm.provision "php", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/php.sh", args: [php_timezone, php_version]


  ####
  # Web Servers
  ##########

  config.vm.provision "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/helpers/needrestart.sh"

  # Provision Apache Base
  config.vm.provision "apache", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/apache.sh", args: [server_ip, public_folder, hostname, resources_url, php_version]


  ####
  # Databases
  ##########

  # Provision MariaDB
  config.vm.provision "mariadb", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/mariadb.sh", args: [mariadb_root_password, mariadb_enable_remote]

  # Provision MongoDB
  config.vm.provision "mongodb", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/mongodb.sh", args: [mongo_enable_remote, mongo_version, php_version]


  ####
  # Additional Languages
  ##########

  # Install Nodejs
  config.vm.provision "nodejs", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/nodejs.sh", args: nodejs_packages.unshift( nodejs_version, resources_url )

  ####
  # Frameworks and Tooling
  ##########

  # Provision Composer
  # You may pass a github auth token as the first argument
  config.vm.provision "composer", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/composer.sh", args: [github_pat, composer_packages.join(" ")]

  # Install Mailcatcher
  config.vm.provision "mailcatcher", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/mailcatcher.sh", args: [php_version]

  # WordPress CLI
  config.vm.provision "wpcli", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/wpcli.sh", args: [resources_url]

  # Provision Vim
  config.vm.provision "vim", type: "shell",
    env: {"DEBIAN_FRONTEND" => "noninteractive"},
    path: "#{resources_url}/vim.sh", args: [resources_url]

  ####
  # Last configurations
  ##########

  # Set Vim for sudoedit command
  config.vm.provision "shell", privileged: true, inline: "update-alternatives --set editor /usr/bin/vim.basic; echo '[ PROVISION IS FINISHED ]'"

end
