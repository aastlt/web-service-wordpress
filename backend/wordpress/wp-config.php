<?php
/**
 * Основные параметры WordPress.
 *
 * Скрипт для создания wp-config.php использует этот файл в процессе установки.
 * Необязательно использовать веб-интерфейс, можно скопировать файл в "wp-config.php"
 * и заполнить значения вручную.
 *
 * Этот файл содержит следующие параметры:
 *
 * * Настройки базы данных
 * * Секретные ключи
 * * Префикс таблиц базы данных
 * * ABSPATH
 *
 * @link https://ru.wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Параметры базы данных: Эту информацию можно получить у вашего хостинг-провайдера ** //
/** Имя базы данных для WordPress */
define( 'DB_NAME', 'wpdb' );

/** Имя пользователя базы данных */
define( 'DB_USER', 'wpuser' );

/** Пароль к базе данных */
define( 'DB_PASSWORD', 'Passw0_rd' );

/** Имя сервера базы данных */
define( 'DB_HOST', '192.168.0.111' );

/** Кодировка базы данных для создания таблиц. */
define( 'DB_CHARSET', 'utf8' );

/** Схема сопоставления. Не меняйте, если не уверены. */
define( 'DB_COLLATE', '' );

/**#@+
 * Уникальные ключи и соли для аутентификации.
 *
 * Смените значение каждой константы на уникальную фразу. Можно сгенерировать их с помощью
 * {@link https://api.wordpress.org/secret-key/1.1/salt/ сервиса ключей на WordPress.org}.
 *
 * Можно изменить их, чтобы сделать существующие файлы cookies недействительными.
 * Пользователям потребуется авторизоваться снова.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '|q+O4k1;VeT{<6~J-m2|fVt^hqc/0S8,9OK 00%1ja[|<IB6Bk&Zx+1+|Rs{Xj4L');
define('SECURE_AUTH_KEY',  'aea602_|qztC#@uBJ]^c3w)[}ih{>;MKFdtUyL2QfjajdC>a7C*;k5:ujO&+8Klr');
define('LOGGED_IN_KEY',    '((gzgcJ+7s=qyg&34Nath/R5N/HyHN*J!jG3n@%|fEc-W+}* F&.@]zV+%NVP.@J');
define('NONCE_KEY',        'o-*-=i[>-<?W$ACNB1npdVSN }aRM2L-hK20tjm)W?fpKmo%B#ss7[4`pAgcA+ig');
define('AUTH_SALT',        '-4+.Pux%i8V+dnMP BJSbR?8nhbH^33m:>j57Cxh|:;tP9_5U(}4|Qhpft+`S:wV');
define('SECURE_AUTH_SALT', 'V07}TT&Ef7#WfZk?b6wb~%n;zFJNU41#{5L+TFjTZIp3.*R}DY+N^|yWIK|yvnpc');
define('LOGGED_IN_SALT',   'tXEzn:`Xa@9rz~XzwR3UVl|Qo)3Qz(C~%hv5<ixfJ%oNK2wUESI2s]+R|Tu<vsYW');
define('NONCE_SALT',       ':knQRJt87x~/G[ x.Ct:nszKmttGU%O:xE<z[+%{`[DX7JPzQ8w(4y+NC|*9wg|b');

/**#@-*/

/**
 * Префикс таблиц в базе данных WordPress.
 *
 * Можно установить несколько сайтов в одну базу данных, если использовать
 * разные префиксы. Пожалуйста, указывайте только цифры, буквы и знак подчеркивания.
 */
$table_prefix = 'wp_';

/**
 * Для разработчиков: Режим отладки WordPress.
 *
 * Измените это значение на true, чтобы включить отображение уведомлений при разработке.
 * Разработчикам плагинов и тем настоятельно рекомендуется использовать WP_DEBUG
 * в своём рабочем окружении.
 *
 * Информацию о других отладочных константах можно найти в документации.
 *
 * @link https://ru.wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Произвольные значения добавляйте между этой строкой и надписью "дальше не редактируем". */

define('FS_METHOD', 'direct');

/* Это всё, дальше не редактируем. Успехов! */

/** Абсолютный путь к директории WordPress. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Инициализирует переменные WordPress и подключает файлы. */
require_once ABSPATH . 'wp-settings.php';
