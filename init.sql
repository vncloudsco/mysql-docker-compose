/* proxysql user */
CREATE USER IF NOT EXISTS 'monitor'@'%' IDENTIFIED BY 'monitor';

/* mysql exporter user */
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'password' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

FLUSH PRIVILEGES;

/* start replication */
CHANGE MASTER TO MASTER_HOST='10.0.2.14',MASTER_USER='slave_user',MASTER_PASSWORD='password',MASTER_AUTO_POSITION=1;
START SLAVE;