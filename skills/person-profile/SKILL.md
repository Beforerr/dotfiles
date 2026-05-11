---
name: person-profile
description: Local vaults for personal information. Use this skill to query specific profile fields, fill forms and documents with personal details, and save or update information.
---

Find available profiles with `ls "${PERSON_PROFILE_DIR}"` (Avoid hardcoding the path). If none exist, offer to create one.

## Guidelines

- **Do not read sensitive information into context** (passport numbers, etc.): compose read with downstream actions (e.g. pipe into the form/document being filled) to avoid exposure.
- Validate before filling forms:
  - Mark missing required fields
  - Note document validity (e.g. expiring soon)
- Prefer saving with `"YYYY-MM-DD"` date format
- Organized profile into logical sections, i.e. `info`, `personal`, `passport`, `contact`, `occupation`. Use intuitive key names to match data (e.g. `date_of_birth`, `place_of_issue`, `visa_number`).

## Examples

```sh
# Inspect structure (list all keys in one-level overview)
yq 'to_entries | .[] | .key + ": " + (.value | keys | tostring)' "${PERSON_PROFILE_DIR}/XXX.yaml"

# Read specific fields — compose with downstream actions (e.g. pipe to form filling)
yq '.passport.number, .info.date_of_birth' "${PERSON_PROFILE_DIR}/XXX.yaml" > form_fields.txt

# Update in place rather than rewriting full file:
yq -i '.contact.phone = "+1-555-0100"' "${PERSON_PROFILE_DIR}/XXX.yaml"
```
