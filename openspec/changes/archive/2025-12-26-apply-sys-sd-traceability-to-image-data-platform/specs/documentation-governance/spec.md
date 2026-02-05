## MODIFIED Requirements

### Requirement: Documentation Consistency Policy

The project SHALL maintain strict consistency between Implementation (Code), Specification (OpenSpec), and Documentation (Docs folder).

#### Scenario: Backend Module Refactoring
- **WHEN** a change is made to the backend module structure (e.g., moving files between `study`, `project`, `report`, `common`)
- **THEN** the following documents MUST be verified and updated:
  1. `docs/MODULE_REFACTORING.md` (Reflect the structural change)
  2. `docs/requirements/03_BACKEND_PRD_SR_SD.md` (Update module paths in SR/SD sections)
  3. `docs/requirements/UR003_UR004_API_CONTRACT.md` (If API paths/imports changed)

#### Scenario: High-Level Feature Addition
- **WHEN** a new Feature or Requirement is added via OpenSpec
- **THEN** the following documents MUST be updated:
  1. `docs/01_PROJECT_OVERVIEW.md` (Add feature to Feature List or Phase Plan)
  2. `docs/requirements/01_SYSTEM_PRD_SR_SD.md` (Add high-level mapping)
  3. `docs/DOCUMENTATION_UPDATE_SUMMARY.md` (Log the documentation update)

#### Scenario: Continuous Documentation Indexing
- **WHEN** any new document is created or renamed
- **THEN** `docs/00_DOCUMENTATION_INDEX.md` MUST be updated to include the new file in the appropriate section.

#### Scenario: Traceability Chain Update
- **WHEN** the traceability chain structure is updated (e.g., adding SYS-SD layer)
- **THEN** the following documents MUST be updated:
  1. `docs/image_data_platform/requirements/01_SYSTEM_PRD_SR_SD.md` (Update traceability chain diagram and matrix)
  2. `docs/image_data_platform/traceability/01_TRACEABILITY_MATRIX.md` (Update traceability hierarchy and tables)
  3. `docs/image_data_platform/requirements/00_REQUIREMENTS_INDEX.md` (If exists, update ID naming conventions)

### Requirement: Regulations Compliance Check

The project SHALL check regulations compliance when requirements are added or modified.

#### Scenario: New Requirement Added
- **WHEN** a new requirement is added via OpenSpec or requirements documents
- **THEN** the following compliance checks MUST be performed:
  1. Use `docs/regulations/ISO-IEC-IEEE-29148/requirements-quality.md` checklist to verify requirement quality
  2. Ensure requirement has unique ID and follows naming conventions (UR-xxx, SYS-SR-xxx, SYS-SD-xxx, FE-SR-xxx, BE-SR-xxx, etc.)
  3. Ensure requirement is traceable to upstream requirements (UR → SYS-SR → SYS-SD → subsystem SR)
  4. Update traceability matrix if needed (`openspec/changes/align-phase1-specs-traceability/specs/traceability/spec.md`)

#### Scenario: Requirement Modified
- **WHEN** an existing requirement is modified
- **THEN** the following compliance checks MUST be performed:
  1. Verify modified requirement still meets quality checklist criteria
  2. Identify all affected downstream elements (design, code, tests)
  3. Update traceability matrix to reflect changes
  4. Document change reason and impact analysis

#### Scenario: Traceability Chain Completeness Check
- **WHEN** a traceability chain is established or updated
- **THEN** the following completeness checks MUST be performed:
  1. Verify all UR have corresponding SYS-SR
  2. Verify all SYS-SR have corresponding SYS-SD (system design)
  3. Verify all SYS-SD have corresponding subsystem SR (FE-SR/BE-SR)
  4. Verify all subsystem SR have corresponding subsystem design and implementation
  5. Verify bidirectional traceability (Traces to and Traced by) is complete

#### Scenario: Regulations File Update Trigger
- **WHEN** any of the following changes occur:
  - New standard or regulation is introduced
  - Compliance gap is identified
  - Standard version is updated
- **THEN** `docs/regulations/` files MUST be updated accordingly:
  1. Update compliance mapping tables
  2. Update gap analysis
  3. Update improvement plans
  4. Document changes in regulations index

