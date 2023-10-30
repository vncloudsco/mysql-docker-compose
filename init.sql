/* proxysql user */
CREATE USER IF NOT EXISTS 'monitor'@'%' IDENTIFIED BY 'monitor';

FLUSH PRIVILEGES;
