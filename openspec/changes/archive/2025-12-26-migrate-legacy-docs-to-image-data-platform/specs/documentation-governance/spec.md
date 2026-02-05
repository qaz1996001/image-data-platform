## ADDED Requirements

### Requirement: Legacy Documentation Migration for image_data_platform

The project SHALL migrate relevant image_data_platform documentation from `docs/old/` into the structured `docs/image_data_platform/` tree using the defined templates, and SHALL deprecate the old documents as non-canonical after migration.

#### Scenario: Canonical Location After Migration
- **WHEN** a document about image_data_platform exists in both `docs/old/` and `docs/image_data_platform/`
- **THEN** the canonical, actively maintained version MUST reside under `docs/image_data_platform/`
- **AND** the `docs/old/` version MUST be clearly marked as Deprecated or moved under `docs/old/archive/` to avoid being treated as current documentation.

#### Scenario: Creating New Documentation After Migration
- **WHEN** a new document for image_data_platform is created
- **THEN** it MUST be placed under `docs/image_data_platform/` (not `docs/old/`)
- **AND** it MUST be created by copying from the appropriate template in `docs/image_data_platform/templates/`
- **AND** it MUST include document metadata (ID, version, status, change history) and traceability fields as required by the templates.

#### Scenario: Updating Legacy Content
- **WHEN** an Agent or developer needs to update information that currently only exists in `docs/old/`
- **THEN** they SHALL first create or identify the corresponding document under `docs/image_data_platform/` using the templates
- **AND** migrate or rewrite the relevant content into the new document
- **AND** mark the original `docs/old/` document section or file as Deprecated with a link to the new location.


