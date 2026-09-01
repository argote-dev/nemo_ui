# Migrating to 0.2.0

Theme Contract v2 replaces the five visual-depth vocabulary with four semantic
materials. Replace `NemoSurface(depth: ...)` with `material:`:

| 0.1 depth | 0.2 material |
| --- | --- |
| `deeplySunken`, `sunken` | `NemoMaterial.recessed` |
| `flat` | `NemoMaterial.base` |
| `raised` | `NemoMaterial.raised` |
| `elevated` | `NemoMaterial.floating` |

Replace `shape:` with `cornerRole:` (`control`, `panel`, or `floating`). Legacy
arguments are deprecated transition aids and do not preserve five distinct v1
appearances. Floating is only for transient/prominent local planes. Do not
rebuild shadows in application code: use `NemoThemeData` materials and the
Nemo components, whose illumination and interaction recipes are intentionally
internal.
