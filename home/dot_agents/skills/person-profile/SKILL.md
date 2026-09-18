---
name: person-profile
description: Local vaults for personal information. Use this skill to query specific profile fields, fill forms and documents with personal details, and save or update information.
---

Find available profiles with `ls "${PERSON_PROFILE_DIR}"` (Avoid hardcoding the path). If none exist, offer to create one.

## Guidelines

- **Do not read sensitive information into context** (passport numbers, etc.): compose read with downstream actions to avoid exposure.
- Validate before filling:
  - Mark missing required fields
  - Note document expiration
- Prefer `"YYYY-MM-DD"` date format- Organized profile into logical sections, i.e. `info`, `contact`, `documents`, `applications`, `education`, `occupation`, `travel`, `family`. Use intuitive key names to match data (e.g. `date_of_birth`, `place_of_issue`).
- Anything that repeats or expires is a list item with an `id`, appended rather than overwritten:
  - `documents[]`: passports, visas, permits, licenses, national/tax IDs — `type`, `country`, `number`, `status` (`current` | `replaced` | `inactive`), dates, `source` (scan path)
  - `applications[]`: one entry per filed form (`kind`, `application_id`, `submitted`, `source`)
  - `travel[]`: one entry per stay (`country`, `arrive`, `depart`); `occupation[]` / `education[]` carry `start_date`, `end_date`, address
  - Older profiles may still have flat `passport` / `*_status` sections; migrate when next edited.

## Examples

```sh
# Inspect structure (list all keys in one-level overview)
yq 'to_entries | .[] | .key + ": " + (.value | keys | tostring)' "${PERSON_PROFILE_DIR}/XXX.yaml"

# Read specific fields — compose with downstream actions (e.g. pipe to form filling)
yq '(.documents[] | select(.type == "passport" and .status == "current") | .number), .info.date_of_birth' "${PERSON_PROFILE_DIR}/XXX.yaml" > form_fields.txt

# Update in place rather than rewriting full file:
yq -i '.contact.phone = "+1-555-0100"' "${PERSON_PROFILE_DIR}/XXX.yaml"
yq -i '(.documents[] | select(.id == "passport_2026")).status = "replaced"' "${PERSON_PROFILE_DIR}/XXX.yaml"
```
