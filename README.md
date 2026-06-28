<div align="center">
  <img src="mobile/assets/images/logo.png" alt="Genesis Logo" width="120" />
</div>

<h1 align="center">Genesis</h1>

<div align="center">
  <p>AI-powered platform that encourages responsible waste management through computer vision, gamification, and environmental insights.</p>
</div>

<div align="center">
  <a href="#license">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" />
  </a>
  <a href="#tech-stack">
    <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  </a>
  <a href="#tech-stack">
    <img src="https://img.shields.io/badge/NestJS-E0234E?logo=nestjs&logoColor=white" alt="NestJS" />
  </a>
  <a href="#tech-stack">
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  </a>
</div>

## Screenshots

<div align="center">
  <img src="docs/assets/screenshot-home.png" width="200" alt="Home Screen" />
  <img src="docs/assets/screenshot-scan.png" width="200" alt="Scan Waste" />
  <img src="docs/assets/screenshot-chat.png" width="200" alt="AI Chatbot" />
  <img src="docs/assets/screenshot-leaderboard.png" width="200" alt="Leaderboard" />
</div>

## Features

- **AI Waste Detection**: Automatically identifies waste types (organic, inorganic, hazardous) and assesses danger levels from uploaded photos.
- **Privacy Protection**: Blurs faces and vehicle license plates in images before storage using Cloud Vision and Sharp.
- **Spatial Deduplication**: Prevents spam by merging duplicate waste reports within a 50-meter radius using PostGIS.
- **Regulation Chatbot (Geni)**: RAG-based AI assistant that answers questions about local environmental regulations, supporting text and voice inputs.
- **Gamification System**: Awards users with XP, levels, and redeemable points for submitting valid environmental reports.
- **Data as a Service (DaaS)**: Provides REST API endpoints for municipal authorities to access trash hotspots and cleanliness indices.

## Architecture

```mermaid
graph TD
    A[Flutter Mobile App] -->|Uploads & Reports| B(NestJS API Gateway)
    B -->|Spatial Query| C[Supabase PostgreSQL + PostGIS]
    B -->|PII Detection| D[GCP Vision API]
    D -->|Blurring| E[Sharp]
    E -->|Storage| F[Google Cloud Storage]
    B -->|Classification| G[OpenRouter Vision]
    A -->|Queries| H(RAG Chatbot)
    H -->|Vector Search| C
    H -->|Inference| I[OpenRouter LLM]
```

## Installation

### Prerequisites
- Node.js (v18+)
- Flutter SDK (v3.19+)
- Supabase Project (PostgreSQL + pgvector)
- OpenRouter API Key
- Google Cloud Service Account (for Vision API)

### Backend Setup

```bash
git clone https://github.com/agissugandi7203-ops/EKKA-2026_MarhasAI.git
cd EKKA-2026_MarhasAI/backend

# Install dependencies
npm install

# Copy environment variables and configure them
cp .env.example .env

# Run development server
npm run start:dev
```

### Mobile Setup

```bash
cd ../mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```text
Genesis/
├── backend/            # NestJS + Fastify REST API and RAG pipeline
├── docs/               # Detailed technical documentation and specifications
├── frontend/           # Next.js web application (Dashboard)
└── mobile/             # Flutter mobile application
```

## Tech Stack

- **Mobile**: Flutter, Dart, BLoC pattern, Dio
- **Backend**: NestJS, Fastify, TypeScript, Prisma
- **Database**: Supabase, PostgreSQL, PostGIS, pgvector
- **AI/ML**: OpenRouter (LLM, Vision, Whisper), Google Cloud Vision API

## Roadmap

- [x] AI waste classification
- [x] RAG chatbot for environmental laws
- [x] Gamification and reward system
- [x] PII image blurring
- [ ] Next.js administrative dashboard implementation
- [ ] Expanded DaaS endpoints for external integrations

## Contributing

Please refer to the `docs/` folder for detailed integration guides and clean code guidelines before submitting pull requests.

## License

This project is licensed under the MIT License.
