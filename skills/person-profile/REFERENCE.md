# Reference: Similar Software and Skills

a local personal-data vault + structured retrieval workflow for AI-assisted form filling.

This skill is a local, structured, privacy-conscious personal profile backend for form filling. It is similar to several existing categories, but differs by being file-based, agent-friendly, and designed for field-level retrieval without exposing the whole profile.

- **Browser autofill**: Chrome can store common identity fields such as name, address, phone, email, and payment details. They are convenient for web forms, but are browser-bound and less flexible for arbitrary PDFs, official forms, or custom fields.
- **Password manager identities**: 1Password, Bitwarden, Dashlane, LastPass, and Keeper support identity records with addresses, passports, licenses, tax IDs, credit cards, and custom fields. They are closest in spirit, but are usually app-centric and not designed for agent workflows that query only specific structured fields.
- **Contacts apps**: Apple Contacts and similar address books store name, address, phone, email, birthday, and organization details. They are useful for basic identity data, but do not model passports, visas, travel documents, or official-form-specific fields well.
- **Personal databases and notes**: Notion, Airtable, Obsidian, Logseq, and personal CRM tools can store structured information. They are flexible, but usually lack sensitive-data handling rules and agent-specific guidance.
- **Secret managers**: Keychain, KeePassXC, `pass`, `gopass`, `sops`, and `age` can store sensitive values locally or encrypted. They are useful for protecting secrets, but do not provide a form-filling profile workflow by themselves.
- **AI memory and form-filling agents**: Some assistants keep user-profile memory or use browser/RPA tools to fill forms. Those systems may automate filling, but often store data in the assistant memory or require sensitive values in the prompt. This skill keeps the profile under user control and encourages targeted retrieval.

The closest mainstream analogue is a password manager's identity profile plus autofill. The distinctive purpose of this skill is:

```text
local structured profile
+ field-level retrieval
+ avoid loading sensitive data into context
+ support for arbitrary forms and documents
```

## Possible Improvements

If you want to evolve this skill, the most useful additions would be:

Encryption support
e.g. YAML encrypted with sops, age, or stored in 1Password CLI.
Schema examples
e.g. info, contact, passport, visa, occupation, education, travel.
Validation
detect expired passport, invalid date formats, missing required fields.
Form mapping
map form labels like “Place of Birth” to info.place_of_birth.
Multi-person support
ask which profile when multiple people exist.
Source attachments
store scans/docs in a per-person folder, referenced from YAML.
