#!/usr/bin/env bash

echo ">>> Installing WP-CLI"

if [[ -z $1 ]]; then
    resources_url="https://nrq.me/scripts/vagrant"
else
    resources_url="$1"
fi

curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

if [ -f ./wp-cli.phar ]; then
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp
  wp --info
fi

echo ">>> Installing WP-CLI bash completions"

curl -sO https://github.com/wp-cli/wp-cli/raw/main/utils/wp-completion.bash

mkdir .wp-cli

chown vagrant:vagrant .wp-cli

mv wp-completion.bash .wp-cli/

echo 'WP-CLI bash completions installed at ~/.wp-cli/wp-completion.bash'

tee -a .bashrc <<EOL

# Enable tab completions for WP-CLI
if [ -f ~/.wp-cli/wp-completion.bash ]; then
    . ~/.wp-cli/wp-completion.bash
fi
EOL

source .bashrc

echo 'WP-CLI bash completions automatically loaded in ~/.bashrc'

