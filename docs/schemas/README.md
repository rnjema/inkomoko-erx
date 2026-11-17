# CBS and IMS schemas for data quality

Use empty databases for these scripts. CBS targets MariaDB 10.8, matching the fork's default Compose image. IMS targets PostgreSQL 16 in the `ims` namespace. Each script creates schema objects without source records.

| Script | Target | Source |
| --- | --- | --- |
| `cbs.tenant.mariadb.sql` | Empty CBS tenant database, such as `cbs_dq` | Fineract tenant migrations, including Inkomoko changes |
| `cbs.tenant-store.mariadb.sql` | Empty tenant registry database, such as `cbs_tenant_store_dq` | Fineract tenant-store migrations |
| `ims.postgresql.sql` | Empty `ims` namespace in a PostgreSQL database | IMS data dictionary and IMS ERD |

## Source inventory

| Source | Evidence used |
| --- | --- |
| [CBS Data Model PDF](../erd/CBS_Data_Model.pdf) and [PNG](../erd/CBS_Data_Model.png) | Production CBS schema documentation. The PDF identifies 308 tables, 3,396 columns, and 530 relationships. The diagram truncates some identifiers and abbreviates wide tables with a remaining-column count. |
| [Inkomoko Fineract fork](../../../fineract-template) | The tenant and tenant-store Liquibase changelogs supply full SQL identifiers, data types, nullability, defaults, constraints, indexes, and migration order for the repository revision. |
| [IMS Data Model PDF](../erd/IMS_Data_Model.pdf) | The overview and detailed diagram describe IMS entities, fields, and relationships. Labels use Django model names and field types. For example, `auth.User` shows `groups` as a field, and `BigAuto` and `Char` appear as types. |
| [IMS Data Dictionary](../erd/IMS_Data_Dictionary.xlsx) | The `Columns` sheet supplies the physical table names, field types, key markers, nullability, and reference targets. Its model counts align with the PDF. The `Relationships` sheet gives the source and target model for each declared relationship. |

## Create the schemas

Run these sample commands from this directory. The MariaDB examples use two separately created databases. The customer tables are in the tenant script. Load the tenant registry only if the pipeline needs tenant-store metadata.

```sql
CREATE DATABASE cbs_dq CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE cbs_tenant_store_dq CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

```text
mariadb --abort-source-on-error --host=localhost --user=YOUR_USER --password --database=cbs_dq --execute="source cbs.tenant.mariadb.sql"
mariadb --abort-source-on-error --host=localhost --user=YOUR_USER --password --database=cbs_tenant_store_dq --execute="source cbs.tenant-store.mariadb.sql"
psql -X -v ON_ERROR_STOP=1 -d YOUR_DQ_DATABASE -f ims.postgresql.sql
```

## CBS provenance

The schema comes from `fineract-template` at commit `e4555bfd9b949fd02ca4c4081c8ad76f7e1a9ed6`. The master changelog is `fineract-provider/src/main/resources/db/changelog/db.changelog-master.xml`. The replay used the fork's Liquibase 4.13.0 version and followed the two passes in `TenantDatabaseUpgradeService`.

| Database | Initial contexts | Upgrade contexts |
| --- | --- | --- |
| Tenant store | `tenant_store_db,initial_switch,mysql` | `tenant_store_db,mysql` |
| Tenant | `tenant_db,initial_switch,mysql` | `tenant_db,mysql` |

The clean replay needed migration ordering adjustments in a disposable changelog copy. I expanded the custom changelog includes and ran these existing prerequisites earlier. The original fork changelogs were left intact.

| Prerequisite | Dependent migration |
| --- | --- |
| `inko_39_create_table_for_client_other_info.xml` | `INKO-158-integration-to-transunion-crb.xml` |
| `CGLT_84_add_loans_to_loan_product_provisional_entries.xml` | `CGLT_537_dynamic_provisioning_categories.xml` |
| `CGLT_537_dynamic_provisioning_categories.xml` | The CGLT-537 nullability and supplement migrations |
| `FSI-187_add_crb_transunion_logger_details.xml` | `CGLT-476-add_date_on_transunion_logger.xml` |
| `INKO-276-update-icreview-approval-form.xml` | `CGLT-496-003_create_loan_decision_level_table.xml` |
| `CGLT-577_provisioning_batching.xml` | `CGLT-577_provisioning_batch_reversal_and_history.xml` |
| `inko_174_add_odoo_journal_entry_details_in_Journal_entry_table.xml` | `CGLT-606_add_odoo_unposted_journal_entry_index.xml` |

The copied replay also marked the earlier INKO-293 foreign-key replacement as run because INKO-308 had already dropped the constraint. The production ERD also shows `m_loan_cashflow_projection.schedule_id` without a foreign key.

### CBS restore checks

Both exports restored successfully on MariaDB 10.8.8. Catalog comparisons matched tables and collations, column order, types, nullability and defaults, index definitions, and foreign-key columns and update/delete rules. The restored `m_client` table was empty.

| Export | Tables | Columns | Foreign keys |
| --- | ---: | ---: | ---: |
| CBS tenant | 343 | 3,958 | 576 |
| CBS tenant store | 3 | 43 | 2 |

The exports omit Liquibase tracking tables and seed data.

### CBS differences from the production ERD

The migration build reflects the checked-out fork. Deployed tenants may have a different migration history or additional datatables.

| Table | ERD columns | Replay columns |
| --- | ---: | ---: |
| `m_client` | 52 | 55 |
| `m_client_identifier` | 11 | 11 |
| `m_client_address` | 5 | 5 |
| `m_client_non_person` | 9 | 9 |
| `m_loan` | 131 | 135 |

The extra `m_client` columns are `is_migrated`, `migrated_on_date`, and `migrated_from_office_id`. ERD datatables such as `Business Information`, `Business Owner Information`, `Entity Business Information`, `Kiva Business Details`, and `Preferred Language` were absent from the replay. Matching column counts alone do not establish that the definitions agree.

For a tenant-specific inventory, capture `SHOW CREATE TABLE` or an approved structure-only dump from that tenant. For a working CBS application database, use the fork's supported installation or upgrade process so the tenant registry, application seed rows, and Liquibase tracking tables are initialized.

## IMS provenance and reconstruction

- The PDF and workbook describe the same 297 model entries and 9,302 model fields. The workbook's `DB table` column supplies physical table names. The `Columns` and `Relationships` sheets agree on all 651 relationship declarations, including 617 foreign keys, 29 one-to-one relations, and 5 many-to-many relations at the model level.
- The 297 model entries resolve to 296 named physical tables because `Token` and `TokenProxy` share `authtoken_token`. Five inferred Django many-to-many join tables bring the total to 301. The output has 9,309 physical columns, 301 primary keys, and 655 foreign keys after the proxy relationship is deduplicated and each many-to-many becomes two foreign keys.
- Relation fields get the Django default `_id` suffix and reference the target primary key type. One-to-one columns and many-to-many pairs are unique. Foreign keys use PostgreSQL's default `NO ACTION` and are initially deferred. Quoted names preserve the workbook's case. Auto fields are identity columns.
- The sources omit any custom `db_column`, `to_field`, through-model settings, length limits, decimal precision, application defaults, FK indexes, extra unique constraints, and application-level delete behavior. The script uses unrestricted `varchar` and `numeric`, maps Django JSON to `jsonb`, and assumes default join-table and column naming. Confirm these choices against IMS migrations or a schema-only `pg_dump` before using the SQL as a physical production contract.
- Applied successfully on PostgreSQL 16.1 with `ON_ERROR_STOP`. Catalog checks confirmed all 301 tables, 9,309 columns, 301 primary keys, 655 foreign keys, 33 unique constraints beyond the primary keys, and 5 nonnegative checks for positive-integer fields.

## Customer reconciliation

For fixture generation and fallback matching, see the [synthetic customer matching brief](SYNTHETIC_CUSTOMER_MATCHING.md).

| Source | Fields to extract | What the schema establishes |
| --- | --- | --- |
| CBS `m_client` | `id`, `external_id`, `account_no`, `office_id` | The tenant-local primary key is `id`. `external_id` is nullable and unique within the replayed tenant. `account_no` is required and unique. Carry the tenant identifier in extracts so the same numeric ID can be distinguished across tenants. |
| CBS `m_client_identifier` | `client_id`, `document_type_id`, `document_key`, `active` | `client_id` links to the customer. The unique document key combines type and number. A customer can have multiple document rows. |
| IMS `ims.mel_client` | `id`, `uid`, `uid_id`, `id_no`, `client_names`, `dateofbirth`, `phone1`, `phone2` | This table holds program client records. The dictionary describes the identifiers, date-of-birth field, and phone numbers as character fields. |
| IMS `ims.due_diligence_demographics` and `ims.mel_duediligence` | `mifos_uid_external`, `mifos_demo_graphics_pk` | Both tables expose these nullable CBS integration fields. The sources do not establish a cross-system foreign key or identify what populates `mifos_demo_graphics_pk`. |

1. Verify the source table and column definitions against the deployed CBS tenant and IMS PostgreSQL schema. Confirm the tenant associated with each IMS record before comparing identifiers.
2. Test CBS `m_client.external_id` against IMS `mifos_uid_external` within the corresponding tenant. Measure missing and blank keys, duplicate keys on each side, one-to-one and ambiguous matches, and records unmatched in both directions before treating it as a join key.
3. Preserve original identifier strings, including leading zeros. Derive comparison values separately. Document-number comparisons also need document type, and names, phones, and dates of birth can help review ambiguous matches.
4. Stage raw extracts separately when the pipeline needs to capture duplicate keys, missing required values, or orphan records before enforcing the target schema constraints.

The validation used empty local databases and migration seed data. It established that the DDL loads and that the expected structure is present. Customer match rates and the meaning of the proposed cross-system keys remain unverified with source records.

