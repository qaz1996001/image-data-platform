# FE Data Import

## ADDED Requirements

### Requirement: FE-PRD-008 Data Import Wizard

The system **SHALL** provide a guided wizard interface for importing external data (Excel/CSV).

#### Scenario: Successful Import
- Given a researcher uploads a valid CSV file
- When they map the columns correctly and click "Execute"
- Then the system should show a progress bar
- And finally display a summary of success/failure counts

### Requirement: FE-SR-070 Import Wizard Flow

The import page **MUST** implement a 3-step wizard: Upload -> Map -> Execute.

#### Scenario: Step Navigation
- Given the user is on the Upload step
- When they upload a file and click "Next"
- Then the system requests a preview (`POST /import/preview`)
- And advances to the Map step upon success

### Requirement: FE-SR-071 Import Progress & Feedback

The frontend **MUST** poll or listen for import task progress and display the final result.

#### Scenario: Import Completion
- Given an import task is running
- When the task status becomes "completed"
- Then the frontend should stop polling
- And display the "Import Report" component with statistics
