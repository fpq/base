#! /bin/bash
echo "                                         ";
echo "██████╗  █████╗ ███████╗███████╗";
echo "██╔══██╗██╔══██╗██╔════╝██╔════╝";
echo "██████╔╝███████║███████╗█████╗  ";
echo "██╔══██╗██╔══██║╚════██║██╔══╝  ";
echo "██████╔╝██║  ██║███████║███████╗";
echo "╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝";
echo "███████    By Felix Q    ███████";

echo "- - - - - - - - - - - - - - - - - - - - -";
echo "- -  WordPress Boilerplate Installer  - -";
echo "- - - - - - - - - - - - - - - - - - - - -";
echo "                                         ";

# ****** D A T A B A S E  ****** #

read -p 'Enter datababse host IP or leave blank to use local IP: ' database_host
if [ "$database_host" == "" ] ; then
database_host='127.0.0.1'
fi

read -p 'Enter datababse name (Required): ' database_name
read -p 'Enter datababse user (Required): ' database_user

echo -n "Enter database password (leave blank for no password):"
read -s database_password
echo

read -p 'Enter datababse table prefix or leave blank to use default 'wp_': ' database_prefix
if [ "$database_prefix" == "" ]; then
database_prefix='wp_'
fi

# # ****** C U S T O M I S A T I O N ****** #
read -p 'Enter domain name E.g mywebsite.com : ' site_url
read -p 'Enter development environment (1/2/3) where development = 1, staging = 2, production = 3): ' wp_env
# Set custom config per environment
if [ "$wp_env" == "3" ]; then
  wp_env='production';
  wp_env_config="ini_set('display_errors', 0);\r\ndefine('WP_DEBUG', false);\r\ndefine('WP_DEBUG_LOG', false);\r\ndefine('WP_DEBUG_DISPLAY', false);\r\ndefine('SCRIPT_DEBUG', false);\r\ndefine('DISALLOW_FILE_MODS', true); // Disable all file modifications including updates and update notifications";
elif [  "$wp_env" == "2" ]; then
  wp_env='staging';
  wp_env_config="ini_set('display_errors', 0);\r\ndefine('WP_DEBUG', true);\r\ndefine('WP_DEBUG_LOG', true);\r\ndefine('WP_DEBUG_DISPLAY', false);\r\ndefine('SCRIPT_DEBUG', false);\r\ndefine('DISALLOW_FILE_MODS', true); // Disable all file modifications including updates and update notifications";
else
  wp_env='development';
  wp_env_config="define('SAVEQUERIES', true);\r\ndefine('WP_DEBUG', true);\r\ndefine('WP_DEBUG_LOG', true );\r\ndefine('WP_DEBUG_DISPLAY', false );\r\ndefine('SCRIPT_DEBUG', true);\r\ndefine('WP_CACHE', false);";
fi

sed -i '' "s|@CUSTOM_CONFIG;|$wp_env_config|g" config/wp-config.php

# >> Set Multisite config
read -p 'Is this a multisite install? (y/n): ' multisite
multisite_config='';
if [ "$multisite" == "y" ]; then
multisite_config="\r\n/** MULTISITE **/\r\ndefine('WP_ALLOW_MULTISITE', true );\r\ndefine('MULTISITE', true);\r\ndefine('SUBDOMAIN_INSTALL', false);\r\ndefine('DOMAIN_CURRENT_SITE', WP_HOME );\r\ndefine('PATH_CURRENT_SITE', '/');\r\ndefine('SITE_ID_CURRENT_SITE', 1);\r\ndefine('BLOG_ID_CURRENT_SITE', 1);";
fi

sed -i '' "s|@MULTI_SITE_CONFIG;|$multisite_config|g" config/wp-config.php

# Create .ENV file using data entered
echo "
# Database
DB_HOST       = $database_host
DB_NAME       = $database_name
DB_USER       = $database_user
DB_PASSWORD   = $database_password
DB_PREFIX     = $database_prefix

# URLs
WP_ENV          = $wp_env
HOME_URL        = https://$site_url
SITE_URL        = ${HOME_URL}

# Salts - https://roots.io/salts.html
{{Spread salts here}}

" > .env

# ****** A U T H  K E Y S / S A L T S  ****** #
echo '    ';
echo "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - -";
echo "Visit -->> https://roots.io/salts.html <<-- to generate WP keys & salts...";
echo 'then copy and paste the ENV formatted keys and values into the root .env file';
echo "- - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - -";

# ****** I N S T A L L  W O R D P R E S S ****** #
read -p 'Is this step completed? Enter "y" to continue with the instllation: ' install_wp

if [ "$install_wp" == "y" ]; then
echo 'Installing Composer...';

# > Create composer.json file... 
echo '{
    "require" : {
    "composer/installers" : "^1.2.0",
    "roots/wp-password-bcrypt" : "1.0.0",
    "vlucas/phpdotenv" : "^5.5.0",
    "oscarotero/env" : "^2.0",
    "johnpbloch/wordpress": "^6.3.0"
    },

    "extra": {
    "installer-paths": {
        "app/www/mu-plugins/{$name}/": ["type:wordpress-muplugin"],
        "app/www/plugins/{$name}/": ["type:wordpress-plugin"],
        "app/www/themes/{$name}/": ["type:wordpress-theme"]
    },
    "wordpress-install-dir": "app/cms"
    }
}' > composer.json;

echo 'Installing WordPress...';

# > Run composer file to install Wordpress
composer update

else 
echo 'Installation failed'; exit;
fi

echo " \o/ All done!!! \o/"; exit; # END