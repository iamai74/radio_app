# Station Model

This model represents a radio station from the Radio-Browser API, matching the specification provided in the API documentation.

## Fields

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique station ID |
| name | String | Station name |
| url | String | Station stream URL |
| homepage | String? | Station homepage URL |
| favicon | String? | Station favicon URL |
| tags | [String]? | Tags associated with the station |
| country | String | Country of the station |
| state | String? | State/region of the station |
| language | String? | Language of the station |
| votes | Int | Number of votes |
| codec | String? | Audio codec |
| bitrate | Int? | Audio bitrate |
| lastCheckOk | Bool | Whether last check was successful |
| lastCheckTime | Date? | Last check time |
| lastCheckTotal | Int | Total checks |
| lastCheckFailures | Int | Failed checks |
| lastCheckDuration | Int | Check duration |
| lastCheckError | String? | Error message |
| lastChangeTime | Date? | Last change time |
| changeCounter | Int | Change counter |
| creationTime | Date? | Creation time |
| urlResolved | String? | Resolved URL |

## Notes

This model implements the `Station` protocol which defines the required properties that all station objects must have. The implementation follows the Radio-Browser API specification for consistent data handling across the application.

The fields have been updated to match the API specification more accurately, including proper data types and documentation of their expected values.