# Component playbooks

Every Nemo UI component ships with a playbook. The playbook is a design and
engineering contract, not a generated API reference.

Copy [`_template.md`](_template.md) to a kebab-case component name and complete
every section before the component is considered done. Use `Not applicable`
with a short reason rather than deleting a section.

Playbooks and the public Dart API are written in English. They must be updated
in the same pull request as any intentional behavioral or visual change.

## Available playbooks

- [NemoSurface](nemo-surface.md) — non-interactive, token-driven visual
  grouping primitive.
