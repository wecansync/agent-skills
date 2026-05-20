# Agent Handoff — Examples

Real-world examples showing how the `.ai/` files look in practice across different
project types and complexity levels.

---

## Example 1: PROJECT.md — PHP/Laravel project (documentation-rich)

```markdown
# Project: Order Management Middleware

## Overview
Multi-brand order management middleware between e-commerce storefronts and an ERP
system. Handles order ingestion, fulfillment orchestration (internal drivers, courier
services, pickup), delivery tracking with PIN verification, financial settlements,
and a Livewire admin panel for multi-location retail operations.

## Tech Stack
- **Language:** PHP 8.3 with `declare(strict_types=1)` on all files
- **Framework:** Laravel 12
- **Database:** MySQL 8.x
- **Frontend:** Livewire 3 + Alpine.js 3 + Tailwind CSS 3
- **Auth:** Laravel Sanctum v4
- **RBAC:** Spatie Laravel Permission v6
- **State machines:** asantibanez/laravel-eloquent-state-machines v6
- **Testing:** PHPUnit 11

## Architecture
Laravel 12 monolith serving: REST API (/api/v1/*), Livewire admin panel (/dashboard/*),
outbound ERP client, and catalog proxy service.

## Key Documents
| Document | Path | Purpose |
|----------|------|---------|
| TRD v5.0 | `docs/TRD-v5.0-final.md` | Source of truth for all features and requirements |
| Implementation Plan | `docs/implementation-plan-v5.md` | Global phasing and priority of all features |
| Project Overview | `docs/project-overview-v5.md` | High-level goals, stakeholders, domain context |
| API Integration Guide | `docs/api-docs/integration-guide.md` | External API reference |
| Delivery Cases Guide | `docs/delivery-cases-guide.md` | Fulfillment flow walkthroughs |

## Conventions
- Service classes in `app/Services/` — no fat controllers
- PHP 8.1 backed enums in `app/Enums/` for all ENUM columns
- All DB changes via migrations — no raw ALTER statements

## How to Run
- Dev server: `php artisan serve`
- Tests: `php artisan test --compact`
- Build frontend: `npm run build`
- Fresh DB: `php artisan migrate:fresh --seed`

## How to Deploy
VPS deployment to Ubuntu via deployer. Post-deploy:
`php artisan migrate --force && php artisan config:cache && php artisan route:cache`
```

---

## Example 2: PROJECT.md — TypeScript/Next.js project (minimal docs)

```markdown
# Project: Analytics Dashboard

## Overview
Real-time analytics dashboard for SaaS metrics. Ingests events via webhooks,
stores in ClickHouse, renders interactive charts and cohort analysis for
product teams.

## Tech Stack
- **Language:** TypeScript 5.6
- **Framework:** Next.js 15 (App Router)
- **Database:** ClickHouse (analytics), PostgreSQL 16 (app data)
- **ORM:** Drizzle ORM
- **Frontend:** React 19 + Tailwind CSS 4 + Recharts
- **Auth:** NextAuth.js v5
- **Testing:** Vitest + Playwright

## Architecture
Next.js 15 monolith with App Router. Server Components for data-heavy pages,
Client Components for interactive charts. API routes handle webhook ingestion.
ClickHouse for time-series queries, PostgreSQL for user/team/config data.

## Key Documents
| Document | Path | Purpose |
|----------|------|---------|
| README | `README.md` | Architecture overview and setup |
| API Spec | `openapi.yaml` | Webhook and query API contract |
| ADR Index | `docs/adrs/` | Architecture Decision Records |

## Conventions
- Collocate components: `app/dashboard/page.tsx` + `app/dashboard/components/`
- Server Components by default, `"use client"` only when needed
- Drizzle schema in `src/db/schema/`, one file per table

## How to Run
- Dev: `pnpm dev`
- Tests: `pnpm test` (unit) / `pnpm test:e2e` (Playwright)
- Build: `pnpm build`

## How to Deploy
Vercel auto-deploy from `main`. Preview deploys on PRs.
```

---

## Example 3: PATHS.md — documentation-rich project

```markdown
# Key Paths

## Application Code
- `app/Models/` — Eloquent models (Order, Delivery, Settlement, Transfer, etc.)
- `app/Services/` — Business logic (FulfillmentService, SettlementService, etc.)
- `app/Enums/` — Backed enums (OrderStatus, DeliveryStatus, PaymentMethod, etc.)
- `app/Http/Controllers/Api/` — REST API endpoints
- `app/Http/Controllers/Dashboard/` — Admin panel controllers

## Database
- `database/migrations/` — Schema changes
- `database/seeders/` — Role, permission, and demo data seeders

## Configuration
- `.env.example` — Environment template
- `config/` — Framework config files

## Tests
- `tests/Feature/` — Feature tests (PHPUnit)
- `tests/Unit/` — Unit tests (PHPUnit)

## Reference Documents (current)

### Requirements
- `docs/TRD-v5.0-final.md` — Technical Requirements Document, source of truth
- `docs/TRD-v5.0-implementation-analysis.md` — Gap analysis: TRD vs codebase

### Implementation Plans
- `docs/implementation-plan-v5.md` — Global plan with feature phasing
- `docs/project-progress-v5.md` — Progress tracking
- `docs/plans/019-per-store-deliveries.md` — Upcoming feature plan
- `docs/plans/020-api-data-population.md` — Upcoming feature plan

### Guides
- `docs/delivery-cases-guide.md` — Fulfillment flow walkthroughs
- `docs/roles-guide.md` — RBAC role definitions and permissions
- `docs/admin-guide.md` — Admin panel user guide
- `docs/demo-guide-v2.0.md` — Demo environment setup

### API Documentation
- `docs/api-docs/integration-guide.md` — External API integration
- `docs/api-docs/api.postman_collection.json` — Postman collection

### Agent & Project Config
- `CLAUDE.md` — Agent coding conventions
- `README.md` — Project readme

## Feature Specs
17 feature specs in `specs/`, numbered 001 through 018.

### Structure per feature
Each `specs/{NNN-feature-name}/` contains:
- `spec.md` — Requirements and acceptance criteria
- `plan.md` — Implementation plan with task breakdown
- `tasks.md` — Actionable task checklist
- `research.md` — Research notes from analysis
- `data-model.md` — Database schema changes
- `contracts/` — API contracts and interface definitions
- `checklists/requirements.md` — Verification checklist

### Active / Recent
- `specs/018-suborder-physical-split/` — Current: multi-location order splitting
- `specs/017-trd-v5-alignment/` — Recent: TRD v5 reconciliation
- `specs/016-inter-branch-transfers/` — Recent: transfer system with QR verification

## Archived Documents
Older versions — reference only, NOT authoritative.
- `docs/archive/TRD-v4.md` — (superseded by TRD-v5.0-final.md)
- `docs/archive/implementation-plan-v4.md` — (superseded by v5)
- `docs/archive/` — 15+ historical docs

## Agent Handoff
- `.ai/conversations/HANDOFF.md` — Agent activity and current state
- `.ai/conversations/LOG.md` — Full activity history
```

---

## Example 4: PATHS.md — minimal project (no docs/ directory)

```markdown
# Key Paths

## Application Code
- `src/app/` — Next.js App Router pages and layouts
- `src/components/` — React components
- `src/hooks/` — Custom React hooks
- `src/db/` — Drizzle schema and queries
- `src/lib/` — Shared utilities

## Configuration
- `.env.example` — Environment template
- `next.config.ts` — Next.js configuration
- `drizzle.config.ts` — Database configuration

## Tests
- `__tests__/` — Vitest unit tests
- `e2e/` — Playwright E2E specs

## Reference Documents (current)
- `README.md` — Architecture overview and setup instructions
- `openapi.yaml` — Webhook and query API contract (OpenAPI 3.1)
- `CONTRIBUTING.md` — Code style and PR guidelines
- `docs/adrs/001-clickhouse-for-analytics.md` — Why ClickHouse over TimescaleDB
- `docs/adrs/002-app-router-migration.md` — Pages → App Router migration notes

## Feature Specs
No dedicated specs directory. Work tracked in GitHub Issues with `feature/` labels.

## Agent Handoff
- `.ai/conversations/HANDOFF.md` — Agent activity and current state
- `.ai/conversations/LOG.md` — Full activity history
```

---

## Example 5: HANDOFF.md — multiple agents collaborating

```markdown
# Agent Handoff
Last updated: 2026-05-20 15:45 by opencode

## Active Work
- Implementing 018-suborder-physical-split — Phase 2: Models & Relations
  - Last session: [sessions/2026-05-20-153022-opencode.md]
  - Status: Migrations done, Order model updated, Settlement model next
  - Blocker: None

## Recent Completions
- [2026-05-20 opencode] Updated Order model with parent/child relations #feature
- [2026-05-20 opencode] Created 3 migration files for suborder split #migration
- [2026-05-20 claude] Created spec and plan for 018-suborder-physical-split #spec
- [2026-05-20 claude] Answered question about settlement flow architecture #question
- [2026-05-19 claude] Fixed COD calculation to include delivery fees (PR #21) #bugfix
- [2026-05-19 codex] Added unit tests for delivery fee calculation #test

## Pending Decisions
- Whether to cascade-delete suborders when parent is cancelled
  → context in decisions/2026-05-20-suborder-cascade-delete.md

## Key Context
- ERP sync is feature-flagged via `erp_settlement_sync` setting
- PIN verification toggleable via `pin_enabled` setting
- Requirements doc is source of truth — check before implementing
```

---

## Example 6: Session file with document references

```markdown
---
agent: opencode
started: 2026-05-20 15:30
task: Implement Order model changes for suborder physical split
tags: [#feature, #model]
---

## Summary
Updated the Order model for parent-child suborder relationships per the 018 spec.
Added two relationships, a scope, and updated casts.

## Files Created/Modified
- `app/Models/Order.php` — added parentOrder(), subOrders(), scopeParentOnly(), casts
- `app/Models/Settlement.php` — added suborder_id to fillable

## Decisions Made
- Used nullable FK (parent_order_id) over polymorphic — simpler queries
  (see decisions/2026-05-20-suborder-relations.md)

## Issues/Blockers Found
- None

## What's Next
- Update state machine for split transitions
- Add splitOrder() to FulfillmentService
- Update admin panel order list to use parentOnly() scope

## References
- `specs/018-suborder-physical-split/spec.md` — feature requirements
- `specs/018-suborder-physical-split/data-model.md` — schema design
- `docs/TRD-v5.0-final.md` (Section 4.3) — suborder requirements
- PR #21 — related fix, touched same Settlement model
```

---

## Example 7: LOG.md — mixed entry types

```markdown
# Agent Activity Log

---
## 2026-05-20 15:30 — opencode #feature
**Task:** Implement Order model changes for suborder physical split
**Outcome:** Added parent_order_id, is_suborder fields. Created parent/children relations.
**Files:** app/Models/Order.php, app/Models/Settlement.php
**Next:** Update state machine for split transitions
---

---
## 2026-05-20 14:30 — opencode #migration
**Task:** Create migrations for 018-suborder-physical-split
**Outcome:** 3 migration files: alter orders, alter settlements, backfill
**Files:** database/migrations/2026_05_20_001*.php, 002*.php, 003*.php
**Next:** Update Eloquent models
---

---
## 2026-05-20 10:15 — claude #question
How does the settlement flow work? → Settlements created per-order on delivery
completion. COD includes delivery_fee. ERP sync gated by setting.
---

---
## 2026-05-19 16:00 — claude #bugfix
**Task:** Fix COD calculation not including delivery fees
**Outcome:** Updated SettlementService. Fixed 3 Livewire views.
**Files:** app/Services/SettlementService.php, resources/views/livewire/orders/*.blade.php
**Next:** PR #21 created — needs review
---
```

---

## Example 8: Decision file

```markdown
# Decision: Nullable FK for suborder parent reference
Date: 2026-05-20
Agent: opencode
Status: accepted

## Context
Feature requires orders to have parent-child relationships for multi-location
fulfillment splitting.

## Decision
Use a nullable `parent_order_id` foreign key on the orders table pointing back
to `orders.id`. Parent orders have NULL parent_order_id.

## Rationale
Only one model type involved (Order → Order). Polymorphic adds complexity for
no benefit. Nullable FK is a standard pattern with built-in ORM relationship support.

## Alternatives Considered
- Polymorphic relation — unnecessary when both sides are the same model
- Separate suborders table — 95% field overlap, maintenance burden
- JSON column — can't query, can't enforce FK constraints

## Consequences
- All list queries must filter to exclude suborders
- Settlement logic needs to handle both parent and suborder rows
- Cascade delete is NOT automatic — needs explicit handling
```

---

## Example 9: First-run bootstrap report

```
Agent handoff system initialized.

Discovered: 12 reference documents, 17 feature specs, 15 archived docs.
Key documents:
  - docs/TRD-v5.0-final.md (requirements, source of truth)
  - docs/implementation-plan-v5.md (global phasing)
  - docs/project-overview-v5.md (stakeholder context)
Active work detected: 018-suborder-physical-split (highest spec + recent commits)
Gaps: none

Files created:
  .ai/PROJECT.md, .ai/PATHS.md, .ai/PLAN.md,
  .ai/conversations/HANDOFF.md, .ai/conversations/LOG.md
```

---

## Quick Reference: When to Create/Update What

| Scenario | LOG.md | HANDOFF.md | Session | Decision | PLAN.md | PATHS.md |
|----------|--------|------------|---------|----------|---------|----------|
| Simple Q&A | one-liner | skip | skip | skip | skip | skip |
| Q&A that reveals insight | one-liner | if important | skip | if decision | skip | skip |
| Bug fix | full entry | update | create | skip usually | update status | skip |
| New feature work | full entry | update | create | if choices made | update status | if new files |
| Spec/plan creation | full entry | update | create | if arch decisions | update | skip |
| Code review | full entry | update | create if findings | skip | skip | skip |
| Migration/schema change | full entry | update | create | if design choice | update status | skip |
| New doc created | full entry | update | skip usually | skip | skip | **add to index** |
| Doc version bumped | one-liner | skip | skip | skip | skip | **update version** |
| First-run bootstrap | skip | create | skip | skip | create | **create full** |
