<?php
use function Env\env;
\Env\Env::$options |= \Env\Env::USE_ENV_ARRAY; // Fix missing ENV Class

/** @var string Directory containing all of the site's files */
$root_dir = dirname(__DIR__);

/** @var string Document Root */
$app_dir = $root_dir . '/app';

/**
 * Use Dotenv to set required environment variables and load .env file in root
 */
$dotenv = \Dotenv\Dotenv::createImmutable($root_dir);
if (file_exists($root_dir . '/.env')) {
    $dotenv->load();
    $dotenv->required(['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'HOME_URL']);
}

/**
 * Set up our global environment constant and load its config first
 * Default: development
 */
define('WP_ENV', env('WP_ENV') ? : 'development');

$local_config = __DIR__ . '/env/' . WP_ENV . '.php';
if (file_exists($local_config)) {
    require_once $local_config;
}

/**
 * URLs
 */
define('DOC_ROOT', $_SERVER['DOCUMENT_ROOT']);
define('WP_HOME', env('HOME_URL'));
define('WP_SITEURL', env('SITE_URL'));

/**
 * Custom Content Directory
 */
define('CONTENT_DIR', '/www');
define('WP_CONTENT_DIR', $app_dir . CONTENT_DIR);
define('WP_CONTENT_URL', WP_HOME  . CONTENT_DIR);
define('UPLOADS', '../media'); // Move uploads into www/media folder

/**
 * DB settings
 */
define('DB_NAME', env('DB_NAME'));
define('DB_USER', env('DB_USER'));
define('DB_PASSWORD', env('DB_PASSWORD'));
define('DB_HOST', env('DB_HOST') ?: 'localhost');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
$table_prefix = env('DB_PREFIX') ?: 'wp_';
@MULTI_SITE_CONFIG;

/**
 * Authentication Unique Keys and Salts
 */
define('AUTH_KEY', env('AUTH_KEY'));
define('SECURE_AUTH_KEY', env('SECURE_AUTH_KEY'));
define('LOGGED_IN_KEY', env('LOGGED_IN_KEY'));
define('NONCE_KEY', env('NONCE_KEY'));
define('AUTH_SALT', env('AUTH_SALT'));
define('SECURE_AUTH_SALT', env('SECURE_AUTH_SALT'));
define('LOGGED_IN_SALT', env('LOGGED_IN_SALT'));
define('NONCE_SALT', env('NONCE_SALT'));

/**
 * Custom Settings
 */
define('AUTOMATIC_UPDATER_DISABLED', true);
define('DISABLE_WP_CRON', false);
define('DISALLOW_FILE_EDIT', true);
define('FORCE_SSL_ADMIN', false);

@CUSTOM_CONFIG;

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
$_SERVER['HTTPS'] = 'on';

/** Language */
define ('WPLANG', 'en_GB');

/**
 * Bootstrap WordPress
 */
if (!defined('ABSPATH')) {
    define('ABSPATH', $app_dir . '/cms/');
}