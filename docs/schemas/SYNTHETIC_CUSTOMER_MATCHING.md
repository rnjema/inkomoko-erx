# Synthetic customer data for CBS and IMS matching

Generate two independent sets of source records from a common set of fictional people. Give each system its own row IDs and apply deliberate differences to one or both records. The fixtures should let the matching pipeline recover valid pairs, flag conflicting evidence, and leave genuinely unmatched or ambiguous records unresolved.

Use the checked-in SQL as the fixture contract. The CBS MariaDB export reflects the fork replay. The IMS PostgreSQL schema uses the physical names inferred from the dictionary. Confirm source-specific identifier semantics and field availability before transferring any synthetic matching rule to production. [Schema findings and run commands](README.md)

## Fixture outputs and ground truth

- Generate CBS and IMS load files separately. A small first run can use 100 to 300 fictional people across two tenant scopes, with a clean baseline and at least one explicit example of every case below. Keep the count and random seed configurable.
- Assign every fictional person a private `truth_entity_id` before creating either source record. Draw birth dates, names, contacts, and geography once per person, then mutate the emitted source records according to the scenarios. Use deterministic row keys and independent CBS and IMS ID sequences. Deliberately overlap some numeric IDs across systems or across CBS tenants.
- Use fabricated names, identifiers, and contact values with fixture data only. Keep synthetic phone numbers out of contact workflows and use addresses on a domain such as `example.invalid` if a fixture field needs email.
- Write a separate truth manifest with `truth_entity_id`, `scenario_id`, source system, source table, source row ID, and tenant or tenant-candidate scope. Include every source row, even singletons and repeated submissions. Include an expected outcome for curated cases, such as `link`, `review`, or `unmatched`. A genuine pair may be expected to go to review when its available evidence is insufficient.
- Keep the manifest, scenario IDs, and mutation logs out of matcher inputs. Avoid encoding the truth in row order, names, local IDs, or a shared extract identifier. Scope and code maps provided to the matcher may identify offices, country codes, or document types. Customer-level truth belongs in the evaluation files.
- Keep database-loadable fixtures separate from intentionally invalid input used to test ingestion. Record the seed, row counts per source and scenario, and the expected outcome of each invalid fixture so rejected rows are visible.

## Source tables and load rules

### CBS tenant database

| Table | What to populate |
| --- | --- |
| `m_office` | Seed first. Supply unique `name` values and a valid `opening_date`. For multi-tenant tests, use a separate CBS tenant database per scope or carry the tenant identifier in exported rows. An office ID is local to its tenant. |
| `m_client` | Supply `account_no` (unique, up to 20 characters), `display_name` (required), and a valid `office_id`. Populate `firstname`, `middlename`, `lastname`, `fullname`, `date_of_birth`, and `mobile_no` as scenario evidence. `external_id` takes up to 100 characters and is nullable and unique per tenant. Check values against MariaDB's target collation when generating variants. |
| `m_code` and `m_code_value` | Seed when using documents. Create a document-type code and corresponding synthetic code values before inserting identifier rows. |
| `m_client_identifier` | Supply a valid `client_id`, a valid `document_type_id`, and `document_key` (up to 50 characters). Respect uniqueness on `(document_type_id, document_key)` and `(client_id, document_type_id, active)`. Multiple document rows can belong to one customer. |
| `m_client_non_person` | Optional extension for business matching. Requires a valid `client_id` and a supplied `constitution_cv_id`. `incorp_no` is a candidate company registration field. Track the registration jurisdiction in the test inputs when using it. |

Keep FK and uniqueness checks enabled for fixture inserts. Multiple CBS customers can have a null external ID. Duplicate non-null external IDs within one CBS tenant belong in a raw extract test that should fail source constraints. To test an incorrect but valid CBS key in an ordinary load, point an IMS record at the external ID of a different existing CBS customer. To test one-to-many candidates without violating CBS uniqueness, put the repeated external ID on multiple IMS records or repeat the token in independent CBS tenants.

### IMS database

| Table | What to populate |
| --- | --- |
| `ims.mel_client` | Supply `flag` explicitly. Use `uid`, `uid_id`, and `id_no` where needed, and populate `fname`, `mname`, `lname`, `client_names`, `dateofbirth`, `phone1`, and `phone2` for matching scenarios. `dateofbirth` is a string, so format variations and invalid strings can be loaded here. Seed `ims.administration_country` if setting `country_id`. |
| `ims.mel_duediligence` | Link `client_id` to `ims.mel_client.id` when the submission belongs to a known IMS client. Populate `mifos_uid_external`, `mifos_demo_graphics_pk`, `mifos_dob`, `mifos_phone`, and any scenario-specific name or document fields. `mifos_national_id` and `mifos_passport_no` are useful for typed document scenarios. |
| `ims.due_diligence_demographics` | Populate `mifos_uid_external`, `mifos_demo_graphics_pk`, `mifos_dob`, `mifos_phone`, and name fields where applicable. Treat these as separate source observations. The reconstructed table has no direct FK to `ims.mel_client`. |

Load parent records first. Leave unused nullable foreign keys null. The due-diligence tables have required boolean columns without defaults in the generated DDL. Read the `NOT NULL` definitions from the SQL and supply every required boolean explicitly. A baseline `false` is sufficient for flags unrelated to the scenario. Use valid calendar dates or null in typed date columns such as `mifos_dob` and CBS `date_of_birth`. Use raw extracts or text fields for invalid date strings. If loading explicit values into identity columns and inserting more generated rows afterward, advance the corresponding identity sequence as needed.

## Cases each run should cover

| Case | How to construct it | Expected behavior |
| --- | --- | --- |
| Clean shared key | Give a CBS client and its IMS due-diligence counterpart the same `external_id` / `mifos_uid_external` in the correct tenant, with consistent demographics. | Link if the candidate key is enabled. |
| Missing or blank keys | Use nulls, empty strings, and whitespace across selected records. Preserve the raw values. Use multiple nulls on the CBS side to avoid duplicate unique values. | Skip empty-key joins. Try demographic matching. |
| Formatting difference | Keep a string key on both sides with different case or surrounding spaces in selected pairs. Add separate customers with IDs such as `00042` and `42` where both tokens are distinct. | Normalize only under a documented source rule. Preserve significant leading zeros and avoid false merges. |
| Stale or orphaned reference | Give IMS a previously used or never-issued external key. Keep another case where that token names a different current CBS customer. | Surface the unmatched reference or conflicting identity. Check fallback evidence before linking. |
| Swapped keys | Exchange two real CBS external IDs between two IMS records while leaving each IMS record's demographics intact. | Flag both conflicts. A valid key lookup alone should not silently produce two false links. |
| Duplicate IMS evidence | Create two due-diligence submissions for one IMS client with the same external key. Separately give two distinct fictional clients the same key. | Preserve repeated submissions as observations. Route a key claimed by distinct customers to review. |
| Tenant collision | Reuse a local numeric ID and an external token across different CBS tenant databases. Drop or corrupt the IMS tenant hint for one case. | Prevent cross-tenant joins. Hold records with unresolved scope for review. |
| Unproven numeric reference | Give `mifos_demo_graphics_pk` values that point to the correct numeric CBS ID, an unrelated ID, or no CBS row in successive cases. Give unrelated CBS and IMS rows the same local ID. | Keep numeric coincidences visible without making them automatic links. |
| Source-only customers | Emit some people to CBS only and others to IMS only. Include a few plausible but unrelated near-neighbors. | Leave them unmatched when evidence is inadequate. |
| Name variation with consistent corroboration | Change case or accents, omit a middle name, reorder components, or add a typo. Keep DOB and a usable phone consistent for a subset. | Recover well-corroborated pairs through fallback matching. |
| Shared or recycled phone | Assign a phone to unrelated clients or people in the same fictional household. Separately shift a phone between dates if the extract includes observation time. | Require independent corroboration. |
| DOB quality problems | Use alternate text formats, ambiguous day/month ordering, year-only values, invalid strings, and one plausible wrong date. | Parse only supported formats. Keep ambiguous values and conflicts visible. |
| Common name and DOB | Give different people the same normalized name and DOB. Add cases with different phones and cases with all corroborating fields absent. | Use additional evidence where available. Leave ties unresolved. |
| Conflicting document evidence | Vary spacing on the same typed document. In separate cases reuse the same string under different document types or issuers, or supply two contradictory strong document values. | Compare within the verified type and issuer namespace. Flag contradictions. |

## Matching when cross-system IDs are absent or unreliable

| Evidence | CBS fields | IMS fields | How to use it |
| --- | --- | --- | --- |
| Document number, when available | `m_client_identifier.document_key` with `document_type_id`, using `m_code_value` to interpret the type | `mel_duediligence.mifos_national_id`, `mifos_passport_no`, and `id_no` in `mel_duediligence` or `mel_client` once its meaning is confirmed | Strong evidence when type, number, and issuing jurisdiction agree. Keep the value as text. Compare generic `id_no` only when its namespace is known. |
| Full name and date of birth | `m_client.firstname`, `middlename`, `lastname`, `fullname`, and `date_of_birth`. For person records, `display_name` can supply an additional variant. | `mel_client.fname`, `mname`, `lname`, `client_names`, and `dateofbirth`. Both due-diligence tables also have `first_name`, `last_name`, `mifos_entity_full_names`, `mifos_dob`, and `cd_date_of_birth`. | Best general fallback combination. Retain original strings and compare normalized components and full-name variants. Parse text DOB using known formats. Common names, placeholder birth dates, and conflicting typed or text dates need further evidence. |
| Phone | `m_client.mobile_no` | `mel_client.phone1`, `phone2`. Both due-diligence tables have `mifos_phone` and `phone_number`. `due_diligence_demographics` also has `mifos_altenative_phone`, using the source spelling. | Normalize to a comparable international number when country context is known. Use phone with name or DOB and account for shared, outdated, and recycled numbers. |
| Office, country, and location | `m_client.office_id` joined to `m_office` | `mel_client.country_id` and location references. Both due-diligence tables have `office_mifos_id_id`, which links to IMS `mel_mifosoffices.id`. | Use mapped country or office values to generate candidates or corroborate matches. Verify any mapping from `mel_mifosoffices.mifos_pk` to CBS office IDs per tenant. Allow for office changes and distinguish office geography from residence or document issuer. |
| Business registration | `m_client_non_person.incorp_no` joined through `client_id`, and CBS client name fields | `mel_duediligence.company_reg_no`, `mifos_inco_no`, and `mifos_business_name`. `due_diligence_demographics` also has `mifos_inco_no`. | Use a separate business matching path. Compare registration numbers plus the issuing jurisdiction and corroborate with company name. |

Start with scoped exact-key candidates where the key is verified. For fallback matching, compare name plus DOB, name plus phone, and typed document evidence using more than one candidate-generation rule so a missing field does not exclude a true pair. Names, phones, or geography on their own are weak evidence. Treat copied values across IMS tables and multiple representations of the same field as one piece of evidence. CBS has `email_address`. The IMS customer and due-diligence tables used here provide no direct email counterpart in the generated schema.

Emit three outcomes for evaluation: linked, needs review, and unmatched. Record which fields agreed, which conflicted, and how many plausible candidates remained. Evaluate accepted-link precision, recall on known pairs, false links on unrelated records, and review or unmatched counts per scenario. Set acceptance thresholds using labeled results, with particular attention to shared contact details, cross-tenant errors, and swapped identifiers.

## Fixture acceptance checks

- A clean load succeeds on both engines with constraints enabled. Invalid input tests fail or quarantine the rows intended to demonstrate ingestion errors.
- Each emitted row resolves to exactly one truth-manifest entry by source, table, scope, and row ID. Verify the per-scenario counts after loading.
- Each intended positive pair, false candidate, and source-only record exists after loading and retains the planned differences. Check this from the stored values, including case, whitespace, and leading zeros.
- Running the generator with the same seed reproduces the same records and truth labels.
- The matching input excludes truth columns and internal scenario identifiers. The evaluation can report a failed case even if overall scores look good.
