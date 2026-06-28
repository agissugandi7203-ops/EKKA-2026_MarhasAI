# Genesis.id — Frontend

> Next.js web portal and administrative dashboard for the Genesis.id environmental crowdsourcing platform.

| | |
|---|---|
| **Framework** | Next.js 16.2.9 (App Router, Turbopack) |
| **Runtime** | React 19, TypeScript 5 (strict) |
| **Styling** | TailwindCSS 4.3, custom design tokens |
| **Production** | [genesisHub.web.id](https://genesisHub.web.id) |
| **Backend API** | [genesisHub.my.id](https://genesisHub.my.id) |

---

## Table of Contents

- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Admin Dashboard](#admin-dashboard)
- [Data Integrity](#data-integrity)
- [Security Model](#security-model)
- [Deployment](#deployment)
- [SEO Configuration](#seo-configuration)
- [Cross-Platform Integration](#cross-platform-integration)

---

## Architecture

```
                    ┌─────────────────────┐
                    │   Supabase          │
                    │   PostgreSQL + RLS  │
                    │   pgvector          │
                    │   Storage (S3)      │
                    └────────┬────────────┘
                             │
                    ┌────────┴────────────┐
                    │   NestJS + Fastify  │
                    │   REST API Gateway  │
                    │   JWT / RBAC        │
                    └──┬──────────────┬───┘
                       │              │
              ┌────────┴───┐   ┌──────┴────────┐
              │ Next.js    │   │ Flutter       │
              │ Admin      │   │ Mobile App    │
              │ Dashboard  │   │ (Citizen)     │
              └────────────┘   └───────────────┘
```

The frontend communicates with the NestJS backend via authenticated REST calls. Read-only analytics may query Supabase directly through the client SDK, but all write operations (profile mutations, badge awards, report status changes) are routed through the backend to enforce RBAC and protect the service role key.

### Technology Decisions

| Concern | Choice | Rationale |
|---|---|---|
| Rendering | Client-side (`"use client"`) for dashboard | Real-time state updates, interactive charts, WebSocket-ready |
| Charts | Custom SVG (Bar, Donut) | Zero external dependency, full control over data binding |
| Maps | Leaflet + CartoDB Voyager tiles | Lightweight, offline-capable tile caching |
| Icons | Lucide React | Tree-shakeable, consistent 24px grid |
| Typography | Geist Sans / Geist Mono | Optimized variable font from Google Fonts |
| Auth | JWT stored in `localStorage` | Stateless session, validated server-side per request |

---

## Getting Started

### Prerequisites

- Node.js >= 18
- npm >= 9

### Installation

```bash
cd frontend
npm install
```

### Configuration

Create `.env.local` in the project root:

```env
NEXT_PUBLIC_SUPABASE_URL=https://<project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

> **Important:** Never place `SUPABASE_SERVICE_ROLE_KEY` in any frontend environment file. Service-level operations must be proxied through the NestJS backend.

### Development

```bash
npm run dev          # Start dev server (Turbopack, http://localhost:3000)
npm run build        # Production build
npm run start        # Serve production build
npm run lint         # ESLint check
```

---

## Project Structure

```
frontend/
├── public/
│   ├── sitemap.xml                   # 6 indexed routes
│   ├── robots.txt                    # Crawler directives
│   ├── manifest.json                 # PWA metadata
│   ├── schema-org.json               # Structured data
│   ├── googlee4a64ab1a21f7c0d.html   # Search Console verification
│   └── videos/                       # Landing page media assets
│
├── src/
│   ├── app/
│   │   ├── layout.tsx                # Root layout (fonts, metadata, JSON-LD)
│   │   ├── globals.css               # Design tokens, utility classes
│   │   ├── page.tsx                  # Public landing page
│   │   │
│   │   ├── admin/
│   │   │   ├── page.tsx              # Dashboard controller (~1360 LOC)
│   │   │   ├── login/page.tsx        # JWT authentication
│   │   │   └── components/
│   │   │       ├── Sidebar.tsx       # Grouped navigation (3 categories)
│   │   │       ├── OverviewTab.tsx   # Analytics: metrics, bar chart, donut, table
│   │   │       ├── ReportsTab.tsx    # Report moderation + Leaflet map
│   │   │       ├── ProfilesTab.tsx   # User management + gamification controls
│   │   │       ├── RagTab.tsx        # AI knowledge base (RAG documents)
│   │   │       ├── ChallengesTab.tsx # Gamification challenges and events
│   │   │       ├── BroadcastTab.tsx  # Notification broadcast center
│   │   │       └── AuditTab.tsx      # Immutable admin action log
│   │   │
│   │   ├── contact/                  # Contact page
│   │   ├── docs/                     # API documentation portal
│   │   ├── features/                 # Feature showcase
│   │   ├── services/                 # DaaS service catalog
│   │   └── solutions/                # Smart city solutions
│   │
│   └── components/
│       ├── Header.tsx                # Global navigation
│       └── BoomerangVideoBg.tsx      # Video background component
│
├── Dockerfile                        # Multi-stage production build
├── tailwind.config.ts
├── tsconfig.json                     # strict: true
└── package.json
```

---

## Admin Dashboard

The admin panel (`/admin`) is the operational command center for managing the Genesis.id platform. Access requires JWT authentication with role `admin`.

### Navigation

The sidebar groups modules into three logical sections:

| Group | Modules |
|---|---|
| **Dashboard & Control** | Overview Analytics, Spatial Reports, Citizen Management |
| **Broadcast & Gamification** | Challenge Center, Broadcast Center |
| **AI & Security** | RAG Knowledge Base, System Audit Log |

### Module Reference

#### Overview Analytics

Aggregated platform health metrics derived from live database state.

- **Metric cards** — Total reports, validation queue depth, active citizens, Vision-AI accuracy
- **Bar chart** — Daily report processing velocity (7-day window, index-bucketed from `reports[]`)
- **Donut chart** — Status distribution: resolved, pending AI, pending human, rejected
- **Recent reports table** — Latest 5 reports sorted by `created_at` descending

All values render directly from state arrays. When the database is empty, values display as `0` — never as placeholder numbers.

#### Spatial Reports

Geospatial report moderation with interactive mapping.

- Leaflet map with CartoDB Voyager tiles showing report pin coordinates
- Full-text search and status-based filtering
- Detail drawer with waste photo, AI classification result, GPS coordinates
- Approve / Reject / Delete actions with mandatory confirmation dialogs
- Batch operations (approve all pending, reject all pending)
- Automatic status mapping: frontend `resolved` → backend DTO `approved`

#### Citizen Management

Full administrative control over registered citizen profiles.

- Profile search by name, username, or city
- Gamification adjustment (XP, level, streak) via modal input
- Badge award and revocation through backend API
- Account ban/unban toggle
- Profile deletion with typed confirmation dialog (not `window.confirm`)
- Badge creation with custom code, title, and description

#### RAG Knowledge Base

Document management for the chatbot's retrieval-augmented generation pipeline.

- Document listing with title, category, character count, upload date
- Full-text reading drawer for inline document review
- Document upload with automatic chunking and pgvector embedding
- Deletion requires typed security confirmation (`HAPUS`)

#### Challenge Center

Gamification incentive management.

- Create and delete XP/point-based challenges
- Manage official community events
- Confirmation dialogs on all destructive actions

#### Broadcast Center

Push notification composition and delivery tracking.

- Compose messages with title, body, category (alert/info/event), and target audience
- Historical broadcast log

#### System Audit Log

Immutable record of all administrative actions.

- Logged actions: LOGIN, REPORT_UPDATE, PROFILE_DELETE, BADGE_AWARD, BAN_TOGGLE, etc.
- Fields: admin name, action type, detail string, ISO 8601 timestamp
- Read-only — entries cannot be modified or deleted

### Theme System

The dashboard supports two visual modes:

| Property | Light (default) | Dark |
|---|---|---|
| Background | White / `bg-surface` | `#0a0915` |
| Card surfaces | White, navy borders | `#111026`, indigo borders |
| Sidebar | `white/80` with blur | `#0b0a1a/95` |
| Accent palette | Navy-900, Indigo-600 | Violet-500, `#a78bfa` |

Theme preference persists in `localStorage` under the key `admin_theme` and synchronizes on session load.

### AI Assistant

A slide-out drawer accessible from the top navigation bar. The assistant reads live state arrays to answer operational queries (e.g., report counts, citizen totals, pending validations) with exact figures from the current database snapshot.

---

## Data Integrity

The dashboard operates in two modes, selected via the sidebar toggle:

### Live Mode

Fetches data from the production NestJS API at `https://genesisHub.my.id`. If any API call fails:

1. All state arrays are cleared to `[]`
2. A `connectionError` state is set with the HTTP status or error message
3. A connection failure banner renders in the main content area
4. **No silent fallback to mock data occurs**

This guarantees that administrators always see actual database state or an explicit error — never stale or fabricated numbers.

### Simulator Mode

Uses `localStorage`-backed emulated datasets for offline development and demonstration. Mock data is only loaded and rendered in this mode.

---

## Security Model

### Secret Key Isolation

| Key | Location | Notes |
|---|---|---|
| `SUPABASE_SERVICE_ROLE_KEY` | Backend `.env` only | Bypasses RLS; never exposed to browser |
| `SUPABASE_ANON_KEY` | Frontend `.env.local` | Read-only, subject to RLS policies |
| Admin JWT | `localStorage` | Validated per-request by NestJS `AuthGuard` |

### Role-Based Access Control

| Role | Surface | Capabilities |
|---|---|---|
| `citizen` | Flutter mobile | Read/write own reports and profile |
| `admin` | Next.js dashboard | Full platform control; protected by `@Roles('admin')` + `RolesGuard` |

### Confirmation Safeguards

All destructive actions (delete report, delete profile, remove document, revoke badge) require a modal confirmation dialog. No action uses `window.confirm()` or `window.alert()`.

---

## Deployment

### Docker

The project includes a multi-stage Dockerfile optimized for production:

```bash
docker build -t genesis-frontend .
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_SUPABASE_URL=<url> \
  -e NEXT_PUBLIC_SUPABASE_ANON_KEY=<key> \
  genesis-frontend
```

Build stages:
1. **Builder** (`node:20-alpine`) — `npm ci`, `npm run build`
2. **Runner** (`node:20-alpine`) — Non-root user (`nextjs`, UID 1001), standalone output only

The runner stage copies only the standalone server and static assets, reducing the final image size from ~500MB to ~100MB.

---

## SEO Configuration

| Element | Implementation |
|---|---|
| Title / Description | Per-page via Next.js `Metadata` export |
| OpenGraph | `og:title`, `og:description`, `og:url`, `og:type`, `og:locale` |
| Twitter Cards | `summary_large_image` |
| JSON-LD | `Organization` schema injected in root layout |
| Sitemap | `/sitemap.xml` — 6 public routes |
| Robots | `/robots.txt` — all crawlers allowed |
| Search Console | Verified via `googlee4a64ab1a21f7c0d.html` |
| Canonical | `https://genesisHub.web.id` |

---

## Cross-Platform Integration

Genesis.id consists of three sub-projects:

| Component | Stack | Domain | Role |
|---|---|---|---|
| Frontend (this) | Next.js 16 | `genesisHub.web.id` | Public portal, admin dashboard |
| Backend | NestJS + Fastify | `genesisHub.my.id` | API gateway, JWT auth, RBAC, AI services |
| Mobile | Flutter, Dio, BLoC | Google Play | Citizen app (reports, chatbot, gamification) |

### Data Flow

```
Citizen submits report (Flutter)
  → POST /reports → NestJS
    → Vision AI classifies waste type + danger level
    → Insert to Supabase with status based on confidence threshold
      → confidence >= 70%  →  status: 'approved'
      → confidence < 70%   →  status: 'pending_human'

Admin reviews pending reports (Next.js)
  → GET /reports → Display in Reports Tab
  → PATCH /reports/:id → Approve or Reject
    → XP and badge awarded to reporter on approval
```

---

## License

Proprietary. All rights reserved.

---

*Genesis.id — MarhasAI Team | LKS Dikdasmen Nasional 2026*
