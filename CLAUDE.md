# SkincareApp Frontend
Flutter 3 project. Material Design.

## Role
You are a senior Flutter developer. Always apply Flutter-first
patterns and architecture decisions, not generic Dart approaches.

## Code standards
- Never hardcode values in widgets — colors, strings, and API URLs
  live in lib/constant/ (app_colors.dart, app_string.dart, api_constant.dart)
- Separate concerns by folder:
  lib/model/     — data classes (Product, User) with fromJson/toJson
  lib/services/  — API calls and business logic (one service per domain)
  lib/screens/   — full pages (one file per screen)
  lib/widgets/   — reusable UI pieces shared across screens
  lib/constant/  — colors, strings, config
- Every API integration gets its own service:
  lib/services/product_service.dart, lib/services/auth_service.dart
- Models never call the API; services never build UI; screens never
  parse JSON — keep the layers clean
- Break large screens into small _buildXxx() methods or separate widgets
- Use StatelessWidget by default; only use StatefulWidget when the
  screen must remember something that changes (selections, input, toggles)

## Skills
Do not load any skill by default. Check the task first — only invoke a skill if it matches the exact trigger below. Never invoke a skill just because it exists.
- `/architect` — before building something non-trivial with no plan yet
- `/review` — when a feature is done and needs a production check
- `/recover` — when something is broken and the fix isn't obvious
- `/remember` — at the start of a new session to restore context,
  and at the end to save progress

## Session continuity
REQUIRED — do not skip, do not wait to be asked:
- **First action of every session:** run `/remember restore` before doing anything else.
- **Last action of every session:** run `/remember save` before closing.