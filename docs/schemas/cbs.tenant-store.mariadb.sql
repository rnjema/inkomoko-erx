-- CBS tenant store DDL for a pre-created empty MariaDB 10.8 database.
-- Generated from a schema-only export of the Inkomoko Fineract migrations.
-- Fork revision: e4555bfd9b949fd02ca4c4081c8ad76f7e1a9ed6.
-- See README.md for replay adjustments and production snapshot differences.


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tenant_server_connections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `schema_server` varchar(100) NOT NULL DEFAULT 'localhost',
  `schema_name` varchar(100) NOT NULL,
  `schema_server_port` varchar(10) NOT NULL DEFAULT '3306',
  `schema_username` varchar(100) NOT NULL DEFAULT 'root',
  `schema_password` varchar(100) NOT NULL DEFAULT 'mysql',
  `auto_update` tinyint(4) NOT NULL DEFAULT 1,
  `pool_initial_size` int(11) DEFAULT 5,
  `pool_validation_interval` int(11) DEFAULT 30000,
  `pool_remove_abandoned` tinyint(4) DEFAULT 1,
  `pool_remove_abandoned_timeout` int(11) DEFAULT 60,
  `pool_log_abandoned` tinyint(4) DEFAULT 1,
  `pool_abandon_when_percentage_full` int(11) DEFAULT 50,
  `pool_test_on_borrow` tinyint(4) DEFAULT 1,
  `pool_max_active` int(11) DEFAULT 40,
  `pool_min_idle` int(11) DEFAULT 20,
  `pool_max_idle` int(11) DEFAULT 10,
  `pool_suspect_timeout` int(11) DEFAULT 60,
  `pool_time_between_eviction_runs_millis` int(11) DEFAULT 34000,
  `pool_min_evictable_idle_time_millis` int(11) DEFAULT 60000,
  `deadlock_max_retries` int(11) DEFAULT 0,
  `deadlock_max_retry_interval` int(11) DEFAULT 1,
  `schema_connection_parameters` text DEFAULT NULL,
  `readonly_schema_server` varchar(100) DEFAULT NULL,
  `readonly_schema_name` varchar(100) DEFAULT NULL,
  `readonly_schema_server_port` varchar(10) DEFAULT NULL,
  `readonly_schema_username` varchar(100) DEFAULT NULL,
  `readonly_schema_password` varchar(100) DEFAULT NULL,
  `readonly_schema_connection_parameters` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tenants` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `timezone_id` varchar(100) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `joined_date` date DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `oltp_id` bigint(20) NOT NULL,
  `report_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`),
  KEY `fk_oltp_id` (`oltp_id`),
  KEY `fk_report_id` (`report_id`),
  CONSTRAINT `fk_oltp_id` FOREIGN KEY (`oltp_id`) REFERENCES `tenant_server_connections` (`id`),
  CONSTRAINT `fk_report_id` FOREIGN KEY (`report_id`) REFERENCES `tenant_server_connections` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timezones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `country_code` varchar(2) NOT NULL,
  `timezonename` varchar(100) NOT NULL,
  `comments` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=416 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

