# FE Annotation Management

## ADDED Requirements

### Requirement: FE-SR-031 Annotation Edit and Delete

The Report Detail page **MUST** provide UI controls to edit and delete existing AI annotations.

#### Scenario: Edit Annotation
- Given a report with an existing annotation
- When the user clicks the "Edit" icon on the annotation card
- Then a modal or inline form appears with the current values
- And saving the form sends a `PUT` request to update the annotation

#### Scenario: Delete Annotation
- Given a report with an existing annotation
- When the user clicks the "Delete" icon
- Then a confirmation dialog appears
- And confirming the dialog sends a `DELETE` request
- And the annotation list refreshes upon success
