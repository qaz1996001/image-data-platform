# Implementation Status: Unify Project Resource Workbench

## Task 1: Audit Results Actions ✅

### Findings

#### Study Search Page (`frontend/src/pages/StudySearch/index.tsx`)
- **Column Manager**: Uses `useColumnManager` hook with localStorage persistence
- **Selection Drawer**: Uses `SelectionDrawer` component from `@components/ListWorkbench`
- **Batch Actions**: Uses `useBatchActions` hook with `batchActionsRegistry` from `@utils/batchActionsRegistry`
- **Available Actions**: 
  - Add to Project (`add_to_project`)
  - Export (`export`)
  - Delete (`delete`)
  - Archive (`archive`)
  - Send (`send`)
  - Print (`print`)

#### Report Search Page (`frontend/src/pages/ReportSearch/index.tsx`)
- **Column Manager**: Uses `useColumnManager` hook with localStorage persistence
- **Selection Drawer**: Uses `SelectionDrawer` component from `@components/ListWorkbench`
- **Batch Actions**: Uses `useReportBatchActions` hook with `reportBatchActionsRegistry` from `@utils/reportBatchActionsRegistry`
- **Available Actions**:
  - Add to Project (`add_to_project`)
  - Export (`export`)
  - Print (`print`)
  - Archive (`archive`)
  - Delete (`delete`)

#### Reusable Components
- `useColumnManager` hook: ✅ Reusable
- `SelectionDrawer` component: ✅ Reusable (generic)
- `useBatchActions` hook: ✅ Reusable (currently typed for StudyListItem, needs generalization)
- `BatchActionsRegistry`: ✅ Reusable (generic registry)

### Next Steps
- [ ] Generalize `useBatchActions` to support both Study and Report types
- [ ] Create unified batch action registry for project resources
- [ ] Ensure SelectionDrawer can handle mixed resource types

