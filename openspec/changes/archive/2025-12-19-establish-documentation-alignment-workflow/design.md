# Traceability & Alignment Design

## Documentation Dependency Graph

This design outlines the dependencies that the new `specs/documentation-governance/spec.md` will enforce.

### 1. System Level
- **Trigger**: Changes to `openspec/project.md` (if exists), `01_PROJECT_OVERVIEW.md`, or high-level architecture.
- **Dependencies**:
  - `docs/01_SYSTEM_PRD_SR_SD.md`
  - `docs/00_DOCUMENTATION_INDEX.md`

### 2. Backend Level
- **Trigger**: Changes to `backend_django/**` or `openspec/specs/backend-*`.
- **Dependencies**:
  - `docs/requirements/03_BACKEND_PRD_SR_SD.md`
  - `docs/MODULE_REFACTORING.md` (if structure changes)
  - `docs/requirements/UR003_UR004_API_CONTRACT.md` (if API changes)

### 3. Frontend Level
- **Trigger**: Changes to `frontend/**` or `openspec/specs/frontend-*`.
- **Dependencies**:
  - `docs/requirements/02_FRONTEND_PRD_SR_SD.md`

### 4. The "Update Summary" Log
- **Trigger**: ANY meaningful change to the above.
- **Action**: Append entry to `docs/DOCUMENTATION_UPDATE_SUMMARY.md`.

## Agent Workflow (The "Protocol")

To ensure "Every question/interaction" maintains alignment, the Agent should conceptually follow this pseudocode:

```python
def on_task_completion(task_context):
    affected_files = git.get_changed_files()
    
    # 1. Check Spec alignment
    if any(f.endswith('.py') for f in affected_files):
        verify_alignment("backend")
    
    if any(f.endswith('.tsx') for f in affected_files):
        verify_alignment("frontend")

    # 2. Check Doc alignment
    requirements = lookup_requirements(affected_files)
    for req in requirements:
        ensure_updated(req.doc_path)

    # 3. Log
    update_summary_log()
```

This logic will be formalized in the Spec scenarios.

