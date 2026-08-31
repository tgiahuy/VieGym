# VieGym — AI_RULES.md

> Mandatory project rules for AI coding/design agents (Antigravity, Codex, Gemini, Claude, etc.).
>
> **Every agent MUST read this file before modifying the VieGym project.**
>
> Last updated: 2026-08-28

---

# 1. Purpose of this file

This file defines the permanent development, UI/UX, architecture, and safety rules for AI agents working on VieGym.

The goal is to ensure that AI-assisted changes:

- Keep the VieGym visual identity consistent.
- Do not accidentally redesign unrelated screens.
- Do not break existing navigation, API integration, state management, or business logic.
- Reuse the existing Flutter design system.
- Produce maintainable Flutter code.
- Preserve the architecture already established in the project.
- Make UI improvements without turning each screen into a different design style.

If a user request conflicts with this file, the explicit user request takes priority only for the requested scope.

---

# 2. Project Context

## Product

**VieGym** is a Vietnamese fitness mobile application focused on:

- Personalized workout planning.
- AI-powered workout recommendations.
- Workout tracking.
- Exercise discovery.
- Vietnamese nutrition tracking.
- Meal planning.
- User health and fitness profiles.
- AI coaching and personalization.

The intended product experience is:

- Modern.
- Premium.
- Sporty.
- Energetic.
- Clean.
- Focused.
- Easy to use during workouts.
- Friendly for Vietnamese users.

---

# 3. Main Application Technology

The primary client application is Flutter.

Main Flutter source:

```text
/mobile
```

Important technologies currently used by the project include:

- Flutter
- Dart
- Material 3
- Riverpod
- go_router
- Dio / generated OpenAPI client

Backend:

```text
/backend
```

Backend technology:

- Java
- Spring Boot
- Spring Security
- JWT
- Spring Data JPA
- Flyway
- PostgreSQL

AI service:

```text
/ai-service
```

AI service technology:

- Python
- FastAPI

---

# 4. Critical Frontend Rule

When modifying the mobile application:

**DO NOT create React, Next.js, Vue, HTML, CSS, or another frontend implementation.**

The production mobile frontend is Flutter.

All mobile UI work must be performed inside:

```text
/mobile
```

unless the user explicitly requests otherwise.

---

# 5. Existing Flutter Architecture Must Be Preserved

The Flutter project is organized approximately as:

```text
mobile/lib/
├── api/
│   └── generated/
├── core/
│   ├── config/
│   ├── network/
│   ├── router/
│   └── theme/
├── features/
├── shared/
│   └── widgets/
└── main.dart
```

Agents must preserve this architecture.

Do not move files across major modules unless necessary.

Do not introduce a completely different application architecture.

---

# 6. VieGym Design Philosophy

VieGym should feel like a premium modern fitness application.

Preferred characteristics:

- Dark fitness-oriented interface.
- Strong visual hierarchy.
- Clear focus on the main action.
- High readability.
- Large touch targets.
- Minimal visual noise.
- Rounded components.
- Strong but controlled red accent.
- Smooth screen-to-screen visual consistency.
- Clear progress indicators.
- Information that can be scanned quickly.

The interface may take inspiration from high-quality fitness and health applications such as:

- Fitbod
- Hevy
- Strong
- Apple Fitness / Apple Health patterns
- Modern premium fitness applications

However:

**Do not directly copy another application's UI.**

VieGym must maintain its own visual identity.

---

# 7. Canonical VieGym Color System

The canonical source of truth for Flutter colors is:

```text
/mobile/lib/core/theme/app_theme.dart
```

Agents MUST inspect that file before changing global colors.

Do not invent a new project-wide palette when editing a single screen.

## 7.1 Primary Brand Color

```text
VieGym Primary
HEX: #FF2E54
Flutter: Color(0xFFFF2E54)
```

Purpose:

- Primary CTA buttons.
- Selected states.
- Active navigation state.
- Important progress indicators.
- Main workout actions.
- Key highlights.
- Focused input borders.
- Important AI actions.

### Rule

Red is an accent color.

**Do NOT cover large portions of every screen with red.**

The main brand color should feel strong because it is used selectively.

---

# 8. Dark Theme Color Tokens

VieGym's primary visual direction is the dark theme.

## App background / main surface

```text
#0A0C14
```

Flutter token:

```dart
AppColors.surfaceDark
```

Use for:

- Screen background.
- Main application canvas.

---

## Surface Container

```text
#141724
```

Use for:

- Cards.
- Input backgrounds.
- Secondary containers.
- Bottom navigation background where defined by theme.

---

## Surface Container High

```text
#1B1F30
```

Use for:

- Elevated sections.
- Selected dark containers.
- Secondary hierarchy surfaces.

---

## Surface Container Highest

```text
#252A40
```

Use sparingly for:

- Stronger elevated surfaces.
- Selected/active dark containers.
- Layered modal UI.

---

## Outline / Border

```text
#282E44
```

Use for:

- Subtle borders.
- Dividers.
- Card outlines.
- Input boundaries.

Borders should remain subtle.

Do not make every component visibly boxed.

---

# 9. Text Colors

## Primary text

```text
#F6F7FB
```

Use for:

- Screen titles.
- Main values.
- Important labels.
- Primary body text.

---

## Secondary text

Secondary text should normally use the current Material `onSurfaceVariant` value generated by the active theme.

Do not hardcode random gray values throughout screens.

Use:

```dart
Theme.of(context).colorScheme.onSurfaceVariant
```

where appropriate.

---

# 10. Semantic Accent Colors

VieGym currently defines the following supporting colors.

## Success / Positive / Completed

```text
Emerald
#10B981
```

Use for:

- Successful completion.
- Positive state.
- Goal achieved.
- Healthy/within-target state where appropriate.

Do not use emerald as another general brand color.

---

## Warning / Attention

```text
Amber
#F59E0B
```

Use for:

- Warnings.
- Attention.
- Pending states.
- Important nutrition/workout notices where appropriate.

---

## Informational

```text
Blue
#3B82F6
```

Use for:

- Informational states.
- Secondary data visualization.
- Informational actions where red would incorrectly imply a primary CTA.

---

## Error

```text
#FF4D6D
```

Use for:

- Validation errors.
- Failed actions.
- Destructive/error messaging.

Do not use error color for normal decoration.

---

# 11. Color Usage Rules

Agents MUST follow these rules.

### Do

- Use colors from the existing theme.
- Prefer `Theme.of(context).colorScheme`.
- Prefer existing `AppColors` tokens.
- Maintain strong contrast.
- Use red for meaningful emphasis.
- Use semantic accent colors only for their semantic purpose.

### Do not

- Introduce random purple, cyan, orange, green, or gradient themes.
- Replace the VieGym red brand color.
- Turn individual screens into different visual themes.
- Hardcode dozens of unrelated color values.
- Use excessive gradients.
- Use excessive glow/neon effects.
- Use red for every icon and every text element.
- Create accessibility problems with low-contrast text.

---

# 12. Gradients

Gradients are allowed only when they improve visual hierarchy.

Preferred usage:

- Hero workout cards.
- Progress visualizations.
- AI feature highlight areas.
- Very limited premium visual elements.

Avoid:

- Gradient backgrounds on every card.
- Rainbow gradients.
- Multiple competing gradients on one screen.
- Bright neon effects that conflict with the dark premium aesthetic.

---

# 13. Typography

The canonical typography is defined in:

```text
/mobile/lib/core/theme/app_theme.dart
```

Current hierarchy includes approximately:

```text
Display Large     57 / Regular
Display Medium    45 / Regular

Headline Large    32 / Extra Bold
Headline Medium   28 / Extra Bold
Headline Small    24 / Bold

Title Large       20 / Bold
Title Medium      16 / Semi Bold

Body Large        16 / Regular
Body Medium       14 / Regular

Label Large       14 / Semi Bold
```

Agents should use the existing theme:

```dart
Theme.of(context).textTheme
```

instead of creating arbitrary text styles.

---

# 14. Typography Rules

Use strong hierarchy.

Typical screen:

```text
Screen title
↓
Short supporting text
↓
Primary content
↓
Secondary information
↓
Primary CTA
```

Avoid:

- Too many font sizes.
- Huge titles on ordinary settings screens.
- Tiny unreadable labels.
- Bold typography everywhere.
- Different font families on different screens.
- Random letter spacing.

Do not add a new project-wide font unless explicitly requested.

---

# 15. Spacing System

Use a consistent spacing scale.

Preferred values:

```text
4
8
12
16
20
24
32
40
48
```

Default horizontal screen padding should normally be:

```text
16–20 px
```

Do not use arbitrary values such as:

```text
13
17
19
27
31
```

unless layout constraints genuinely require them.

Consistency is more important than microscopic visual differences.

---

# 16. Border Radius

The existing VieGym theme uses rounded geometry.

Canonical examples:

```text
Cards:          18px
Filled buttons: 16px
Elevated btn:   14px
Inputs:         14px
```

Agents should stay near these values.

Avoid mixing:

```text
4px
8px
17px
25px
34px
```

randomly across a single screen.

---

# 17. Cards

Current theme behavior:

- Dark elevated surface.
- No unnecessary elevation.
- Rounded corners.
- Subtle outline.
- Comfortable internal spacing.

Cards should be used only when content genuinely needs grouping.

Avoid "card inside card inside card".

Avoid placing every text item inside its own card.

---

# 18. Buttons

Primary actions should normally use the project's filled button style.

Current global characteristics:

```text
Minimum height: 52px
Border radius: 16px
Text: 16px / Extra Bold
Primary background: #FF2E54
Foreground: white
```

Primary CTA examples:

- Tiếp tục
- Bắt đầu tập
- Hoàn thành
- Lưu thay đổi
- Áp dụng

There should usually be one visually dominant primary CTA per screen.

---

# 19. Inputs

Inputs currently follow:

```text
Border radius: 14px
Horizontal padding: 16px
Vertical padding: 14px
Filled dark surface
Focused border: primary red
```

For onboarding screens with a single numeric/text input, it is acceptable to create a more focused input presentation if requested.

However:

- Preserve validation.
- Preserve controller/state behavior.
- Preserve accessibility.
- Preserve keyboard behavior.
- Preserve submit logic.

---

# 20. Navigation

The existing navigation architecture must be preserved.

VieGym uses:

```text
go_router
```

Agents must not:

- Rename routes without explicit instruction.
- Replace go_router.
- Create a second parallel navigation system.
- Break deep-link or redirect logic.
- Change navigation behavior merely to redesign a screen.

---

# 21. Bottom Navigation

The current navigation theme uses:

- Dark surface container.
- Red active state.
- Red translucent selected indicator.
- Muted unselected state.
- Compact labels.

Agents must keep bottom navigation visually consistent between main tabs.

Do not redesign it independently for a single tab.

---

# 22. State Management

VieGym currently uses Riverpod.

Agents MUST NOT introduce:

- Bloc
- GetX
- MobX
- Redux
- Provider replacement
- another state-management architecture

unless explicitly requested.

Reuse the existing Riverpod architecture.

---

# 23. API Integration

The mobile app communicates with the Spring Boot backend.

Generated API code may exist under:

```text
/mobile/lib/api/generated
```

Do not manually redesign generated API files.

Do not change API contracts when the request is only UI-related.

Do not change request/response models just to simplify frontend implementation.

---

# 24. Backend Protection Rule

If a task is specifically about UI:

**Do NOT modify `/backend`.**

Do not change:

- Controllers.
- Services.
- DTOs.
- Entities.
- Security.
- JWT handling.
- Database migrations.
- API contracts.

unless the requested UI change genuinely requires a backend change and the user explicitly authorizes it.

---

# 25. AI Service Protection Rule

If a task is specifically about UI:

**Do NOT modify `/ai-service`.**

AI interface improvements should normally affect Flutter presentation only.

Do not modify AI prompts, provider logic, FastAPI routes, or AI contracts merely because an AI screen is being redesigned.

---

# 26. Generated Code Rule

Generated code should be treated as generated code.

Before modifying a generated file:

1. Determine the source generator.
2. Determine whether the change belongs in the source schema/config instead.
3. Avoid manually editing generated output unless absolutely necessary.

---

# 27. Existing Screen Modification Workflow

Before editing an existing screen, the agent MUST:

1. Read `AI_RULES.md`.
2. Locate the target Flutter screen.
3. Read the complete screen implementation.
4. Inspect widgets used by that screen.
5. Inspect related provider/state/controller logic.
6. Inspect nearby screens in the same flow.
7. Inspect `/mobile/lib/core/theme/app_theme.dart`.
8. Identify existing reusable components.
9. Determine the smallest safe change set.
10. Implement only what is required.

---

# 28. Minimum Change Principle

When the user requests:

> "Change the nickname input design."

Do NOT interpret this as:

> "Redesign the entire onboarding."

When the user requests:

> "Improve this card."

Do NOT interpret this as:

> "Rewrite the entire dashboard."

Make the minimum changes necessary to satisfy the request well.

---

# 29. Preserve Business Logic

UI redesigns must preserve:

- Existing state.
- Validation.
- API calls.
- Data models.
- Loading states.
- Error handling.
- Navigation.
- Persistence.
- User data.
- Analytics hooks if present.
- Existing completed functionality.

When possible, isolate visual changes from business logic.

---

# 30. Shared Component Rule

Before building a new widget:

1. Search `/mobile/lib/shared`.
2. Search the current feature's widgets/components.
3. Search for an existing equivalent widget.
4. Reuse or extend it if appropriate.
5. Create a new component only when reuse would make the code worse.

Do not duplicate nearly identical widgets across multiple screens.

---

# 31. Global Theme Rule

Do NOT modify:

```text
/mobile/lib/core/theme/app_theme.dart
```

for a request affecting only one screen unless there is a clear design-system reason.

Changing the global theme can unintentionally alter every screen.

If a global token change is genuinely required:

- Explain why.
- Verify affected shared widgets.
- Verify important screens.
- Keep backward compatibility whenever possible.

---

# 32. Onboarding Design Rules

Onboarding should feel:

- Friendly.
- Focused.
- Motivational.
- Calm.
- Premium.
- Easy to complete.

Each onboarding screen should primarily focus on **one question or one decision**.

Examples:

- Nickname.
- Age.
- Height.
- Current weight.
- Target weight.
- Fitness goal.
- Training experience.
- Available equipment.
- Preferred workout schedule.

Avoid excessive cards and explanations.

---

# 33. Onboarding Layout Guidance

Preferred pattern:

```text
Progress / Back
        ↓
Question / Title
        ↓
Short explanation
        ↓
Main interaction
        ↓
Optional supporting information
        ↓
Primary CTA
```

The main interaction should be visually dominant.

Examples:

For nickname:

```text
What's your nickname?
      HUY
   ─────────
```

For target weight:

```text
Target weight

      70 kg

────|────|────|────
```

The user should immediately understand what to do.

---

# 34. Workout UI Rules

During an active workout, prioritize:

1. Current exercise.
2. Exercise media/instructions.
3. Sets.
4. Reps.
5. Weight.
6. Completed sets.
7. Workout progress.
8. Next exercise.
9. Exercise replacement when available.

The UI should be usable while the user is tired or moving.

Therefore:

- Large touch targets.
- Clear numbers.
- Minimal unnecessary typing.
- Important actions reachable with one hand where possible.
- Avoid dense paragraphs.
- Avoid hidden primary actions.

---

# 35. Exercise Cards

Exercise cards should clearly communicate:

- Exercise name.
- Target muscle.
- Equipment.
- Sets/reps when relevant.
- Completion state.
- Exercise image/video where relevant.
- Replace/swap action where supported.

Do not overload cards with every available metric.

---

# 36. Nutrition UI Rules

Nutrition screens should prioritize:

```text
Calories
Protein
Carbohydrates
Fat
```

Macro values should be scannable.

Vietnamese dishes should be presented using familiar Vietnamese naming.

Avoid turning nutrition screens into an e-commerce aesthetic.

---

# 37. Macro Color Rule

If macro colors are already established in the target screen or shared component, preserve them.

If not established:

- Prefer neutral UI plus semantic accent colors.
- Do not invent an entirely new rainbow palette.
- Maintain accessibility.
- Keep red reserved primarily for VieGym brand/primary actions.

---

# 38. AI Feature UI Rules

AI is an important VieGym capability but should not visually dominate every screen.

AI UI should communicate:

```text
Recommendation
↓
Reason
↓
Suggested Action
```

AI recommendations should be explainable.

Where relevant, clearly distinguish:

- AI recommendation.
- Existing plan.
- User choice.
- Applied changes.

Use subtle AI visual indicators rather than making every AI element neon.

---

# 39. AI Personalization States

Where applicable, preserve distinctions such as:

```text
PENDING
APPLIED
DISMISSED
EXPIRED
```

Do not collapse meaningful product states for visual convenience.

---

# 40. Empty States

Empty states should:

- Explain what is missing.
- Provide one useful next action.
- Avoid looking like an error when nothing is actually wrong.

Example:

```text
Bạn chưa có lịch tập hôm nay.

[Tạo lịch tập]
```

Better than an empty blank container.

---

# 41. Loading States

Long-running operations should show feedback.

Preferred:

- Skeleton.
- Inline progress.
- Button loading state.
- Small progress indicator.

Avoid blocking full-screen loaders for minor actions.

---

# 42. Error States

Errors must be understandable.

Prefer:

```text
Không thể tải dữ liệu.
Thử lại
```

over raw technical messages.

Do not expose:

- Stack traces.
- Internal exception strings.
- Backend implementation details.
- Sensitive server responses.

---

# 43. Accessibility

All UI changes should consider:

- Text contrast.
- Touch target size.
- Readable font size.
- Dynamic text where practical.
- Screen safe areas.
- Keyboard overlap.
- Long Vietnamese labels.
- Small-screen devices.

Do not design only for one simulator resolution.

---

# 44. Responsive Mobile Layout

VieGym is a mobile-first application.

Screens should work across common phone sizes.

Do not hardcode major layout dimensions based solely on one iPhone simulator.

Prefer:

- Expanded.
- Flexible.
- LayoutBuilder.
- MediaQuery where appropriate.
- SafeArea.
- Scrollable layouts where content may exceed the viewport.

Avoid fixed pixel positioning for major components.

---

# 45. iOS and Android

UI should remain functional on both platforms unless a feature is explicitly platform-specific.

Consider:

- Safe area.
- Keyboard.
- Back navigation.
- Status bar.
- Bottom gesture area.
- Text scaling.

Do not fix an iOS visual issue by breaking Android.

---

# 46. Animations

Animations should be:

- Smooth.
- Short.
- Intentional.
- Subtle.

Good uses:

- Selection changes.
- Progress transitions.
- Expand/collapse.
- Button feedback.
- Page state changes.

Avoid:

- Excessive bouncing.
- Constant glowing.
- Long cinematic transitions.
- Animating every element on screen.

---

# 47. Icons

Use the icon family already used by the application whenever possible.

Avoid mixing many unrelated icon styles.

Icons must communicate function clearly.

Do not replace text with ambiguous icons for important actions.

---

# 48. Images and Exercise Media

Images/videos must:

- Preserve aspect ratio.
- Avoid distortion.
- Load gracefully.
- Provide placeholders/fallbacks when needed.

Exercise media should support understanding the movement, not merely decorate the screen.

---

# 49. Vietnamese UX

VieGym primarily targets Vietnamese users.

User-facing copy should generally be natural Vietnamese unless a screen is intentionally English.

Avoid literal machine-translated Vietnamese.

Prefer concise language.

Example:

Good:

```text
Cân nặng mục tiêu
```

Less desirable:

```text
Mục tiêu của trọng lượng cơ thể của bạn
```

---

# 50. Do Not Invent Product Behavior

If the UI request does not define behavior:

- Inspect existing behavior.
- Preserve it.

Do not invent:

- New APIs.
- New onboarding questions.
- New business rules.
- New subscription/paywall behavior.
- New AI behavior.
- New navigation flows.

unless needed to fulfill an explicit user request.

---

# 51. Do Not Remove Features

Unless explicitly requested:

NEVER remove existing:

- Buttons.
- Navigation.
- Form fields.
- Validation.
- Workout controls.
- Nutrition controls.
- AI actions.
- History.
- Settings.
- Profile data.
- API integrations.

A redesign should not silently reduce functionality.

---

# 52. Forbidden Changes for UI-Only Tasks

For UI-only requests, the agent MUST NOT:

- Rewrite the whole project.
- Replace Riverpod.
- Replace go_router.
- Replace Dio.
- Change backend APIs.
- Modify DB schema.
- Rename routes.
- Rename models without reason.
- Delete working screens.
- Delete validation.
- Remove error states.
- Remove loading states.
- Change authentication flow.
- Add unrelated dependencies.
- Modify unrelated features.
- Change the entire color palette.
- Introduce a second design system.

---

# 53. Package Dependency Rule

Do not add a Flutter package merely to implement a minor visual detail.

Before adding a dependency, check whether Flutter already supports the behavior.

If a package is required:

- Prefer actively maintained packages.
- Avoid huge dependencies for tiny features.
- Confirm compatibility with the existing Flutter SDK.
- Explain why the dependency is needed.

---

# 54. Code Quality

UI code should remain:

- Readable.
- Modular.
- Testable.
- Consistent with existing code.
- Free from unnecessary duplication.

Avoid giant `build()` methods when meaningful subcomponents can improve readability.

However, do not over-engineer simple screens.

---

# 55. Comments

Comments should explain WHY, not obvious WHAT.

Avoid:

```dart
// Create a container
Container(...)
```

Useful:

```dart
// Keep CTA above the iOS home indicator while preserving onboarding spacing.
```

---

# 56. File Scope

Before editing, identify the files that are truly necessary.

For a small screen UI change, typically modify:

```text
1–3 files
```

not dozens.

A large diff is not automatically a better solution.

---

# 57. Existing UI Takes Priority

When a prompt includes a reference image:

Use the image to understand:

- Layout.
- Hierarchy.
- Interaction.
- Visual emphasis.

But preserve VieGym:

- Colors.
- Typography.
- Navigation.
- Components.
- Product identity.

Do not blindly reproduce the reference application's visual identity.

---

# 58. Reference Image Rule

If the user says:

> "Make this look like image 2."

Interpret it as:

> Use image 2 as a layout/UX reference while keeping VieGym's design system.

Do NOT:

- Copy unrelated colors.
- Copy brand logos.
- Copy another app's navigation.
- Replace VieGym design tokens.
- Rebuild unrelated parts of the screen.

---

# 59. Visual Improvement Rule

Agents are allowed to improve details not explicitly specified only when they are clearly within the same requested component.

Examples:

Allowed:

- Slightly improve spacing around the requested nickname input.
- Improve visual alignment of the requested weight ruler.
- Fix minor overflow directly caused by the redesigned component.

Not allowed:

- Redesign dashboard while editing onboarding.
- Change bottom navigation while editing a workout card.
- Replace the global theme while changing a single input.

---

# 60. Completion Checklist

Before declaring a task complete, verify:

### UI

- [ ] Matches VieGym design language.
- [ ] Uses existing theme colors.
- [ ] Text hierarchy is consistent.
- [ ] Spacing is consistent.
- [ ] No overflow.
- [ ] Works on common phone sizes.
- [ ] Safe areas are respected.
- [ ] Keyboard does not break layout.

### Functionality

- [ ] Existing actions still work.
- [ ] Navigation still works.
- [ ] Validation still works.
- [ ] State is preserved.
- [ ] API calls are preserved.
- [ ] Loading/error behavior is preserved.

### Code

- [ ] No unnecessary package added.
- [ ] No unrelated files changed.
- [ ] No duplicate component created unnecessarily.
- [ ] Flutter analyzer issues were not introduced.
- [ ] Formatting remains consistent.

---

# 61. Agent Output Requirement

After making code changes, the agent must provide a concise report.

Required format:

```text
Implementation summary

Modified files:
- ...

Created files:
- ...

Reused components:
- ...

UI changes:
- ...

Behavior changes:
- None / describe if applicable

Business logic:
- Preserved

Navigation:
- Preserved

API contracts:
- Preserved
```

If business logic was not intentionally modified, explicitly state:

```text
Business logic preserved.
```

---

# 62. Required Agent Instruction

For every Antigravity task, use this instruction at the beginning of the prompt:

```text
Before making any changes, read /AI_RULES.md completely and follow it as the authoritative project, Flutter, architecture, and VieGym UI/UX rule set.

Inspect the current implementation before editing.
Preserve existing business logic, navigation, state management, API integrations, and unrelated UI.
Make the minimum safe change required by this task.
```

---

# 63. Source of Truth Priority

When multiple sources disagree, follow this priority:

```text
1. Explicit current user request
2. Existing working application behavior
3. AI_RULES.md
4. Current Flutter theme/design system
5. Project specification/docs
6. Reference screenshots/apps
7. Agent assumptions
```

Agent assumptions always have the lowest priority.

---

# 64. Design Token Source of Truth

The current Flutter design token implementation is located at:

```text
/mobile/lib/core/theme/app_theme.dart
```

Current primary tokens include:

```text
Primary               #FF2E54
Primary Container     #3B121A
Secondary             #232838
Error                 #FF4D6D

Main Dark Surface     #0A0C14
Primary Text          #F6F7FB

Surface Container     #141724
Surface Container Hi  #1B1F30
Surface Highest       #252A40
Outline Variant       #282E44

Success Emerald       #10B981
Warning Amber         #F59E0B
Information Blue      #3B82F6
```

These values reflect the current project theme.

If `app_theme.dart` is intentionally changed later, this section of `AI_RULES.md` should also be updated.

---

# 65. Final Principle

The most important rule when working on VieGym is:

> **Improve the requested part without making the rest of the application feel like a different product.**

Every screen should look and behave as if it belongs to the same VieGym application.

Consistency > novelty.

Clarity > decoration.

Functionality > visual tricks.

Minimal safe changes > unnecessary rewrites.
