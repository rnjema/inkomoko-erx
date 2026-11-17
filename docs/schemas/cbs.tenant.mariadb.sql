-- CBS tenant DDL for a pre-created empty MariaDB 10.8 database.
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
CREATE TABLE `Fx_rate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_id` bigint(20) NOT NULL,
  `Rate` decimal(19,6) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Fk_fx_rate_office_id` (`office_id`),
  CONSTRAINT `Fk_fx_rate_office_id` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ProjectionRate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `DefaultRate` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_ProjectionRate-data_loan` (`loan_id`),
  CONSTRAINT `FK_ProjectionRate-data_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_accounting_rule` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `office_id` bigint(20) DEFAULT NULL,
  `debit_account_id` bigint(20) DEFAULT NULL,
  `allow_multiple_debits` bit(1) NOT NULL DEFAULT b'0',
  `credit_account_id` bigint(20) DEFAULT NULL,
  `allow_multiple_credits` bit(1) NOT NULL DEFAULT b'0',
  `description` varchar(500) DEFAULT NULL,
  `system_defined` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `FK_acc_accounting_rule_acc_gl_account_credit` (`credit_account_id`),
  KEY `FK_acc_accounting_rule_acc_gl_account_debit` (`debit_account_id`),
  KEY `FK_acc_accounting_rule_m_office` (`office_id`),
  CONSTRAINT `FK_acc_accounting_rule_acc_gl_account_credit` FOREIGN KEY (`credit_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_acc_accounting_rule_acc_gl_account_debit` FOREIGN KEY (`debit_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_acc_accounting_rule_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_gl_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `hierarchy` varchar(50) DEFAULT NULL,
  `gl_code` varchar(45) NOT NULL,
  `disabled` bit(1) NOT NULL DEFAULT b'0',
  `manual_journal_entries_allowed` bit(1) NOT NULL DEFAULT b'1',
  `account_usage` tinyint(4) NOT NULL DEFAULT 2,
  `classification_enum` smallint(6) NOT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `gl_code` (`gl_code`),
  KEY `FKGLACC000000002` (`tag_id`),
  KEY `FK_ACC_0000000001` (`parent_id`),
  CONSTRAINT `FKGLACC000000002` FOREIGN KEY (`tag_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_ACC_0000000001` FOREIGN KEY (`parent_id`) REFERENCES `acc_gl_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_gl_closure` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_id` bigint(20) NOT NULL,
  `closing_date` date NOT NULL,
  `is_deleted` bit(1) NOT NULL DEFAULT b'0',
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `office_id_closing_date` (`office_id`,`closing_date`),
  KEY `FK_acc_gl_closure_m_appuser` (`createdby_id`),
  KEY `FK_acc_gl_closure_m_appuser_2` (`lastmodifiedby_id`),
  KEY `FK_acc_gl_closure_m_office` (`office_id`),
  CONSTRAINT `FK_acc_gl_closure_m_appuser` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_acc_gl_closure_m_appuser_2` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_acc_gl_closure_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_gl_financial_activity_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gl_account_id` bigint(20) NOT NULL DEFAULT 0,
  `financial_activity_type` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `financial_activity_type` (`financial_activity_type`),
  KEY `FK_office_mapping_acc_gl_account` (`gl_account_id`),
  CONSTRAINT `FK_office_mapping_acc_gl_account` FOREIGN KEY (`gl_account_id`) REFERENCES `acc_gl_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_gl_journal_entry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `reversal_id` bigint(20) DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL,
  `transaction_id` varchar(50) NOT NULL,
  `loan_transaction_id` bigint(20) DEFAULT NULL,
  `savings_transaction_id` bigint(20) DEFAULT NULL,
  `client_transaction_id` bigint(20) DEFAULT NULL,
  `reversed` bit(1) NOT NULL DEFAULT b'0',
  `ref_num` varchar(100) DEFAULT NULL,
  `manual_entry` bit(1) NOT NULL DEFAULT b'0',
  `entry_date` date NOT NULL,
  `type_enum` smallint(6) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `entity_type_enum` smallint(6) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  `is_running_balance_calculated` bit(1) NOT NULL DEFAULT b'0',
  `office_running_balance` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `organization_running_balance` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `payment_details_id` bigint(20) DEFAULT NULL,
  `share_transaction_id` bigint(20) DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `odoo_ack` bit(1) DEFAULT NULL,
  `odoo_response` varchar(255) DEFAULT NULL,
  `odoo_amount` decimal(19,6) DEFAULT NULL,
  `odoo_account_gl` varchar(50) DEFAULT NULL,
  `is_correction` bit(1) DEFAULT NULL,
  `correction_date` date DEFAULT NULL,
  `is_oddo_posted` bit(1) DEFAULT NULL,
  `odoo_journal_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_acc_gl_journal_entry_acc_gl_account` (`account_id`),
  KEY `FK_acc_gl_journal_entry_acc_gl_journal_entry` (`reversal_id`),
  KEY `FK_acc_gl_journal_entry_m_appuser` (`createdby_id`),
  KEY `FK_acc_gl_journal_entry_m_appuser_2` (`lastmodifiedby_id`),
  KEY `FK_acc_gl_journal_entry_m_client_transaction` (`client_transaction_id`),
  KEY `FK_acc_gl_journal_entry_m_loan_transaction` (`loan_transaction_id`),
  KEY `FK_acc_gl_journal_entry_m_office` (`office_id`),
  KEY `FK_acc_gl_journal_entry_m_payment_detail` (`payment_details_id`),
  KEY `FK_acc_gl_journal_entry_m_savings_account_transaction` (`savings_transaction_id`),
  KEY `FK_acc_gl_journal_entry_m_share_account_transaction` (`share_transaction_id`),
  KEY `transaction_date_index` (`transaction_date`),
  KEY `idx_gl_journal_odoo_posted_loan_txn` (`is_oddo_posted`,`loan_transaction_id`),
  KEY `idx_acc_gl_journal_entry_account_entry_date` (`account_id`,`entry_date`),
  CONSTRAINT `FK_acc_gl_journal_entry_acc_gl_account` FOREIGN KEY (`account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_acc_gl_journal_entry` FOREIGN KEY (`reversal_id`) REFERENCES `acc_gl_journal_entry` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_appuser` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_appuser_2` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_client_transaction` FOREIGN KEY (`client_transaction_id`) REFERENCES `m_client_transaction` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_loan_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_payment_detail` FOREIGN KEY (`payment_details_id`) REFERENCES `m_payment_detail` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_savings_account_transaction` FOREIGN KEY (`savings_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`),
  CONSTRAINT `FK_acc_gl_journal_entry_m_share_account_transaction` FOREIGN KEY (`share_transaction_id`) REFERENCES `m_share_account_transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_product_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gl_account_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `product_type` smallint(6) DEFAULT NULL,
  `payment_type` int(11) DEFAULT NULL,
  `charge_id` bigint(20) DEFAULT NULL,
  `financial_account_type` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_acc_product_mapping_m_charge` (`charge_id`),
  KEY `FK_acc_product_mapping_m_payment_type` (`payment_type`),
  CONSTRAINT `FK_acc_product_mapping_m_charge` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `FK_acc_product_mapping_m_payment_type` FOREIGN KEY (`payment_type`) REFERENCES `m_payment_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acc_rule_tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `acc_rule_id` bigint(20) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `acc_type_enum` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQUE_ACCOUNT_RULE_TAGS` (`acc_rule_id`,`tag_id`,`acc_type_enum`),
  KEY `FK_acc_accounting_rule_id` (`acc_rule_id`),
  KEY `FK_m_code_value_id` (`tag_id`),
  CONSTRAINT `FK_acc_accounting_rule_id` FOREIGN KEY (`acc_rule_id`) REFERENCES `acc_accounting_rule` (`id`),
  CONSTRAINT `FK_m_code_value_id` FOREIGN KEY (`tag_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `c_account_number_format` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_type_enum` smallint(6) NOT NULL,
  `prefix_type_enum` smallint(6) DEFAULT NULL,
  `prefix_character` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_type_enum` (`account_type_enum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `c_cache` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cache_type_enum` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `c_configuration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `date_value` date DEFAULT NULL,
  `string_value` varchar(100) DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'0',
  `is_trap_door` bit(1) NOT NULL DEFAULT b'0',
  `description` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `c_external_service` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `c_external_service_properties` (
  `name` varchar(150) NOT NULL,
  `value` varchar(250) DEFAULT NULL,
  `external_service_id` bigint(20) NOT NULL,
  KEY `FK_c_external_service_properties_c_external_service` (`external_service_id`),
  CONSTRAINT `FK_c_external_service_properties_c_external_service` FOREIGN KEY (`external_service_id`) REFERENCES `c_external_service` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_device_registration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `updatedon_date` datetime NOT NULL,
  `registration_id` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_id` (`client_id`),
  UNIQUE KEY `registration_id` (`registration_id`),
  CONSTRAINT `FK1_client_device_registration_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communication_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_id` varchar(100) DEFAULT NULL,
  `channel` varchar(20) NOT NULL,
  `direction` varchar(20) NOT NULL,
  `recipient_type` varchar(20) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `phone_number` varchar(50) NOT NULL,
  `message_body` text DEFAULT NULL,
  `template_name` varchar(100) DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `status_detail` varchar(255) DEFAULT NULL,
  `idempotency_key` varchar(100) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `delivered_date` datetime DEFAULT NULL,
  `read_date` datetime DEFAULT NULL,
  `campaign_id` bigint(20) DEFAULT NULL,
  `template_language` varchar(15) DEFAULT NULL,
  `template_body_values` text DEFAULT NULL,
  `dispatch_retry_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_communication_message_idempotency` (`idempotency_key`),
  KEY `idx_communication_message_external_id` (`external_id`),
  KEY `idx_communication_message_phone_number` (`phone_number`),
  KEY `idx_communication_message_status` (`status`),
  KEY `idx_communication_message_campaign_id` (`campaign_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communication_webhook_event` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_id` varchar(150) NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `payload_hash` varchar(64) NOT NULL,
  `processed` bit(1) NOT NULL DEFAULT b'0',
  `processed_date` datetime DEFAULT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_communication_webhook_event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_client_on_migration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_Id` bigint(20) NOT NULL DEFAULT 1,
  `external_Id` varchar(100) NOT NULL,
  `firstname` varchar(255) NOT NULL,
  `lastname` varchar(255) NOT NULL,
  `error_msg` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_failed_client_on_migration_office` (`office_Id`),
  CONSTRAINT `FK_failed_client_on_migration_office` FOREIGN KEY (`office_Id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `glim_accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` bigint(20) NOT NULL DEFAULT 0,
  `account_number` varchar(50) NOT NULL,
  `principal_amount` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `child_accounts_count` int(11) NOT NULL,
  `accepting_child` bit(1) NOT NULL DEFAULT b'0',
  `loan_status_id` smallint(6) NOT NULL DEFAULT 0,
  `application_id` decimal(10,0) DEFAULT 0,
  `actual_principal_amount` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_number` (`account_number`),
  KEY `FK_group_id` (`group_id`),
  CONSTRAINT `FK_group_id` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gsim_accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` bigint(20) NOT NULL DEFAULT 0,
  `account_number` varchar(50) NOT NULL,
  `parent_deposit` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `child_accounts_count` int(11) NOT NULL,
  `accepting_child` bit(1) NOT NULL DEFAULT b'0',
  `savings_status_id` smallint(6) NOT NULL DEFAULT 0,
  `application_id` decimal(10,0) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_number` (`account_number`),
  KEY `FK_gsim_group_id` (`group_id`),
  CONSTRAINT `FK_gsim_group_id` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interop_identifier` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) NOT NULL,
  `type` varchar(32) NOT NULL,
  `a_value` varchar(128) NOT NULL,
  `sub_value_or_type` varchar(128) DEFAULT NULL,
  `created_by` varchar(32) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `modified_by` varchar(32) DEFAULT NULL,
  `modified_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_interop_identifier_account` (`account_id`,`type`),
  UNIQUE KEY `uk_interop_identifier_value` (`type`,`a_value`,`sub_value_or_type`),
  KEY `fk_interop_identifier_account` (`account_id`),
  CONSTRAINT `fk_interop_identifier_account` FOREIGN KEY (`account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jasper_report_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `report_name` varchar(255) NOT NULL,
  `requested_by` varchar(100) NOT NULL,
  `requested_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `parameters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`parameters`)),
  `status` varchar(30) NOT NULL,
  `approved_by` varchar(100) DEFAULT NULL,
  `approved_on` timestamp NULL DEFAULT NULL,
  `file_format` varchar(255) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `cron_expression` varchar(20) NOT NULL,
  `create_time` datetime NOT NULL,
  `task_priority` smallint(6) NOT NULL DEFAULT 5,
  `group_name` varchar(50) DEFAULT NULL,
  `previous_run_start_time` datetime DEFAULT NULL,
  `next_run_time` datetime DEFAULT NULL,
  `job_key` varchar(500) DEFAULT NULL,
  `initializing_errorlog` text DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `currently_running` bit(1) NOT NULL DEFAULT b'0',
  `updates_allowed` bit(1) NOT NULL DEFAULT b'1',
  `scheduler_group` smallint(6) NOT NULL DEFAULT 0,
  `is_misfired` bit(1) NOT NULL DEFAULT b'0',
  `node_id` int(11) DEFAULT NULL,
  `is_mismatched_job` bit(1) DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_parameters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) NOT NULL,
  `parameter_name` varchar(100) NOT NULL,
  `parameter_value` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_job_id` (`job_id`),
  CONSTRAINT `FK_job_id` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_run_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) NOT NULL,
  `version` bigint(20) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` varchar(10) NOT NULL,
  `error_message` text DEFAULT NULL,
  `trigger_type` varchar(25) NOT NULL,
  `error_log` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scheduledjobsFK` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loan_balancesheet` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `cash` decimal(19,6) NOT NULL,
  `inventory_stock` decimal(19,6) NOT NULL,
  `receivables` decimal(19,6) NOT NULL,
  `chama_tontines` decimal(19,6) NOT NULL,
  `other_current_assets` decimal(19,6) NOT NULL,
  `total_current_assets` decimal(19,6) NOT NULL,
  `goods_bought_on_credit` decimal(19,6) NOT NULL,
  `any_other_pending_payables` decimal(19,6) NOT NULL,
  `total_short_term` varchar(255) NOT NULL,
  `equipment_tools` decimal(19,6) NOT NULL,
  `furniture` decimal(19,6) NOT NULL,
  `business_premises` decimal(19,6) NOT NULL,
  `other_fixed_assets` decimal(19,6) DEFAULT NULL,
  `total_fixed_assets` decimal(19,6) NOT NULL,
  `total_assets` decimal(19,6) NOT NULL,
  `equity` decimal(19,6) NOT NULL,
  `unsecured_loans` decimal(19,6) NOT NULL,
  `secured_loans` decimal(19,6) NOT NULL,
  `total_long_term` decimal(19,6) NOT NULL,
  `total_liabilities` decimal(19,6) NOT NULL,
  `bss_deposits` decimal(19,6) NOT NULL,
  `bss_withdrawals` decimal(19,6) NOT NULL,
  `bss_monthly_turn_over` decimal(19,6) NOT NULL,
  `created_at` datetime NOT NULL,
  `short_term_loans` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_balancesheet-data_table_m_loan` (`loan_id`),
  CONSTRAINT `FK_loan_balancesheet-data_table_m_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loan_cashflow` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `CashFlowMonthType_cd_Cashflow_month` int(11) NOT NULL,
  `total_purchases` int(11) NOT NULL,
  `tax` decimal(19,6) NOT NULL,
  `transport` decimal(19,6) NOT NULL,
  `rent` decimal(19,6) NOT NULL,
  `communications` decimal(19,6) NOT NULL,
  `other_expense_amount` decimal(19,6) DEFAULT NULL,
  `utilities` decimal(19,6) NOT NULL,
  `worker_salary` decimal(19,6) DEFAULT NULL,
  `wages` decimal(19,6) DEFAULT NULL,
  `often_do_you_purchase` varchar(255) NOT NULL,
  `MonthType_cd_Purchase_last_month` int(11) NOT NULL,
  `MonthType_cd_When_last_purchase` int(11) NOT NULL,
  `purchase_for_last_month_but_1` decimal(19,6) NOT NULL,
  `last_purchase_amount` decimal(19,6) NOT NULL,
  `other_expenses_monthly` decimal(19,6) NOT NULL,
  `rent_monthly` decimal(19,6) DEFAULT NULL,
  `utilities_monthly` decimal(19,6) DEFAULT NULL,
  `average_monthly_revenue` decimal(19,6) NOT NULL,
  `amount_in_cash` decimal(19,6) NOT NULL,
  `amount_in_savings` decimal(19,6) NOT NULL,
  `amount_in_inventory` decimal(19,6) NOT NULL,
  `business_asset` decimal(19,6) NOT NULL,
  `fixed_assets_cost` decimal(19,6) NOT NULL,
  `income_generating_activity` varchar(255) DEFAULT NULL,
  `income_generating_activity_amount` decimal(19,6) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `update_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_cashflow-data_table_m_loan` (`loan_id`),
  CONSTRAINT `FK_loan_cashflow-data_table_m_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loan_cashflow_information` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `CashFlowType_cd_CashFlowType` int(11) NOT NULL,
  `ParticularType_cd_ParticularType` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `PreviousMonth2` decimal(19,6) NOT NULL,
  `PreviousMonth1` decimal(19,6) NOT NULL,
  `Month0` decimal(19,6) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_cashflow_info-data_loan` (`loan_id`),
  CONSTRAINT `FK_loan_cashflow_info-data_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loan_due_diligence` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `survey_name` varchar(255) NOT NULL,
  `COUNTRY_cd_Country` int(11) NOT NULL,
  `SurveyLocation_cd_survey_location` int(11) NOT NULL,
  `Program_cd_Program` int(11) NOT NULL,
  `Cohort_cd_Cohort` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date NOT NULL,
  `created_at` datetime NOT NULL,
  `update_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_due_diligence-data_table_m_loan` (`loan_id`),
  CONSTRAINT `FK_loan_due_diligence-data_table_m_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loan_overdue_reminder_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `number_of_days_from_due_date` int(11) NOT NULL,
  `office_id` bigint(20) NOT NULL DEFAULT 1,
  `batch_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_repayment_overdue_settings-data_table_m_office` (`office_id`),
  CONSTRAINT `FK_loan_repayment_overdue_settings-data_table_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loan_repayment_reminder_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `number_of_days_to_due_date` int(11) NOT NULL,
  `office_id` bigint(20) NOT NULL DEFAULT 1,
  `batch_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_repayment_reminder_settings-data_table_m_product_loan` (`office_id`),
  CONSTRAINT `FK_loan_repayment_reminder_settings-data_table_m_product_loan` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_account_transfer_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `from_office_id` bigint(20) NOT NULL,
  `to_office_id` bigint(20) NOT NULL,
  `from_client_id` bigint(20) DEFAULT NULL,
  `to_client_id` bigint(20) DEFAULT NULL,
  `from_savings_account_id` bigint(20) DEFAULT NULL,
  `to_savings_account_id` bigint(20) DEFAULT NULL,
  `from_loan_account_id` bigint(20) DEFAULT NULL,
  `to_loan_account_id` bigint(20) DEFAULT NULL,
  `transfer_type` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_account_transfer_details_from_client` (`from_client_id`),
  KEY `FK_m_account_transfer_details_from_loan_account` (`from_loan_account_id`),
  KEY `FK_m_account_transfer_details_from_office` (`from_office_id`),
  KEY `FK_m_account_transfer_details_from_savings_account` (`from_savings_account_id`),
  KEY `FK_m_account_transfer_details_to_client` (`to_client_id`),
  KEY `FK_m_account_transfer_details_to_loan_account` (`to_loan_account_id`),
  KEY `FK_m_account_transfer_details_to_office` (`to_office_id`),
  KEY `FK_m_account_transfer_details_to_savings_account` (`to_savings_account_id`),
  CONSTRAINT `FK_m_account_transfer_details_from_client` FOREIGN KEY (`from_client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_from_loan_account` FOREIGN KEY (`from_loan_account_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_from_office` FOREIGN KEY (`from_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_from_savings_account` FOREIGN KEY (`from_savings_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_to_client` FOREIGN KEY (`to_client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_to_loan_account` FOREIGN KEY (`to_loan_account_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_to_office` FOREIGN KEY (`to_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_account_transfer_details_to_savings_account` FOREIGN KEY (`to_savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_account_transfer_standing_instructions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `account_transfer_details_id` bigint(20) NOT NULL,
  `priority` tinyint(4) NOT NULL,
  `status` tinyint(4) NOT NULL,
  `instruction_type` tinyint(4) NOT NULL,
  `amount` decimal(19,6) DEFAULT NULL,
  `valid_from` date NOT NULL,
  `valid_till` date DEFAULT NULL,
  `recurrence_type` tinyint(4) NOT NULL,
  `recurrence_frequency` smallint(6) DEFAULT NULL,
  `recurrence_interval` smallint(6) DEFAULT NULL,
  `recurrence_on_day` smallint(6) DEFAULT NULL,
  `recurrence_on_month` smallint(6) DEFAULT NULL,
  `last_run_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `FK_m_standing_instructions_account_transfer_details` (`account_transfer_details_id`),
  CONSTRAINT `FK_m_standing_instructions_account_transfer_details` FOREIGN KEY (`account_transfer_details_id`) REFERENCES `m_account_transfer_details` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_account_transfer_standing_instructions_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `standing_instruction_id` bigint(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `execution_time` datetime NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `error_log` varchar(500) DEFAULT NULL,
  `is_notification_sent` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FK_m_account_transfer_standing_instructions_history` (`standing_instruction_id`),
  CONSTRAINT `FK_m_account_transfer_standing_instructions_m_history` FOREIGN KEY (`standing_instruction_id`) REFERENCES `m_account_transfer_standing_instructions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_account_transfer_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_transfer_details_id` bigint(20) NOT NULL,
  `from_savings_transaction_id` bigint(20) DEFAULT NULL,
  `from_loan_transaction_id` bigint(20) DEFAULT NULL,
  `to_savings_transaction_id` bigint(20) DEFAULT NULL,
  `to_loan_transaction_id` bigint(20) DEFAULT NULL,
  `is_reversed` bit(1) NOT NULL,
  `transaction_date` date NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `description` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_account_transfer_transaction_account_detail` (`account_transfer_details_id`),
  KEY `FK_m_account_transfer_transaction_from_m_loan_transaction` (`from_loan_transaction_id`),
  KEY `FK_m_account_transfer_transaction_from_m_savings_transaction` (`from_savings_transaction_id`),
  KEY `FK_m_account_transfer_transaction_to_m_loan_transaction` (`to_loan_transaction_id`),
  KEY `FK_m_account_transfer_transaction_to_m_savings_transaction` (`to_savings_transaction_id`),
  CONSTRAINT `FK_m_account_transfer_transaction_account_detail` FOREIGN KEY (`account_transfer_details_id`) REFERENCES `m_account_transfer_details` (`id`),
  CONSTRAINT `FK_m_account_transfer_transaction_from_m_loan_transaction` FOREIGN KEY (`from_loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`),
  CONSTRAINT `FK_m_account_transfer_transaction_from_m_savings_transaction` FOREIGN KEY (`from_savings_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`),
  CONSTRAINT `FK_m_account_transfer_transaction_to_m_loan_transaction` FOREIGN KEY (`to_loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`),
  CONSTRAINT `FK_m_account_transfer_transaction_to_m_savings_transaction` FOREIGN KEY (`to_savings_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_address` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `street` varchar(100) DEFAULT NULL,
  `address_line_1` varchar(100) DEFAULT NULL,
  `address_line_2` varchar(100) DEFAULT NULL,
  `address_line_3` varchar(100) DEFAULT NULL,
  `town_village` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `county_district` varchar(100) DEFAULT NULL,
  `state_province_id` int(11) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT 0.00000000,
  `longitude` decimal(10,8) DEFAULT 0.00000000,
  `created_by` varchar(100) DEFAULT NULL,
  `created_on` date DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_on` date DEFAULT NULL,
  `lga_id` int(11) DEFAULT NULL,
  `at_address_since` date DEFAULT NULL,
  `physical_address_district` varchar(255) DEFAULT NULL,
  `physical_address_sector` varchar(255) DEFAULT NULL,
  `physical_address_cell` varchar(255) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `address_fields_codefk1` (`state_province_id`),
  KEY `address_fields_codefk2` (`country_id`),
  KEY `address_fields_code_lga` (`lga_id`),
  CONSTRAINT `address_fields_code_lga` FOREIGN KEY (`lga_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `address_fields_codefk1` FOREIGN KEY (`state_province_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `address_fields_codefk2` FOREIGN KEY (`country_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_adhoc` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `query` varchar(2000) DEFAULT NULL,
  `table_name` varchar(100) DEFAULT NULL,
  `table_fields` varchar(1000) DEFAULT NULL,
  `email` varchar(500) DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `report_run_frequency_code` int(11) DEFAULT NULL,
  `report_run_every` int(11) DEFAULT NULL,
  `last_run` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `createdby_id` (`createdby_id`),
  KEY `lastmodifiedby_id` (`lastmodifiedby_id`),
  CONSTRAINT `createdby_id` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_appuser` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_deleted` bit(1) NOT NULL DEFAULT b'0',
  `office_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `firstname` varchar(100) NOT NULL,
  `lastname` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `firsttime_login_remaining` bit(1) NOT NULL,
  `nonexpired` bit(1) NOT NULL,
  `nonlocked` bit(1) NOT NULL,
  `nonexpired_credentials` bit(1) NOT NULL,
  `enabled` bit(1) NOT NULL,
  `last_time_password_updated` date NOT NULL DEFAULT '1970-01-01',
  `password_never_expires` bit(1) NOT NULL DEFAULT b'0' COMMENT 'define if the password, should be check for validity period or not',
  `is_self_service_user` bit(1) NOT NULL DEFAULT b'0',
  `cannot_change_password` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_org` (`username`),
  KEY `FKB3D587CE0DD567A` (`office_id`),
  KEY `fk_m_appuser_002x` (`staff_id`),
  KEY `last_time_password_updated` (`last_time_password_updated`),
  CONSTRAINT `FKB3D587CE0DD567A` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `fk_m_appuser_002` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_appuser_office` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `appuser_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_appuser_office` (`appuser_id`,`office_id`),
  KEY `fk_m_appuser_office_office_id` (`office_id`),
  CONSTRAINT `fk_m_appuser_office_appuser_id` FOREIGN KEY (`appuser_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_m_appuser_office_office_id` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_appuser_password_reset` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `token_hash` varchar(128) NOT NULL,
  `email_hint` varchar(100) DEFAULT NULL,
  `attempt_count` int(11) NOT NULL DEFAULT 0,
  `used` bit(1) NOT NULL DEFAULT b'0',
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_password_reset_user_created` (`user_id`,`created_at`),
  CONSTRAINT `FK_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_appuser_previous_password` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `removal_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `m_appuser_previous_password_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_appuser_role` (
  `appuser_id` bigint(20) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  PRIMARY KEY (`appuser_id`,`role_id`),
  KEY `FK7662CE5915CEC7AB` (`role_id`),
  KEY `FK7662CE59B4100309` (`appuser_id`),
  CONSTRAINT `FK7662CE5915CEC7AB` FOREIGN KEY (`role_id`) REFERENCES `m_role` (`id`),
  CONSTRAINT `FK7662CE59B4100309` FOREIGN KEY (`appuser_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_bulk_reschedule_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bulk_reschedule_execution_id` bigint(20) NOT NULL,
  `action_enum` int(11) NOT NULL,
  `actor_id` bigint(20) NOT NULL,
  `timestamp` datetime NOT NULL,
  `details_json` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_bulk_reschedule_audit_actor_id` (`actor_id`),
  KEY `idx_bulk_reschedule_audit_execution_id` (`bulk_reschedule_execution_id`),
  KEY `idx_bulk_reschedule_audit_timestamp` (`timestamp`),
  CONSTRAINT `FK_bulk_reschedule_audit_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_bulk_reschedule_audit_execution_id` FOREIGN KEY (`bulk_reschedule_execution_id`) REFERENCES `m_bulk_reschedule_execution` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_bulk_reschedule_execution` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `status_enum` int(11) NOT NULL,
  `mode_enum` int(11) NOT NULL,
  `filters_json` longtext DEFAULT NULL,
  `rescheduling_details_json` longtext DEFAULT NULL,
  `approver_id` bigint(20) DEFAULT NULL,
  `approval_note` longtext DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `total_loans_found` int(11) NOT NULL,
  `total_succeeded` int(11) NOT NULL,
  `total_failed` int(11) NOT NULL,
  `total_excluded` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `submission_note` longtext DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `execution_error` longtext DEFAULT NULL,
  `execution_started_at` datetime DEFAULT NULL,
  `execution_completed_at` datetime DEFAULT NULL,
  `total_execution_failed` int(11) NOT NULL DEFAULT 0,
  `worker_token` varchar(64) DEFAULT NULL,
  `lease_expires_at` datetime DEFAULT NULL,
  `last_heartbeat_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bulk_reschedule_execution_user_id` (`user_id`),
  KEY `idx_bulk_reschedule_execution_office_id` (`office_id`),
  KEY `idx_bulk_reschedule_execution_status` (`status_enum`),
  KEY `idx_bulk_reschedule_execution_created_at` (`created_at`),
  KEY `idx_bulk_reschedule_execution_approver` (`approver_id`),
  KEY `idx_bulk_reschedule_execution_lease` (`status_enum`,`lease_expires_at`),
  CONSTRAINT `FK_bulk_reschedule_execution_approver_id` FOREIGN KEY (`approver_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_bulk_reschedule_execution_office_id` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_bulk_reschedule_execution_user_id` FOREIGN KEY (`user_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_bulk_reschedule_result` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bulk_reschedule_execution_id` bigint(20) NOT NULL,
  `loan_id` bigint(20) NOT NULL,
  `status_enum` int(11) NOT NULL,
  `original_interest_rate` decimal(19,6) DEFAULT NULL,
  `new_interest_rate` decimal(19,6) DEFAULT NULL,
  `original_reschedule_request_id` bigint(20) DEFAULT NULL,
  `reschedule_request_id` bigint(20) DEFAULT NULL,
  `error_message` longtext DEFAULT NULL,
  `exclude_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `loan_account_number` varchar(100) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `office_id_snapshot` bigint(20) DEFAULT NULL,
  `office_name` varchar(255) DEFAULT NULL,
  `loan_product_name` varchar(255) DEFAULT NULL,
  `loan_officer_id_snapshot` bigint(20) DEFAULT NULL,
  `loan_officer_name` varchar(255) DEFAULT NULL,
  `loan_status` varchar(100) DEFAULT NULL,
  `interest_rate_method` varchar(100) DEFAULT NULL,
  `total_outstanding` decimal(19,6) DEFAULT NULL,
  `new_total_outstanding` decimal(19,6) DEFAULT NULL,
  `current_term` int(11) DEFAULT NULL,
  `new_term` int(11) DEFAULT NULL,
  `next_scheduled_installment` date DEFAULT NULL,
  `reschedule_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_bulk_reschedule_result_reschedule_request_id` (`reschedule_request_id`),
  KEY `idx_bulk_reschedule_result_execution_id` (`bulk_reschedule_execution_id`),
  KEY `idx_bulk_reschedule_result_loan_id` (`loan_id`),
  KEY `idx_bulk_reschedule_result_status` (`status_enum`),
  CONSTRAINT `FK_bulk_reschedule_result_execution_id` FOREIGN KEY (`bulk_reschedule_execution_id`) REFERENCES `m_bulk_reschedule_execution` (`id`),
  CONSTRAINT `FK_bulk_reschedule_result_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK_bulk_reschedule_result_reschedule_request_id` FOREIGN KEY (`reschedule_request_id`) REFERENCES `m_loan_reschedule_request` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_business_date` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` varchar(100) NOT NULL,
  `date` date NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `version` bigint(20) NOT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_business_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `external_id` varchar(255) NOT NULL,
  `business_type_id` int(11) DEFAULT NULL,
  `business_creation_date` date NOT NULL,
  `starting_capital` decimal(19,6) NOT NULL,
  `source_of_capital` int(11) DEFAULT NULL,
  `total_employee` bigint(20) NOT NULL,
  `business_revenue` decimal(19,6) NOT NULL,
  `average_monthly_revenue` decimal(19,6) NOT NULL,
  `best_month` varchar(255) NOT NULL,
  `reason_for_best_month` varchar(255) NOT NULL,
  `worst_month` varchar(255) NOT NULL,
  `reason_for_worst_month` varchar(255) NOT NULL,
  `number_of_purchase` bigint(20) NOT NULL,
  `purchase_frequency` varchar(255) NOT NULL,
  `total_purchase_last_month` bigint(20) NOT NULL,
  `last_purchase` varchar(255) NOT NULL,
  `last_purchase_amount` decimal(19,6) NOT NULL,
  `business_asset_amount` decimal(19,6) NOT NULL,
  `amount_at_cash` decimal(19,6) NOT NULL,
  `amount_at_saving` decimal(19,6) NOT NULL,
  `amount_at_inventory` decimal(19,6) NOT NULL,
  `fixed_asset_cost` decimal(19,6) DEFAULT NULL,
  `total_in_tax` decimal(19,6) NOT NULL,
  `total_in_transport` decimal(19,6) NOT NULL,
  `total_in_rent` decimal(19,6) NOT NULL,
  `total_in_communication` decimal(19,6) NOT NULL,
  `other_expense` varchar(255) DEFAULT NULL,
  `other_expense_amount` decimal(19,6) DEFAULT NULL,
  `total_utility` decimal(19,6) NOT NULL,
  `total_worker_salary` decimal(19,6) DEFAULT NULL,
  `total_wage` decimal(19,6) DEFAULT NULL,
  `society` decimal(19,6) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_business_detail-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_business_detail-m_client_client_id` (`client_id`),
  KEY `FK_m_business_detail-created_by` (`createdby_id`),
  KEY `FK_m_business_detail_m_code_value_business_type_id_2` (`business_type_id`),
  KEY `FK_m_business_detail_m_code_value_source_of_capital` (`source_of_capital`),
  CONSTRAINT `FK_m_business_detail-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_business_detail-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_business_detail-m_client_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_business_detail_m_code_value_business_type_id_2` FOREIGN KEY (`business_type_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_m_business_detail_m_code_value_source_of_capital` FOREIGN KEY (`source_of_capital`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_business_owners` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `firstname` varchar(100) NOT NULL,
  `lastname` varchar(100) NOT NULL,
  `ownership` decimal(5,2) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `bvn` varchar(200) DEFAULT NULL,
  `nin` varchar(200) DEFAULT NULL,
  `mobile_number` varchar(200) NOT NULL,
  `email` varchar(100) NOT NULL,
  `type_id` int(11) DEFAULT NULL,
  `business_owner_number` varchar(200) DEFAULT NULL,
  `street` varchar(200) NOT NULL,
  `address1` varchar(200) DEFAULT NULL,
  `address2` varchar(200) DEFAULT NULL,
  `address3` varchar(200) DEFAULT NULL,
  `landmark` varchar(500) DEFAULT NULL,
  `city_id` int(11) NOT NULL,
  `state_province_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `postal_code` varchar(100) DEFAULT NULL,
  `created_by` varchar(200) NOT NULL,
  `updated_by` varchar(200) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `image_id` bigint(20) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'0',
  `middlename` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `client_business_owner_Fk_m_city_id` (`city_id`),
  KEY `client_business_owner_Fk_m_state_province_id` (`state_province_id`),
  KEY `client_business_owner_Fk_m_country_id` (`country_id`),
  KEY `client_business_owner_Fk_m_type_id` (`type_id`),
  KEY `client_business_owner_Fk_m_title_id` (`title_id`),
  KEY `client_business_owner_Fk_m_image` (`image_id`),
  KEY `client_business_owner_Fk_m_client_id` (`client_id`),
  CONSTRAINT `client_business_owner_Fk_m_city_id` FOREIGN KEY (`city_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_business_owner_Fk_m_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `client_business_owner_Fk_m_country_id` FOREIGN KEY (`country_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_business_owner_Fk_m_image` FOREIGN KEY (`image_id`) REFERENCES `m_image` (`id`),
  CONSTRAINT `client_business_owner_Fk_m_state_province_id` FOREIGN KEY (`state_province_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_business_owner_Fk_m_title_id` FOREIGN KEY (`title_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_business_owner_Fk_m_type_id` FOREIGN KEY (`type_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_calendar` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(70) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `duration` smallint(6) DEFAULT NULL,
  `calendar_type_enum` smallint(6) NOT NULL,
  `repeating` bit(1) NOT NULL DEFAULT b'0',
  `recurrence` varchar(100) DEFAULT NULL,
  `remind_by_enum` smallint(6) DEFAULT NULL,
  `first_reminder` smallint(6) DEFAULT NULL,
  `second_reminder` smallint(6) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `meeting_time` time DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_calendar_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calendar_id` bigint(20) NOT NULL,
  `title` varchar(70) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `duration` smallint(6) DEFAULT NULL,
  `calendar_type_enum` smallint(6) NOT NULL,
  `repeating` bit(1) NOT NULL DEFAULT b'0',
  `recurrence` varchar(100) DEFAULT NULL,
  `remind_by_enum` smallint(6) DEFAULT NULL,
  `first_reminder` smallint(6) DEFAULT NULL,
  `second_reminder` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_calendar_m_calendar_history` (`calendar_id`),
  CONSTRAINT `FK_m_calendar_m_calendar_history` FOREIGN KEY (`calendar_id`) REFERENCES `m_calendar` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_calendar_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calendar_id` bigint(20) NOT NULL,
  `entity_id` bigint(20) NOT NULL,
  `entity_type_enum` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_calendar_m_calendar_instance` (`calendar_id`),
  CONSTRAINT `FK_m_calendar_m_calendar_instance` FOREIGN KEY (`calendar_id`) REFERENCES `m_calendar` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_cashier_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cashier_id` bigint(20) NOT NULL,
  `txn_type` smallint(6) NOT NULL,
  `txn_amount` decimal(19,6) NOT NULL,
  `txn_date` date NOT NULL,
  `created_date` datetime NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `txn_note` varchar(200) DEFAULT NULL,
  `currency_code` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IK_m_teller_transactions_m_cashier` (`cashier_id`),
  CONSTRAINT `FK_m_teller_transactions_m_cashiers` FOREIGN KEY (`cashier_id`) REFERENCES `m_cashiers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_cashiers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `staff_id` bigint(20) DEFAULT NULL,
  `teller_id` bigint(20) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `start_time` varchar(10) DEFAULT NULL,
  `end_time` varchar(10) DEFAULT NULL,
  `full_day` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IK_m_cashiers_m_staff` (`staff_id`),
  KEY `IK_m_cashiers_m_teller` (`teller_id`),
  CONSTRAINT `FK_m_cashiers_m_staff` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`),
  CONSTRAINT `FK_m_cashiers_m_teller` FOREIGN KEY (`teller_id`) REFERENCES `m_tellers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL,
  `charge_applies_to_enum` smallint(6) NOT NULL,
  `charge_time_enum` smallint(6) NOT NULL,
  `charge_calculation_enum` smallint(6) NOT NULL,
  `charge_payment_mode_enum` smallint(6) DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `fee_on_day` smallint(6) DEFAULT NULL,
  `fee_interval` smallint(6) DEFAULT NULL,
  `fee_on_month` smallint(6) DEFAULT NULL,
  `is_penalty` bit(1) NOT NULL DEFAULT b'0',
  `is_active` bit(1) NOT NULL,
  `is_deleted` bit(1) NOT NULL DEFAULT b'0',
  `min_cap` decimal(19,6) DEFAULT NULL,
  `max_cap` decimal(19,6) DEFAULT NULL,
  `fee_frequency` smallint(6) DEFAULT NULL,
  `is_free_withdrawal` bit(1) NOT NULL DEFAULT b'0',
  `free_withdrawal_charge_frequency` int(11) DEFAULT 0,
  `restart_frequency` int(11) DEFAULT 0,
  `restart_frequency_enum` int(11) DEFAULT 0,
  `is_payment_type` bit(1) DEFAULT b'0',
  `payment_type_id` int(11) DEFAULT NULL,
  `income_or_liability_account_id` bigint(20) DEFAULT NULL,
  `tax_group_id` bigint(20) DEFAULT NULL,
  `min_amount` decimal(19,6) DEFAULT NULL,
  `max_amount` decimal(19,6) DEFAULT NULL,
  `has_varying_charge` bit(1) DEFAULT NULL,
  `max_occurrence` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `FK_m_charge_acc_gl_account` (`income_or_liability_account_id`),
  KEY `FK_m_charge_m_tax_group` (`tax_group_id`),
  KEY `FK_m_payment_detail_m_payment_types` (`payment_type_id`),
  CONSTRAINT `FK_m_charge_acc_gl_account` FOREIGN KEY (`income_or_liability_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_m_charge_m_tax_group` FOREIGN KEY (`tax_group_id`) REFERENCES `m_tax_group` (`id`),
  CONSTRAINT `FK_m_payment_detail_m_payment_types` FOREIGN KEY (`payment_type_id`) REFERENCES `m_payment_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_no` varchar(20) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `status_enum` int(11) NOT NULL DEFAULT 300,
  `sub_status` int(11) DEFAULT NULL,
  `activation_date` date DEFAULT NULL,
  `office_joining_date` date DEFAULT NULL,
  `office_id` bigint(20) NOT NULL,
  `transfer_to_office_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `fullname` varchar(100) DEFAULT NULL,
  `display_name` varchar(100) NOT NULL,
  `mobile_no` varchar(50) DEFAULT NULL,
  `is_staff` bit(1) NOT NULL DEFAULT b'0',
  `gender_cv_id` int(11) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `image_id` bigint(20) DEFAULT NULL,
  `closure_reason_cv_id` int(11) DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `updated_by` bigint(20) DEFAULT NULL,
  `updated_on` date DEFAULT NULL,
  `submittedon_date` date DEFAULT NULL,
  `activatedon_userid` bigint(20) DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `default_savings_product` bigint(20) DEFAULT NULL,
  `default_savings_account` bigint(20) DEFAULT NULL,
  `client_type_cv_id` int(11) DEFAULT NULL,
  `client_classification_cv_id` int(11) DEFAULT NULL,
  `reject_reason_cv_id` int(11) DEFAULT NULL,
  `rejectedon_date` date DEFAULT NULL,
  `rejectedon_userid` bigint(20) DEFAULT NULL,
  `withdraw_reason_cv_id` int(11) DEFAULT NULL,
  `withdrawn_on_date` date DEFAULT NULL,
  `withdraw_on_userid` bigint(20) DEFAULT NULL,
  `reactivated_on_date` date DEFAULT NULL,
  `reactivated_on_userid` bigint(20) DEFAULT NULL,
  `legal_form_enum` int(11) DEFAULT NULL,
  `reopened_on_date` date DEFAULT NULL,
  `reopened_by_userid` bigint(20) DEFAULT NULL,
  `email_address` varchar(150) DEFAULT NULL,
  `proposed_transfer_date` date DEFAULT NULL,
  `created_on_utc` datetime DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` datetime DEFAULT NULL,
  `kiva_id` varchar(255) DEFAULT NULL,
  `is_odoo_customer_posted` bit(1) DEFAULT NULL,
  `odoo_customer_id` bigint(20) DEFAULT NULL,
  `is_updated_to_odoo` bit(1) DEFAULT NULL,
  `is_migrated` bit(1) NOT NULL DEFAULT b'0',
  `migrated_on_date` date DEFAULT NULL,
  `migrated_from_office_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_no` (`account_no`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FK1_m_client_gender_m_code_value` (`gender_cv_id`),
  KEY `FKCE00CAB3E0DD567A` (`office_id`),
  KEY `FK_m_client_classification_m_code_value` (`client_classification_cv_id`),
  KEY `FK_m_client_m_code` (`closure_reason_cv_id`),
  KEY `FK_m_client_m_image` (`image_id`),
  KEY `FK_m_client_m_office` (`transfer_to_office_id`),
  KEY `FK_m_client_m_savings_account` (`default_savings_account`),
  KEY `FK_m_client_m_savings_product` (`default_savings_product`),
  KEY `FK_m_client_substatus_m_code_value` (`sub_status`),
  KEY `FK_m_client_type_m_code_value` (`client_type_cv_id`),
  KEY `FK_m_client_type_m_code_value_withdraw` (`withdraw_reason_cv_id`),
  KEY `FK_m_client_type_mcode_value_reject` (`reject_reason_cv_id`),
  KEY `client_staff_id` (`staff_id`),
  KEY `FK_client_created_by` (`created_by`),
  KEY `FK_client_last_modified_by` (`last_modified_by`),
  KEY `idx_m_client_status_office` (`status_enum`,`office_id`),
  KEY `idx_m_client_display_name` (`display_name`),
  KEY `FK_m_client_migrated_from_office` (`migrated_from_office_id`),
  CONSTRAINT `FK1_m_client_gender_m_code_value` FOREIGN KEY (`gender_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FKCE00CAB3E0DD567A` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_client_created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_client_last_modified_by` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_client_classification_m_code_value` FOREIGN KEY (`client_classification_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_client_m_code` FOREIGN KEY (`closure_reason_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_client_m_image` FOREIGN KEY (`image_id`) REFERENCES `m_image` (`id`),
  CONSTRAINT `FK_m_client_m_office` FOREIGN KEY (`transfer_to_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_client_m_savings_account` FOREIGN KEY (`default_savings_account`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `FK_m_client_m_savings_product` FOREIGN KEY (`default_savings_product`) REFERENCES `m_savings_product` (`id`),
  CONSTRAINT `FK_m_client_m_staff` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`),
  CONSTRAINT `FK_m_client_migrated_from_office` FOREIGN KEY (`migrated_from_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_client_substatus_m_code_value` FOREIGN KEY (`sub_status`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_client_type_m_code_value` FOREIGN KEY (`client_type_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_client_type_m_code_value_withdraw` FOREIGN KEY (`withdraw_reason_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_client_type_mcode_value_reject` FOREIGN KEY (`reject_reason_cv_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_additional_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) DEFAULT NULL,
  `alt_phone_no` varchar(50) DEFAULT NULL,
  `title` int(11) DEFAULT NULL,
  `mnemonics` varchar(255) DEFAULT NULL,
  `marital_status` int(11) DEFAULT NULL,
  `initials` varchar(255) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `m_client_client_additional_info` (`client_id`),
  KEY `m_client_code_value_title` (`title`),
  KEY `m_client_code_value_marital_status` (`marital_status`),
  CONSTRAINT `m_client_client_additional_info` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `m_client_code_value_marital_status` FOREIGN KEY (`marital_status`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `m_client_code_value_title` FOREIGN KEY (`title`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_address` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL DEFAULT 0,
  `address_id` bigint(20) NOT NULL DEFAULT 0,
  `address_type_id` int(11) NOT NULL DEFAULT 0,
  `is_active` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `addressIdFk` (`address_id`),
  KEY `address_codefk` (`address_type_id`),
  KEY `clientaddressfk` (`client_id`),
  CONSTRAINT `address_codefk` FOREIGN KEY (`address_type_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `clientaddressfk` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_attendance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL DEFAULT 0,
  `meeting_id` bigint(20) NOT NULL,
  `attendance_type_enum` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_client_meeting_attendance` (`client_id`,`meeting_id`),
  KEY `FK_m_meeting_m_client_attendance` (`meeting_id`),
  CONSTRAINT `FK_m_client_m_client_attendance` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_meeting_m_client_attendance` FOREIGN KEY (`meeting_id`) REFERENCES `m_meeting` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  `is_penalty` bit(1) NOT NULL,
  `charge_time_enum` smallint(6) NOT NULL,
  `charge_due_date` date DEFAULT NULL,
  `charge_calculation_enum` smallint(6) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `amount_paid_derived` decimal(19,6) DEFAULT NULL,
  `amount_waived_derived` decimal(19,6) DEFAULT NULL,
  `amount_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_derived` decimal(19,6) NOT NULL,
  `is_paid_derived` bit(1) DEFAULT NULL,
  `waived` bit(1) DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `inactivated_on_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_client_charge_m_charge` (`charge_id`),
  KEY `FK_m_client_charge_m_client` (`client_id`),
  CONSTRAINT `FK_m_client_charge_m_charge` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `FK_m_client_charge_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_charge_paid_by` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_transaction_id` bigint(20) NOT NULL,
  `client_charge_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_client_charge_paid_by_m_client_charge` (`client_charge_id`),
  KEY `FK_m_client_charge_paid_by_m_client_transaction` (`client_transaction_id`),
  CONSTRAINT `FK_m_client_charge_paid_by_m_client_charge` FOREIGN KEY (`client_charge_id`) REFERENCES `m_client_charge` (`id`),
  CONSTRAINT `FK_m_client_charge_paid_by_m_client_transaction` FOREIGN KEY (`client_transaction_id`) REFERENCES `m_client_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_collateral_management` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` decimal(20,5) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `collateral_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fkClient` (`client_id`),
  KEY `fkCollateral` (`collateral_id`),
  CONSTRAINT `fkClient` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fkCollateral` FOREIGN KEY (`collateral_id`) REFERENCES `m_collateral_management` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_collateral_management_additional_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_collateral_id` bigint(20) NOT NULL,
  `UPI_NO` varchar(200) DEFAULT NULL,
  `chassis_no` varchar(200) DEFAULT NULL,
  `collateral_owner_first` varchar(200) NOT NULL,
  `id_no_of_collateral_owner_first` varchar(200) NOT NULL,
  `collateral_owner_second` varchar(200) DEFAULT NULL,
  `id_no_of_collateral_owner_second` varchar(200) DEFAULT NULL,
  `worth_of_collateral` decimal(19,6) DEFAULT NULL,
  `province_cv_id` int(11) DEFAULT NULL,
  `district_cv_id` int(11) DEFAULT NULL,
  `sector_cv_id` int(11) DEFAULT NULL,
  `cell_cv_id` int(11) DEFAULT NULL,
  `village_cv_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `client_collateral_additional_details_Fk_client_collateral_id` (`client_collateral_id`),
  KEY `FK_province_cv_id_m_code_value_id` (`province_cv_id`),
  KEY `FK_district_cv_id_m_code_value_id` (`district_cv_id`),
  KEY `FK_sector_cv_id_m_code_value_id` (`sector_cv_id`),
  KEY `FK_cell_cv_id_m_code_value_id` (`cell_cv_id`),
  KEY `FK_village_cv_id_m_code_value_id` (`village_cv_id`),
  CONSTRAINT `FK_cell_cv_id_m_code_value_id` FOREIGN KEY (`cell_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_district_cv_id_m_code_value_id` FOREIGN KEY (`district_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_province_cv_id_m_code_value_id` FOREIGN KEY (`province_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_sector_cv_id_m_code_value_id` FOREIGN KEY (`sector_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_village_cv_id_m_code_value_id` FOREIGN KEY (`village_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_collateral_additional_details_Fk_client_collateral_id` FOREIGN KEY (`client_collateral_id`) REFERENCES `m_client_collateral_management` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_household_expenses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) DEFAULT NULL,
  `food_expenses_amount` bigint(20) DEFAULT NULL,
  `school_fees_amount` bigint(20) DEFAULT NULL,
  `rent_amount` bigint(20) DEFAULT NULL,
  `utilities_amount` bigint(20) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `lastmodified_date` datetime DEFAULT current_timestamp(),
  `external_id` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_identifier` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `document_type_id` int(11) NOT NULL,
  `document_key` varchar(50) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 300,
  `active` int(11) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_identifier_key` (`document_type_id`,`document_key`),
  UNIQUE KEY `unique_active_client_identifier` (`client_id`,`document_type_id`,`active`),
  KEY `FK_m_client_document_m_client` (`client_id`),
  KEY `FK_m_client_document_m_code_value` (`document_type_id`),
  KEY `idx_m_client_identifier_document_key` (`document_key`),
  CONSTRAINT `FK_m_client_document_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_client_document_m_code_value` FOREIGN KEY (`document_type_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_non_person` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `constitution_cv_id` int(11) NOT NULL,
  `incorp_no` varchar(50) DEFAULT NULL,
  `incorp_validity_till` datetime DEFAULT NULL,
  `main_business_line_cv_id` int(11) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `in_business_since` date DEFAULT NULL,
  `is_registered` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_id` (`client_id`),
  CONSTRAINT `FK_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_other_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `year_arrived_in_country_cv_id` int(11) DEFAULT NULL,
  `strata_cv_id` int(11) NOT NULL,
  `nationality_cv_id` int(11) DEFAULT NULL,
  `number_of_children` int(11) DEFAULT NULL,
  `number_of_dependents` int(11) DEFAULT NULL,
  `co_signors` varchar(200) DEFAULT NULL,
  `guarantor` varchar(200) DEFAULT NULL,
  `year_arrived_in_country` date DEFAULT NULL,
  `national_identification_number` varchar(255) DEFAULT NULL,
  `passport_number` varchar(255) DEFAULT NULL,
  `bank_account_number` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_id` bigint(20) DEFAULT NULL,
  `business_location` varchar(200) DEFAULT NULL,
  `tax_identification_number` bigint(20) DEFAULT NULL,
  `income_generating_activity` bigint(20) DEFAULT NULL,
  `income_generating_activity_monthly_amount` bigint(20) DEFAULT NULL,
  `telephone_no` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `co_signors_constraint` (`co_signors`),
  KEY `client_other_info_Fk_m_client_id` (`client_id`),
  KEY `FK_client_other_info_m_code_value_year_arrived_in_country_cv_id` (`year_arrived_in_country_cv_id`),
  KEY `FK_client_other_info_m_code_value_strata_id` (`strata_cv_id`),
  KEY `FK_client_other_info_m_code_value_nationality_cv_id` (`nationality_cv_id`),
  KEY `idx_client_other_info_bank_id` (`bank_id`),
  CONSTRAINT `FK_client_other_info_m_code_value_nationality_cv_id` FOREIGN KEY (`nationality_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_client_other_info_m_code_value_strata_id` FOREIGN KEY (`strata_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_client_other_info_m_code_value_year_arrived_in_country_cv_id` FOREIGN KEY (`year_arrived_in_country_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_other_info_Fk_m_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `fk_client_bank_id` FOREIGN KEY (`bank_id`) REFERENCES `ref_banks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_recruitment_survey` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `survey_name` varchar(200) NOT NULL,
  `start_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `end_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `country_cv_id` int(11) NOT NULL,
  `cohort_cv_id` int(11) NOT NULL,
  `program_cv_id` int(11) NOT NULL,
  `survey_location_cv_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `client_recruitment_survey_Fk_m_client_id` (`client_id`),
  KEY `FK_client_recruitment_survey_m_code_value_cohort_cv_id` (`cohort_cv_id`),
  KEY `FK_client_recruitment_survey_m_code_value_program_cv_id` (`program_cv_id`),
  KEY `FK_client_recruitment_survey_m_code_value_country_cv_id` (`country_cv_id`),
  KEY `FK_m_client_recruitment_location_cv_id` (`survey_location_cv_id`),
  CONSTRAINT `FK_client_recruitment_survey_m_code_value_cohort_cv_id` FOREIGN KEY (`cohort_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_client_recruitment_survey_m_code_value_country_cv_id` FOREIGN KEY (`country_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_client_recruitment_survey_m_code_value_program_cv_id` FOREIGN KEY (`program_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_m_client_recruitment_location_cv_id` FOREIGN KEY (`survey_location_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_recruitment_survey_Fk_m_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `payment_detail_id` bigint(20) DEFAULT NULL,
  `is_reversed` bit(1) NOT NULL,
  `external_id` varchar(50) DEFAULT NULL,
  `transaction_date` date NOT NULL,
  `transaction_type_enum` smallint(6) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `created_date` datetime NOT NULL,
  `appuser_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FK_m_client_transaction_m_appuser` (`appuser_id`),
  KEY `FK_m_client_transaction_m_client` (`client_id`),
  CONSTRAINT `FK_m_client_transaction_m_appuser` FOREIGN KEY (`appuser_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_client_transaction_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_transaction_limit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) DEFAULT NULL,
  `client_level_id` bigint(20) DEFAULT NULL,
  `daily_withdraw_limit` bigint(20) DEFAULT NULL,
  `single_withdraw_limit` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_client_transfer_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `from_office_id` bigint(20) NOT NULL,
  `to_office_id` bigint(20) NOT NULL,
  `proposed_transfer_date` date DEFAULT NULL,
  `transfer_type` tinyint(4) NOT NULL,
  `submitted_on` date NOT NULL,
  `submitted_by` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_client_transfer_details_m_appuser` (`submitted_by`),
  KEY `FK_m_client_transfer_details_m_client` (`client_id`),
  KEY `FK_m_client_transfer_details_m_office` (`from_office_id`),
  KEY `FK_m_client_transfer_details_m_office_2` (`to_office_id`),
  CONSTRAINT `FK_m_client_transfer_details_m_appuser` FOREIGN KEY (`submitted_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_client_transfer_details_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_client_transfer_details_m_office` FOREIGN KEY (`from_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_client_transfer_details_m_office_2` FOREIGN KEY (`to_office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code_name` varchar(100) DEFAULT NULL,
  `is_system_defined` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_name` (`code_name`),
  KEY `idx_m_code_code_name` (`code_name`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_code_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code_id` int(11) NOT NULL,
  `code_value` varchar(100) DEFAULT NULL,
  `code_description` varchar(500) DEFAULT NULL,
  `order_position` int(11) NOT NULL DEFAULT 0,
  `code_score` int(11) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `is_mandatory` bit(1) NOT NULL DEFAULT b'0',
  `external_code` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_value` (`code_id`,`code_value`),
  KEY `FKCFCEA42640BE071Z` (`code_id`),
  KEY `idx_m_code_value_code_active_order` (`code_id`,`is_active`,`order_position`),
  CONSTRAINT `FKCFCEA42640BE071Z` FOREIGN KEY (`code_id`) REFERENCES `m_code` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=305 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_collateral_management` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `quality` varchar(40) NOT NULL,
  `base_price` decimal(20,5) NOT NULL,
  `unit_type` varchar(10) NOT NULL,
  `pct_to_base` decimal(20,5) NOT NULL,
  `currency` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fkCurrencyCode` (`currency`),
  CONSTRAINT `fkCurrencyCode` FOREIGN KEY (`currency`) REFERENCES `m_currency` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_crb_posting_logger` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(255) NOT NULL,
  `has_passed` bit(1) DEFAULT b'0',
  `loan_id` int(11) DEFAULT NULL,
  `crb_response_id` varchar(255) DEFAULT NULL,
  `error_logs` text DEFAULT NULL,
  `pay_load` text DEFAULT NULL,
  `date` date DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_crb_posting_logger-created_by` (`created_by`),
  KEY `FK_m_crb_posting_logger-lastmodifiedby_id` (`last_modified_by`),
  KEY `idx_m_crb_posting_logger_date` (`date`),
  KEY `idx_m_crb_posting_logger_loan_id` (`loan_id`),
  KEY `idx_m_crb_posting_logger_batch_id` (`batch_id`),
  CONSTRAINT `FK_m_crb_posting_logger-created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_crb_posting_logger-lastmodifiedby_id` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_creditbureau` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `product` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `implementation_key` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique impl` (`name`,`product`,`country`,`implementation_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_creditbureau_configuration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `configkey` varchar(50) DEFAULT NULL,
  `value` longtext DEFAULT NULL,
  `organisation_creditbureau_id` bigint(20) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mcbconfig` (`configkey`,`organisation_creditbureau_id`),
  KEY `cbConfigfk1` (`organisation_creditbureau_id`),
  CONSTRAINT `cbConfigfk1` FOREIGN KEY (`organisation_creditbureau_id`) REFERENCES `m_creditbureau` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_creditbureau_loanproduct_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `organisation_creditbureau_id` bigint(20) NOT NULL,
  `loan_product_id` bigint(20) NOT NULL,
  `is_creditcheck_mandatory` bit(1) DEFAULT NULL,
  `skip_creditcheck_in_failure` bit(1) DEFAULT NULL,
  `stale_period` int(11) DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cblpunique_key` (`organisation_creditbureau_id`,`loan_product_id`),
  KEY `fk_cb_lp2` (`loan_product_id`),
  CONSTRAINT `cblpfk2` FOREIGN KEY (`organisation_creditbureau_id`) REFERENCES `m_organisation_creditbureau` (`id`),
  CONSTRAINT `fk_cb_lp2` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_creditbureau_token` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) DEFAULT NULL,
  `token` mediumtext DEFAULT NULL,
  `token_type` varchar(128) DEFAULT NULL,
  `expires_in` varchar(128) DEFAULT NULL,
  `issued` varchar(128) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_creditreport` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `credit_bureau_id` bigint(20) DEFAULT NULL,
  `national_id` varchar(128) DEFAULT NULL,
  `credit_reports` blob DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cbId` (`credit_bureau_id`),
  CONSTRAINT `cbId` FOREIGN KEY (`credit_bureau_id`) REFERENCES `m_creditbureau` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_currency` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(3) NOT NULL,
  `decimal_places` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `display_symbol` varchar(10) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `internationalized_name_code` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=165 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_deposit_account_on_hold_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `transaction_type_enum` smallint(6) NOT NULL,
  `transaction_date` date NOT NULL,
  `is_reversed` bit(1) NOT NULL DEFAULT b'0',
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_deposit_on_hold_transaction_m_savings_account` (`savings_account_id`),
  CONSTRAINT `FK_deposit_on_hold_transaction_m_savings_account` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_deposit_account_recurring_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL DEFAULT 0,
  `mandatory_recommended_deposit_amount` decimal(19,6) DEFAULT NULL,
  `is_mandatory` bit(1) NOT NULL DEFAULT b'0',
  `allow_withdrawal` bit(1) NOT NULL DEFAULT b'0',
  `adjust_advance_towards_future_payments` bit(1) NOT NULL DEFAULT b'1',
  `is_calendar_inherited` bit(1) NOT NULL DEFAULT b'0',
  `total_overdue_amount` decimal(19,6) DEFAULT NULL,
  `no_of_overdue_installments` int(11) DEFAULT NULL,
  `allow_free_withdrawal` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FKDARD00000000000001` (`savings_account_id`),
  CONSTRAINT `FKDARD00000000000001` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_deposit_account_term_and_preclosure` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL DEFAULT 0,
  `min_deposit_term` int(11) DEFAULT NULL,
  `max_deposit_term` int(11) DEFAULT NULL,
  `min_deposit_term_type_enum` smallint(6) DEFAULT NULL,
  `max_deposit_term_type_enum` smallint(6) DEFAULT NULL,
  `in_multiples_of_deposit_term` int(11) DEFAULT NULL,
  `in_multiples_of_deposit_term_type_enum` smallint(6) DEFAULT NULL,
  `pre_closure_penal_applicable` bit(1) DEFAULT NULL,
  `pre_closure_penal_interest` decimal(19,6) DEFAULT NULL,
  `pre_closure_penal_interest_on_enum` smallint(6) DEFAULT NULL,
  `deposit_period` int(11) DEFAULT NULL,
  `deposit_period_frequency_enum` smallint(6) DEFAULT NULL,
  `deposit_amount` decimal(19,6) DEFAULT NULL,
  `maturity_amount` decimal(19,6) DEFAULT NULL,
  `maturity_date` date DEFAULT NULL,
  `on_account_closure_enum` smallint(6) DEFAULT NULL,
  `expected_firstdepositon_date` date DEFAULT NULL,
  `transfer_interest_to_linked_account` bit(1) NOT NULL DEFAULT b'0',
  `transfer_to_savings_account_id` bigint(20) DEFAULT NULL,
  `interest_carried_forward_on_top_up` decimal(19,6) DEFAULT NULL,
  `auto_rollover` bit(1) NOT NULL DEFAULT b'0',
  `pre_closure_charge_applicable` bit(1) NOT NULL DEFAULT b'0',
  `allow_partial_liquidation` bit(1) DEFAULT NULL,
  `total_liquidation_allowed` int(11) DEFAULT NULL,
  `linked_origin_account_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKDATP00000000000001` (`savings_account_id`),
  KEY `transfer_to_savings_account_id` (`transfer_to_savings_account_id`),
  KEY `FK_linked_origin_m_savings` (`linked_origin_account_id`),
  CONSTRAINT `FKDATP00000000000001` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `FK_linked_origin_m_savings` FOREIGN KEY (`linked_origin_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `m_deposit_account_term_and_preclosure_ibfk_1` FOREIGN KEY (`transfer_to_savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_deposit_product_interest_rate_chart` (
  `deposit_product_id` bigint(20) NOT NULL,
  `interest_rate_chart_id` bigint(20) NOT NULL,
  UNIQUE KEY `deposit_product_id_interest_rate_chart_id` (`deposit_product_id`,`interest_rate_chart_id`),
  KEY `FKDPIRC00000000000002` (`interest_rate_chart_id`),
  CONSTRAINT `FKDPIRC00000000000001` FOREIGN KEY (`deposit_product_id`) REFERENCES `m_savings_product` (`id`),
  CONSTRAINT `FKDPIRC00000000000002` FOREIGN KEY (`interest_rate_chart_id`) REFERENCES `m_interest_rate_chart` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_deposit_product_recurring_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_product_id` bigint(20) NOT NULL DEFAULT 0,
  `is_mandatory` bit(1) NOT NULL DEFAULT b'1',
  `allow_withdrawal` bit(1) NOT NULL DEFAULT b'0',
  `adjust_advance_towards_future_payments` bit(1) NOT NULL DEFAULT b'1',
  `allow_free_withdrawal` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FKDPRD00000000000001` (`savings_product_id`),
  CONSTRAINT `FKDPRD00000000000001` FOREIGN KEY (`savings_product_id`) REFERENCES `m_savings_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_deposit_product_term_and_preclosure` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_product_id` bigint(20) NOT NULL DEFAULT 0,
  `min_deposit_term` int(11) DEFAULT NULL,
  `max_deposit_term` int(11) DEFAULT NULL,
  `min_deposit_term_type_enum` smallint(6) DEFAULT NULL,
  `max_deposit_term_type_enum` smallint(6) DEFAULT NULL,
  `in_multiples_of_deposit_term` int(11) DEFAULT NULL,
  `in_multiples_of_deposit_term_type_enum` smallint(6) DEFAULT NULL,
  `pre_closure_penal_applicable` bit(1) DEFAULT NULL,
  `pre_closure_penal_interest` decimal(19,6) DEFAULT NULL,
  `pre_closure_penal_interest_on_enum` smallint(6) DEFAULT NULL,
  `min_deposit_amount` decimal(19,6) DEFAULT NULL,
  `max_deposit_amount` decimal(19,6) DEFAULT NULL,
  `deposit_amount` decimal(19,6) DEFAULT NULL,
  `pre_closure_charge_applicable` bit(1) NOT NULL DEFAULT b'0',
  `pre_closure_charge_id` bigint(20) DEFAULT NULL,
  `allow_partial_liquidation` bit(1) DEFAULT NULL,
  `total_liquidation_allowed` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKDPTP00000000000001` (`savings_product_id`),
  KEY `m_deposit_product_term_and_preclosure_charge_ibfk_1` (`pre_closure_charge_id`),
  CONSTRAINT `FKDPTP00000000000001` FOREIGN KEY (`savings_product_id`) REFERENCES `m_savings_product` (`id`),
  CONSTRAINT `m_deposit_product_term_and_preclosure_charge_ibfk_1` FOREIGN KEY (`pre_closure_charge_id`) REFERENCES `m_charge` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_disbursement_provider` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_disbursement_provider_appuser_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `appuser_id` bigint(20) NOT NULL,
  `disbursement_provider_code` varchar(50) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_disbursement_provider_appuser` (`appuser_id`),
  KEY `idx_disb_provider_appuser_code_active` (`disbursement_provider_code`,`is_active`),
  CONSTRAINT `fk_disb_provider_appuser_appuser` FOREIGN KEY (`appuser_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_document` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_entity_type` varchar(50) NOT NULL,
  `parent_entity_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(250) NOT NULL,
  `file_name` varchar(250) NOT NULL,
  `size` int(11) DEFAULT 0,
  `type` varchar(500) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `location` varchar(500) NOT NULL DEFAULT '0',
  `storage_type_enum` smallint(6) DEFAULT NULL,
  `is_kiva_profile_image` bit(1) DEFAULT b'0',
  `document_type_cv_id` int(11) DEFAULT NULL,
  `data_migration_loan_number` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_entity_datatable_check` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `application_table_name` varchar(200) NOT NULL,
  `x_registered_table_name` varchar(50) NOT NULL,
  `status_enum` int(11) NOT NULL,
  `system_defined` bit(1) NOT NULL DEFAULT b'0',
  `product_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entity_check` (`application_table_name`,`x_registered_table_name`,`status_enum`,`product_id`),
  KEY `product_id` (`product_id`),
  KEY `x_registered_table_name` (`x_registered_table_name`),
  CONSTRAINT `m_entity_datatable_check_ibfk_1` FOREIGN KEY (`x_registered_table_name`) REFERENCES `x_registered_table` (`registered_table_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_entity_relation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `from_entity_type` int(11) NOT NULL,
  `to_entity_type` int(11) NOT NULL,
  `code_name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `from_entity_type_to_entity_type_code_name` (`from_entity_type`,`to_entity_type`,`code_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_entity_to_entity_access` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` bigint(20) NOT NULL,
  `access_type_code_value_id` int(11) NOT NULL,
  `second_entity_type` varchar(50) NOT NULL,
  `second_entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_uniq_m_entity_to_entity_access` (`entity_type`,`entity_id`,`access_type_code_value_id`,`second_entity_type`,`second_entity_id`),
  KEY `FK_access_type_code_m_code_value` (`access_type_code_value_id`),
  KEY `IDX_OFFICE` (`entity_type`,`entity_id`),
  CONSTRAINT `FK_access_type_code_m_code_value` FOREIGN KEY (`access_type_code_value_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_entity_to_entity_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rel_id` bigint(20) NOT NULL DEFAULT 0,
  `from_id` bigint(20) NOT NULL DEFAULT 0,
  `to_id` bigint(20) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rel_id_from_id_to_id` (`rel_id`,`from_id`,`to_id`),
  CONSTRAINT `FK__rel_id_m_entity_relation_id` FOREIGN KEY (`rel_id`) REFERENCES `m_entity_relation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_external_organization_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_id` bigint(20) NOT NULL,
  `external_system` varchar(50) NOT NULL,
  `external_id` varchar(100) NOT NULL,
  `external_name` varchar(150) NOT NULL,
  `currency_code` varchar(10) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ext_org_mapping_office_system` (`office_id`,`external_system`),
  KEY `idx_ext_org_mapping_system_active` (`external_system`,`is_active`),
  CONSTRAINT `fk_ext_org_mapping_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_failed_client_creation_on_data_migration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_Id` bigint(20) NOT NULL DEFAULT 1,
  `external_Id` varchar(100) NOT NULL,
  `client_type` int(11) NOT NULL,
  `firstname` varchar(255) NOT NULL,
  `lastname` varchar(255) NOT NULL,
  `error_msg` text DEFAULT NULL,
  `json_object` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_failed_client_creation_on_data_migration_office` (`office_Id`),
  CONSTRAINT `FK_m_failed_client_creation_on_data_migration_office` FOREIGN KEY (`office_Id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_failed_loan_creation_on_data_migration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_Id` mediumtext DEFAULT NULL,
  `odoo_loan_number` varchar(100) NOT NULL,
  `odoo_loan_id` varchar(50) DEFAULT NULL,
  `amount` decimal(19,6) DEFAULT NULL,
  `error_msg` text DEFAULT NULL,
  `json_object` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `odoo_loan_number` (`odoo_loan_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_failed_loan_repayment_on_data_migration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `transaction_amount` decimal(19,6) DEFAULT NULL,
  `note` varchar(255) NOT NULL,
  `transaction_date` varchar(20) DEFAULT NULL,
  `payment_type` int(11) DEFAULT NULL,
  `error_msg` text DEFAULT NULL,
  `json_object` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `note` (`note`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_family_member_identifier` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `family_member_id` bigint(20) NOT NULL,
  `document_type_id` int(11) NOT NULL,
  `document_key` varchar(50) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 300,
  `active` int(11) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_family_members` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `qualification` varchar(50) DEFAULT NULL,
  `relationship_cv_id` int(11) NOT NULL,
  `marital_status_cv_id` int(11) DEFAULT NULL,
  `gender_cv_id` int(11) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `profession_cv_id` int(11) DEFAULT NULL,
  `mobile_number` varchar(50) DEFAULT NULL,
  `is_dependent` bit(1) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address_type_id` int(11) DEFAULT NULL,
  `address1` varchar(200) DEFAULT NULL,
  `address2` varchar(200) DEFAULT NULL,
  `address3` varchar(200) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `state_province_id` int(11) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `postal_code` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_family_members_client_id_m_client` (`client_id`),
  KEY `FK_m_family_members_gender_m_code_value` (`gender_cv_id`),
  KEY `FK_m_family_members_marital_status_m_code_value` (`marital_status_cv_id`),
  KEY `FK_m_family_members_profession_m_code_value` (`profession_cv_id`),
  KEY `FK_m_family_members_relationship_m_code_value` (`relationship_cv_id`),
  KEY `client_family_Fk_m_address_type_id` (`address_type_id`),
  KEY `client_family_Fk_m_city_id` (`city_id`),
  KEY `client_family_Fk_m_state_province_id` (`state_province_id`),
  KEY `client_family_Fk_m_country_id` (`country_id`),
  CONSTRAINT `FK_m_family_members_client_id_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_family_members_gender_m_code_value` FOREIGN KEY (`gender_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_family_members_marital_status_m_code_value` FOREIGN KEY (`marital_status_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_family_members_profession_m_code_value` FOREIGN KEY (`profession_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_family_members_relationship_m_code_value` FOREIGN KEY (`relationship_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_family_Fk_m_address_type_id` FOREIGN KEY (`address_type_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_family_Fk_m_city_id` FOREIGN KEY (`city_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_family_Fk_m_country_id` FOREIGN KEY (`country_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `client_family_Fk_m_state_province_id` FOREIGN KEY (`state_province_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_fee_charge_slab` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `charge_id` bigint(20) NOT NULL,
  `description` text DEFAULT NULL,
  `period_type_enum` int(11) DEFAULT NULL,
  `from_period` int(11) DEFAULT NULL,
  `to_period` int(11) DEFAULT NULL,
  `value` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_charge_id_charge_slab_id` (`charge_id`),
  CONSTRAINT `FK_charge_id_charge_slab_id` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_field_configuration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity` varchar(100) NOT NULL,
  `subentity` varchar(100) NOT NULL,
  `field` varchar(100) NOT NULL,
  `is_enabled` bit(1) NOT NULL,
  `is_mandatory` bit(1) NOT NULL,
  `validation_regex` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_floating_rates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `is_base_lending_rate` bit(1) NOT NULL DEFAULT b'0',
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `createdby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_floating_rates_periods` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `floating_rates_id` bigint(20) NOT NULL,
  `from_date` datetime NOT NULL,
  `interest_rate` decimal(19,6) NOT NULL,
  `is_differential_to_base_lending_rate` bit(1) NOT NULL DEFAULT b'0',
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `createdby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mappings_m_floating_rates` (`floating_rates_id`),
  CONSTRAINT `FK_mappings_m_floating_rates` FOREIGN KEY (`floating_rates_id`) REFERENCES `m_floating_rates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_fund` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `external_id` (`external_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_id` varchar(100) DEFAULT NULL,
  `status_enum` int(11) NOT NULL DEFAULT 300,
  `activation_date` date DEFAULT NULL,
  `office_id` bigint(20) NOT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `level_id` int(11) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `hierarchy` varchar(100) DEFAULT NULL,
  `closure_reason_cv_id` int(11) DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `activatedon_userid` bigint(20) DEFAULT NULL,
  `submittedon_date` date DEFAULT NULL,
  `submittedon_userid` bigint(20) DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `account_no` varchar(20) NOT NULL,
  `representative_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`display_name`,`level_id`),
  UNIQUE KEY `external_id` (`external_id`),
  UNIQUE KEY `uk_m_group_external_id` (`external_id`,`level_id`),
  KEY `FK_m_group_level` (`level_id`),
  KEY `FK_m_group_m_code` (`closure_reason_cv_id`),
  KEY `Parent_Id_reference` (`parent_id`),
  KEY `group_office_id` (`office_id`),
  KEY `staff_id` (`staff_id`),
  KEY `FK_m_group-m_client-representative_id` (`representative_id`),
  KEY `idx_m_group_account_no` (`account_no`),
  KEY `idx_m_group_display_name` (`display_name`),
  CONSTRAINT `FK_m_group-m_client-representative_id` FOREIGN KEY (`representative_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_group_level` FOREIGN KEY (`level_id`) REFERENCES `m_group_level` (`id`),
  CONSTRAINT `FK_m_group_m_code` FOREIGN KEY (`closure_reason_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_group_m_staff` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`),
  CONSTRAINT `Parent_Id_reference` FOREIGN KEY (`parent_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `m_group_ibfk_1` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_group_client` (
  `group_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  PRIMARY KEY (`group_id`,`client_id`),
  KEY `client_id` (`client_id`),
  CONSTRAINT `m_group_client_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `m_group_client_ibfk_2` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_group_level` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `super_parent` bit(1) NOT NULL,
  `level_name` varchar(100) NOT NULL,
  `recursable` bit(1) NOT NULL,
  `can_have_clients` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Parent_levelId_reference` (`parent_id`),
  CONSTRAINT `Parent_levelId_reference` FOREIGN KEY (`parent_id`) REFERENCES `m_group_level` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_group_roles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `role_cv_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQUE_GROUP_ROLES` (`client_id`,`group_id`,`role_cv_id`),
  KEY `FKGroupRoleClientId` (`client_id`),
  KEY `FKGroupRoleGroupId` (`group_id`),
  KEY `FK_grouprole_m_codevalue` (`role_cv_id`),
  CONSTRAINT `FKGroupRoleClientId` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FKGroupRoleGroupId` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FK_grouprole_m_codevalue` FOREIGN KEY (`role_cv_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_guarantor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `client_reln_cv_id` int(11) DEFAULT NULL,
  `type_enum` smallint(6) NOT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `address_line_1` varchar(500) DEFAULT NULL,
  `address_line_2` varchar(500) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `zip` varchar(20) DEFAULT NULL,
  `house_phone_number` varchar(20) DEFAULT NULL,
  `mobile_number` varchar(20) DEFAULT NULL,
  `comment` varchar(500) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `is_pep` bit(1) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `bvn` varchar(255) DEFAULT NULL,
  `gender_id_cv` bigint(20) DEFAULT NULL,
  `middlename` varchar(255) DEFAULT NULL,
  `client_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_guarantor_m_code_value` (`client_reln_cv_id`),
  KEY `FK_m_guarantor_m_loan` (`loan_id`),
  CONSTRAINT `FK_m_guarantor_m_code_value` FOREIGN KEY (`client_reln_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_guarantor_m_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_guarantor_funding_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `guarantor_id` bigint(20) NOT NULL,
  `account_associations_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `amount_released_derived` decimal(19,6) DEFAULT NULL,
  `amount_remaining_derived` decimal(19,6) DEFAULT NULL,
  `amount_transfered_derived` decimal(19,6) DEFAULT NULL,
  `status_enum` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_guarantor_fund_details_account_associations_id` (`account_associations_id`),
  KEY `FK_m_guarantor_fund_details_m_guarantor` (`guarantor_id`),
  CONSTRAINT `FK_m_guarantor_fund_details_account_associations_id` FOREIGN KEY (`account_associations_id`) REFERENCES `m_portfolio_account_associations` (`id`),
  CONSTRAINT `FK_m_guarantor_fund_details_m_guarantor` FOREIGN KEY (`guarantor_id`) REFERENCES `m_guarantor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_guarantor_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `guarantor_fund_detail_id` bigint(20) NOT NULL,
  `loan_transaction_id` bigint(20) DEFAULT NULL,
  `deposit_on_hold_transaction_id` bigint(20) NOT NULL,
  `is_reversed` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FK_guarantor_transaction_guarantor_fund_detail` (`guarantor_fund_detail_id`),
  KEY `FK_guarantor_transaction_m_deposit_account_on_hold_transaction` (`deposit_on_hold_transaction_id`),
  KEY `FK_guarantor_transaction_m_loan_transaction` (`loan_transaction_id`),
  CONSTRAINT `FK_guarantor_transaction_guarantor_fund_detail` FOREIGN KEY (`guarantor_fund_detail_id`) REFERENCES `m_guarantor_funding_details` (`id`),
  CONSTRAINT `FK_guarantor_transaction_m_deposit_account_on_hold_transaction` FOREIGN KEY (`deposit_on_hold_transaction_id`) REFERENCES `m_deposit_account_on_hold_transaction` (`id`),
  CONSTRAINT `FK_guarantor_transaction_m_loan_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_holiday` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `from_date` datetime NOT NULL,
  `to_date` datetime NOT NULL,
  `repayments_rescheduled_to` datetime DEFAULT NULL,
  `status_enum` int(11) NOT NULL DEFAULT 100,
  `processed` bit(1) NOT NULL DEFAULT b'0',
  `description` varchar(100) DEFAULT NULL,
  `rescheduling_type` int(11) NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`),
  UNIQUE KEY `holiday_name` (`name`,`from_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_holiday_office` (
  `holiday_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  PRIMARY KEY (`holiday_id`,`office_id`),
  KEY `m_holiday_id_ibfk_1` (`holiday_id`),
  KEY `m_office_id_ibfk_2` (`office_id`),
  CONSTRAINT `m_holiday_id_ibfk_1` FOREIGN KEY (`holiday_id`) REFERENCES `m_holiday` (`id`),
  CONSTRAINT `m_office_id_ibfk_2` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_hook` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `template_id` smallint(6) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `name` varchar(45) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `ugd_template_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_template_id_idx` (`template_id`),
  KEY `fk_ugd_template_id` (`ugd_template_id`),
  CONSTRAINT `fk_template_id` FOREIGN KEY (`template_id`) REFERENCES `m_hook_templates` (`id`),
  CONSTRAINT `fk_ugd_template_id` FOREIGN KEY (`ugd_template_id`) REFERENCES `m_template` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_hook_configuration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `hook_id` bigint(20) DEFAULT NULL,
  `field_type` varchar(45) NOT NULL,
  `field_name` varchar(100) NOT NULL,
  `field_value` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_hook_configuration_hook` (`hook_id`),
  CONSTRAINT `fk_hook_id_cfg` FOREIGN KEY (`hook_id`) REFERENCES `m_hook` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_hook_registered_events` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `hook_id` bigint(20) NOT NULL,
  `entity_name` varchar(45) NOT NULL,
  `action_name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_hook_id_idx` (`hook_id`),
  CONSTRAINT `fk_hook_idc` FOREIGN KEY (`hook_id`) REFERENCES `m_hook` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_hook_schema` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `hook_template_id` smallint(6) NOT NULL,
  `field_type` varchar(45) NOT NULL,
  `field_name` varchar(100) NOT NULL,
  `placeholder` varchar(100) DEFAULT NULL,
  `optional` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_hook_template_id_idx` (`hook_template_id`),
  CONSTRAINT `fk_hook_template_id` FOREIGN KEY (`hook_template_id`) REFERENCES `m_hook_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_hook_templates` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_ic_review_level_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `level_number` int(11) NOT NULL,
  `level_name` varchar(100) NOT NULL,
  `level_code` varchar(50) NOT NULL,
  `decision_state_value` int(11) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `display_order` int(11) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `level_code` (`level_code`),
  UNIQUE KEY `decision_state_value` (`decision_state_value`),
  KEY `FK_m_ic_review_level_config-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_ic_review_level_config-created_by` (`createdby_id`),
  CONSTRAINT `FK_m_ic_review_level_config-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_ic_review_level_config-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_image` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `location` varchar(500) DEFAULT NULL,
  `storage_type_enum` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_import_document` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `document_id` int(11) NOT NULL,
  `import_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `entity_type` tinyint(4) NOT NULL,
  `completed` bit(1) DEFAULT b'0',
  `total_records` bigint(20) DEFAULT 0,
  `success_count` bigint(20) DEFAULT 0,
  `failure_count` bigint(20) DEFAULT 0,
  `createdby_id` bigint(20) DEFAULT NULL,
  `failure_message` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_import_m_appuser` (`createdby_id`),
  KEY `import_document_id` (`document_id`),
  CONSTRAINT `FK_m_import_m_appuser` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_import_m_document` FOREIGN KEY (`document_id`) REFERENCES `m_document` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_interest_incentives` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `interest_rate_slab_id` bigint(20) NOT NULL,
  `entiry_type` smallint(6) NOT NULL,
  `attribute_name` smallint(6) NOT NULL,
  `condition_type` smallint(6) NOT NULL,
  `attribute_value` varchar(50) NOT NULL,
  `incentive_type` smallint(6) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_interest_incentives_m_interest_rate_slab` (`interest_rate_slab_id`),
  CONSTRAINT `FK_m_interest_incentives_m_interest_rate_slab` FOREIGN KEY (`interest_rate_slab_id`) REFERENCES `m_interest_rate_slab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_interest_rate_chart` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `from_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `is_primary_grouping_by_amount` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_interest_rate_slab` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `interest_rate_chart_id` bigint(20) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `period_type_enum` smallint(6) DEFAULT NULL,
  `from_period` int(11) DEFAULT NULL,
  `to_period` int(11) DEFAULT NULL,
  `amount_range_from` decimal(19,6) DEFAULT NULL,
  `amount_range_to` decimal(19,6) DEFAULT NULL,
  `annual_interest_rate` decimal(19,6) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKIRS00000000000001` (`interest_rate_chart_id`),
  CONSTRAINT `FKIRS00000000000001` FOREIGN KEY (`interest_rate_chart_id`) REFERENCES `m_interest_rate_chart` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_kiva_currencies` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `language` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_kiva_loan_awaiting_approval` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `borrower_count` int(11) DEFAULT NULL,
  `internal_loan_id` varchar(255) DEFAULT NULL,
  `internal_client_id` varchar(255) DEFAULT NULL,
  `partner_id` varchar(255) DEFAULT NULL,
  `partner` varchar(255) DEFAULT NULL,
  `kiva_id` varchar(255) DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `loan_price` varchar(255) DEFAULT NULL,
  `loan_local_price` varchar(255) DEFAULT NULL,
  `loan_currency` varchar(255) DEFAULT NULL,
  `create_time` int(11) DEFAULT NULL,
  `ended_time` int(11) DEFAULT NULL,
  `refunded_time` int(11) DEFAULT NULL,
  `expired_time` int(11) DEFAULT NULL,
  `defaulted_time` int(11) DEFAULT NULL,
  `planned_expiration_time` int(11) DEFAULT NULL,
  `planned_inactive_expire_time` int(11) DEFAULT NULL,
  `delinquent` bit(1) DEFAULT NULL,
  `issue_feedback_time` int(11) DEFAULT NULL,
  `issue_reported_by` int(11) DEFAULT NULL,
  `flexible_fundraising_enabled` varchar(255) DEFAULT NULL,
  `funded_amount` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_kiva_locations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country` varchar(100) NOT NULL,
  `location` varchar(100) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_kiva_posting_logger` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(255) NOT NULL,
  `has_passed` bit(1) DEFAULT b'0',
  `loan_id` bigint(20) DEFAULT NULL,
  `loan_account_no` varchar(100) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `failure_stage` varchar(100) DEFAULT NULL,
  `failure_category` varchar(100) DEFAULT NULL,
  `kiva_response_id` varchar(255) DEFAULT NULL,
  `error_logs` text DEFAULT NULL,
  `pay_load` text DEFAULT NULL,
  `date` date DEFAULT NULL,
  `created_by` bigint(20) NOT NULL,
  `last_modified_by` bigint(20) NOT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_kiva_posting_logger_created_by` (`created_by`),
  KEY `FK_m_kiva_posting_logger_last_modified_by` (`last_modified_by`),
  KEY `idx_m_kiva_posting_logger_batch_id` (`batch_id`),
  KEY `idx_m_kiva_posting_logger_loan_id` (`loan_id`),
  KEY `idx_m_kiva_posting_logger_category` (`failure_category`),
  CONSTRAINT `FK_m_kiva_posting_logger_created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_kiva_posting_logger_last_modified_by` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_kiva_sector_activity` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `activity_id` bigint(20) NOT NULL,
  `sector_name` varchar(100) NOT NULL,
  `activity_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=164 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_kiva_themes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `theme_id` bigint(20) NOT NULL,
  `theme_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_no` varchar(20) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `glim_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `fund_id` bigint(20) DEFAULT NULL,
  `loan_officer_id` bigint(20) DEFAULT NULL,
  `loanpurpose_cv_id` int(11) DEFAULT NULL,
  `loan_status_id` smallint(6) NOT NULL,
  `loan_type_enum` smallint(6) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `principal_amount_proposed` decimal(19,6) NOT NULL,
  `principal_amount` decimal(19,6) NOT NULL,
  `approved_icreview` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `approved_principal` decimal(19,6) NOT NULL,
  `net_disbursal_amount` decimal(19,6) NOT NULL,
  `arrearstolerance_amount` decimal(19,6) DEFAULT NULL,
  `is_floating_interest_rate` bit(1) DEFAULT b'0',
  `interest_rate_differential` decimal(19,6) DEFAULT 0.000000,
  `nominal_interest_rate_per_period` decimal(19,6) DEFAULT NULL,
  `interest_period_frequency_enum` smallint(6) DEFAULT NULL,
  `annual_nominal_interest_rate` decimal(19,6) DEFAULT NULL,
  `interest_method_enum` smallint(6) NOT NULL,
  `interest_calculated_in_period_enum` smallint(6) NOT NULL DEFAULT 1,
  `allow_partial_period_interest_calcualtion` bit(1) NOT NULL DEFAULT b'0',
  `term_frequency` smallint(6) NOT NULL DEFAULT 0,
  `term_period_frequency_enum` smallint(6) NOT NULL DEFAULT 2,
  `repay_every` smallint(6) NOT NULL,
  `repayment_period_frequency_enum` smallint(6) NOT NULL,
  `number_of_repayments` smallint(6) NOT NULL,
  `grace_on_principal_periods` smallint(6) DEFAULT NULL,
  `recurring_moratorium_principal_periods` smallint(6) DEFAULT NULL,
  `grace_on_interest_periods` smallint(6) DEFAULT NULL,
  `grace_interest_free_periods` smallint(6) DEFAULT NULL,
  `amortization_method_enum` smallint(6) NOT NULL,
  `submittedon_date` date DEFAULT NULL,
  `approvedon_date` date DEFAULT NULL,
  `approvedon_userid` bigint(20) DEFAULT NULL,
  `expected_disbursedon_date` date DEFAULT NULL,
  `expected_firstrepaymenton_date` date DEFAULT NULL,
  `interest_calculated_from_date` date DEFAULT NULL,
  `disbursedon_date` date DEFAULT NULL,
  `disbursedon_userid` bigint(20) DEFAULT NULL,
  `expected_maturedon_date` date DEFAULT NULL,
  `maturedon_date` date DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `total_charges_due_at_disbursement_derived` decimal(19,6) DEFAULT NULL,
  `principal_disbursed_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `principal_repaid_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `principal_writtenoff_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `principal_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `interest_charged_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `interest_repaid_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `interest_waived_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `interest_writtenoff_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `interest_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `fee_charges_charged_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `fee_charges_repaid_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `fee_charges_waived_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `fee_charges_writtenoff_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `fee_charges_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `penalty_charges_charged_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `penalty_charges_repaid_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `penalty_charges_waived_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `penalty_charges_writtenoff_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `penalty_charges_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_expected_repayment_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_repayment_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_expected_costofloan_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_costofloan_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_waived_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_writtenoff_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_overpaid_derived` decimal(19,6) DEFAULT NULL,
  `rejectedon_date` date DEFAULT NULL,
  `rejectedon_userid` bigint(20) DEFAULT NULL,
  `rescheduledon_date` date DEFAULT NULL,
  `rescheduledon_userid` bigint(20) DEFAULT NULL,
  `withdrawnon_date` date DEFAULT NULL,
  `withdrawnon_userid` bigint(20) DEFAULT NULL,
  `writtenoffon_date` date DEFAULT NULL,
  `loan_transaction_strategy_id` bigint(20) DEFAULT NULL,
  `sync_disbursement_with_meeting` bit(1) DEFAULT NULL,
  `loan_counter` smallint(6) DEFAULT NULL,
  `loan_product_counter` smallint(6) DEFAULT NULL,
  `fixed_emi_amount` decimal(19,6) DEFAULT NULL,
  `max_outstanding_loan_balance` decimal(19,6) DEFAULT NULL,
  `grace_on_arrears_ageing` smallint(6) DEFAULT NULL,
  `is_npa` bit(1) NOT NULL DEFAULT b'0',
  `total_recovered_derived` decimal(19,6) DEFAULT NULL,
  `accrued_till` date DEFAULT NULL,
  `interest_recalcualated_on` date DEFAULT NULL,
  `days_in_month_enum` smallint(6) NOT NULL DEFAULT 1,
  `days_in_year_enum` smallint(6) NOT NULL DEFAULT 1,
  `interest_recalculation_enabled` bit(1) NOT NULL DEFAULT b'0',
  `guarantee_amount_derived` decimal(19,6) DEFAULT NULL,
  `create_standing_instruction_at_disbursement` bit(1) DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `writeoff_reason_cv_id` int(11) DEFAULT NULL,
  `loan_sub_status_id` smallint(6) DEFAULT NULL,
  `is_topup` bit(1) NOT NULL DEFAULT b'0',
  `is_equal_amortization` bit(1) NOT NULL DEFAULT b'0',
  `fixed_principal_percentage_per_installment` decimal(5,2) DEFAULT NULL,
  `created_on_utc` datetime DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` datetime DEFAULT NULL,
  `is_loan_term_includes_topped_up_loan_term` bit(1) NOT NULL DEFAULT b'0',
  `total_extensions` int(11) DEFAULT NULL,
  `is_bnpl_loan` bit(1) DEFAULT b'0',
  `requires_equity_contribution` bit(1) DEFAULT b'0',
  `equity_contribution_loan_percentage` decimal(19,6) DEFAULT NULL,
  `department_cv_id` int(11) DEFAULT NULL,
  `loan_decision_state` int(11) DEFAULT NULL,
  `last_repayment_amount` decimal(19,6) DEFAULT NULL,
  `last_repayment_date` date DEFAULT NULL,
  `kiva_id` varchar(255) DEFAULT NULL,
  `kiva_uuid` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `stop_consumer_credit_upload_to_trans_union` bit(1) DEFAULT b'0',
  `stop_consumer_credit_upload_to_trans_union_on` timestamp NULL DEFAULT current_timestamp(),
  `generic_loan_counter` int(11) DEFAULT NULL,
  `application_date` date DEFAULT NULL,
  `office_id` bigint(20) DEFAULT NULL,
  `third_party_disbursement_provider` varchar(50) DEFAULT NULL,
  `loan_with_another_institution_amount` decimal(19,6) DEFAULT NULL,
  `interest_cancelled_derived` decimal(19,6) DEFAULT NULL,
  `is_migrated` bit(1) NOT NULL DEFAULT b'0',
  `migrated_on_date` date DEFAULT NULL,
  `migrated_from_office_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_no` (`account_no`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FK7C885877240145` (`fund_id`),
  KEY `FKB6F935D87179A0CB` (`client_id`),
  KEY `FKB6F935D8C8D4B434` (`product_id`),
  KEY `FK_approvedon_userid` (`approvedon_userid`),
  KEY `FK_closedon_userid` (`closedon_userid`),
  KEY `FK_disbursedon_userid` (`disbursedon_userid`),
  KEY `FK_glim_id` (`glim_id`),
  KEY `FK_loan_ltp_strategy` (`loan_transaction_strategy_id`),
  KEY `FK_m_loan_m_staff` (`loan_officer_id`),
  KEY `FK_m_loanpurpose_codevalue` (`loanpurpose_cv_id`),
  KEY `FK_rejectedon_userid` (`rejectedon_userid`),
  KEY `FK_withdrawnon_userid` (`withdrawnon_userid`),
  KEY `FK_writeoffreason_m_loan_m_code_value` (`writeoff_reason_cv_id`),
  KEY `fk_m_group_client_001_idx` (`group_id`,`client_id`),
  KEY `group_id` (`group_id`),
  KEY `FK_loan_created_by` (`created_by`),
  KEY `FK_loan_last_modified_by` (`last_modified_by`),
  KEY `FK_m_loan_m_code_value_department_cv_id` (`department_cv_id`),
  KEY `fk_loan_office_id` (`office_id`),
  KEY `idx_m_loan_status` (`loan_status_id`),
  KEY `idx_m_loan_status_client` (`loan_status_id`,`client_id`),
  KEY `FK_m_loan_migrated_from_office` (`migrated_from_office_id`),
  CONSTRAINT `FK7C885877240145` FOREIGN KEY (`fund_id`) REFERENCES `m_fund` (`id`),
  CONSTRAINT `FKB6F935D87179A0CB` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FKB6F935D8C8D4B434` FOREIGN KEY (`product_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `FK_approvedon_userid` FOREIGN KEY (`approvedon_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_closedon_userid` FOREIGN KEY (`closedon_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_disbursedon_userid` FOREIGN KEY (`disbursedon_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_glim_id` FOREIGN KEY (`glim_id`) REFERENCES `glim_accounts` (`id`),
  CONSTRAINT `FK_loan_created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_loan_last_modified_by` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_loan_ltp_strategy` FOREIGN KEY (`loan_transaction_strategy_id`) REFERENCES `ref_loan_transaction_processing_strategy` (`id`),
  CONSTRAINT `FK_m_loan_m_code_value_department_cv_id` FOREIGN KEY (`department_cv_id`) REFERENCES `m_code_value` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_m_loan_m_staff` FOREIGN KEY (`loan_officer_id`) REFERENCES `m_staff` (`id`),
  CONSTRAINT `FK_m_loan_migrated_from_office` FOREIGN KEY (`migrated_from_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_loanpurpose_codevalue` FOREIGN KEY (`loanpurpose_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_rejectedon_userid` FOREIGN KEY (`rejectedon_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_withdrawnon_userid` FOREIGN KEY (`withdrawnon_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_writeoffreason_m_loan_m_code_value` FOREIGN KEY (`writeoff_reason_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `fk_loan_office_id` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `m_loan_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_approval_matrix` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `currency` varchar(10) NOT NULL,
  `level_one_unsecured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_one_unsecured_first_cycle_min_term` int(11) NOT NULL,
  `level_one_unsecured_first_cycle_max_term` int(11) NOT NULL,
  `level_one_unsecured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_one_unsecured_second_cycle_min_term` int(11) NOT NULL,
  `level_one_unsecured_second_cycle_max_term` int(11) NOT NULL,
  `level_one_secured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_one_secured_first_cycle_min_term` int(11) NOT NULL,
  `level_one_secured_first_cycle_max_term` int(11) NOT NULL,
  `level_one_secured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_one_secured_second_cycle_min_term` int(11) NOT NULL,
  `level_one_secured_second_cycle_max_term` int(11) NOT NULL,
  `level_two_unsecured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_two_unsecured_first_cycle_min_term` int(11) NOT NULL,
  `level_two_unsecured_first_cycle_max_term` int(11) NOT NULL,
  `level_two_unsecured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_two_unsecured_second_cycle_min_term` int(11) NOT NULL,
  `level_two_unsecured_second_cycle_max_term` int(11) NOT NULL,
  `level_two_secured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_two_secured_first_cycle_min_term` int(11) NOT NULL,
  `level_two_secured_first_cycle_max_term` int(11) NOT NULL,
  `level_two_secured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_two_secured_second_cycle_min_term` int(11) NOT NULL,
  `level_two_secured_second_cycle_max_term` int(11) NOT NULL,
  `level_three_unsecured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_three_unsecured_first_cycle_min_term` int(11) NOT NULL,
  `level_three_unsecured_first_cycle_max_term` int(11) NOT NULL,
  `level_three_unsecured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_three_unsecured_second_cycle_min_term` int(11) NOT NULL,
  `level_three_unsecured_second_cycle_max_term` int(11) NOT NULL,
  `level_three_secured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_three_secured_first_cycle_min_term` int(11) NOT NULL,
  `level_three_secured_first_cycle_max_term` int(11) NOT NULL,
  `level_three_secured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_three_secured_second_cycle_min_term` int(11) NOT NULL,
  `level_three_secured_second_cycle_max_term` int(11) NOT NULL,
  `level_four_unsecured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_four_unsecured_first_cycle_min_term` int(11) NOT NULL,
  `level_four_unsecured_first_cycle_max_term` int(11) NOT NULL,
  `level_four_unsecured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_four_unsecured_second_cycle_min_term` int(11) NOT NULL,
  `level_four_unsecured_second_cycle_max_term` int(11) NOT NULL,
  `level_four_secured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_four_secured_first_cycle_min_term` int(11) NOT NULL,
  `level_four_secured_first_cycle_max_term` int(11) NOT NULL,
  `level_four_secured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_four_secured_second_cycle_min_term` int(11) NOT NULL,
  `level_four_secured_second_cycle_max_term` int(11) NOT NULL,
  `level_five_unsecured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_five_unsecured_first_cycle_min_term` int(11) NOT NULL,
  `level_five_unsecured_first_cycle_max_term` int(11) NOT NULL,
  `level_five_unsecured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_five_unsecured_second_cycle_min_term` int(11) NOT NULL,
  `level_five_unsecured_second_cycle_max_term` int(11) NOT NULL,
  `level_five_secured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_five_secured_first_cycle_min_term` int(11) NOT NULL,
  `level_five_secured_first_cycle_max_term` int(11) NOT NULL,
  `level_five_secured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `level_five_secured_second_cycle_min_term` int(11) NOT NULL,
  `level_five_secured_second_cycle_max_term` int(11) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_approval_matrix-created_by` (`createdby_id`),
  KEY `FK_m_loan_approval_matrix-lastmodifiedby_id` (`lastmodifiedby_id`),
  CONSTRAINT `FK_m_loan_approval_matrix-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_approval_matrix-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_approval_matrix_level` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `approval_matrix_id` bigint(20) NOT NULL,
  `ic_review_level_id` bigint(20) NOT NULL,
  `level_number` int(11) NOT NULL,
  `unsecured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `unsecured_first_cycle_min_term` int(11) NOT NULL,
  `unsecured_first_cycle_max_term` int(11) NOT NULL,
  `unsecured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `unsecured_second_cycle_min_term` int(11) NOT NULL,
  `unsecured_second_cycle_max_term` int(11) NOT NULL,
  `secured_first_cycle_max_amount` decimal(19,6) NOT NULL,
  `secured_first_cycle_min_term` int(11) NOT NULL,
  `secured_first_cycle_max_term` int(11) NOT NULL,
  `secured_second_cycle_max_amount` decimal(19,6) NOT NULL,
  `secured_second_cycle_min_term` int(11) NOT NULL,
  `secured_second_cycle_max_term` int(11) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_approval_matrix_level` (`approval_matrix_id`,`ic_review_level_id`),
  KEY `FK_approval_matrix_level-ic_level_id` (`ic_review_level_id`),
  KEY `FK_m_loan_approval_matrix_level-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_loan_approval_matrix_level-created_by` (`createdby_id`),
  CONSTRAINT `FK_approval_matrix_level-ic_level_id` FOREIGN KEY (`ic_review_level_id`) REFERENCES `m_ic_review_level_config` (`id`),
  CONSTRAINT `FK_approval_matrix_level-matrix_id` FOREIGN KEY (`approval_matrix_id`) REFERENCES `m_loan_approval_matrix` (`id`),
  CONSTRAINT `FK_m_loan_approval_matrix_level-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_approval_matrix_level-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_arrears_aging` (
  `loan_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `principal_overdue_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `interest_overdue_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `fee_charges_overdue_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `penalty_charges_overdue_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_overdue_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `overdue_since_date_derived` date DEFAULT NULL,
  PRIMARY KEY (`loan_id`),
  CONSTRAINT `m_loan_arrears_aging_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_cashflow_projection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `schedule_id` bigint(20) NOT NULL,
  `cashflow_info_id` bigint(20) NOT NULL,
  `projection_rate` int(11) NOT NULL,
  `amount` decimal(30,6) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_repayment_schedule_cashflow` (`schedule_id`),
  KEY `FK_m_loan_cashflow_projection-created_by` (`createdby_id`),
  KEY `FK_m_loan_cashflow_projection-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_loan_cashflow_information_info_id` (`cashflow_info_id`),
  CONSTRAINT `FK_loan_cashflow_information_info_id` FOREIGN KEY (`cashflow_info_id`) REFERENCES `loan_cashflow_information` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_m_loan_cashflow_projection-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_cashflow_projection-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  `is_penalty` bit(1) NOT NULL DEFAULT b'0',
  `charge_time_enum` smallint(6) NOT NULL,
  `due_for_collection_as_of_date` date DEFAULT NULL,
  `charge_calculation_enum` smallint(6) NOT NULL,
  `charge_payment_mode_enum` smallint(6) NOT NULL DEFAULT 0,
  `calculation_percentage` decimal(19,6) DEFAULT NULL,
  `calculation_on_amount` decimal(19,6) DEFAULT NULL,
  `charge_amount_or_percentage` decimal(19,6) DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `amount_paid_derived` decimal(19,6) DEFAULT NULL,
  `amount_waived_derived` decimal(19,6) DEFAULT NULL,
  `amount_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `is_paid_derived` bit(1) NOT NULL DEFAULT b'0',
  `waived` bit(1) NOT NULL DEFAULT b'0',
  `min_cap` decimal(19,6) DEFAULT NULL,
  `max_cap` decimal(19,6) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `external_id` varchar(100) DEFAULT NULL,
  `min_amount` decimal(19,6) DEFAULT NULL,
  `max_amount` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `charge_id` (`charge_id`),
  KEY `m_loan_charge_ibfk_2` (`loan_id`),
  KEY `idx_m_loan_charge_loan_penalty_active` (`loan_id`,`is_penalty`,`is_active`),
  KEY `idx_mlc_pmr` (`loan_id`,`is_active`,`is_penalty`,`due_for_collection_as_of_date`,`amount`),
  CONSTRAINT `m_loan_charge_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `m_loan_charge_ibfk_2` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_charge_paid_by` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_transaction_id` bigint(20) NOT NULL,
  `loan_charge_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `installment_number` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK__m_loan_charge` (`loan_charge_id`),
  KEY `FK__m_loan_transaction` (`loan_transaction_id`),
  CONSTRAINT `FK__m_loan_charge` FOREIGN KEY (`loan_charge_id`) REFERENCES `m_loan_charge` (`id`),
  CONSTRAINT `FK__m_loan_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_classification` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `classification_code` smallint(6) DEFAULT NULL,
  `status` varchar(40) NOT NULL,
  `source` varchar(40) NOT NULL,
  `days_in_arrears` int(11) DEFAULT NULL,
  `country_cv_id` int(11) DEFAULT NULL,
  `error_message` varchar(1000) DEFAULT NULL,
  `excluded_from_downstream` bit(1) NOT NULL DEFAULT b'0',
  `override_active` bit(1) NOT NULL DEFAULT b'0',
  `override_reason` varchar(500) DEFAULT NULL,
  `override_by` bigint(20) DEFAULT NULL,
  `override_on_utc` timestamp NULL DEFAULT NULL,
  `classified_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `classified_by` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_loan_classification_loan` (`loan_id`),
  KEY `idx_loan_classification_status` (`status`),
  KEY `idx_loan_classification_country` (`country_cv_id`),
  CONSTRAINT `fk_loan_classification_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `chk_loan_classification_code` CHECK (`classification_code` is null or `classification_code` between 1 and 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_classification_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `old_classification` smallint(6) DEFAULT NULL,
  `new_classification` smallint(6) DEFAULT NULL,
  `old_status` varchar(40) DEFAULT NULL,
  `new_status` varchar(40) NOT NULL,
  `source` varchar(40) NOT NULL,
  `days_in_arrears` int(11) DEFAULT NULL,
  `country_cv_id` int(11) DEFAULT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `error_message` varchar(1000) DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_loan_classification_audit_loan_created` (`loan_id`,`created_on_utc`),
  CONSTRAINT `fk_loan_classification_audit_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_classification_code` (
  `code` smallint(6) NOT NULL,
  `label` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_classification_country_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country_cv_id` int(11) NOT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_loan_classification_country` (`country_cv_id`),
  CONSTRAINT `fk_loan_classification_country_cv` FOREIGN KEY (`country_cv_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_classification_job_run` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `started_on_utc` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `completed_on_utc` timestamp NULL DEFAULT NULL,
  `processed_count` int(11) DEFAULT 0,
  `classified_count` int(11) DEFAULT 0,
  `flagged_count` int(11) DEFAULT 0,
  `skipped_override_count` int(11) DEFAULT 0,
  `error_log` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_classification_threshold` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country_config_id` bigint(20) NOT NULL,
  `classification_code` smallint(6) NOT NULL,
  `min_days_in_arrears` int(11) NOT NULL,
  `max_days_in_arrears` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_loan_classification_threshold_code` (`classification_code`),
  KEY `idx_loan_classification_threshold_config` (`country_config_id`),
  CONSTRAINT `fk_loan_classification_threshold_code` FOREIGN KEY (`classification_code`) REFERENCES `m_loan_classification_code` (`code`),
  CONSTRAINT `fk_loan_classification_threshold_config` FOREIGN KEY (`country_config_id`) REFERENCES `m_loan_classification_country_config` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_collateral` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `type_cv_id` int(11) NOT NULL,
  `value` decimal(19,6) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_collateral_code_value` (`type_cv_id`),
  KEY `FK_collateral_m_loan` (`loan_id`),
  CONSTRAINT `FK_collateral_code_value` FOREIGN KEY (`type_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_collateral_m_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_collateral_management` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` decimal(20,5) NOT NULL,
  `loan_id` bigint(20) DEFAULT NULL,
  `client_collateral_id` bigint(20) DEFAULT NULL,
  `is_released` bit(1) DEFAULT b'0',
  `transaction_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fkClientCollateral` (`client_collateral_id`),
  KEY `fkLoan` (`loan_id`),
  KEY `fkTransaction` (`transaction_id`),
  CONSTRAINT `fkClientCollateral` FOREIGN KEY (`client_collateral_id`) REFERENCES `m_client_collateral_management` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fkLoan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fkTransaction` FOREIGN KEY (`transaction_id`) REFERENCES `m_loan_transaction` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_daily_late_fee` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  `loan_charge_id` bigint(20) DEFAULT NULL,
  `penalty_date` date NOT NULL,
  `overdue_principal_amount` decimal(19,6) NOT NULL,
  `monthly_rate` decimal(19,6) NOT NULL,
  `daily_rate` decimal(19,12) NOT NULL,
  `penalty_amount` decimal(19,6) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_m_loan_daily_late_fee` (`loan_id`,`charge_id`,`penalty_date`),
  KEY `idx_m_loan_daily_late_fee_loan_date` (`loan_id`,`penalty_date`),
  KEY `idx_m_loan_daily_late_fee_loan_charge` (`loan_charge_id`),
  KEY `fk_m_loan_daily_late_fee_charge` (`charge_id`),
  KEY `idx_m_loan_daily_late_fee_loan_active` (`loan_id`,`is_active`),
  CONSTRAINT `fk_m_loan_daily_late_fee_charge` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `fk_m_loan_daily_late_fee_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `fk_m_loan_daily_late_fee_loan_charge` FOREIGN KEY (`loan_charge_id`) REFERENCES `m_loan_charge` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_decision` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `review_application_note` text DEFAULT NULL,
  `is_review_application_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_review_application` bit(1) NOT NULL DEFAULT b'0',
  `review_application_on` date DEFAULT NULL,
  `review_application_by` bigint(20) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `loan_decision_state` int(11) NOT NULL,
  `due_diligence_note` text DEFAULT NULL,
  `is_due_diligence_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_due_diligence` bit(1) NOT NULL DEFAULT b'0',
  `due_diligence_on` date DEFAULT NULL,
  `due_diligence_by` bigint(20) DEFAULT NULL,
  `collateral_review_note` text DEFAULT NULL,
  `is_collateral_review_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_collateral_review` bit(1) NOT NULL DEFAULT b'0',
  `collateral_review_on` date DEFAULT NULL,
  `collateral_review_by` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_one_note` text DEFAULT NULL,
  `is_ic_review_decision_level_one_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_ic_review_decision_level_one` bit(1) NOT NULL DEFAULT b'0',
  `ic_review_decision_level_one_on` date DEFAULT NULL,
  `ic_review_decision_level_one_by` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_one_recommended_amount` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_one_term_frequency` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_one_term_period_frequency_enum` smallint(6) DEFAULT NULL,
  `next_loan_ic_review_decision_state` int(11) DEFAULT NULL,
  `ic_review_decision_level_two_note` text DEFAULT NULL,
  `is_ic_review_decision_level_two_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_ic_review_decision_level_two` bit(1) NOT NULL DEFAULT b'0',
  `ic_review_decision_level_two_on` date DEFAULT NULL,
  `ic_review_decision_level_two_by` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_two_recommended_amount` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_two_term_frequency` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_two_term_period_frequency_enum` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_three_note` text DEFAULT NULL,
  `is_ic_review_decision_level_three_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_ic_review_decision_level_three` bit(1) NOT NULL DEFAULT b'0',
  `ic_review_decision_level_three_on` date DEFAULT NULL,
  `ic_review_decision_level_three_by` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_three_recommended_amount` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_three_term_frequency` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_three_term_period_frequency_enum` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_four_note` text DEFAULT NULL,
  `is_ic_review_decision_level_four_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_ic_review_decision_level_four` bit(1) NOT NULL DEFAULT b'0',
  `ic_review_decision_level_four_on` date DEFAULT NULL,
  `ic_review_decision_level_four_by` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_four_recommended_amount` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_four_term_frequency` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_four_term_period_frequency_enum` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_five_note` text DEFAULT NULL,
  `is_ic_review_decision_level_five_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_ic_review_decision_level_five` bit(1) NOT NULL DEFAULT b'0',
  `ic_review_decision_level_five_on` date DEFAULT NULL,
  `ic_review_decision_level_five_by` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_five_recommended_amount` bigint(20) DEFAULT NULL,
  `ic_review_decision_level_five_term_frequency` smallint(6) DEFAULT NULL,
  `ic_review_decision_level_five_term_period_frequency_enum` smallint(6) DEFAULT NULL,
  `prepare_and_sign_contract_note` text DEFAULT NULL,
  `is_prepare_and_sign_contract_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_reject_prepare_and_sign_contract` bit(1) NOT NULL DEFAULT b'0',
  `prepare_and_sign_contract_on` date DEFAULT NULL,
  `prepare_and_sign_contract_by` bigint(20) DEFAULT NULL,
  `due_diligence_recommended_amount` bigint(20) DEFAULT NULL,
  `due_diligence_term_frequency` smallint(6) DEFAULT NULL,
  `due_diligence_term_period_frequency_type` smallint(6) DEFAULT NULL,
  `is_idea_client` bit(1) DEFAULT b'0',
  `is_crb_verification_required` bit(1) DEFAULT b'1',
  `previous_loan_ic_review_decision_state` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `loan_id` (`loan_id`),
  KEY `FK_m_loan_decision-m_appuser-review_application_by` (`review_application_by`),
  KEY `FK_m_loan_decision-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_loan_decision-created_by` (`createdby_id`),
  KEY `FK_m_loan_decision-m_appuser-due_diligence_by` (`due_diligence_by`),
  KEY `FK_m_loan_decision-m_appuser-collateral_review_by` (`collateral_review_by`),
  KEY `FK_m_loan_decision-m_appuser-ic_review_decision_level_one_by` (`ic_review_decision_level_one_by`),
  KEY `FK_m_loan_decision-m_appuser-ic_review_decision_level_two_by` (`ic_review_decision_level_two_by`),
  KEY `FK_m_loan_decision-m_appuser-ic_review_decision_level_three_by` (`ic_review_decision_level_three_by`),
  KEY `FK_m_loan_decision-m_appuser-ic_review_decision_level_four_by` (`ic_review_decision_level_four_by`),
  KEY `FK_m_loan_decision-m_appuser-ic_review_decision_level_five_by` (`ic_review_decision_level_five_by`),
  KEY `FK_m_loan_decision-m_appuser-prepare_and_sign_contract_by` (`prepare_and_sign_contract_by`),
  KEY `idx_m_loan_decision_loan_id` (`loan_id`),
  CONSTRAINT `FK_m_loan_decision-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-collateral_review_by` FOREIGN KEY (`collateral_review_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-due_diligence_by` FOREIGN KEY (`due_diligence_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-ic_review_decision_level_five_by` FOREIGN KEY (`ic_review_decision_level_five_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-ic_review_decision_level_four_by` FOREIGN KEY (`ic_review_decision_level_four_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-ic_review_decision_level_one_by` FOREIGN KEY (`ic_review_decision_level_one_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-ic_review_decision_level_three_by` FOREIGN KEY (`ic_review_decision_level_three_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-ic_review_decision_level_two_by` FOREIGN KEY (`ic_review_decision_level_two_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-prepare_and_sign_contract_by` FOREIGN KEY (`prepare_and_sign_contract_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_appuser-review_application_by` FOREIGN KEY (`review_application_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision-m_loan_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_decision_level` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_decision_id` bigint(20) NOT NULL,
  `ic_review_level_id` bigint(20) NOT NULL,
  `level_number` int(11) NOT NULL,
  `note` text DEFAULT NULL,
  `is_signed` bit(1) NOT NULL DEFAULT b'0',
  `is_rejected` bit(1) NOT NULL DEFAULT b'0',
  `decision_on` date DEFAULT NULL,
  `decision_by` bigint(20) DEFAULT NULL,
  `recommended_amount` decimal(19,6) DEFAULT NULL,
  `term_frequency` int(11) DEFAULT NULL,
  `term_period_frequency_enum` int(11) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_loan_decision_level` (`loan_decision_id`,`ic_review_level_id`),
  KEY `FK_m_loan_decision_level-created_by` (`createdby_id`),
  KEY `FK_m_loan_decision_level-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_loan_decision_level-ic_level_id` (`ic_review_level_id`),
  KEY `FK_loan_decision_level-decision_by` (`decision_by`),
  CONSTRAINT `FK_loan_decision_level-decision_by` FOREIGN KEY (`decision_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_loan_decision_level-decision_id` FOREIGN KEY (`loan_decision_id`) REFERENCES `m_loan_decision` (`id`),
  CONSTRAINT `FK_loan_decision_level-ic_level_id` FOREIGN KEY (`ic_review_level_id`) REFERENCES `m_ic_review_level_config` (`id`),
  CONSTRAINT `FK_m_loan_decision_level-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_decision_level-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_disbursement_charge_adjustment_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `loan_charge_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  `original_transaction_id` bigint(20) NOT NULL,
  `adjustment_transaction_id` bigint(20) DEFAULT NULL,
  `previous_amount` decimal(19,6) NOT NULL,
  `new_amount` decimal(19,6) NOT NULL,
  `amount_delta` decimal(19,6) NOT NULL,
  `previous_payment_type_id` bigint(20) DEFAULT NULL,
  `previous_payment_type_name` varchar(100) DEFAULT NULL,
  `new_payment_type_id` bigint(20) DEFAULT NULL,
  `new_payment_type_name` varchar(100) DEFAULT NULL,
  `previous_payment_detail_id` bigint(20) DEFAULT NULL,
  `new_payment_detail_id` bigint(20) DEFAULT NULL,
  `previous_fund_source_gl_account_id` bigint(20) DEFAULT NULL,
  `new_fund_source_gl_account_id` bigint(20) DEFAULT NULL,
  `previous_income_gl_account_id` bigint(20) DEFAULT NULL,
  `new_income_gl_account_id` bigint(20) DEFAULT NULL,
  `reason` varchar(1000) NOT NULL,
  `adjustedby_id` bigint(20) NOT NULL,
  `adjustedby_username` varchar(100) NOT NULL,
  `adjustedby_roles` varchar(1000) DEFAULT NULL,
  `adjusted_on_date` datetime NOT NULL,
  `charge_paid_by_backfilled` bit(1) NOT NULL DEFAULT b'0',
  `correction_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ldca_audit_loan` (`loan_id`),
  KEY `idx_ldca_audit_transaction` (`original_transaction_id`),
  KEY `idx_ldca_audit_adjusted_on` (`adjusted_on_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_disbursement_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `expected_disburse_date` datetime NOT NULL,
  `disbursedon_date` datetime DEFAULT NULL,
  `principal` decimal(19,6) NOT NULL,
  `net_disbursal_amount` decimal(19,6) DEFAULT NULL,
  `payment_type_id` int(11) DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `check_number` varchar(100) DEFAULT NULL,
  `routing_code` varchar(100) DEFAULT NULL,
  `receipt_number` varchar(100) DEFAULT NULL,
  `bank_number` varchar(100) DEFAULT NULL,
  `client_bank_name` varchar(100) DEFAULT NULL,
  `client_account_number` varchar(100) DEFAULT NULL,
  `client_phone_number` varchar(50) DEFAULT NULL,
  `payment_to` int(11) NOT NULL DEFAULT 1,
  `beneficiary_name` varchar(255) DEFAULT NULL,
  `mfi_code` varchar(100) DEFAULT NULL,
  `disbursement_type` varchar(20) DEFAULT 'CLIENT',
  `fx_rate` decimal(19,6) DEFAULT NULL,
  `usd_amount` decimal(19,6) DEFAULT NULL,
  `fx_source` varchar(100) DEFAULT NULL,
  `fx_timestamp` datetime DEFAULT NULL,
  `budget_location` varchar(255) DEFAULT NULL,
  `budget_review_required` bit(1) DEFAULT NULL,
  `supplier_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_disbursement_detail_loan_id` (`loan_id`),
  KEY `fk_m_loan_disbursement_detail_payment_type` (`payment_type_id`),
  CONSTRAINT `FK_loan_disbursement_detail_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `fk_m_loan_disbursement_detail_payment_type` FOREIGN KEY (`payment_type_id`) REFERENCES `m_payment_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_disbursement_instruction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `disbursement_provider_code` varchar(50) NOT NULL,
  `supplier_id` bigint(20) DEFAULT NULL,
  `supplier_external_id` varchar(100) NOT NULL,
  `status` varchar(50) NOT NULL,
  `idempotency_key` varchar(100) NOT NULL,
  `request_hash` varchar(128) DEFAULT NULL,
  `loan_disbursement_detail_id` bigint(20) DEFAULT NULL,
  `failure_message` varchar(1000) DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_on_date` datetime NOT NULL,
  `last_modified_on_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_loan_disb_instruction_provider_idempotency` (`disbursement_provider_code`,`idempotency_key`),
  KEY `idx_loan_disb_instruction_loan` (`loan_id`),
  KEY `idx_loan_disb_instruction_provider_status` (`disbursement_provider_code`,`status`),
  CONSTRAINT `fk_loan_disb_instruction_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_due_diligence_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_decision_id` bigint(20) NOT NULL,
  `survey_name` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `survey_location_cv_id` int(11) NOT NULL,
  `cohort_cv_id` int(11) NOT NULL,
  `program_cv_id` int(11) NOT NULL,
  `country_cv_id` int(11) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_due_diligence_info_m_code_value_cohort_cv_id` (`cohort_cv_id`),
  KEY `FK_m_loan_due_diligence_info_m_code_value_program_cv_id` (`program_cv_id`),
  KEY `FK_m_loan_due_diligence_info-m_loan_decision_loan_decision_id` (`loan_decision_id`),
  KEY `FK_m_loan_due_diligence_info_m_code_value_country_cv_id` (`country_cv_id`),
  KEY `FK_m_loan_due_diligence_info-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_loan_due_diligence_info-created_by` (`createdby_id`),
  KEY `FK_m_loan_due_diligence_info_m_code_value_survey_location_cv_id` (`survey_location_cv_id`),
  KEY `FK_m_loan_due_diligence_info-m_loan_loan_id` (`loan_id`),
  CONSTRAINT `FK_m_loan_due_diligence_info-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info-m_loan_decision_loan_decision_id` FOREIGN KEY (`loan_decision_id`) REFERENCES `m_loan_decision` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info-m_loan_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info_m_code_value_cohort_cv_id` FOREIGN KEY (`cohort_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info_m_code_value_country_cv_id` FOREIGN KEY (`country_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info_m_code_value_program_cv_id` FOREIGN KEY (`program_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `FK_m_loan_due_diligence_info_m_code_value_survey_location_cv_id` FOREIGN KEY (`survey_location_cv_id`) REFERENCES `m_code_value` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_excess_refund` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `batch_id` bigint(20) DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `payment_mode_enum` int(11) NOT NULL,
  `payment_type_id` bigint(20) DEFAULT NULL,
  `status_enum` int(11) NOT NULL,
  `beneficiary_json` longtext NOT NULL,
  `hub_request_id` varchar(100) DEFAULT NULL,
  `hub_transaction_ref` varchar(100) DEFAULT NULL,
  `manual_payment_ref` varchar(100) DEFAULT NULL,
  `paid_on` date DEFAULT NULL,
  `submitted_by` bigint(20) NOT NULL,
  `submitted_at` datetime NOT NULL,
  `approved_by` bigint(20) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejected_by` bigint(20) DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL,
  `rejection_note` longtext DEFAULT NULL,
  `posted_transaction_id` bigint(20) DEFAULT NULL,
  `failure_reason` varchar(500) DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `open_loan_key` bigint(20) GENERATED ALWAYS AS (case when `status_enum` in (100,200,300,400,450) then `loan_id` else NULL end) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_excess_refund_hub_request_id` (`hub_request_id`),
  UNIQUE KEY `uk_excess_refund_open_loan` (`open_loan_key`),
  KEY `fk_excess_refund_approved_by` (`approved_by`),
  KEY `fk_excess_refund_client` (`client_id`),
  KEY `fk_excess_refund_posted_txn` (`posted_transaction_id`),
  KEY `fk_excess_refund_submitted_by` (`submitted_by`),
  KEY `fk_excess_refund_rejected_by` (`rejected_by`),
  KEY `idx_excess_refund_loan` (`loan_id`),
  KEY `idx_excess_refund_status` (`status_enum`),
  KEY `idx_excess_refund_batch_id` (`batch_id`),
  CONSTRAINT `fk_excess_refund_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_excess_refund_batch` FOREIGN KEY (`batch_id`) REFERENCES `m_loan_excess_refund_batch` (`id`),
  CONSTRAINT `fk_excess_refund_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `fk_excess_refund_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `fk_excess_refund_posted_txn` FOREIGN KEY (`posted_transaction_id`) REFERENCES `m_loan_transaction` (`id`),
  CONSTRAINT `fk_excess_refund_rejected_by` FOREIGN KEY (`rejected_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_excess_refund_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_excess_refund_batch` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_id` bigint(20) NOT NULL,
  `submitted_by` bigint(20) NOT NULL,
  `status_enum` int(11) NOT NULL,
  `total_count` int(11) NOT NULL DEFAULT 0,
  `success_count` int(11) NOT NULL DEFAULT 0,
  `failed_count` int(11) NOT NULL DEFAULT 0,
  `submission_note` longtext DEFAULT NULL,
  `approver_id` bigint(20) DEFAULT NULL,
  `approval_note` longtext DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_excess_refund_batch_approver` (`approver_id`),
  KEY `idx_excess_refund_batch_office` (`office_id`),
  KEY `idx_excess_refund_batch_submitted_by` (`submitted_by`),
  KEY `idx_excess_refund_batch_status` (`status_enum`),
  KEY `idx_excess_refund_batch_created_at` (`created_at`),
  CONSTRAINT `fk_excess_refund_batch_approver` FOREIGN KEY (`approver_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_excess_refund_batch_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `fk_excess_refund_batch_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_historical_penalty_waiver` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `correction_reference` varchar(32) DEFAULT NULL,
  `loan_id` bigint(20) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `office_id` bigint(20) DEFAULT NULL,
  `loan_charge_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) DEFAULT NULL,
  `charge_name` varchar(200) DEFAULT NULL,
  `charge_due_date` date DEFAULT NULL,
  `penalty_age_days` int(11) DEFAULT NULL,
  `installment_number` int(11) DEFAULT NULL,
  `original_charge_amount` decimal(19,6) DEFAULT NULL,
  `amount_paid_before` decimal(19,6) DEFAULT NULL,
  `amount_waived_before` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_before` decimal(19,6) DEFAULT NULL,
  `waiver_amount` decimal(19,6) DEFAULT NULL,
  `amount_waived_after` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_after` decimal(19,6) DEFAULT NULL,
  `is_partial_waiver` bit(1) DEFAULT b'0',
  `waiver_effective_date` date DEFAULT NULL,
  `reason` varchar(1000) NOT NULL,
  `requires_approval` bit(1) DEFAULT b'0',
  `approval_trigger` varchar(20) DEFAULT NULL,
  `next_approver_id` bigint(20) DEFAULT NULL,
  `submitted_by_id` bigint(20) DEFAULT NULL,
  `submitted_on_date` datetime DEFAULT NULL,
  `approved_by_id` bigint(20) DEFAULT NULL,
  `approved_on_date` datetime DEFAULT NULL,
  `rejected_by_id` bigint(20) DEFAULT NULL,
  `rejected_on_date` datetime DEFAULT NULL,
  `decision_reason` varchar(1000) DEFAULT NULL,
  `escalated_on_date` datetime DEFAULT NULL,
  `escalated_to_id` bigint(20) DEFAULT NULL,
  `status` varchar(40) NOT NULL,
  `failure_message` varchar(1000) DEFAULT NULL,
  `waive_transaction_id` bigint(20) DEFAULT NULL,
  `reprocessed_transaction_count` int(11) DEFAULT NULL,
  `loan_status_before` smallint(6) DEFAULT NULL,
  `loan_status_after` smallint(6) DEFAULT NULL,
  `total_outstanding_before` decimal(19,6) DEFAULT NULL,
  `total_outstanding_after` decimal(19,6) DEFAULT NULL,
  `transaction_processing_strategy_id` bigint(20) DEFAULT NULL,
  `transaction_processing_strategy_name` varchar(200) DEFAULT NULL,
  `accounting_rule_type` smallint(6) DEFAULT NULL,
  `correction_date` date DEFAULT NULL,
  `gl_closure_id` bigint(20) DEFAULT NULL,
  `odoo_sync_completed_on_date` datetime DEFAULT NULL,
  `performed_by_id` bigint(20) DEFAULT NULL,
  `performed_by_username` varchar(100) DEFAULT NULL,
  `performed_by_roles` varchar(1000) DEFAULT NULL,
  `created_on_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_hpw_correction_reference` (`correction_reference`),
  KEY `idx_hpw_loan` (`loan_id`),
  KEY `idx_hpw_charge` (`loan_charge_id`),
  KEY `idx_hpw_status` (`status`),
  KEY `idx_hpw_submitted` (`submitted_on_date`),
  CONSTRAINT `fk_hpw_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_historical_penalty_waiver_txn` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `waiver_id` bigint(20) NOT NULL,
  `loan_transaction_id` bigint(20) NOT NULL,
  `txn_role` varchar(20) NOT NULL,
  `principal_before` decimal(19,6) DEFAULT NULL,
  `interest_before` decimal(19,6) DEFAULT NULL,
  `fees_before` decimal(19,6) DEFAULT NULL,
  `penalties_before` decimal(19,6) DEFAULT NULL,
  `principal_after` decimal(19,6) DEFAULT NULL,
  `interest_after` decimal(19,6) DEFAULT NULL,
  `fees_after` decimal(19,6) DEFAULT NULL,
  `penalties_after` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_hpw_txn_waiver` (`waiver_id`),
  KEY `idx_hpw_txn_transaction` (`loan_transaction_id`),
  CONSTRAINT `fk_hpw_txn_waiver` FOREIGN KEY (`waiver_id`) REFERENCES `m_loan_historical_penalty_waiver` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_installment_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_charge_id` bigint(20) NOT NULL,
  `loan_schedule_id` bigint(20) NOT NULL,
  `due_date` date DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `amount_paid_derived` decimal(19,6) DEFAULT NULL,
  `amount_waived_derived` decimal(19,6) DEFAULT NULL,
  `amount_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `is_paid_derived` bit(1) NOT NULL DEFAULT b'0',
  `waived` bit(1) NOT NULL DEFAULT b'0',
  `amount_through_charge_payment` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_charge_id_charge_schedule` (`loan_charge_id`),
  KEY `FK_loan_schedule_id_charge_schedule` (`loan_schedule_id`),
  CONSTRAINT `FK_loan_charge_id_charge_schedule` FOREIGN KEY (`loan_charge_id`) REFERENCES `m_loan_charge` (`id`),
  CONSTRAINT `FK_loan_schedule_id_charge_schedule` FOREIGN KEY (`loan_schedule_id`) REFERENCES `m_loan_repayment_schedule` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_interest_recalculation_additional_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_repayment_schedule_id` bigint(20) NOT NULL,
  `effective_date` date NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_additional_details_repayment_schedule_id` (`loan_repayment_schedule_id`),
  CONSTRAINT `FK_additional_details_repayment_schedule_id` FOREIGN KEY (`loan_repayment_schedule_id`) REFERENCES `m_loan_repayment_schedule` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_officer_assignment_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_officer_id` bigint(20) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_m_loan_officer_assignment_history_0001` (`loan_id`),
  KEY `fk_m_loan_officer_assignment_history_0002` (`loan_officer_id`),
  CONSTRAINT `fk_m_loan_officer_assignment_history_0001` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `fk_m_loan_officer_assignment_history_0002` FOREIGN KEY (`loan_officer_id`) REFERENCES `m_staff` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_overdue_installment_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_charge_id` bigint(20) NOT NULL,
  `loan_schedule_id` bigint(20) NOT NULL,
  `frequency_number` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_overdue_installment_charge_m_loan_charge` (`loan_charge_id`),
  KEY `FK_m_loan_overdue_installment_charge_m_loan_repayment_schedule` (`loan_schedule_id`),
  CONSTRAINT `FK_m_loan_overdue_installment_charge_m_loan_charge` FOREIGN KEY (`loan_charge_id`) REFERENCES `m_loan_charge` (`id`),
  CONSTRAINT `FK_m_loan_overdue_installment_charge_m_loan_repayment_schedule` FOREIGN KEY (`loan_schedule_id`) REFERENCES `m_loan_repayment_schedule` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_overdue_reminder` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `loan_product_id` bigint(20) NOT NULL,
  `loan_schedule_id` bigint(20) NOT NULL,
  `loan_repayment_reminder_settings_id` bigint(20) NOT NULL,
  `due_date` date NOT NULL,
  `installment_number` bigint(20) NOT NULL,
  `principal_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `interest_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `fees_charge_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `penalty_charge_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `total_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `total_overdue_amount` decimal(19,6) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `message_status` varchar(255) DEFAULT NULL,
  `batch_id` varchar(50) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_overdue_reminder-loan_schedule_id` (`loan_schedule_id`),
  KEY `FK_m_loan_overdue_reminder-m_loan_id` (`loan_id`),
  KEY `FK_m_loan_overdue_reminder-client_id` (`client_id`),
  KEY `FK_m_loan_overdue_reminder-loan_overdue_reminder_settings_id` (`loan_repayment_reminder_settings_id`),
  KEY `FK_m_loan_overdue_reminder-lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_loan_overdue_reminder-created_by` (`createdby_id`),
  KEY `FK_m_loan_overdue_reminder-loan_product_id` (`loan_product_id`),
  KEY `FK_m_loan_overdue_reminder-group_id` (`group_id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-group_id` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-loan_overdue_reminder_settings_id` FOREIGN KEY (`loan_repayment_reminder_settings_id`) REFERENCES `loan_overdue_reminder_settings` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-loan_product_id` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-loan_schedule_id` FOREIGN KEY (`loan_schedule_id`) REFERENCES `m_loan_repayment_schedule` (`id`),
  CONSTRAINT `FK_m_loan_overdue_reminder-m_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_rate` (
  `loan_id` bigint(20) NOT NULL,
  `rate_id` bigint(20) NOT NULL,
  PRIMARY KEY (`loan_id`,`rate_id`),
  KEY `FK_M_LOAN_RATE_RATE` (`rate_id`),
  CONSTRAINT `FK_M_LOAN_RATE_LOAN` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK_M_LOAN_RATE_RATE` FOREIGN KEY (`rate_id`) REFERENCES `m_rate` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_recalculation_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `compound_type_enum` smallint(6) NOT NULL,
  `reschedule_strategy_enum` smallint(6) NOT NULL,
  `rest_frequency_type_enum` smallint(6) NOT NULL,
  `rest_frequency_interval` smallint(6) NOT NULL DEFAULT 0,
  `compounding_frequency_type_enum` smallint(6) DEFAULT NULL,
  `compounding_frequency_interval` smallint(6) DEFAULT NULL,
  `rest_frequency_nth_day_enum` int(11) DEFAULT NULL,
  `rest_frequency_on_day` int(11) DEFAULT NULL,
  `rest_frequency_weekday_enum` int(11) DEFAULT NULL,
  `compounding_frequency_nth_day_enum` int(11) DEFAULT NULL,
  `compounding_frequency_on_day` int(11) DEFAULT NULL,
  `is_compounding_to_be_posted_as_transaction` bit(1) NOT NULL DEFAULT b'0',
  `compounding_frequency_weekday_enum` int(11) DEFAULT NULL,
  `allow_compounding_on_eod` bit(1) NOT NULL DEFAULT b'0',
  `advance_payment_interest_for_exact_days_in_period` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_m_loan_recalculation_details` (`loan_id`),
  CONSTRAINT `FK_m_loan_m_loan_recalculation_details` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_redraw_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `withdrawn_by` bigint(20) DEFAULT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `loan_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `withdrawn_on_date` datetime DEFAULT NULL,
  `redraw_balance` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Fk_redraw_account_created_by` (`createdby_id`),
  KEY `Fk_redraw_account_loan_id` (`loan_id`),
  KEY `Fk_redraw_account_last_modified_by` (`lastmodifiedby_id`),
  KEY `Fk_redraw_account_withdrawn_by` (`withdrawn_by`),
  CONSTRAINT `Fk_redraw_account_created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `Fk_redraw_account_last_modified_by` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `Fk_redraw_account_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `Fk_redraw_account_withdrawn_by` FOREIGN KEY (`withdrawn_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_repayment_reminder` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `loan_product_id` bigint(20) NOT NULL,
  `loan_schedule_id` bigint(20) NOT NULL,
  `loan_repayment_reminder_settings_id` bigint(20) NOT NULL,
  `due_date` date NOT NULL,
  `installment_number` bigint(20) NOT NULL,
  `principal_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `interest_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `fees_charge_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `penalty_charge_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `total_amount_outstanding` decimal(19,6) DEFAULT NULL,
  `total_overdue_amount` decimal(19,6) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `client_name` varchar(255) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `message_status` varchar(255) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmodified_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `batch_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_repayment_reminder-loan_product_id` (`loan_product_id`),
  KEY `FK_m_loan_repayment_reminder-created_by` (`createdby_id`),
  KEY `FK_m_loan_repayment_reminder-loan_schedule_id` (`loan_schedule_id`),
  KEY `FK_m_loan_repayment_reminder-group_id` (`group_id`),
  KEY `FK_m_loan_repayment_reminder-m_loan_id` (`loan_id`),
  KEY `FK_m_loan_repayment_reminder-client_id` (`client_id`),
  KEY `FK_m_loan_repayment_reminder-loan_repayment_reminder_settings_id` (`loan_repayment_reminder_settings_id`),
  KEY `FK_m_loan_repayment_reminder-lastmodifiedby_id` (`lastmodifiedby_id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-created_by` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-group_id` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-loan_product_id` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-loan_repayment_reminder_settings_id` FOREIGN KEY (`loan_repayment_reminder_settings_id`) REFERENCES `loan_repayment_reminder_settings` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-loan_schedule_id` FOREIGN KEY (`loan_schedule_id`) REFERENCES `m_loan_repayment_schedule` (`id`),
  CONSTRAINT `FK_m_loan_repayment_reminder-m_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_repayment_schedule` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `fromdate` date DEFAULT NULL,
  `duedate` date NOT NULL,
  `installment` smallint(6) NOT NULL,
  `principal_amount` decimal(19,6) DEFAULT NULL,
  `principal_completed_derived` decimal(19,6) DEFAULT NULL,
  `principal_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `interest_amount` decimal(19,6) DEFAULT NULL,
  `interest_completed_derived` decimal(19,6) DEFAULT NULL,
  `interest_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `interest_waived_derived` decimal(19,6) DEFAULT NULL,
  `accrual_interest_derived` decimal(19,6) DEFAULT NULL,
  `reschedule_interest_portion` decimal(19,6) DEFAULT NULL,
  `fee_charges_amount` decimal(19,6) DEFAULT NULL,
  `fee_charges_completed_derived` decimal(19,6) DEFAULT NULL,
  `fee_charges_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `fee_charges_waived_derived` decimal(19,6) DEFAULT NULL,
  `accrual_fee_charges_derived` decimal(19,6) DEFAULT NULL,
  `penalty_charges_amount` decimal(19,6) DEFAULT NULL,
  `penalty_charges_completed_derived` decimal(19,6) DEFAULT NULL,
  `penalty_charges_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `penalty_charges_waived_derived` decimal(19,6) DEFAULT NULL,
  `accrual_penalty_charges_derived` decimal(19,6) DEFAULT NULL,
  `total_paid_in_advance_derived` decimal(19,6) DEFAULT NULL,
  `total_paid_late_derived` decimal(19,6) DEFAULT NULL,
  `completed_derived` bit(1) NOT NULL,
  `obligations_met_on_date` date DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `recalculated_interest_component` bit(1) NOT NULL DEFAULT b'0',
  `interest_cancelled_derived` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK488B92AA40BE0710` (`loan_id`),
  KEY `idx_mlrs_pmr` (`loan_id`,`duedate`),
  CONSTRAINT `FK488B92AA40BE0710` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_repayment_schedule_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_reschedule_request_id` bigint(20) DEFAULT NULL,
  `fromdate` date DEFAULT NULL,
  `duedate` date NOT NULL,
  `installment` smallint(6) NOT NULL,
  `principal_amount` decimal(19,6) DEFAULT NULL,
  `interest_amount` decimal(19,6) DEFAULT NULL,
  `fee_charges_amount` decimal(19,6) DEFAULT NULL,
  `penalty_charges_amount` decimal(19,6) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `version` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `loan_id` (`loan_id`),
  KEY `loan_reschedule_request_id` (`loan_reschedule_request_id`),
  CONSTRAINT `m_loan_repayment_schedule_history_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `m_loan_repayment_schedule_history_ibfk_2` FOREIGN KEY (`loan_reschedule_request_id`) REFERENCES `m_loan_reschedule_request` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_reschedule_request` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `status_enum` smallint(6) NOT NULL,
  `reschedule_from_installment` smallint(6) NOT NULL COMMENT 'Rescheduling will start from this installment',
  `reschedule_from_date` date NOT NULL COMMENT 'Rescheduling will start from the installment with due date similar to this date.',
  `recalculate_interest` bit(1) DEFAULT NULL COMMENT 'If set to 1, interest will be recalculated starting from the reschedule period.',
  `reschedule_reason_cv_id` int(11) DEFAULT NULL COMMENT 'ID of code value of reason for rescheduling',
  `reschedule_reason_comment` varchar(500) DEFAULT NULL COMMENT 'Text provided in addition to the reason code value',
  `submitted_on_date` date NOT NULL,
  `submitted_by_user_id` bigint(20) NOT NULL,
  `approved_on_date` date DEFAULT NULL,
  `approved_by_user_id` bigint(20) DEFAULT NULL,
  `rejected_on_date` date DEFAULT NULL,
  `rejected_by_user_id` bigint(20) DEFAULT NULL,
  `charge_handling` varchar(20) DEFAULT NULL,
  `carry_forward_charge_id` bigint(20) DEFAULT NULL,
  `carry_forward_charge_due_date` date DEFAULT NULL,
  `repayment_every` int(11) DEFAULT NULL,
  `repayment_frequency_type` int(11) DEFAULT NULL,
  `preserve_loan_term_duration` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `approved_by_user_id` (`approved_by_user_id`),
  KEY `loan_reschedule_request_loan_id` (`loan_id`),
  KEY `rejected_by_user_id` (`rejected_by_user_id`),
  KEY `reschedule_reason_cv_id` (`reschedule_reason_cv_id`),
  KEY `submitted_by_user_id` (`submitted_by_user_id`),
  CONSTRAINT `m_loan_reschedule_request_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `m_loan_reschedule_request_ibfk_2` FOREIGN KEY (`reschedule_reason_cv_id`) REFERENCES `m_code_value` (`id`),
  CONSTRAINT `m_loan_reschedule_request_ibfk_3` FOREIGN KEY (`submitted_by_user_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_loan_reschedule_request_ibfk_4` FOREIGN KEY (`approved_by_user_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_loan_reschedule_request_ibfk_5` FOREIGN KEY (`rejected_by_user_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_reschedule_request_term_variations_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_reschedule_request_id` bigint(20) NOT NULL,
  `loan_term_variations_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK__m_loan_reschedule_request` (`loan_reschedule_request_id`),
  KEY `FK__m_loan_term_variations` (`loan_term_variations_id`),
  CONSTRAINT `FK__m_loan_reschedule_request` FOREIGN KEY (`loan_reschedule_request_id`) REFERENCES `m_loan_reschedule_request` (`id`),
  CONSTRAINT `FK__m_loan_term_variations` FOREIGN KEY (`loan_term_variations_id`) REFERENCES `m_loan_term_variations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_residual_adjustment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_transaction_id` bigint(20) NOT NULL,
  `signed_residual_before` decimal(19,6) NOT NULL,
  `threshold_used` decimal(19,6) NOT NULL,
  `automatic` bit(1) NOT NULL DEFAULT b'1',
  `created_by` bigint(20) DEFAULT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `loan_transaction_id` (`loan_transaction_id`),
  KEY `idx_residual_adjustment_loan` (`loan_id`),
  CONSTRAINT `fk_residual_adjustment_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `fk_residual_adjustment_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_supplier_disbursement_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_disbursement_detail_id` bigint(20) DEFAULT NULL,
  `change_source` varchar(50) NOT NULL,
  `previous_supplier_id` bigint(20) DEFAULT NULL,
  `new_supplier_id` bigint(20) DEFAULT NULL,
  `previous_payment_to` int(11) DEFAULT NULL,
  `new_payment_to` int(11) DEFAULT NULL,
  `previous_beneficiary_name` varchar(150) DEFAULT NULL,
  `new_beneficiary_name` varchar(150) DEFAULT NULL,
  `previous_client_phone_number` varchar(50) DEFAULT NULL,
  `new_client_phone_number` varchar(50) DEFAULT NULL,
  `previous_client_account_number` varchar(150) DEFAULT NULL,
  `new_client_account_number` varchar(150) DEFAULT NULL,
  `previous_client_bank_name` varchar(150) DEFAULT NULL,
  `new_client_bank_name` varchar(150) DEFAULT NULL,
  `previous_payment_type_id` bigint(20) DEFAULT NULL,
  `new_payment_type_id` bigint(20) DEFAULT NULL,
  `changed_by_id` bigint(20) DEFAULT NULL,
  `changed_by_username` varchar(100) DEFAULT NULL,
  `changed_on_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_term_variations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `term_type` smallint(6) NOT NULL,
  `applicable_date` date NOT NULL,
  `decimal_value` decimal(19,6) DEFAULT NULL,
  `date_value` date DEFAULT NULL,
  `is_specific_to_installment` bit(1) NOT NULL DEFAULT b'0',
  `applied_on_loan_status` smallint(6) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `parent_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_loan_id_m_loan_id` (`loan_id`),
  CONSTRAINT `FK_loan_id_m_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_topup` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `closure_loan_id` bigint(20) NOT NULL,
  `account_transfer_details_id` bigint(20) DEFAULT NULL,
  `topup_amount` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `m_loan_topup_FK_account_transfer_details_id` (`account_transfer_details_id`),
  KEY `m_loan_topup_FK_closure_loan_id` (`closure_loan_id`),
  KEY `m_loan_topup_FK_loan_id` (`loan_id`),
  CONSTRAINT `m_loan_topup_FK_account_transfer_details_id` FOREIGN KEY (`account_transfer_details_id`) REFERENCES `m_account_transfer_details` (`id`),
  CONSTRAINT `m_loan_topup_FK_closure_loan_id` FOREIGN KEY (`closure_loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `m_loan_topup_FK_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_tranche_charges` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_tranche_charges_m_charge` (`charge_id`),
  KEY `FK_m_loan_tranche_charges_m_loan` (`loan_id`),
  CONSTRAINT `FK_m_loan_tranche_charges_m_charge` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `FK_m_loan_tranche_charges_m_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_tranche_disbursement_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_charge_id` bigint(20) NOT NULL,
  `disbursement_detail_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_loan_tranche_disbursement_charge_m_loan_charge` (`loan_charge_id`),
  KEY `FK_m_loan_tranche_disbursement_charge_m_loan_disbursement_detail` (`disbursement_detail_id`),
  CONSTRAINT `FK_m_loan_tranche_disbursement_charge_m_loan_charge` FOREIGN KEY (`loan_charge_id`) REFERENCES `m_loan_charge` (`id`),
  CONSTRAINT `FK_m_loan_tranche_disbursement_charge_m_loan_disbursement_detail` FOREIGN KEY (`disbursement_detail_id`) REFERENCES `m_loan_disbursement_detail` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `payment_detail_id` bigint(20) DEFAULT NULL,
  `is_reversed` bit(1) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `transaction_type_enum` smallint(6) NOT NULL,
  `transaction_date` date NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `principal_portion_derived` decimal(19,6) DEFAULT NULL,
  `interest_portion_derived` decimal(19,6) DEFAULT NULL,
  `fee_charges_portion_derived` decimal(19,6) DEFAULT NULL,
  `penalty_charges_portion_derived` decimal(19,6) DEFAULT NULL,
  `overpayment_portion_derived` decimal(19,6) DEFAULT NULL,
  `unrecognized_income_portion` decimal(19,6) DEFAULT NULL,
  `outstanding_loan_balance_derived` decimal(19,6) DEFAULT NULL,
  `submitted_on_date` date NOT NULL,
  `manually_adjusted_or_reversed` bit(1) DEFAULT b'0',
  `created_date` datetime DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `created_on_utc` datetime DEFAULT NULL,
  `last_modified_on_utc` datetime DEFAULT NULL,
  `original_transaction_id` bigint(20) DEFAULT NULL,
  `is_reversal` bit(1) NOT NULL DEFAULT b'0',
  `correction_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FKCFCEA42640BE0710` (`loan_id`),
  KEY `FK_m_loan_transaction_m_office` (`office_id`),
  KEY `FK_m_loan_transaction_m_payment_detail` (`payment_detail_id`),
  KEY `FK_loan_transaction_created_by` (`created_by`),
  KEY `FK_loan_transaction_last_modified_by` (`last_modified_by`),
  KEY `idx_m_loan_transaction_original_transaction_id` (`original_transaction_id`),
  KEY `idx_m_loan_transaction_last_repayment` (`loan_id`,`transaction_type_enum`,`is_reversed`,`transaction_date`),
  KEY `idx_m_loan_transaction_transaction_date` (`transaction_date`,`is_reversed`),
  KEY `idx_mlt_pmr` (`loan_id`,`is_reversed`,`transaction_date`,`transaction_type_enum`),
  CONSTRAINT `FKCFCEA42640BE0710` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK_loan_transaction_created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_loan_transaction_last_modified_by` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_loan_transaction_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_loan_transaction_m_payment_detail` FOREIGN KEY (`payment_detail_id`) REFERENCES `m_payment_detail` (`id`),
  CONSTRAINT `FK_m_loan_transaction_original_transaction` FOREIGN KEY (`original_transaction_id`) REFERENCES `m_loan_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_transaction_repayment_schedule_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_transaction_id` bigint(20) NOT NULL,
  `loan_repayment_schedule_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `principal_portion_derived` decimal(19,6) DEFAULT NULL,
  `interest_portion_derived` decimal(19,6) DEFAULT NULL,
  `fee_charges_portion_derived` decimal(19,6) DEFAULT NULL,
  `penalty_charges_portion_derived` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mappings_m_loan_repayment_schedule` (`loan_repayment_schedule_id`),
  KEY `FK_mappings_m_loan_transaction` (`loan_transaction_id`),
  CONSTRAINT `FK_mappings_m_loan_repayment_schedule` FOREIGN KEY (`loan_repayment_schedule_id`) REFERENCES `m_loan_repayment_schedule` (`id`),
  CONSTRAINT `FK_mappings_m_loan_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loan_transaction_reprocess` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `is_processed` bit(1) NOT NULL DEFAULT b'0',
  `process_duration` int(11) DEFAULT NULL,
  `exception_message` text DEFAULT NULL,
  `processed_on_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `loan_transaction_reprocess_id_index` (`loan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loanproduct_provisioning_entry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `history_id` bigint(20) NOT NULL,
  `criteria_id` bigint(20) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  `overdue_in_days` bigint(20) DEFAULT 0,
  `reseve_amount` decimal(20,6) DEFAULT 0.000000,
  `liability_account` bigint(20) DEFAULT NULL,
  `expense_account` bigint(20) DEFAULT NULL,
  `classification_type` varchar(50) NOT NULL,
  `criteria_version_id` bigint(20) NOT NULL,
  `criteria_definition_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `fk_loanproduct_provisioning_entry_criteria` (`criteria_id`),
  KEY `expense_account` (`expense_account`),
  KEY `history_id` (`history_id`),
  KEY `loanproduct_provisioning_entry_liability_account` (`liability_account`),
  KEY `loanproduct_provisioning_entry_office_id` (`office_id`),
  KEY `loanproduct_provisioning_entry_product_id` (`product_id`),
  KEY `fk_loanproduct_provisioning_entry_version` (`criteria_version_id`),
  KEY `fk_loanproduct_provisioning_entry_definition` (`criteria_definition_id`),
  CONSTRAINT `fk_loanproduct_provisioning_entry_definition` FOREIGN KEY (`criteria_definition_id`) REFERENCES `m_provisioning_criteria_definition` (`id`),
  CONSTRAINT `fk_loanproduct_provisioning_entry_version` FOREIGN KEY (`criteria_version_id`) REFERENCES `m_provisioning_criteria_version` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_1` FOREIGN KEY (`history_id`) REFERENCES `m_provisioning_history` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_2` FOREIGN KEY (`criteria_id`) REFERENCES `m_provisioning_criteria` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_3` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_4` FOREIGN KEY (`product_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_5` FOREIGN KEY (`category_id`) REFERENCES `m_provision_category` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_6` FOREIGN KEY (`liability_account`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_entry_ibfk_7` FOREIGN KEY (`expense_account`) REFERENCES `acc_gl_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loanproduct_provisioning_entry_loans` (
  `loan_id` bigint(20) DEFAULT NULL,
  `loanproduct_provision_entry_id` bigint(20) DEFAULT NULL,
  `account_no` varchar(100) DEFAULT NULL,
  `outstanding_balance` decimal(20,6) DEFAULT 0.000000,
  `provisioning_amount` decimal(20,6) DEFAULT 0.000000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_loanproduct_provisioning_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `criteria_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id` (`product_id`),
  KEY `fk_loanproduct_provisioning_mapping_criteria` (`criteria_id`),
  CONSTRAINT `m_loanproduct_provisioning_mapping_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `m_loanproduct_provisioning_mapping_ibfk_2` FOREIGN KEY (`criteria_id`) REFERENCES `m_provisioning_criteria` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_mandatory_savings_schedule` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `fromdate` date DEFAULT NULL,
  `duedate` date NOT NULL,
  `installment` smallint(6) NOT NULL,
  `deposit_amount` decimal(19,6) DEFAULT NULL,
  `deposit_amount_completed_derived` decimal(19,6) DEFAULT NULL,
  `total_paid_in_advance_derived` decimal(19,6) DEFAULT NULL,
  `total_paid_late_derived` decimal(19,6) DEFAULT NULL,
  `completed_derived` bit(1) NOT NULL,
  `obligations_met_on_date` date DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKMSS0000000001` (`savings_account_id`),
  CONSTRAINT `FKMSS0000000001` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_meeting` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calendar_instance_id` bigint(20) NOT NULL,
  `meeting_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_calendar_instance_id_meeting_date` (`calendar_instance_id`,`meeting_date`),
  CONSTRAINT `FK_m_calendar_instance_m_meeting` FOREIGN KEY (`calendar_instance_id`) REFERENCES `m_calendar_instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_account_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `account_number` varchar(255) DEFAULT NULL,
  `account_status` varchar(255) DEFAULT NULL,
  `current_balance` varchar(255) DEFAULT NULL,
  `date_opened` varchar(255) DEFAULT NULL,
  `days_in_arrears` int(11) DEFAULT NULL,
  `delinquency_code` varchar(255) DEFAULT NULL,
  `highest_days_in_arrears` int(11) DEFAULT NULL,
  `is_your_account` bit(1) DEFAULT b'0',
  `last_payment_amount` varchar(255) DEFAULT NULL,
  `last_payment_date` varchar(255) DEFAULT NULL,
  `loaded_at` varchar(255) DEFAULT NULL,
  `original_amount` varchar(255) DEFAULT NULL,
  `overdue_balance` varchar(255) DEFAULT NULL,
  `overdue_date` varchar(255) DEFAULT NULL,
  `product_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_crb_credit_info_enhanced_report_id` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_m_metropol_crb_credit_info_enhanced_report_id` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_crb_credit_info_enhanced_report` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `loan_id` bigint(20) NOT NULL,
  `report_type` varchar(255) DEFAULT NULL,
  `api_code` varchar(255) DEFAULT NULL,
  `api_code_description` varchar(255) DEFAULT NULL,
  `application_ref_no` varchar(255) DEFAULT NULL,
  `credit_score` varchar(255) DEFAULT NULL,
  `delinquency_code` varchar(255) DEFAULT NULL,
  `has_error` bit(1) DEFAULT b'0',
  `has_fraud` bit(1) DEFAULT b'0',
  `identity_number` varchar(255) DEFAULT NULL,
  `identity_type` varchar(255) DEFAULT NULL,
  `is_guarantor` bit(1) DEFAULT b'0',
  `trx_id` varchar(255) DEFAULT NULL,
  `created_on_utc` datetime DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_crb_credit_info_enhanced_report_client_id` (`client_id`),
  KEY `FK_m_metropol_crb_credit_info_enhanced_report_loan_id` (`loan_id`),
  CONSTRAINT `FK_m_metropol_crb_credit_info_enhanced_report_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_metropol_crb_credit_info_enhanced_report_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_crb_identity_report` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `loan_id` bigint(20) NOT NULL,
  `citizenship` varchar(255) DEFAULT NULL,
  `clan` varchar(255) DEFAULT NULL,
  `date_of_birth` varchar(255) DEFAULT NULL,
  `date_of_death` varchar(255) DEFAULT NULL,
  `date_of_issue` varchar(255) DEFAULT NULL,
  `ethnic_group` varchar(255) DEFAULT NULL,
  `family` varchar(255) DEFAULT NULL,
  `fingerprint` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `identity_number` varchar(255) DEFAULT NULL,
  `identity_type` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `occupation` varchar(255) DEFAULT NULL,
  `other_name` varchar(255) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `place_of_birth` varchar(255) DEFAULT NULL,
  `place_of_death` varchar(255) DEFAULT NULL,
  `place_of_live` varchar(255) DEFAULT NULL,
  `reg_office` varchar(255) DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `signature` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  `trx_id` varchar(255) DEFAULT NULL,
  `created_on_utc` datetime DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_crb_identity_report-m_client_client_id` (`client_id`),
  KEY `FK_m_metropol_crb_identity_report_loan_id` (`loan_id`),
  CONSTRAINT `FK_m_metropol_crb_identity_report-m_client_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_metropol_crb_identity_report_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_lender_sector` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `bank_account_npa` int(11) DEFAULT NULL,
  `bank_account_performing` int(11) DEFAULT NULL,
  `bank_account_performing_npa_history` int(11) DEFAULT NULL,
  `other_account_npa` int(11) DEFAULT NULL,
  `other_account_performing` int(11) DEFAULT NULL,
  `other_account_performing_npa_history` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_metropol_crb_credit_info_enhanced_report` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_metropol_crb_credit_info_enhanced_report` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_no_of_bounced_cheques` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `last_12_months` int(11) DEFAULT NULL,
  `last_3_months` int(11) DEFAULT NULL,
  `last_6_months` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_crb_credit_info_enhanced_id` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_m_metropol_crb_credit_info_enhanced_id` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_no_of_credit_applications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `last_12_months` int(11) DEFAULT NULL,
  `last_3_months` int(11) DEFAULT NULL,
  `last_6_months` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_crb_credit_enhanced_report_id` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_m_metropol_crb_credit_enhanced_report_id` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_number_of_enquiries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `last_12_months` int(11) DEFAULT NULL,
  `last_3_months` int(11) DEFAULT NULL,
  `last_6_months` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_crb_info_enhanced_report_id` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_m_metropol_crb_info_enhanced_report_id` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_ppi_analysis` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `month` varchar(255) DEFAULT NULL,
  `ppi` double DEFAULT NULL,
  `ppi_rank` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_ppi_analysis_info_id` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_m_metropol_ppi_analysis_info_id` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_metropol_verified_name` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_info_enhanced_id` bigint(20) NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `other_name` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_metropol_verified_name_info_id` (`credit_info_enhanced_id`),
  CONSTRAINT `FK_m_metropol_verified_name_info_id` FOREIGN KEY (`credit_info_enhanced_id`) REFERENCES `m_metropol_crb_credit_info_enhanced_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_note` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `loan_id` bigint(20) DEFAULT NULL,
  `loan_transaction_id` bigint(20) DEFAULT NULL,
  `savings_account_id` bigint(20) DEFAULT NULL,
  `savings_account_transaction_id` bigint(20) DEFAULT NULL,
  `share_account_id` bigint(20) DEFAULT NULL,
  `note_type_enum` smallint(6) NOT NULL,
  `note` varchar(1000) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK7C9708924D26803` (`loan_transaction_id`),
  KEY `FK7C9708940BE0710` (`loan_id`),
  KEY `FK7C97089541F0A56` (`createdby_id`),
  KEY `FK7C970897179A0CB` (`client_id`),
  KEY `FK7C970898F889C3F` (`lastmodifiedby_id`),
  KEY `FK_m_note_m_group` (`group_id`),
  KEY `FK_savings_account_id` (`savings_account_id`),
  KEY `savings_account_transaction_id` (`savings_account_transaction_id`),
  CONSTRAINT `FK7C9708924D26803` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`),
  CONSTRAINT `FK7C9708940BE0710` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `FK7C97089541F0A56` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK7C970897179A0CB` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK7C970898F889C3F` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_note_m_group` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FK_savings_account_id` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_office` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) DEFAULT NULL,
  `hierarchy` varchar(100) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `opening_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FK2291C477E2551DCC` (`parent_id`),
  KEY `idx_m_office_hierarchy` (`hierarchy`),
  CONSTRAINT `FK2291C477E2551DCC` FOREIGN KEY (`parent_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_office_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `from_office_id` bigint(20) DEFAULT NULL,
  `to_office_id` bigint(20) DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` int(11) NOT NULL,
  `transaction_amount` decimal(19,6) NOT NULL,
  `transaction_date` date NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1E37728B783C5C25` (`from_office_id`),
  KEY `FK1E37728B93C6C1B6` (`to_office_id`),
  CONSTRAINT `FK1E37728B783C5C25` FOREIGN KEY (`from_office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK1E37728B93C6C1B6` FOREIGN KEY (`to_office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_organisation_creditbureau` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `alias` varchar(50) NOT NULL,
  `creditbureau_id` bigint(20) NOT NULL,
  `is_active` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `morgcb` (`alias`,`creditbureau_id`),
  KEY `orgcb_cbfk` (`creditbureau_id`),
  CONSTRAINT `orgcb_cbfk` FOREIGN KEY (`creditbureau_id`) REFERENCES `m_creditbureau` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_organisation_currency` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(3) NOT NULL,
  `decimal_places` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `display_symbol` varchar(10) DEFAULT NULL,
  `internationalized_name_code` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_other_client_expenses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_expenses_id` bigint(20) DEFAULT NULL,
  `other_expense_id` bigint(20) DEFAULT NULL,
  `amount` bigint(20) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `lastmodified_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_partial_writeoff_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_transaction_id` bigint(20) NOT NULL,
  `transaction_date` date NOT NULL,
  `principal_portion` decimal(19,6) DEFAULT NULL,
  `interest_portion` decimal(19,6) DEFAULT NULL,
  `fee_charges_portion` decimal(19,6) DEFAULT NULL,
  `penalty_charges_portion` decimal(19,6) DEFAULT NULL,
  `total_amount` decimal(19,6) NOT NULL,
  `loan_balance_before` decimal(19,6) NOT NULL,
  `loan_balance_after` decimal(19,6) NOT NULL,
  `reason` varchar(500) NOT NULL,
  `initiated_by` bigint(20) NOT NULL,
  `initiated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `approved_by` bigint(20) DEFAULT NULL,
  `approved_on` timestamp NULL DEFAULT NULL,
  `office_id` bigint(20) NOT NULL,
  `note` varchar(1000) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_on_utc` timestamp NULL DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_partial_writeoff_audit_external_id` (`external_id`),
  KEY `fk_partial_writeoff_audit_loan` (`loan_id`),
  KEY `fk_partial_writeoff_audit_loan_transaction` (`loan_transaction_id`),
  KEY `fk_partial_writeoff_audit_initiated_by` (`initiated_by`),
  KEY `fk_partial_writeoff_audit_approved_by` (`approved_by`),
  KEY `fk_partial_writeoff_audit_office` (`office_id`),
  CONSTRAINT `fk_partial_writeoff_audit_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_partial_writeoff_audit_initiated_by` FOREIGN KEY (`initiated_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_partial_writeoff_audit_loan` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `fk_partial_writeoff_audit_loan_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`),
  CONSTRAINT `fk_partial_writeoff_audit_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_password_validation_policy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `regex` text NOT NULL,
  `description` text NOT NULL,
  `active` bit(1) NOT NULL DEFAULT b'0',
  `key` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_payment_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `payment_type_id` int(11) DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `check_number` varchar(100) DEFAULT NULL,
  `receipt_number` varchar(100) DEFAULT NULL,
  `bank_number` varchar(100) DEFAULT NULL,
  `routing_code` varchar(100) DEFAULT NULL,
  `actual_transaction_type` varchar(50) DEFAULT NULL,
  `parent_savings_account_transaction_id` bigint(20) DEFAULT NULL,
  `parent_transaction_payment_details_id` bigint(20) DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_payment_detail_m_payment_type` (`payment_type_id`),
  KEY `FK_m_savings_account_transaction_parent_sa_tx_id_X` (`parent_savings_account_transaction_id`),
  KEY `FK_m_payment_detail_parent_transaction_payment_details_id` (`parent_transaction_payment_details_id`),
  CONSTRAINT `FK_m_payment_detail_m_payment_type` FOREIGN KEY (`payment_type_id`) REFERENCES `m_payment_type` (`id`),
  CONSTRAINT `FK_m_payment_detail_parent_transaction_payment_details_id` FOREIGN KEY (`parent_transaction_payment_details_id`) REFERENCES `m_payment_detail` (`id`),
  CONSTRAINT `FK_m_savings_account_transaction_parent_sa_tx_id_X` FOREIGN KEY (`parent_savings_account_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_payment_hub_disbursement_poll` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) NOT NULL,
  `loan_disbursement_detail_id` bigint(20) DEFAULT NULL,
  `request_id` varchar(100) NOT NULL,
  `transaction_id` varchar(64) DEFAULT NULL,
  `payment_type_id` bigint(20) DEFAULT NULL,
  `actual_disbursement_date` date DEFAULT NULL,
  `status` varchar(32) NOT NULL,
  `status_code` int(11) DEFAULT NULL,
  `reason` varchar(1000) DEFAULT NULL,
  `transaction_ref` varchar(100) DEFAULT NULL,
  `created_on` datetime NOT NULL,
  `last_checked_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ph_disb_poll_request_id` (`request_id`),
  KEY `idx_ph_disb_poll_status` (`status`),
  KEY `idx_ph_disb_poll_loan_status` (`loan_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_payment_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(100) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_cash_payment` bit(1) DEFAULT b'0',
  `order_position` int(11) NOT NULL DEFAULT 0,
  `is_mobile_money` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `grouping` varchar(45) DEFAULT NULL,
  `code` varchar(100) NOT NULL,
  `entity_name` varchar(100) DEFAULT NULL,
  `action_name` varchar(100) DEFAULT NULL,
  `can_maker_checker` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1137 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_pocket` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app_user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_user_id` (`app_user_id`),
  CONSTRAINT `FK__m_appuser__pocket` FOREIGN KEY (`app_user_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_pocket_accounts_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `pocket_id` bigint(20) NOT NULL,
  `account_id` bigint(20) NOT NULL,
  `account_type` int(11) NOT NULL,
  `account_number` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_pocket_mapping` (`pocket_id`,`account_id`,`account_type`),
  CONSTRAINT `FK__m_pocket` FOREIGN KEY (`pocket_id`) REFERENCES `m_pocket` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_portfolio_account_associations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_account_id` bigint(20) DEFAULT NULL,
  `savings_account_id` bigint(20) DEFAULT NULL,
  `linked_loan_account_id` bigint(20) DEFAULT NULL,
  `linked_savings_account_id` bigint(20) DEFAULT NULL,
  `association_type_enum` smallint(6) NOT NULL DEFAULT 1,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `account_association_loan_fk` (`loan_account_id`),
  KEY `account_association_savings_fk` (`savings_account_id`),
  KEY `linked_loan_fk` (`linked_loan_account_id`),
  KEY `linked_savings_fk` (`linked_savings_account_id`),
  CONSTRAINT `account_association_loan_fk` FOREIGN KEY (`loan_account_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `account_association_savings_fk` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `linked_loan_fk` FOREIGN KEY (`linked_loan_account_id`) REFERENCES `m_loan` (`id`),
  CONSTRAINT `linked_savings_fk` FOREIGN KEY (`linked_savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_portfolio_command_source` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `action_name` varchar(50) NOT NULL,
  `entity_name` varchar(50) NOT NULL,
  `office_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `loan_id` bigint(20) DEFAULT NULL,
  `savings_account_id` bigint(20) DEFAULT NULL,
  `api_get_url` varchar(100) NOT NULL,
  `resource_id` bigint(20) DEFAULT NULL,
  `subresource_id` bigint(20) DEFAULT NULL,
  `command_as_json` text NOT NULL,
  `maker_id` bigint(20) NOT NULL,
  `made_on_date` datetime NOT NULL,
  `checker_id` bigint(20) DEFAULT NULL,
  `checked_on_date` datetime DEFAULT NULL,
  `processing_result_enum` smallint(6) NOT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `creditbureau_id` bigint(20) DEFAULT NULL,
  `organisation_creditbureau_id` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `notes` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_checker_m_appuser` (`checker_id`),
  KEY `FK_m_maker_m_appuser` (`maker_id`),
  KEY `action_name` (`action_name`),
  KEY `checked_on_date` (`checked_on_date`),
  KEY `entity_name` (`entity_name`,`resource_id`),
  KEY `made_on_date` (`made_on_date`),
  KEY `portfolio_command_source_office_id` (`office_id`),
  KEY `processing_result_enum` (`processing_result_enum`),
  CONSTRAINT `FK_m_checker_m_appuser` FOREIGN KEY (`checker_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_maker_m_appuser` FOREIGN KEY (`maker_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `short_name` varchar(4) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `principal_amount` decimal(19,6) DEFAULT NULL,
  `min_principal_amount` decimal(19,6) DEFAULT NULL,
  `max_principal_amount` decimal(19,6) DEFAULT NULL,
  `arrearstolerance_amount` decimal(19,6) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `fund_id` bigint(20) DEFAULT NULL,
  `is_linked_to_floating_interest_rates` bit(1) NOT NULL DEFAULT b'0',
  `allow_variabe_installments` bit(1) NOT NULL DEFAULT b'0',
  `nominal_interest_rate_per_period` decimal(19,6) DEFAULT NULL,
  `min_nominal_interest_rate_per_period` decimal(19,6) DEFAULT NULL,
  `max_nominal_interest_rate_per_period` decimal(19,6) DEFAULT NULL,
  `interest_period_frequency_enum` smallint(6) DEFAULT NULL,
  `annual_nominal_interest_rate` decimal(19,6) DEFAULT NULL,
  `interest_method_enum` smallint(6) NOT NULL,
  `interest_calculated_in_period_enum` smallint(6) NOT NULL DEFAULT 1,
  `allow_partial_period_interest_calcualtion` bit(1) NOT NULL DEFAULT b'0',
  `repay_every` smallint(6) NOT NULL,
  `repayment_period_frequency_enum` smallint(6) NOT NULL,
  `number_of_repayments` smallint(6) NOT NULL,
  `min_number_of_repayments` smallint(6) DEFAULT NULL,
  `max_number_of_repayments` smallint(6) DEFAULT NULL,
  `grace_on_principal_periods` smallint(6) DEFAULT NULL,
  `recurring_moratorium_principal_periods` smallint(6) DEFAULT NULL,
  `grace_on_interest_periods` smallint(6) DEFAULT NULL,
  `grace_interest_free_periods` smallint(6) DEFAULT NULL,
  `amortization_method_enum` smallint(6) NOT NULL,
  `accounting_type` smallint(6) NOT NULL,
  `loan_transaction_strategy_id` bigint(20) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `include_in_borrower_cycle` bit(1) NOT NULL DEFAULT b'0',
  `use_borrower_cycle` bit(1) NOT NULL DEFAULT b'0',
  `start_date` date DEFAULT NULL,
  `close_date` date DEFAULT NULL,
  `allow_multiple_disbursals` bit(1) NOT NULL DEFAULT b'0',
  `max_disbursals` int(11) DEFAULT NULL,
  `max_outstanding_loan_balance` decimal(19,6) DEFAULT NULL,
  `grace_on_arrears_ageing` smallint(6) DEFAULT NULL,
  `overdue_days_for_npa` smallint(6) DEFAULT NULL,
  `days_in_month_enum` smallint(6) NOT NULL DEFAULT 1,
  `days_in_year_enum` smallint(6) NOT NULL DEFAULT 1,
  `interest_recalculation_enabled` bit(1) NOT NULL DEFAULT b'0',
  `min_days_between_disbursal_and_first_repayment` int(11) DEFAULT NULL,
  `hold_guarantee_funds` bit(1) NOT NULL DEFAULT b'0',
  `principal_threshold_for_last_installment` decimal(5,2) NOT NULL DEFAULT 50.00,
  `account_moves_out_of_npa_only_on_arrears_completion` bit(1) NOT NULL DEFAULT b'0',
  `can_define_fixed_emi_amount` bit(1) NOT NULL DEFAULT b'0',
  `instalment_amount_in_multiples_of` decimal(19,6) DEFAULT NULL,
  `can_use_for_topup` bit(1) NOT NULL DEFAULT b'0',
  `sync_expected_with_disbursement_date` bit(1) DEFAULT b'0',
  `is_equal_amortization` bit(1) NOT NULL DEFAULT b'0',
  `fixed_principal_percentage_per_installment` decimal(5,2) DEFAULT NULL,
  `disallow_expected_disbursements` bit(1) NOT NULL DEFAULT b'0',
  `allow_approved_disbursed_amounts_over_applied` bit(1) NOT NULL DEFAULT b'0',
  `over_applied_calculation_type` varchar(10) DEFAULT NULL,
  `over_applied_number` int(11) DEFAULT NULL,
  `is_loan_term_includes_topped_up_loan_term` bit(1) NOT NULL DEFAULT b'0',
  `max_number_of_loan_extensions_allowed` int(11) DEFAULT NULL,
  `is_account_level_arrears_tolerance_enable` bit(1) NOT NULL DEFAULT b'0',
  `is_bnpl_loan_product` bit(1) DEFAULT b'0',
  `requires_equity_contribution` bit(1) DEFAULT b'0',
  `equity_contribution_loan_percentage` decimal(19,6) DEFAULT NULL,
  `is_islamic` bit(1) NOT NULL DEFAULT b'0',
  `residual_auto_close_enabled` bit(1) NOT NULL DEFAULT b'0',
  `residual_closure_threshold` decimal(19,6) DEFAULT NULL,
  `enable_third_party_disbursement` bit(1) NOT NULL DEFAULT b'0',
  `product_category_id` bigint(20) DEFAULT NULL,
  `product_type_id` bigint(20) DEFAULT NULL,
  `maintain_interest_rate_on_loan_term_extension` bit(1) DEFAULT b'0',
  `allowable_dscr` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `short_name` (`short_name`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FKA6A8A7D77240145` (`fund_id`),
  KEY `FK_ltp_strategy` (`loan_transaction_strategy_id`),
  KEY `idx_m_product_loan_residual_closure` (`residual_auto_close_enabled`),
  CONSTRAINT `FKA6A8A7D77240145` FOREIGN KEY (`fund_id`) REFERENCES `m_fund` (`id`),
  CONSTRAINT `FK_ltp_strategy` FOREIGN KEY (`loan_transaction_strategy_id`) REFERENCES `ref_loan_transaction_processing_strategy` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_charge` (
  `product_loan_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  PRIMARY KEY (`product_loan_id`,`charge_id`),
  KEY `fk_product_loan_charge_charge` (`charge_id`),
  CONSTRAINT `m_product_loan_charge_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `m_product_loan_charge_ibfk_2` FOREIGN KEY (`product_loan_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_configurable_attributes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_product_id` bigint(20) NOT NULL,
  `amortization_method_enum` bit(1) NOT NULL DEFAULT b'1',
  `interest_method_enum` bit(1) NOT NULL DEFAULT b'1',
  `loan_transaction_strategy_id` bit(1) NOT NULL DEFAULT b'1',
  `interest_calculated_in_period_enum` bit(1) NOT NULL DEFAULT b'1',
  `arrearstolerance_amount` bit(1) NOT NULL DEFAULT b'1',
  `repay_every` bit(1) NOT NULL DEFAULT b'1',
  `moratorium` bit(1) NOT NULL DEFAULT b'1',
  `grace_on_arrears_ageing` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `fk_m_product_loan_configurable_attributes_0001` (`loan_product_id`),
  CONSTRAINT `fk_m_product_loan_configurable_attributes_0001` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_floating_rates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_product_id` bigint(20) NOT NULL,
  `floating_rates_id` bigint(20) NOT NULL,
  `interest_rate_differential` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `min_differential_lending_rate` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `default_differential_lending_rate` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `max_differential_lending_rate` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `is_floating_interest_rate_calculation_allowed` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FK_mappings_m_floating_rates_id` (`floating_rates_id`),
  KEY `FK_mappings_m_product_loan_id` (`loan_product_id`),
  CONSTRAINT `FK_mappings_m_floating_rates_id` FOREIGN KEY (`floating_rates_id`) REFERENCES `m_floating_rates` (`id`),
  CONSTRAINT `FK_mappings_m_product_loan_id` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_guarantee_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_product_id` bigint(20) NOT NULL,
  `mandatory_guarantee` decimal(19,5) NOT NULL,
  `minimum_guarantee_from_own_funds` decimal(19,5) DEFAULT NULL,
  `minimum_guarantee_from_guarantor_funds` decimal(19,5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_guarantee_details_loan_product` (`loan_product_id`),
  CONSTRAINT `FK_guarantee_details_loan_product` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_interest_rate_chart` (
  `loan_product_id` bigint(20) NOT NULL,
  `interest_rate_chart_id` bigint(20) NOT NULL,
  KEY `FK_m_product_loan_interest_rate_chart_m_product_loan` (`loan_product_id`),
  KEY `FK_m_product_loan_interest_rate_chart_interest_rate_chart` (`interest_rate_chart_id`),
  CONSTRAINT `FK_m_product_loan_interest_rate_chart_interest_rate_chart` FOREIGN KEY (`interest_rate_chart_id`) REFERENCES `m_interest_rate_chart` (`id`),
  CONSTRAINT `FK_m_product_loan_interest_rate_chart_m_product_loan` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_rate` (
  `product_loan_id` bigint(20) NOT NULL,
  `rate_id` bigint(20) NOT NULL,
  PRIMARY KEY (`product_loan_id`,`rate_id`),
  KEY `FK_M_PRODUCT_LOAN_RATE_RATE` (`rate_id`),
  CONSTRAINT `FK_M_PRODUCT_LOAN_RATE_LOAN` FOREIGN KEY (`product_loan_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `FK_M_PRODUCT_LOAN_RATE_RATE` FOREIGN KEY (`rate_id`) REFERENCES `m_rate` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_recalculation_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `compound_type_enum` smallint(6) NOT NULL,
  `reschedule_strategy_enum` smallint(6) NOT NULL,
  `rest_frequency_type_enum` smallint(6) NOT NULL,
  `rest_frequency_interval` smallint(6) NOT NULL DEFAULT 0,
  `arrears_based_on_original_schedule` bit(1) NOT NULL DEFAULT b'0',
  `pre_close_interest_calculation_strategy` smallint(6) NOT NULL DEFAULT 1,
  `compounding_frequency_type_enum` smallint(6) DEFAULT NULL,
  `compounding_frequency_interval` smallint(6) DEFAULT NULL,
  `rest_frequency_nth_day_enum` int(11) DEFAULT NULL,
  `rest_frequency_on_day` int(11) DEFAULT NULL,
  `rest_frequency_weekday_enum` int(11) DEFAULT NULL,
  `compounding_frequency_nth_day_enum` int(11) DEFAULT NULL,
  `compounding_frequency_on_day` int(11) DEFAULT NULL,
  `compounding_frequency_weekday_enum` int(11) DEFAULT NULL,
  `is_compounding_to_be_posted_as_transaction` bit(1) NOT NULL DEFAULT b'0',
  `allow_compounding_on_eod` bit(1) NOT NULL DEFAULT b'0',
  `advance_payment_interest_for_exact_days_in_period` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FK_m_product_loan_m_product_loan_recalculation_details` (`product_id`),
  CONSTRAINT `FK_m_product_loan_m_product_loan_recalculation_details` FOREIGN KEY (`product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_variable_installment_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_product_id` bigint(20) NOT NULL,
  `minimum_gap` int(11) NOT NULL,
  `maximum_gap` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mappings_m_variable_product_loan_id` (`loan_product_id`),
  CONSTRAINT `FK_mappings_m_variable_product_loan_id` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_loan_variations_borrower_cycle` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_product_id` bigint(20) NOT NULL DEFAULT 0,
  `borrower_cycle_number` int(11) NOT NULL DEFAULT 0,
  `value_condition` int(11) NOT NULL DEFAULT 0,
  `param_type` int(11) NOT NULL DEFAULT 0,
  `default_value` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `max_value` decimal(19,6) DEFAULT NULL,
  `min_value` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `borrower_cycle_loan_product_FK` (`loan_product_id`),
  CONSTRAINT `borrower_cycle_loan_product_FK` FOREIGN KEY (`loan_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_product_mix` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `restricted_product_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_product_mix_product_id_to_m_product_loan` (`product_id`),
  KEY `FK_m_product_mix_restricted_product_id_to_m_product_loan` (`restricted_product_id`),
  CONSTRAINT `FK_m_product_mix_product_id_to_m_product_loan` FOREIGN KEY (`product_id`) REFERENCES `m_product_loan` (`id`),
  CONSTRAINT `FK_m_product_mix_restricted_product_id_to_m_product_loan` FOREIGN KEY (`restricted_product_id`) REFERENCES `m_product_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provision_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `description` varchar(300) DEFAULT NULL,
  `category_code` varchar(100) NOT NULL,
  `display_order` int(11) NOT NULL,
  `is_active` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `category_name` (`category_name`),
  UNIQUE KEY `uk_m_provision_category_code` (`category_code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_batch` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_reference` varchar(100) NOT NULL,
  `accounting_period` date NOT NULL,
  `status` varchar(30) NOT NULL,
  `total_debit` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_credit` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `entry_count` int(11) NOT NULL DEFAULT 0,
  `journal_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` bigint(20) DEFAULT NULL,
  `posted_at` timestamp NULL DEFAULT NULL,
  `reversed_at` timestamp NULL DEFAULT NULL,
  `reversal_of_batch_id` bigint(20) DEFAULT NULL,
  `failure_reason` text DEFAULT NULL,
  `version` bigint(20) NOT NULL DEFAULT 0,
  `provisioning_history_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `batch_reference` (`batch_reference`),
  UNIQUE KEY `uk_provisioning_batch_period` (`accounting_period`),
  KEY `fk_provisioning_batch_reversal` (`reversal_of_batch_id`),
  KEY `idx_provisioning_batch_status` (`status`),
  KEY `idx_provisioning_batch_history` (`provisioning_history_id`),
  CONSTRAINT `fk_provisioning_batch_reversal` FOREIGN KEY (`reversal_of_batch_id`) REFERENCES `m_provisioning_batch` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_batch_entry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` bigint(20) NOT NULL,
  `provisioning_entry_id` bigint(20) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_provisioning_batch_entry` (`batch_id`,`provisioning_entry_id`),
  KEY `idx_provisioning_batch_entry_batch` (`batch_id`),
  KEY `idx_provisioning_batch_entry_provisioning` (`provisioning_entry_id`),
  KEY `idx_provisioning_batch_entry_currency` (`currency_code`),
  CONSTRAINT `fk_provisioning_batch_entry_batch` FOREIGN KEY (`batch_id`) REFERENCES `m_provisioning_batch` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_batch_journal` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` bigint(20) NOT NULL,
  `journal_reference` varchar(150) NOT NULL,
  `transaction_id` varchar(150) NOT NULL,
  `reference` varchar(255) NOT NULL,
  `entry_date` date NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `status` varchar(30) NOT NULL,
  `odoo_journal_id` varchar(100) DEFAULT NULL,
  `total_debit` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `total_credit` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `entry_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `posted_at` timestamp NULL DEFAULT NULL,
  `failure_reason` text DEFAULT NULL,
  `version` bigint(20) NOT NULL DEFAULT 0,
  `is_reversal` bit(1) NOT NULL DEFAULT b'0',
  `reversed_journal_id` bigint(20) DEFAULT NULL,
  `provisioning_history_id` bigint(20) DEFAULT NULL,
  `office_id` bigint(20) DEFAULT NULL,
  `office_name` varchar(150) DEFAULT NULL,
  `payload_json` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `journal_reference` (`journal_reference`),
  KEY `idx_provisioning_batch_journal_batch` (`batch_id`),
  KEY `idx_provisioning_batch_journal_status` (`status`),
  KEY `idx_provisioning_batch_journal_currency` (`currency_code`),
  KEY `idx_provisioning_batch_journal_reversal` (`is_reversal`),
  KEY `idx_provisioning_batch_journal_office` (`office_id`),
  CONSTRAINT `fk_provisioning_batch_journal_batch` FOREIGN KEY (`batch_id`) REFERENCES `m_provisioning_batch` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_batch_journal_line` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `journal_id` bigint(20) NOT NULL,
  `gl_account_id` bigint(20) DEFAULT NULL,
  `gl_account_code` varchar(100) DEFAULT NULL,
  `entry_type` varchar(20) NOT NULL,
  `debit_amount` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `credit_amount` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `transaction_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_provisioning_batch_journal_line_journal` (`journal_id`),
  KEY `idx_provisioning_batch_journal_line_account` (`gl_account_id`,`gl_account_code`),
  CONSTRAINT `fk_provisioning_batch_journal_line_journal` FOREIGN KEY (`journal_id`) REFERENCES `m_provisioning_batch_journal` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_criteria` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(200) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `criteria_name` (`criteria_name`),
  KEY `fk_provisioning_criteria_createdby` (`createdby_id`),
  KEY `provisioning_criteria_lastmodifiedby_id` (`lastmodifiedby_id`),
  CONSTRAINT `m_provisioning_criteria_ibfk_1` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_provisioning_criteria_ibfk_2` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_criteria_definition` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `criteria_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `min_age` bigint(20) NOT NULL,
  `max_age` bigint(20) DEFAULT NULL,
  `provision_percentage` decimal(5,2) NOT NULL,
  `liability_account` bigint(20) DEFAULT NULL,
  `expense_account` bigint(20) DEFAULT NULL,
  `criteria_version_id` bigint(20) NOT NULL,
  `category_code` varchar(100) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `display_order` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_provisioning_criteria_definition_category` (`category_id`),
  KEY `fk_loanproduct_criteria_definition_criteria` (`criteria_id`),
  KEY `fk_provisioning_criteria_definition_expense_account` (`expense_account`),
  KEY `provisioning_criteria_definition_liability_account` (`liability_account`),
  KEY `fk_provisioning_criteria_definition_version` (`criteria_version_id`),
  CONSTRAINT `fk_provisioning_criteria_definition_version` FOREIGN KEY (`criteria_version_id`) REFERENCES `m_provisioning_criteria_version` (`id`),
  CONSTRAINT `m_provisioning_criteria_definition_ibfk_1` FOREIGN KEY (`criteria_id`) REFERENCES `m_provisioning_criteria` (`id`),
  CONSTRAINT `m_provisioning_criteria_definition_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `m_provision_category` (`id`),
  CONSTRAINT `m_provisioning_criteria_definition_ibfk_3` FOREIGN KEY (`liability_account`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `m_provisioning_criteria_definition_ibfk_4` FOREIGN KEY (`expense_account`) REFERENCES `acc_gl_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_criteria_version` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `criteria_id` bigint(20) NOT NULL,
  `version_no` int(11) NOT NULL,
  `effective_from` date NOT NULL,
  `retired_on` date DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `policy_change_reason` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_provisioning_criteria_version` (`criteria_id`,`version_no`),
  KEY `fk_provisioning_criteria_version_criteria` (`criteria_id`),
  KEY `fk_provisioning_criteria_version_createdby` (`createdby_id`),
  KEY `fk_provisioning_criteria_version_lastmodifiedby` (`lastmodifiedby_id`),
  CONSTRAINT `fk_provisioning_criteria_version_createdby` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `fk_provisioning_criteria_version_criteria` FOREIGN KEY (`criteria_id`) REFERENCES `m_provisioning_criteria` (`id`),
  CONSTRAINT `fk_provisioning_criteria_version_lastmodifiedby` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_provisioning_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `journal_entry_created` bit(1) DEFAULT b'0',
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` date DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` date DEFAULT NULL,
  `executed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_provisioning_history_createdby` (`createdby_id`),
  KEY `provisioning_history_lastmodifiedby_id` (`lastmodifiedby_id`),
  CONSTRAINT `m_provisioning_history_ibfk_1` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_provisioning_history_ibfk_2` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_rate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `percentage` decimal(10,2) NOT NULL,
  `active` bit(1) DEFAULT b'0',
  `product_apply` smallint(6) NOT NULL,
  `created_date` datetime DEFAULT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `approve_user` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_M_RATE_APPROVE_USER` (`approve_user`),
  KEY `FK_M_RATE_CREATE_USER` (`createdby_id`),
  CONSTRAINT `FK_M_RATE_APPROVE_USER` FOREIGN KEY (`approve_user`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_M_RATE_CREATE_USER` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_repayment_with_post_dated_checks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `check_no` bigint(20) NOT NULL,
  `amount` decimal(20,5) NOT NULL,
  `loan_id` bigint(20) DEFAULT NULL,
  `repayment_id` bigint(20) DEFAULT NULL,
  `account_no` bigint(20) NOT NULL,
  `bank_name` varchar(200) NOT NULL,
  `repayment_date` date NOT NULL,
  `status` smallint(6) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `check_no` (`check_no`),
  KEY `fkloanrepayment` (`loan_id`),
  KEY `fkrepaymentwithpostdated` (`repayment_id`),
  CONSTRAINT `fkloanrepayment` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fkrepaymentwithpostdated` FOREIGN KEY (`repayment_id`) REFERENCES `m_loan_repayment_schedule` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_report_mailing_job` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `start_datetime` datetime NOT NULL,
  `recurrence` varchar(100) DEFAULT NULL,
  `created_date` date NOT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `lastmodified_date` date DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `email_recipients` text NOT NULL,
  `email_subject` varchar(100) NOT NULL,
  `email_message` text NOT NULL,
  `email_attachment_file_format` varchar(10) NOT NULL,
  `stretchy_report_id` int(11) NOT NULL,
  `stretchy_report_param_map` text DEFAULT NULL,
  `previous_run_datetime` datetime DEFAULT NULL,
  `next_run_datetime` datetime DEFAULT NULL,
  `previous_run_status` varchar(10) DEFAULT NULL,
  `previous_run_error_log` text DEFAULT NULL,
  `previous_run_error_message` text DEFAULT NULL,
  `number_of_runs` int(11) NOT NULL DEFAULT 0,
  `is_active` bit(1) NOT NULL DEFAULT b'0',
  `is_deleted` bit(1) NOT NULL DEFAULT b'0',
  `run_as_userid` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `fk_report_mailing_job_createdby` (`createdby_id`),
  KEY `report_mailing_job_lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `run_as_userid` (`run_as_userid`),
  KEY `stretchy_report_id` (`stretchy_report_id`),
  CONSTRAINT `m_report_mailing_job_ibfk_1` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_report_mailing_job_ibfk_2` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_report_mailing_job_ibfk_3` FOREIGN KEY (`stretchy_report_id`) REFERENCES `stretchy_report` (`id`),
  CONSTRAINT `m_report_mailing_job_ibfk_4` FOREIGN KEY (`run_as_userid`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_report_mailing_job_configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `value` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_report_mailing_job_run_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) NOT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `status` varchar(10) NOT NULL,
  `error_message` text DEFAULT NULL,
  `error_log` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `job_id` (`job_id`),
  CONSTRAINT `m_report_mailing_job_run_history_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `m_report_mailing_job` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_reprocess_rescheduled_migrated_loans_in_nifi` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` varchar(255) NOT NULL,
  `external_id` varchar(255) NOT NULL,
  `submitted_on_date` date NOT NULL,
  `loan_disbursed_on_in_cbs` date NOT NULL,
  `reschedule_from_date_in_cbs` date NOT NULL,
  `adjusted_due_date_for_odoo` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) NOT NULL,
  `is_disabled` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_role_permission` (
  `role_id` bigint(20) NOT NULL,
  `permission_id` bigint(20) NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `FK8DEDB048103B544B` (`permission_id`),
  KEY `FK8DEDB04815CEC7AB` (`role_id`),
  CONSTRAINT `FK8DEDB048103B544B` FOREIGN KEY (`permission_id`) REFERENCES `m_permission` (`id`),
  CONSTRAINT `FK8DEDB04815CEC7AB` FOREIGN KEY (`role_id`) REFERENCES `m_role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_no` varchar(20) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `gsim_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `field_officer_id` bigint(20) DEFAULT NULL,
  `status_enum` smallint(6) NOT NULL DEFAULT 300,
  `sub_status_enum` smallint(6) NOT NULL DEFAULT 0,
  `account_type_enum` smallint(6) NOT NULL DEFAULT 1,
  `deposit_type_enum` smallint(6) NOT NULL DEFAULT 100,
  `submittedon_date` date NOT NULL,
  `submittedon_userid` bigint(20) DEFAULT NULL,
  `approvedon_date` date DEFAULT NULL,
  `approvedon_userid` bigint(20) DEFAULT NULL,
  `rejectedon_date` date DEFAULT NULL,
  `rejectedon_userid` bigint(20) DEFAULT NULL,
  `withdrawnon_date` date DEFAULT NULL,
  `withdrawnon_userid` bigint(20) DEFAULT NULL,
  `activatedon_date` date DEFAULT NULL,
  `activatedon_userid` bigint(20) DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `nominal_annual_interest_rate` decimal(19,6) NOT NULL,
  `interest_compounding_period_enum` smallint(6) NOT NULL,
  `interest_posting_period_enum` smallint(6) NOT NULL DEFAULT 4,
  `interest_calculation_type_enum` smallint(6) NOT NULL,
  `interest_calculation_days_in_year_type_enum` smallint(6) NOT NULL,
  `min_required_opening_balance` decimal(19,6) DEFAULT NULL,
  `lockin_period_frequency` decimal(19,6) DEFAULT NULL,
  `lockin_period_frequency_enum` smallint(6) DEFAULT NULL,
  `withdrawal_fee_for_transfer` bit(1) DEFAULT b'1',
  `allow_overdraft` bit(1) NOT NULL DEFAULT b'0',
  `overdraft_limit` decimal(19,6) DEFAULT NULL,
  `nominal_annual_interest_rate_overdraft` decimal(19,6) DEFAULT 0.000000,
  `min_overdraft_for_interest_calculation` decimal(19,6) DEFAULT 0.000000,
  `lockedin_until_date_derived` date DEFAULT NULL,
  `total_deposits_derived` decimal(19,6) DEFAULT NULL,
  `total_withdrawals_derived` decimal(19,6) DEFAULT NULL,
  `total_withdrawal_fees_derived` decimal(19,6) DEFAULT NULL,
  `total_fees_charge_derived` decimal(19,6) DEFAULT NULL,
  `total_penalty_charge_derived` decimal(19,6) DEFAULT NULL,
  `total_annual_fees_derived` decimal(19,6) DEFAULT NULL,
  `total_interest_earned_derived` decimal(19,6) DEFAULT NULL,
  `total_interest_posted_derived` decimal(19,6) DEFAULT NULL,
  `total_overdraft_interest_derived` decimal(19,6) DEFAULT 0.000000,
  `total_withhold_tax_derived` decimal(19,6) DEFAULT NULL,
  `account_balance_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `min_required_balance` decimal(19,6) DEFAULT NULL,
  `enforce_min_required_balance` bit(1) NOT NULL DEFAULT b'0',
  `min_balance_for_interest_calculation` decimal(19,6) DEFAULT NULL,
  `start_interest_calculation_date` date DEFAULT NULL,
  `on_hold_funds_derived` decimal(19,6) DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `withhold_tax` bit(1) NOT NULL DEFAULT b'0',
  `tax_group_id` bigint(20) DEFAULT NULL,
  `last_interest_calculation_date` date DEFAULT NULL,
  `total_savings_amount_on_hold` decimal(19,6) DEFAULT NULL,
  `interest_posted_till_date` date DEFAULT NULL,
  `reason_for_block` varchar(256) DEFAULT NULL,
  `max_allowed_lien_limit` decimal(19,6) DEFAULT NULL,
  `is_lien_allowed` bit(1) NOT NULL DEFAULT b'0',
  `block_narration_id` bigint(20) DEFAULT NULL,
  `num_of_credit_transaction` bigint(20) DEFAULT NULL,
  `num_of_debit_transaction` bigint(20) DEFAULT NULL,
  `start_interest_accrual_calculation_date` date DEFAULT NULL,
  `total_overdraft_interest_earned_derived` decimal(19,6) DEFAULT NULL,
  `original_interest_rate` decimal(19,6) DEFAULT NULL,
  `closed_fixed_deposit_account_no` varchar(20) DEFAULT NULL,
  `vault_target_date` date DEFAULT NULL,
  `vault_target_amount` decimal(19,6) DEFAULT NULL,
  `unlock_date` date DEFAULT NULL,
  `is_unlocked` bit(1) DEFAULT b'0',
  `use_floating_interest_rate` bit(1) DEFAULT NULL,
  `withdrawal_frequency` bigint(20) DEFAULT NULL,
  `withdrawal_frequency_enum` bigint(20) DEFAULT NULL,
  `previous_flex_withdrawal_date` date DEFAULT NULL,
  `next_flex_withdrawal_date` date DEFAULT NULL,
  `post_overdraft_interest_on_deposit` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_no` (`account_no`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FKSA00000000000001` (`client_id`),
  KEY `FKSA00000000000002` (`group_id`),
  KEY `FKSA00000000000003` (`product_id`),
  KEY `FK_gsim_id` (`gsim_id`),
  KEY `FK_savings_account_tax_group` (`tax_group_id`),
  CONSTRAINT `FKSA00000000000001` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FKSA00000000000002` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FKSA00000000000003` FOREIGN KEY (`product_id`) REFERENCES `m_savings_product` (`id`),
  CONSTRAINT `FK_gsim_id` FOREIGN KEY (`gsim_id`) REFERENCES `gsim_accounts` (`id`),
  CONSTRAINT `FK_savings_account_tax_group` FOREIGN KEY (`tax_group_id`) REFERENCES `m_tax_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_block_narration_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) NOT NULL,
  `block_narration_comment` varchar(500) DEFAULT NULL,
  `block_narration_id` bigint(20) DEFAULT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `sub_status` varchar(50) DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_m_savings_account_block_narration_history_0001` (`account_id`),
  CONSTRAINT `fk_m_savings_account_block_narration_history_0001` FOREIGN KEY (`account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  `is_penalty` bit(1) NOT NULL DEFAULT b'0',
  `charge_time_enum` smallint(6) NOT NULL,
  `charge_due_date` date DEFAULT NULL,
  `fee_on_month` smallint(6) DEFAULT NULL,
  `fee_on_day` smallint(6) DEFAULT NULL,
  `fee_interval` smallint(6) DEFAULT NULL,
  `free_withdrawal_count` int(11) DEFAULT 0,
  `charge_reset_date` date DEFAULT NULL,
  `charge_calculation_enum` smallint(6) NOT NULL,
  `calculation_percentage` decimal(19,6) DEFAULT NULL,
  `calculation_on_amount` decimal(19,6) DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `amount_paid_derived` decimal(19,6) DEFAULT NULL,
  `amount_waived_derived` decimal(19,6) DEFAULT NULL,
  `amount_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `is_paid_derived` bit(1) NOT NULL DEFAULT b'0',
  `waived` bit(1) NOT NULL DEFAULT b'0',
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `inactivated_on_date` date DEFAULT NULL,
  `min_amount` decimal(19,6) DEFAULT NULL,
  `max_amount` decimal(19,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_savings_account_charge_charge` (`charge_id`),
  KEY `m_savings_account_charge_ibfk_2` (`savings_account_id`),
  CONSTRAINT `m_savings_account_charge_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `m_savings_account_charge_ibfk_2` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_charge_paid_by` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_transaction_id` bigint(20) NOT NULL,
  `savings_account_charge_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK__m_savings_account_charge` (`savings_account_charge_id`),
  KEY `FK__m_savings_account_transaction` (`savings_account_transaction_id`),
  CONSTRAINT `FK__m_savings_account_charge` FOREIGN KEY (`savings_account_charge_id`) REFERENCES `m_savings_account_charge` (`id`),
  CONSTRAINT `FK__m_savings_account_transaction` FOREIGN KEY (`savings_account_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_floating_interest_rate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `from_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `floating_interest_rate` decimal(19,6) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1_m_savings_account_floating_interest_rate_m_savings_account` (`savings_account_id`),
  CONSTRAINT `FK1_m_savings_account_floating_interest_rate_m_savings_account` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_interest_rate_chart` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `from_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `is_primary_grouping_by_amount` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FKSAIRC00000000000001` (`savings_account_id`),
  CONSTRAINT `FKSAIRC00000000000001` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_interest_rate_slab` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_interest_rate_chart_id` bigint(20) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `period_type_enum` smallint(6) DEFAULT NULL,
  `from_period` int(11) DEFAULT NULL,
  `to_period` int(11) DEFAULT NULL,
  `amount_range_from` decimal(19,6) DEFAULT NULL,
  `amount_range_to` decimal(19,6) DEFAULT NULL,
  `annual_interest_rate` decimal(19,6) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKSAIRS00000000000001` (`savings_account_interest_rate_chart_id`),
  CONSTRAINT `FKSAIRS00000000000001` FOREIGN KEY (`savings_account_interest_rate_chart_id`) REFERENCES `m_savings_account_interest_rate_chart` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `payment_detail_id` bigint(20) DEFAULT NULL,
  `transaction_type_enum` smallint(6) NOT NULL,
  `is_reversed` bit(1) NOT NULL,
  `transaction_date` date NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `overdraft_amount_derived` decimal(19,6) DEFAULT NULL,
  `balance_end_date_derived` date DEFAULT NULL,
  `balance_number_of_days_derived` int(11) DEFAULT NULL,
  `running_balance_derived` decimal(19,6) DEFAULT NULL,
  `cumulative_balance_derived` decimal(19,6) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `appuser_id` bigint(20) DEFAULT NULL,
  `is_manual` bit(1) DEFAULT b'0',
  `release_id_of_hold_amount` bigint(20) DEFAULT NULL,
  `is_loan_disbursement` bit(1) DEFAULT NULL,
  `ref_no` varchar(128) DEFAULT NULL,
  `original_transaction_id` bigint(20) DEFAULT NULL,
  `is_reversal` bit(1) NOT NULL DEFAULT b'0',
  `reason_for_block` varchar(256) DEFAULT NULL,
  `is_lien_transaction` bit(1) NOT NULL DEFAULT b'0',
  `is_account_transfer` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `FKSAT0000000001` (`savings_account_id`),
  KEY `FK_m_savings_account_transaction_m_office` (`office_id`),
  KEY `FK_m_savings_account_transaction_m_payment_detail` (`payment_detail_id`),
  CONSTRAINT `FKSAT0000000001` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `FK_m_savings_account_transaction_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`),
  CONSTRAINT `FK_m_savings_account_transaction_m_payment_detail` FOREIGN KEY (`payment_detail_id`) REFERENCES `m_payment_detail` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_transaction_pending` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_account_id` bigint(20) NOT NULL,
  `committed_transaction_id` bigint(20) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `transaction_type_enum` int(11) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `locale` varchar(50) NOT NULL,
  `currency_code` varchar(3) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `is_processed` bit(1) NOT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `lastmodified_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `lastmodifiedby_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_savings_account_transaction_transaction_pending` (`committed_transaction_id`),
  KEY `FK_m_savings_account_sv_pending` (`savings_account_id`),
  KEY `FK_client_transaction_on_hold` (`client_id`),
  CONSTRAINT `FK_client_transaction_on_hold` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_savings_account_sv_pending` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `FK_m_savings_account_transaction_transaction_pending` FOREIGN KEY (`committed_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_account_transaction_tax_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_transaction_id` bigint(20) NOT NULL,
  `tax_component_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_savings_account_transaction_tax_details_savings_transaction` (`savings_transaction_id`),
  KEY `FK_savings_account_transaction_tax_details_tax_component` (`tax_component_id`),
  CONSTRAINT `FK_savings_account_transaction_tax_details_savings_transaction` FOREIGN KEY (`savings_transaction_id`) REFERENCES `m_savings_account_transaction` (`id`),
  CONSTRAINT `FK_savings_account_transaction_tax_details_tax_component` FOREIGN KEY (`tax_component_id`) REFERENCES `m_tax_component` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_interest_incentives` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_interest_rate_slab_id` bigint(20) NOT NULL,
  `entiry_type` smallint(6) NOT NULL,
  `attribute_name` smallint(6) NOT NULL,
  `condition_type` smallint(6) NOT NULL,
  `attribute_value` varchar(50) NOT NULL,
  `incentive_type` smallint(6) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_savings_interest_incentives_m_savings_interest_rate_slab` (`deposit_account_interest_rate_slab_id`),
  CONSTRAINT `FK_m_savings_interest_incentives_m_savings_interest_rate_slab` FOREIGN KEY (`deposit_account_interest_rate_slab_id`) REFERENCES `m_savings_account_interest_rate_slab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_officer_assignment_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) NOT NULL,
  `savings_officer_id` bigint(20) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_m_savings_officer_assignment_history_0001` (`account_id`),
  KEY `fk_m_savings_officer_assignment_history_0002` (`savings_officer_id`),
  CONSTRAINT `fk_m_savings_officer_assignment_history_0001` FOREIGN KEY (`account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `fk_m_savings_officer_assignment_history_0002` FOREIGN KEY (`savings_officer_id`) REFERENCES `m_staff` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `short_name` varchar(4) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `deposit_type_enum` smallint(6) NOT NULL DEFAULT 100,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `nominal_annual_interest_rate` decimal(19,6) NOT NULL,
  `interest_compounding_period_enum` smallint(6) NOT NULL,
  `interest_posting_period_enum` smallint(6) NOT NULL DEFAULT 4,
  `interest_calculation_type_enum` smallint(6) NOT NULL,
  `interest_calculation_days_in_year_type_enum` smallint(6) NOT NULL,
  `min_required_opening_balance` decimal(19,6) DEFAULT NULL,
  `lockin_period_frequency` decimal(19,6) DEFAULT NULL,
  `lockin_period_frequency_enum` smallint(6) DEFAULT NULL,
  `accounting_type` smallint(6) NOT NULL,
  `withdrawal_fee_amount` decimal(19,6) DEFAULT NULL,
  `withdrawal_fee_type_enum` smallint(6) DEFAULT NULL,
  `withdrawal_fee_for_transfer` bit(1) DEFAULT b'1',
  `allow_overdraft` bit(1) NOT NULL DEFAULT b'0',
  `overdraft_limit` decimal(19,6) DEFAULT NULL,
  `nominal_annual_interest_rate_overdraft` decimal(19,6) DEFAULT 0.000000,
  `min_overdraft_for_interest_calculation` decimal(19,6) DEFAULT 0.000000,
  `min_required_balance` decimal(19,6) DEFAULT NULL,
  `enforce_min_required_balance` bit(1) NOT NULL DEFAULT b'0',
  `min_balance_for_interest_calculation` decimal(19,6) DEFAULT NULL,
  `withhold_tax` bit(1) NOT NULL DEFAULT b'0',
  `tax_group_id` bigint(20) DEFAULT NULL,
  `is_dormancy_tracking_active` bit(1) DEFAULT NULL,
  `days_to_inactive` int(11) DEFAULT NULL,
  `days_to_dormancy` int(11) DEFAULT NULL,
  `days_to_escheat` int(11) DEFAULT NULL,
  `max_allowed_lien_limit` decimal(19,6) DEFAULT NULL,
  `is_lien_allowed` bit(1) NOT NULL DEFAULT b'0',
  `is_interest_posting_config_update` bit(1) NOT NULL DEFAULT b'0',
  `num_of_credit_transaction` bigint(20) DEFAULT NULL,
  `num_of_debit_transaction` bigint(20) DEFAULT NULL,
  `is_usd_product` bit(1) NOT NULL DEFAULT b'0',
  `allow_manually_enter_interest_rate` bit(1) NOT NULL DEFAULT b'0',
  `add_penalty_on_missed_target_savings` bit(1) NOT NULL DEFAULT b'0',
  `use_floating_interest_rate` bit(1) DEFAULT NULL,
  `withdrawal_frequency` bigint(20) DEFAULT NULL,
  `withdrawal_frequency_enum` bigint(20) DEFAULT NULL,
  `post_overdraft_interest_on_deposit` bit(1) DEFAULT NULL,
  `product_category_id` bigint(20) DEFAULT NULL,
  `product_type_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `short_name` (`short_name`),
  KEY `FK_savings_product_tax_group` (`tax_group_id`),
  CONSTRAINT `FK_savings_product_tax_group` FOREIGN KEY (`tax_group_id`) REFERENCES `m_tax_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_product_charge` (
  `savings_product_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  PRIMARY KEY (`savings_product_id`,`charge_id`),
  KEY `fk_savings_product_charge_charge` (`charge_id`),
  CONSTRAINT `m_savings_product_charge_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `m_savings_product_charge_ibfk_2` FOREIGN KEY (`savings_product_id`) REFERENCES `m_savings_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_savings_product_floating_interest_rate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `savings_product_id` bigint(20) NOT NULL,
  `from_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `floating_interest_rate` decimal(19,6) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1_m_savings_product_floating_interest_rate_m_savings_product` (`savings_product_id`),
  CONSTRAINT `FK1_m_savings_product_floating_interest_rate_m_savings_product` FOREIGN KEY (`savings_product_id`) REFERENCES `m_savings_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_selfservice_beneficiaries_tpt` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app_user_id` bigint(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `office_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `account_id` bigint(20) NOT NULL,
  `account_type` smallint(6) NOT NULL,
  `transfer_limit` bigint(20) DEFAULT 0,
  `is_active` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_m_selfservice_beneficiaries_tpt_name` (`name`,`app_user_id`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_selfservice_user_client_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `appuser_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `appuser_id_client_id` (`appuser_id`,`client_id`),
  UNIQUE KEY `unique_self_client` (`client_id`),
  CONSTRAINT `m_selfservice_appuser_id` FOREIGN KEY (`appuser_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_selfservice_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_no` varchar(50) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `status_enum` smallint(6) NOT NULL DEFAULT 300,
  `total_approved_shares` bigint(20) DEFAULT NULL,
  `total_pending_shares` bigint(20) DEFAULT NULL,
  `submitted_date` date NOT NULL,
  `submitted_userid` bigint(20) DEFAULT NULL,
  `approved_date` date DEFAULT NULL,
  `approved_userid` bigint(20) DEFAULT NULL,
  `rejected_date` date DEFAULT NULL,
  `rejected_userid` bigint(20) DEFAULT NULL,
  `activated_date` date DEFAULT NULL,
  `activated_userid` bigint(20) DEFAULT NULL,
  `closed_date` date DEFAULT NULL,
  `closed_userid` bigint(20) DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `savings_account_id` bigint(20) NOT NULL,
  `minimum_active_period_frequency` decimal(19,6) DEFAULT NULL,
  `minimum_active_period_frequency_enum` smallint(6) DEFAULT NULL,
  `lockin_period_frequency` decimal(19,6) DEFAULT NULL,
  `lockin_period_frequency_enum` smallint(6) DEFAULT NULL,
  `allow_dividends_inactive_clients` bit(1) DEFAULT b'0',
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `m_share_account_ibfk_1` (`product_id`),
  KEY `m_share_account_ibfk_2` (`savings_account_id`),
  KEY `m_share_account_ibfk_3` (`submitted_userid`),
  KEY `m_share_account_ibfk_4` (`approved_userid`),
  KEY `m_share_account_ibfk_5` (`rejected_userid`),
  KEY `m_share_account_ibfk_6` (`activated_userid`),
  KEY `m_share_account_ibfk_7` (`closed_userid`),
  KEY `m_share_account_ibfk_8` (`lastmodifiedby_id`),
  KEY `m_share_account_ibfk_9` (`client_id`),
  CONSTRAINT `m_share_account_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `m_share_product` (`id`),
  CONSTRAINT `m_share_account_ibfk_2` FOREIGN KEY (`savings_account_id`) REFERENCES `m_savings_account` (`id`),
  CONSTRAINT `m_share_account_ibfk_3` FOREIGN KEY (`submitted_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_account_ibfk_4` FOREIGN KEY (`approved_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_account_ibfk_5` FOREIGN KEY (`rejected_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_account_ibfk_6` FOREIGN KEY (`activated_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_account_ibfk_7` FOREIGN KEY (`closed_userid`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_account_ibfk_8` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_account_ibfk_9` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_account_charge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  `charge_time_enum` smallint(6) NOT NULL,
  `charge_calculation_enum` smallint(6) NOT NULL,
  `charge_payment_mode_enum` smallint(6) NOT NULL DEFAULT 0,
  `calculation_percentage` decimal(19,6) DEFAULT NULL,
  `calculation_on_amount` decimal(19,6) DEFAULT NULL,
  `charge_amount_or_percentage` decimal(19,6) DEFAULT NULL,
  `amount` decimal(19,6) NOT NULL,
  `amount_paid_derived` decimal(19,6) DEFAULT NULL,
  `amount_waived_derived` decimal(19,6) DEFAULT NULL,
  `amount_writtenoff_derived` decimal(19,6) DEFAULT NULL,
  `amount_outstanding_derived` decimal(19,6) NOT NULL DEFAULT 0.000000,
  `is_paid_derived` bit(1) NOT NULL DEFAULT b'0',
  `waived` bit(1) NOT NULL DEFAULT b'0',
  `min_cap` decimal(19,6) DEFAULT NULL,
  `max_cap` decimal(19,6) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `fk_share_account_charge_charge` (`charge_id`),
  KEY `m_share_account_charge_ibfk_2` (`account_id`),
  CONSTRAINT `m_share_account_charge_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `m_share_account_charge_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `m_share_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_account_charge_paid_by` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `share_transaction_id` bigint(20) DEFAULT NULL,
  `charge_transaction_id` bigint(20) DEFAULT NULL,
  `amount` decimal(20,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `m_share_account_transactions_charge_mapping_ibfk1` (`share_transaction_id`),
  KEY `m_share_account_transactions_charge_mapping_ibfk2` (`charge_transaction_id`),
  CONSTRAINT `m_share_account_transactions_charge_mapping_ibfk1` FOREIGN KEY (`share_transaction_id`) REFERENCES `m_share_account_transactions` (`id`),
  CONSTRAINT `m_share_account_transactions_charge_mapping_ibfk2` FOREIGN KEY (`charge_transaction_id`) REFERENCES `m_share_account_charge` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_account_dividend_details` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dividend_pay_out_id` bigint(20) NOT NULL,
  `account_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `status` smallint(6) NOT NULL,
  `savings_transaction_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_share_account_dividend_details_account_id` (`account_id`),
  KEY `FK_m_share_account_dividend_details_dividend_pay_out_id` (`dividend_pay_out_id`),
  CONSTRAINT `FK_m_share_account_dividend_details_account_id` FOREIGN KEY (`account_id`) REFERENCES `m_share_account` (`id`),
  CONSTRAINT `FK_m_share_account_dividend_details_dividend_pay_out_id` FOREIGN KEY (`dividend_pay_out_id`) REFERENCES `m_share_product_dividend_pay_out` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_account_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) NOT NULL,
  `transaction_date` date DEFAULT NULL,
  `total_shares` bigint(20) DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `amount` decimal(20,2) DEFAULT NULL,
  `charge_amount` decimal(20,2) DEFAULT NULL,
  `amount_paid` decimal(20,2) DEFAULT NULL,
  `status_enum` smallint(6) NOT NULL DEFAULT 300,
  `type_enum` smallint(6) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `m_share_account_purchased_shares_ibfk_1` (`account_id`),
  CONSTRAINT `m_share_account_purchased_shares_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `m_share_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `short_name` varchar(4) NOT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `description` varchar(500) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL,
  `currency_digits` smallint(6) NOT NULL,
  `currency_multiplesof` smallint(6) DEFAULT NULL,
  `total_shares` bigint(20) NOT NULL,
  `issued_shares` bigint(20) DEFAULT NULL,
  `totalsubscribed_shares` bigint(20) DEFAULT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `capital_amount` decimal(20,2) NOT NULL,
  `minimum_client_shares` bigint(20) DEFAULT NULL,
  `nominal_client_shares` bigint(20) NOT NULL,
  `maximum_client_shares` bigint(20) DEFAULT NULL,
  `minimum_active_period_frequency` decimal(19,6) DEFAULT NULL,
  `minimum_active_period_frequency_enum` smallint(6) DEFAULT NULL,
  `lockin_period_frequency` decimal(19,6) DEFAULT NULL,
  `lockin_period_frequency_enum` smallint(6) DEFAULT NULL,
  `allow_dividends_inactive_clients` bit(1) DEFAULT b'0',
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `accounting_type` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `m_share_product_ibfk_1` (`createdby_id`),
  KEY `m_share_product_ibfk_2` (`lastmodifiedby_id`),
  CONSTRAINT `m_share_product_ibfk_1` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_share_product_ibfk_2` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_product_charge` (
  `product_id` bigint(20) NOT NULL,
  `charge_id` bigint(20) NOT NULL,
  PRIMARY KEY (`product_id`,`charge_id`),
  KEY `m_share_product_charge_ibfk_1` (`charge_id`),
  CONSTRAINT `m_share_product_charge_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `m_charge` (`id`),
  CONSTRAINT `m_share_product_charge_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `m_share_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_product_dividend_pay_out` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `dividend_period_start_date` date NOT NULL,
  `dividend_period_end_date` date NOT NULL,
  `status` smallint(6) NOT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_share_product_dividend_pay_out_createdby_id` (`createdby_id`),
  KEY `FK_m_share_product_dividend_pay_out_lastmodifiedby_id` (`lastmodifiedby_id`),
  KEY `FK_m_share_product_dividend_pay_out_product_id` (`product_id`),
  CONSTRAINT `FK_m_share_product_dividend_pay_out_createdby_id` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_share_product_dividend_pay_out_lastmodifiedby_id` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_share_product_dividend_pay_out_product_id` FOREIGN KEY (`product_id`) REFERENCES `m_share_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_share_product_market_price` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `from_date` date DEFAULT NULL,
  `share_value` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `m_share_product_market_price_ibfk_1` (`product_id`),
  CONSTRAINT `m_share_product_market_price_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `m_share_product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_staff` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_loan_officer` bit(1) NOT NULL DEFAULT b'0',
  `office_id` bigint(20) DEFAULT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `display_name` varchar(102) NOT NULL,
  `mobile_no` varchar(50) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `organisational_role_enum` smallint(6) DEFAULT NULL,
  `organisational_role_parent_staff_id` bigint(20) DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `joining_date` date DEFAULT NULL,
  `image_id` bigint(20) DEFAULT NULL,
  `email_address` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `display_name` (`display_name`),
  UNIQUE KEY `mobile_no` (`mobile_no`),
  UNIQUE KEY `external_id` (`external_id`),
  KEY `FK_m_staff_m_image` (`image_id`),
  KEY `FK_m_staff_m_office` (`office_id`),
  CONSTRAINT `FK_m_staff_m_image` FOREIGN KEY (`image_id`) REFERENCES `m_image` (`id`),
  CONSTRAINT `FK_m_staff_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_staff_assignment_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `centre_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `createdby_id` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `lastmodified_date` datetime DEFAULT NULL,
  `lastmodifiedby_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_staff_assignment_history_centre_id_m_group` (`centre_id`),
  KEY `FK_m_staff_assignment_history_m_staff` (`staff_id`),
  CONSTRAINT `FK_m_staff_assignment_history_centre_id_m_group` FOREIGN KEY (`centre_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FK_m_staff_assignment_history_m_staff` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_supplier` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `source_system` varchar(50) NOT NULL,
  `external_id` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `business_license_number` varchar(100) DEFAULT NULL,
  `supplier_type` varchar(100) DEFAULT NULL,
  `business_sector` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `tin` varchar(50) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `sync_status` varchar(20) NOT NULL,
  `last_sync_error` varchar(1000) DEFAULT NULL,
  `raw_payload` text DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `last_modified_date` datetime DEFAULT NULL,
  `payment_type_id` bigint(20) DEFAULT NULL,
  `payment_phone_number` varchar(50) DEFAULT NULL,
  `payment_account_number` varchar(150) DEFAULT NULL,
  `payment_bank_name` varchar(150) DEFAULT NULL,
  `payment_account_name` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_m_supplier_source_system_external_id` (`source_system`,`external_id`),
  UNIQUE KEY `uq_m_supplier_source_system_business_license_number` (`source_system`,`business_license_number`),
  UNIQUE KEY `uq_m_supplier_source_system_tin` (`source_system`,`tin`),
  KEY `idx_m_supplier_sync_status` (`sync_status`),
  KEY `idx_m_supplier_business_sector` (`business_sector`),
  KEY `idx_m_supplier_country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_survey_components` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `survey_id` bigint(20) NOT NULL,
  `a_key` varchar(32) NOT NULL,
  `a_text` varchar(255) NOT NULL,
  `description` varchar(4000) DEFAULT NULL,
  `sequence_no` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `survey_id` (`survey_id`),
  CONSTRAINT `m_survey_components_ibfk_1` FOREIGN KEY (`survey_id`) REFERENCES `m_surveys` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_survey_lookup_tables` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `survey_id` bigint(20) NOT NULL,
  `a_key` varchar(255) NOT NULL,
  `description` int(11) DEFAULT NULL,
  `value_from` int(11) NOT NULL,
  `value_to` int(11) NOT NULL,
  `score` decimal(5,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `survey_lookup_tables_survey_id` (`survey_id`),
  CONSTRAINT `m_survey_lookup_tables_ibfk_1` FOREIGN KEY (`survey_id`) REFERENCES `m_surveys` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_survey_questions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `survey_id` bigint(20) NOT NULL,
  `component_key` varchar(32) DEFAULT NULL,
  `a_key` varchar(32) NOT NULL,
  `a_text` varchar(255) NOT NULL,
  `description` varchar(4000) DEFAULT NULL,
  `sequence_no` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `survey_questions_survey_id` (`survey_id`),
  CONSTRAINT `m_survey_questions_ibfk_1` FOREIGN KEY (`survey_id`) REFERENCES `m_surveys` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_survey_responses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `question_id` bigint(20) NOT NULL,
  `a_text` varchar(255) NOT NULL,
  `a_value` int(11) NOT NULL,
  `sequence_no` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `survey_responses_question_id` (`question_id`),
  CONSTRAINT `m_survey_responses_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `m_survey_questions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_survey_scorecards` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `survey_id` bigint(20) NOT NULL,
  `question_id` bigint(20) NOT NULL,
  `response_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `created_on` datetime DEFAULT NULL,
  `a_value` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_survey_scorecards_client` (`client_id`),
  KEY `survey_scorecards_question_id` (`question_id`),
  KEY `response_id` (`response_id`),
  KEY `survey_scorecards_survey_id` (`survey_id`),
  KEY `survey_scorecards_user_id` (`user_id`),
  CONSTRAINT `m_survey_scorecards_ibfk_1` FOREIGN KEY (`survey_id`) REFERENCES `m_surveys` (`id`),
  CONSTRAINT `m_survey_scorecards_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `m_survey_questions` (`id`),
  CONSTRAINT `m_survey_scorecards_ibfk_3` FOREIGN KEY (`response_id`) REFERENCES `m_survey_responses` (`id`),
  CONSTRAINT `m_survey_scorecards_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `m_survey_scorecards_ibfk_5` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_surveys` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `a_key` varchar(32) NOT NULL,
  `a_name` varchar(255) NOT NULL,
  `description` varchar(4000) DEFAULT NULL,
  `country_code` varchar(2) NOT NULL,
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_tasks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `status` bigint(20) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` varchar(300) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `updated_date` datetime DEFAULT NULL,
  `assigned_to` bigint(20) DEFAULT NULL,
  `due_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Fk_tsk_user_id` (`user_id`),
  CONSTRAINT `Fk_tsk_user_id` FOREIGN KEY (`user_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_tax_component` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `percentage` decimal(19,6) NOT NULL,
  `debit_account_type_enum` smallint(6) DEFAULT NULL,
  `debit_account_id` bigint(20) DEFAULT NULL,
  `credit_account_type_enum` smallint(6) DEFAULT NULL,
  `credit_account_id` bigint(20) DEFAULT NULL,
  `start_date` date NOT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_tax_component_createdby` (`createdby_id`),
  KEY `FK_tax_component_credit_gl_account` (`credit_account_id`),
  KEY `FK_tax_component_debit_gl_account` (`debit_account_id`),
  KEY `FK_tax_component_lastmodifiedby` (`lastmodifiedby_id`),
  CONSTRAINT `FK_tax_component_createdby` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_tax_component_credit_gl_account` FOREIGN KEY (`credit_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_tax_component_debit_gl_account` FOREIGN KEY (`debit_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_tax_component_lastmodifiedby` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_tax_component_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tax_component_id` bigint(20) NOT NULL,
  `percentage` decimal(19,6) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_tax_component_history_createdby` (`createdby_id`),
  KEY `FK_tax_component_history_lastmodifiedby` (`lastmodifiedby_id`),
  KEY `FK_tax_component_history_tax_component_id` (`tax_component_id`),
  CONSTRAINT `FK_tax_component_history_createdby` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_tax_component_history_lastmodifiedby` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_tax_component_history_tax_component_id` FOREIGN KEY (`tax_component_id`) REFERENCES `m_tax_component` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_tax_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_tax_group_createdby` (`createdby_id`),
  KEY `FK_tax_group_lastmodifiedby` (`lastmodifiedby_id`),
  CONSTRAINT `FK_tax_group_createdby` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_tax_group_lastmodifiedby` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_tax_group_mappings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tax_group_id` bigint(20) NOT NULL,
  `tax_component_id` bigint(20) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `createdby_id` bigint(20) NOT NULL,
  `created_date` datetime NOT NULL,
  `lastmodifiedby_id` bigint(20) NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_tax_group_mappings_createdby` (`createdby_id`),
  KEY `FK_tax_group_mappings_lastmodifiedby` (`lastmodifiedby_id`),
  KEY `FK_tax_group_mappings_tax_component` (`tax_component_id`),
  KEY `FK_tax_group_mappings_tax_group` (`tax_group_id`),
  CONSTRAINT `FK_tax_group_mappings_createdby` FOREIGN KEY (`createdby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_tax_group_mappings_lastmodifiedby` FOREIGN KEY (`lastmodifiedby_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_tax_group_mappings_tax_component` FOREIGN KEY (`tax_component_id`) REFERENCES `m_tax_component` (`id`),
  CONSTRAINT `FK_tax_group_mappings_tax_group` FOREIGN KEY (`tax_group_id`) REFERENCES `m_tax_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_tellers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `office_id` bigint(20) NOT NULL,
  `debit_account_id` bigint(20) DEFAULT NULL,
  `credit_account_id` bigint(20) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `valid_from` date DEFAULT NULL,
  `valid_to` date DEFAULT NULL,
  `state` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `FK_m_tellers_gl_account_credit_account_id` (`credit_account_id`),
  KEY `FK_m_tellers_gl_account_debit_account_id` (`debit_account_id`),
  KEY `IK_m_tellers_m_office` (`office_id`),
  CONSTRAINT `FK_m_tellers_gl_account_credit_account_id` FOREIGN KEY (`credit_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_m_tellers_gl_account_debit_account_id` FOREIGN KEY (`debit_account_id`) REFERENCES `acc_gl_account` (`id`),
  CONSTRAINT `FK_m_tellers_m_office` FOREIGN KEY (`office_id`) REFERENCES `m_office` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `text` longtext NOT NULL,
  `entity` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_template_m_templatemappers` (
  `m_template_id` bigint(20) NOT NULL,
  `mappers_id` bigint(20) NOT NULL,
  UNIQUE KEY `mappers_id` (`mappers_id`),
  KEY `m_template_id` (`m_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_templatemappers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `mapperkey` varchar(255) DEFAULT NULL,
  `mapperorder` int(11) DEFAULT NULL,
  `mappervalue` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_third_party_disbursement_repayment_event` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_transaction_id` bigint(20) NOT NULL,
  `partner_code` varchar(50) NOT NULL,
  `event_id` varchar(36) NOT NULL,
  `action` varchar(30) NOT NULL,
  `payload` text NOT NULL,
  `delivery_status` varchar(30) NOT NULL,
  `attempt_count` int(11) NOT NULL DEFAULT 0,
  `next_attempt_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_error` varchar(1000) DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_id` (`event_id`),
  UNIQUE KEY `uk_third_party_repayment_event_transaction_action` (`loan_transaction_id`,`action`),
  KEY `idx_third_party_repayment_event_pending` (`delivery_status`,`next_attempt_on_utc`),
  CONSTRAINT `fk_third_party_repayment_event_transaction` FOREIGN KEY (`loan_transaction_id`) REFERENCES `m_loan_transaction` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `header_id` bigint(20) NOT NULL,
  `account_no` varchar(255) DEFAULT NULL,
  `account_opening_date` varchar(255) DEFAULT NULL,
  `account_owner` varchar(255) DEFAULT NULL,
  `account_status` varchar(255) DEFAULT NULL,
  `account_type` varchar(255) DEFAULT NULL,
  `arrear_amount` decimal(19,6) DEFAULT NULL,
  `arrear_days` int(11) DEFAULT NULL,
  `balance_amount` decimal(19,6) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `disputed` bit(1) NOT NULL DEFAULT b'0',
  `is_my_account` bit(1) NOT NULL DEFAULT b'0',
  `last_payment_date` varchar(255) DEFAULT NULL,
  `listing_date` varchar(255) DEFAULT NULL,
  `principal_amount` decimal(19,6) DEFAULT NULL,
  `repayment_duration` int(11) DEFAULT NULL,
  `repayment_term` varchar(255) DEFAULT NULL,
  `scheduled_payment_amount` decimal(30,6) DEFAULT NULL,
  `trade_sector` varchar(255) DEFAULT NULL,
  `worst_arrear` int(11) DEFAULT NULL,
  `account_classification` varchar(255) DEFAULT NULL,
  `account_closing_date` varchar(255) DEFAULT NULL,
  `joint_loan_participants` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion_crb_account_header_id` (`header_id`),
  CONSTRAINT `FK_m_transunion_crb_account_header_id` FOREIGN KEY (`header_id`) REFERENCES `m_transunion_crb_header` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_consumer_logger` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(255) NOT NULL,
  `has_passed` bit(1) DEFAULT b'0',
  `loan_id` int(11) DEFAULT NULL,
  `crb_response_id` varchar(255) DEFAULT NULL,
  `error_logs` text DEFAULT NULL,
  `pay_load` text DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion_crb_consumer_logger-lastmodifiedby_id` (`last_modified_by`),
  KEY `FK_m_transunion_crb_consumer_logger-created_by` (`created_by`),
  CONSTRAINT `FK_m_transunion_crb_consumer_logger-created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_transunion_crb_consumer_logger-lastmodifiedby_id` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_corporate_logger` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(255) NOT NULL,
  `has_passed` bit(1) DEFAULT b'0',
  `loan_id` int(11) DEFAULT NULL,
  `crb_response_id` varchar(255) DEFAULT NULL,
  `error_logs` text DEFAULT NULL,
  `pay_load` text DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `created_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_modified_on_utc` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion_crb_corporate_logger-created_by` (`created_by`),
  KEY `FK_m_transunion_crb_corporate_logger-lastmodifiedby_id` (`last_modified_by`),
  CONSTRAINT `FK_m_transunion_crb_corporate_logger-created_by` FOREIGN KEY (`created_by`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `FK_m_transunion_crb_corporate_logger-lastmodifiedby_id` FOREIGN KEY (`last_modified_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_corporate_profile` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `header_id` bigint(20) NOT NULL,
  `crn` varchar(255) DEFAULT NULL,
  `company_reg_no` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `company_reg_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion-879-m_transunion_crb_header_header_id` (`header_id`),
  CONSTRAINT `FK_m_transunion-879-m_transunion_crb_header_header_id` FOREIGN KEY (`header_id`) REFERENCES `m_transunion_crb_header` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_header` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `crb_name` varchar(255) DEFAULT NULL,
  `pdf_id` varchar(255) DEFAULT NULL,
  `product_display_name` varchar(255) DEFAULT NULL,
  `report_date` varchar(255) DEFAULT NULL,
  `report_type` varchar(255) DEFAULT NULL,
  `request_no` varchar(255) DEFAULT NULL,
  `requester` varchar(255) DEFAULT NULL,
  `created_on_utc` datetime DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `last_modified_by` bigint(20) DEFAULT NULL,
  `last_modified_on_utc` datetime DEFAULT NULL,
  `loan_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion_crb_header-m_client_client_id` (`client_id`),
  KEY `FK_m_transunion_crb_header_loan_id` (`loan_id`),
  CONSTRAINT `FK_m_transunion_crb_header-m_client_client_id` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FK_m_transunion_crb_header_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `m_loan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_personal_profile` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `header_id` bigint(20) NOT NULL,
  `crn` varchar(255) DEFAULT NULL,
  `date_of_birth` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `health_insurance_no` varchar(255) DEFAULT NULL,
  `marital_status` varchar(255) DEFAULT NULL,
  `national_id` varchar(255) DEFAULT NULL,
  `other_names` varchar(255) DEFAULT NULL,
  `salutation` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion_678_crb_header_header_id` (`header_id`),
  CONSTRAINT `FK_m_transunion_678_crb_header_header_id` FOREIGN KEY (`header_id`) REFERENCES `m_transunion_crb_header` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_score_output` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `header_id` bigint(20) NOT NULL,
  `grade` varchar(255) DEFAULT NULL,
  `positive_score` varchar(255) DEFAULT NULL,
  `possibility` varchar(255) DEFAULT NULL,
  `reason_code_aarc1` varchar(255) DEFAULT NULL,
  `reason_code_aarc2` varchar(255) DEFAULT NULL,
  `reason_code_aarc3` varchar(255) DEFAULT NULL,
  `reason_code_aarc4` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion-m_transunion_crb_header_header_id` (`header_id`),
  CONSTRAINT `FK_m_transunion-m_transunion_crb_header_header_id` FOREIGN KEY (`header_id`) REFERENCES `m_transunion_crb_header` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_transunion_crb_summary` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `header_id` bigint(20) NOT NULL,
  `bc_all_sectors` int(11) DEFAULT NULL,
  `bc_my_sector` int(11) DEFAULT NULL,
  `bc_other_sectors` int(11) DEFAULT NULL,
  `bc_180_all_sectors` int(11) DEFAULT NULL,
  `bc_180_my_sector` int(11) DEFAULT NULL,
  `bc_180_other_sectors` int(11) DEFAULT NULL,
  `bc_90_all_sectors` int(11) DEFAULT NULL,
  `bc_90_my_sector` int(11) DEFAULT NULL,
  `bc_90_other_sectors` int(11) DEFAULT NULL,
  `bc_365_all_sectors` int(11) DEFAULT NULL,
  `bc_365_my_sector` int(11) DEFAULT NULL,
  `bc_365_other_sectors` int(11) DEFAULT NULL,
  `fc_all_sectors` int(11) DEFAULT NULL,
  `fc_my_sector` int(11) DEFAULT NULL,
  `fc_other_sectors` int(11) DEFAULT NULL,
  `last_bounced_cheque_date` varchar(255) DEFAULT NULL,
  `last_credit_application_date` varchar(255) DEFAULT NULL,
  `last_fraud_date` varchar(255) DEFAULT NULL,
  `last_npa_listing_date` varchar(255) DEFAULT NULL,
  `last_pa_listing_date` varchar(255) DEFAULT NULL,
  `last_insurance_policy_date` varchar(255) DEFAULT NULL,
  `npa_accounts_all_sectors` int(11) DEFAULT NULL,
  `npa_accounts_my_sector` int(11) DEFAULT NULL,
  `npa_accounts_other_sectors` int(11) DEFAULT NULL,
  `open_accounts_all_sectors` int(11) DEFAULT NULL,
  `open_accounts_my_sector` int(11) DEFAULT NULL,
  `open_accounts_other_sectors` int(11) DEFAULT NULL,
  `pa_accounts_all_sectors` int(11) DEFAULT NULL,
  `pa_accounts_my_sector` int(11) DEFAULT NULL,
  `pa_accounts_other_sectors` int(11) DEFAULT NULL,
  `pa_accounts_with_dh_all_sectors` int(11) DEFAULT NULL,
  `pa_accounts_with_dh_my_sector` int(11) DEFAULT NULL,
  `pa_accounts_with_dh_other_sectors` int(11) DEFAULT NULL,
  `closed_accounts_all_sectors` int(11) DEFAULT NULL,
  `closed_accounts_my_sector` int(11) DEFAULT NULL,
  `closed_accounts_other_sectors` int(11) DEFAULT NULL,
  `ca_all_sectors` int(11) DEFAULT NULL,
  `ca_my_sector` int(11) DEFAULT NULL,
  `ca_other_sectors` int(11) DEFAULT NULL,
  `ch_all_sectors` int(11) DEFAULT NULL,
  `ch_my_sector` int(11) DEFAULT NULL,
  `ch_other_sectors` int(11) DEFAULT NULL,
  `enq_31_to_60_days_all_sectors` int(11) DEFAULT NULL,
  `enq_31_to_60_days_my_sector` int(11) DEFAULT NULL,
  `enq_31_to_60_days_other_sectors` int(11) DEFAULT NULL,
  `enq_61_to_90_days_all_sectors` int(11) DEFAULT NULL,
  `enq_61_to_90_days_my_sector` int(11) DEFAULT NULL,
  `enq_61_to_90_days_other_sectors` int(11) DEFAULT NULL,
  `enq_91_to_180_days_all_sectors` int(11) DEFAULT NULL,
  `enq_91_to_180_days_my_sector` int(11) DEFAULT NULL,
  `enq_91_to_180_days_other_sectors` int(11) DEFAULT NULL,
  `enq_last_30_days_all_sectors` int(11) DEFAULT NULL,
  `enq_last_30_days_my_sector` int(11) DEFAULT NULL,
  `enq_last_30_days_other_sectors` int(11) DEFAULT NULL,
  `pa_closed_accounts_all_sectors` int(11) DEFAULT NULL,
  `pa_closed_accounts_my_sector` int(11) DEFAULT NULL,
  `pa_closed_accounts_other_sectors` int(11) DEFAULT NULL,
  `pa_closed_accounts_with_dh_all_sectors` int(11) DEFAULT NULL,
  `pa_closed_accounts_with_dh_my_sector` int(11) DEFAULT NULL,
  `pa_closed_accounts_with_dh_other_sectors` int(11) DEFAULT NULL,
  `insurance_policies_all_sectors` int(11) DEFAULT NULL,
  `insurance_policies_my_sector` int(11) DEFAULT NULL,
  `insurance_policies_other_sectors` int(11) DEFAULT NULL,
  `enq_91_days_all_sectors` int(11) DEFAULT NULL,
  `enq_91_days_my_sector` int(11) DEFAULT NULL,
  `enq_91_days_other_sectors` int(11) DEFAULT NULL,
  `npa_open_accounts_all_sectors` int(11) DEFAULT NULL,
  `npa_open_accounts_my_sector` int(11) DEFAULT NULL,
  `npa_open_accounts_other_sectors` int(11) DEFAULT NULL,
  `npa_total_value_all_sectors` varchar(255) DEFAULT NULL,
  `npa_total_value_listed_my_sector` varchar(255) DEFAULT NULL,
  `npa_total_value_listed_other_sectors` varchar(255) DEFAULT NULL,
  `pa_open_accounts_all_sectors` int(11) DEFAULT NULL,
  `pa_open_accounts_my_sector` int(11) DEFAULT NULL,
  `pa_open_accounts_other_sectors` int(11) DEFAULT NULL,
  `pa_open_accounts_with_dh_all_sectors` int(11) DEFAULT NULL,
  `pa_open_accounts_with_dh_my_sector` int(11) DEFAULT NULL,
  `pa_open_accounts_with_dh_other_sectors` int(11) DEFAULT NULL,
  `npa_closed_accounts_all_sectors` int(11) DEFAULT NULL,
  `npa_closed_accounts_my_sector` int(11) DEFAULT NULL,
  `npa_closed_accounts_other_sectors` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_transunion_crb_summary_header_id` (`header_id`),
  CONSTRAINT `FK_m_transunion_crb_summary_header_id` FOREIGN KEY (`header_id`) REFERENCES `m_transunion_crb_header` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_trial_balance` (
  `office_id` bigint(20) NOT NULL,
  `account_id` bigint(20) NOT NULL,
  `amount` decimal(19,6) NOT NULL,
  `entry_date` date NOT NULL,
  `created_date` date DEFAULT NULL,
  `closing_balance` decimal(19,6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_validation_limits` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_level_cv_id` bigint(20) DEFAULT NULL,
  `maximum_single_deposit_amount` bigint(20) DEFAULT NULL,
  `maximum_cumulative_balance` bigint(20) DEFAULT NULL,
  `maximum_transaction_limit` bigint(20) DEFAULT NULL,
  `maximum_daily_transaction_amount_limit` bigint(20) DEFAULT NULL,
  `max_client_specific_single_withdrawal_limit` bigint(20) DEFAULT NULL,
  `max_client_specific_daily_withdrawal_limit` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_working_days` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `recurrence` varchar(100) DEFAULT NULL,
  `repayment_rescheduling_enum` smallint(6) DEFAULT NULL,
  `extend_term_daily_repayments` bit(1) DEFAULT b'0',
  `extend_term_holiday_repayment` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mix_taxonomy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `namespace_id` int(11) DEFAULT NULL,
  `dimension` varchar(100) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `need_mapping` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mix_taxonomy_mapping` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL DEFAULT '',
  `config` varchar(200) DEFAULT NULL,
  `last_update_date` datetime DEFAULT NULL,
  `currency` varchar(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mix_xbrl_namespace` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prefix` varchar(20) NOT NULL DEFAULT '',
  `url` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prefix` (`prefix`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_generator` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `object_type` text DEFAULT NULL,
  `object_identifier` bigint(20) DEFAULT NULL,
  `action` text DEFAULT NULL,
  `actor` bigint(20) DEFAULT NULL,
  `is_system_generated` bit(1) DEFAULT b'0',
  `notification_content` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_mapper` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `notification_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `is_read` bit(1) DEFAULT b'0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notification_id` (`notification_id`),
  KEY `notification_mapper_user` (`user_id`),
  KEY `idx_notification_mapper_user_unread` (`user_id`,`is_read`),
  CONSTRAINT `notification_mapper_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `m_appuser` (`id`),
  CONSTRAINT `notification_mapper_ibfk_3` FOREIGN KEY (`notification_id`) REFERENCES `notification_generator` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_token` (
  `token_id` varchar(256) DEFAULT NULL,
  `token` blob DEFAULT NULL,
  `authentication_id` varchar(256) DEFAULT NULL,
  `user_name` varchar(256) DEFAULT NULL,
  `client_id` varchar(256) DEFAULT NULL,
  `authentication` blob DEFAULT NULL,
  `refresh_token` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_client_details` (
  `client_id` varchar(128) NOT NULL,
  `resource_ids` varchar(256) DEFAULT NULL,
  `client_secret` varchar(256) DEFAULT NULL,
  `scope` varchar(256) DEFAULT NULL,
  `authorized_grant_types` varchar(256) DEFAULT NULL,
  `web_server_redirect_uri` varchar(256) DEFAULT NULL,
  `authorities` varchar(256) DEFAULT NULL,
  `access_token_validity` int(11) DEFAULT NULL,
  `refresh_token_validity` int(11) DEFAULT NULL,
  `additional_information` varchar(4096) DEFAULT NULL,
  `autoapprove` bit(1) DEFAULT b'0',
  PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_refresh_token` (
  `token_id` varchar(256) DEFAULT NULL,
  `token` blob DEFAULT NULL,
  `authentication` blob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ppi_likelihoods` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `name` varchar(250) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ppi_likelihoods_ppi` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `likelihood_id` bigint(20) NOT NULL,
  `ppi_name` varchar(250) NOT NULL,
  `enabled` int(11) NOT NULL DEFAULT 100,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ppi_scores` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `score_from` int(11) NOT NULL,
  `score_to` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `r_enum_value` (
  `enum_name` varchar(100) NOT NULL,
  `enum_id` int(11) NOT NULL,
  `enum_message_property` varchar(100) NOT NULL,
  `enum_value` varchar(100) NOT NULL,
  `enum_type` bit(1) NOT NULL,
  PRIMARY KEY (`enum_name`,`enum_id`),
  UNIQUE KEY `enum_message_property` (`enum_name`,`enum_message_property`),
  UNIQUE KEY `enum_value` (`enum_name`,`enum_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ref_banks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bank_code` varchar(20) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `country` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bank_code_country` (`bank_code`,`country`),
  UNIQUE KEY `uq_ref_banks_country_bank_name` (`country`,`bank_name`),
  KEY `idx_ref_banks_active_country_name` (`is_active`,`country`,`bank_name`),
  KEY `idx_ref_banks_active_name` (`is_active`,`bank_name`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ref_loan_transaction_processing_strategy` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(100) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_audit_table` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lastname` varchar(100) NOT NULL,
  `username` varchar(100) NOT NULL,
  `mobile_number` varchar(50) DEFAULT NULL,
  `firstname` varchar(100) NOT NULL,
  `authentication_token` varchar(100) DEFAULT NULL,
  `password` varchar(250) NOT NULL,
  `email` varchar(100) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `created_date` date NOT NULL,
  `account_number` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1_request_audit_table_m_client` (`client_id`),
  CONSTRAINT `FK1_request_audit_table_m_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rpt_sequence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_email_campaign` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `campaign_name` varchar(100) NOT NULL,
  `campaign_type` int(11) NOT NULL,
  `business_rule_id` int(11) DEFAULT NULL,
  `param_value` text DEFAULT NULL,
  `status_enum` int(11) NOT NULL,
  `email_subject` varchar(100) NOT NULL,
  `email_message` text NOT NULL,
  `email_attachment_file_format` varchar(10) DEFAULT NULL,
  `stretchy_report_id` int(11) DEFAULT NULL,
  `stretchy_report_param_map` text DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `submittedon_date` date DEFAULT NULL,
  `submittedon_userid` bigint(20) DEFAULT NULL,
  `approvedon_date` date DEFAULT NULL,
  `approvedon_userid` bigint(20) DEFAULT NULL,
  `recurrence` varchar(100) DEFAULT NULL,
  `next_trigger_date` datetime DEFAULT NULL,
  `last_trigger_date` datetime DEFAULT NULL,
  `recurrence_start_date` datetime DEFAULT NULL,
  `is_visible` bit(1) DEFAULT b'1',
  `previous_run_error_log` text DEFAULT NULL,
  `previous_run_error_message` text DEFAULT NULL,
  `previous_run_status` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scheduled_email_campaign_ibfk_1` (`stretchy_report_id`),
  CONSTRAINT `scheduled_email_campaign_ibfk_1` FOREIGN KEY (`stretchy_report_id`) REFERENCES `stretchy_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_email_configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_email_messages_outbound` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` bigint(20) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `email_campaign_id` bigint(20) DEFAULT NULL,
  `status_enum` int(11) NOT NULL DEFAULT 100,
  `email_address` varchar(50) NOT NULL,
  `email_subject` varchar(50) NOT NULL,
  `message` text NOT NULL,
  `campaign_name` varchar(200) DEFAULT NULL,
  `submittedon_date` date DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `SEFKCLIENT00000001` (`client_id`),
  KEY `SEFKGROUP000000001` (`group_id`),
  KEY `SEFKSTAFF000000001` (`staff_id`),
  KEY `fk_schedule_email_campign1` (`email_campaign_id`),
  CONSTRAINT `SEFKCLIENT00000001` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `SEFKGROUP000000001` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `SEFKSTAFF000000001` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`),
  CONSTRAINT `fk_schedule_email_campign1` FOREIGN KEY (`email_campaign_id`) REFERENCES `scheduled_email_campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduler_detail` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `is_suspended` bit(1) NOT NULL DEFAULT b'0',
  `execute_misfired_jobs` bit(1) NOT NULL DEFAULT b'1',
  `reset_scheduler_on_bootup` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_campaign` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `campaign_name` varchar(100) NOT NULL,
  `campaign_type` int(11) NOT NULL,
  `campaign_trigger_type` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `provider_id` bigint(20) DEFAULT NULL,
  `param_value` text DEFAULT NULL,
  `status_enum` int(11) NOT NULL,
  `message` text NOT NULL,
  `submittedon_date` date DEFAULT NULL,
  `submittedon_userid` bigint(20) DEFAULT NULL,
  `approvedon_date` date DEFAULT NULL,
  `approvedon_userid` bigint(20) DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `recurrence` varchar(100) DEFAULT NULL,
  `next_trigger_date` datetime DEFAULT NULL,
  `last_trigger_date` datetime DEFAULT NULL,
  `recurrence_start_date` datetime DEFAULT NULL,
  `is_visible` bit(1) DEFAULT b'1',
  `is_notification` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  CONSTRAINT `sms_campaign_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `stretchy_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_messages_outbound` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` bigint(20) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `status_enum` int(11) NOT NULL DEFAULT 100,
  `mobile_no` varchar(50) DEFAULT NULL,
  `message` varchar(1000) NOT NULL,
  `campaign_id` bigint(20) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `submittedon_date` date DEFAULT NULL,
  `delivered_on_date` datetime DEFAULT NULL,
  `is_notification` bit(1) NOT NULL DEFAULT b'0',
  `error_message` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKCAMPAIGN00000001` (`campaign_id`),
  KEY `FKCLIENT00000001` (`client_id`),
  KEY `FKGROUP000000001` (`group_id`),
  KEY `FKSTAFF000000001` (`staff_id`),
  CONSTRAINT `FKCAMPAIGN00000001` FOREIGN KEY (`campaign_id`) REFERENCES `sms_campaign` (`id`),
  CONSTRAINT `FKCLIENT00000001` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `FKGROUP000000001` FOREIGN KEY (`group_id`) REFERENCES `m_group` (`id`),
  CONSTRAINT `FKSTAFF000000001` FOREIGN KEY (`staff_id`) REFERENCES `m_staff` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stretchy_parameter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parameter_name` varchar(45) NOT NULL,
  `parameter_variable` varchar(45) DEFAULT NULL,
  `parameter_label` varchar(45) NOT NULL,
  `parameter_displayType` varchar(45) NOT NULL,
  `parameter_FormatType` varchar(10) NOT NULL,
  `parameter_default` varchar(45) NOT NULL,
  `special` varchar(1) DEFAULT NULL,
  `selectOne` varchar(1) DEFAULT NULL,
  `selectAll` varchar(1) DEFAULT NULL,
  `parameter_sql` text DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `parameter_name` (`parameter_name`),
  KEY `fk_stretchy_parameter_001_idx` (`parent_id`),
  CONSTRAINT `fk_stretchy_parameter_001` FOREIGN KEY (`parent_id`) REFERENCES `stretchy_parameter` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1048 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stretchy_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_name` varchar(100) NOT NULL,
  `report_type` varchar(20) NOT NULL,
  `report_subtype` varchar(20) DEFAULT NULL,
  `report_category` varchar(45) DEFAULT NULL,
  `report_sql` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `core_report` bit(1) DEFAULT b'0',
  `use_report` bit(1) DEFAULT b'0',
  `self_service_user_report` bit(1) NOT NULL DEFAULT b'0',
  `report_count_sql` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_name` (`report_name`)
) ENGINE=InnoDB AUTO_INCREMENT=235 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stretchy_report_parameter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `parameter_id` int(11) NOT NULL,
  `report_parameter_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_parameter_unique` (`report_id`,`parameter_id`),
  KEY `fk_report_parameter_001_idx` (`report_id`),
  KEY `fk_report_parameter_002_idx` (`parameter_id`),
  CONSTRAINT `fk_report_parameter_001` FOREIGN KEY (`report_id`) REFERENCES `stretchy_report` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_report_parameter_002` FOREIGN KEY (`parameter_id`) REFERENCES `stretchy_parameter` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=705 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twofactor_access_token` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` varchar(32) NOT NULL,
  `appuser_id` bigint(20) NOT NULL,
  `valid_from` datetime NOT NULL,
  `valid_to` datetime NOT NULL,
  `enabled` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_appuser_UNIQUE` (`token`,`appuser_id`),
  KEY `token` (`token`),
  KEY `user` (`appuser_id`),
  CONSTRAINT `fk_2fa_access_token_user_id` FOREIGN KEY (`appuser_id`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twofactor_configuration` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `value` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_call_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_session_id` varchar(100) DEFAULT NULL,
  `direction` varchar(20) NOT NULL,
  `caller_number` varchar(50) DEFAULT NULL,
  `destination_number` varchar(50) DEFAULT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `recording_url` varchar(500) DEFAULT NULL,
  `dtmf_digits` varchar(50) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `call_purpose` varchar(50) DEFAULT NULL,
  `recording_consent_required` bit(1) NOT NULL DEFAULT b'0',
  `recording_consent_given` bit(1) DEFAULT NULL,
  `callback_request_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_voice_call_log_session_id` (`external_session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_call_queue_entry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_session_id` varchar(100) NOT NULL,
  `ivr_session_id` bigint(20) DEFAULT NULL,
  `caller_number` varchar(50) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `department_code` varchar(50) NOT NULL,
  `queue_position` int(11) NOT NULL,
  `status` varchar(30) NOT NULL,
  `support_ticket_id` bigint(20) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  `connected_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_voice_queue_department_status` (`department_code`,`status`),
  KEY `idx_voice_queue_external_session` (`external_session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_callback_request` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_session_id` varchar(100) NOT NULL,
  `ivr_session_id` bigint(20) DEFAULT NULL,
  `caller_number` varchar(50) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `department_code` varchar(50) DEFAULT NULL,
  `language_code` varchar(15) DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `support_ticket_id` bigint(20) DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  `outbound_call_log_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_voice_callback_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_ivr_menu_definition` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `menu_key` varchar(100) NOT NULL,
  `language_code` varchar(15) NOT NULL,
  `prompt_text` varchar(500) NOT NULL,
  `parent_menu_key` varchar(100) DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_voice_ivr_menu_definition` (`menu_key`,`language_code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_ivr_menu_option` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `menu_key` varchar(100) NOT NULL,
  `language_code` varchar(15) NOT NULL,
  `option_digit` int(11) NOT NULL,
  `option_label` varchar(255) NOT NULL,
  `action_type` varchar(50) NOT NULL,
  `action_target` varchar(100) DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_voice_ivr_menu_option` (`menu_key`,`language_code`,`option_digit`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_ivr_session` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_session_id` varchar(100) NOT NULL,
  `caller_number` varchar(50) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `language_code` varchar(15) DEFAULT NULL,
  `session_status` varchar(40) NOT NULL,
  `current_menu_key` varchar(100) DEFAULT NULL,
  `parent_menu_key` varchar(100) DEFAULT NULL,
  `last_activity_at` datetime NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  `session_context` text DEFAULT NULL,
  `authenticated` bit(1) NOT NULL DEFAULT b'0',
  `auth_expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_voice_ivr_session_external_id` (`external_session_id`),
  KEY `idx_voice_ivr_session_caller_number` (`caller_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voice_voicemail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `external_session_id` varchar(100) NOT NULL,
  `ivr_session_id` bigint(20) DEFAULT NULL,
  `caller_number` varchar(50) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `department_code` varchar(50) DEFAULT NULL,
  `recording_url` varchar(500) DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_voice_voicemail_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_auth_challenge` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `otp_hash` varchar(128) NOT NULL,
  `attempt_count` int(11) NOT NULL DEFAULT 0,
  `expires_at` datetime NOT NULL,
  `verified` bit(1) NOT NULL DEFAULT b'0',
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_whatsapp_auth_phone_created` (`phone_number`,`created_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_business_hours` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `open_time` varchar(8) NOT NULL,
  `close_time` varchar(8) NOT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_business_hours_day` (`day_of_week`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_campaign` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `campaign_name` varchar(100) NOT NULL,
  `campaign_type` int(11) NOT NULL,
  `campaign_trigger_type` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `param_value` text DEFAULT NULL,
  `status_enum` int(11) NOT NULL,
  `message` text DEFAULT NULL,
  `at_template_name` varchar(100) NOT NULL,
  `language_code` varchar(15) NOT NULL,
  `body_variable_mapping` text NOT NULL,
  `submittedon_date` date DEFAULT NULL,
  `submittedon_userid` bigint(20) DEFAULT NULL,
  `approvedon_date` date DEFAULT NULL,
  `approvedon_userid` bigint(20) DEFAULT NULL,
  `closedon_date` date DEFAULT NULL,
  `closedon_userid` bigint(20) DEFAULT NULL,
  `recurrence` varchar(100) DEFAULT NULL,
  `next_trigger_date` datetime DEFAULT NULL,
  `last_trigger_date` datetime DEFAULT NULL,
  `recurrence_start_date` datetime DEFAULT NULL,
  `is_visible` bit(1) DEFAULT b'1',
  `recipient_type` varchar(20) NOT NULL DEFAULT 'CLIENT',
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_name` (`campaign_name`),
  KEY `whatsapp_campaign_ibfk_1` (`report_id`),
  CONSTRAINT `whatsapp_campaign_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `stretchy_report` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_consent_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `consent_granted` bit(1) NOT NULL,
  `consent_source` varchar(50) DEFAULT NULL,
  `terms_version` varchar(50) DEFAULT NULL,
  `recorded_by_user_id` bigint(20) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_whatsapp_consent_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_content_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content_key` varchar(100) NOT NULL,
  `language_code` varchar(15) NOT NULL,
  `body_text` text NOT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_content_message` (`content_key`,`language_code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_conversation_session` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) NOT NULL,
  `conversation_type` varchar(30) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `staff_id` bigint(20) DEFAULT NULL,
  `language_code` varchar(15) DEFAULT NULL,
  `session_status` varchar(40) NOT NULL,
  `current_menu_key` varchar(100) DEFAULT NULL,
  `authenticated` bit(1) NOT NULL DEFAULT b'0',
  `auth_expires_at` datetime DEFAULT NULL,
  `last_activity_at` datetime NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  `session_context` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_whatsapp_session_phone_active` (`phone_number`,`conversation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_interactive_setting` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `config_area` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_interactive_setting_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_menu_definition` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `menu_key` varchar(100) NOT NULL,
  `language_code` varchar(15) NOT NULL,
  `header_text` varchar(500) NOT NULL,
  `parent_menu_key` varchar(100) DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_menu_definition` (`menu_key`,`language_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_menu_option` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `menu_key` varchar(100) NOT NULL,
  `language_code` varchar(15) NOT NULL,
  `option_number` int(11) NOT NULL,
  `option_label` varchar(255) NOT NULL,
  `action_type` varchar(50) NOT NULL,
  `action_target` varchar(100) DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_menu_option` (`menu_key`,`language_code`,`option_number`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_operational_notification` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) NOT NULL,
  `notification_type` varchar(30) NOT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_operational_notification_ticket_type` (`ticket_id`,`notification_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_opt_out_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) NOT NULL,
  `event_type` varchar(20) NOT NULL,
  `keyword` varchar(50) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_whatsapp_opt_out_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whatsapp_support_ticket` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ticket_number` varchar(30) NOT NULL,
  `phone_number` varchar(50) NOT NULL,
  `client_id` bigint(20) DEFAULT NULL,
  `conversation_session_id` bigint(20) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `status` varchar(30) NOT NULL,
  `priority` varchar(20) NOT NULL,
  `summary` varchar(500) DEFAULT NULL,
  `customer_message` text DEFAULT NULL,
  `language_code` varchar(15) DEFAULT NULL,
  `assigned_staff_id` bigint(20) DEFAULT NULL,
  `sla_due_at` datetime DEFAULT NULL,
  `first_response_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `lastmodified_date` datetime NOT NULL,
  `voice_ivr_session_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_whatsapp_support_ticket_number` (`ticket_number`),
  KEY `idx_whatsapp_ticket_status` (`status`),
  KEY `idx_whatsapp_ticket_assigned_staff` (`assigned_staff_id`),
  KEY `idx_whatsapp_ticket_voice_session` (`voice_ivr_session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `x_partner_client_mapping` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `partner_code` varchar(50) NOT NULL,
  `assigned_date` date NOT NULL,
  `assigned_by` bigint(20) NOT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `created_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_partner_client_mapping_client_partner` (`client_id`,`partner_code`),
  KEY `fk_partner_client_mapping_user` (`assigned_by`),
  KEY `idx_partner_client_mapping_client_id` (`client_id`),
  KEY `idx_partner_client_mapping_partner_code` (`partner_code`),
  CONSTRAINT `fk_partner_client_mapping_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `fk_partner_client_mapping_user` FOREIGN KEY (`assigned_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `x_partner_client_mapping_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `mapping_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `partner_code` varchar(50) NOT NULL,
  `action_type` varchar(20) NOT NULL,
  `previous_partner_code` varchar(50) DEFAULT NULL,
  `new_partner_code` varchar(50) DEFAULT NULL,
  `changed_date` datetime NOT NULL,
  `changed_by` bigint(20) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_partner_client_mapping_history_user` (`changed_by`),
  KEY `idx_partner_client_mapping_history_client_id` (`client_id`),
  KEY `idx_partner_client_mapping_history_mapping_id` (`mapping_id`),
  CONSTRAINT `fk_partner_client_mapping_history_client` FOREIGN KEY (`client_id`) REFERENCES `m_client` (`id`),
  CONSTRAINT `fk_partner_client_mapping_history_mapping` FOREIGN KEY (`mapping_id`) REFERENCES `x_partner_client_mapping` (`id`),
  CONSTRAINT `fk_partner_client_mapping_history_user` FOREIGN KEY (`changed_by`) REFERENCES `m_appuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `x_partner_client_verification_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `national_id_masked` varchar(50) DEFAULT NULL,
  `phone_number_masked` varchar(50) DEFAULT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `source_system` varchar(50) DEFAULT NULL,
  `client_account_no` varchar(50) DEFAULT NULL,
  `is_registered` bit(1) DEFAULT NULL,
  `verification_status` varchar(20) DEFAULT NULL,
  `eligibility_status` varchar(20) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `verification_timestamp` datetime DEFAULT NULL,
  `tenant_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_partner_verification_audit_timestamp` (`verification_timestamp`),
  KEY `idx_partner_verification_audit_client` (`client_account_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `x_registered_table` (
  `registered_table_name` varchar(50) NOT NULL,
  `application_table_name` varchar(50) NOT NULL,
  `entity_subtype` varchar(50) DEFAULT NULL,
  `category` int(11) NOT NULL DEFAULT 100,
  PRIMARY KEY (`registered_table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `x_table_column_code_mappings` (
  `column_alias_name` varchar(50) NOT NULL,
  `code_id` int(11) NOT NULL,
  PRIMARY KEY (`column_alias_name`),
  KEY `FK_x_code_id` (`code_id`),
  CONSTRAINT `FK_x_code_id` FOREIGN KEY (`code_id`) REFERENCES `m_code` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

