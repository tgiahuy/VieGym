# VieGym

VieGym is a comprehensive fitness and nutrition tracking application. This project contains the Flutter mobile app, the Spring Boot backend, and a FastAPI AI Service.

## Architecture
- **Mobile**: Flutter app for User and Admin.
- **Backend**: Spring Boot providing REST API and authoritative business logic.
- **AI Service**: Stateless FastAPI service for AI processing.
- **Database**: PostgreSQL managed by Flyway.

## Prerequisites
- Flutter SDK
- Java 21 & Maven
- Python 3.12 & `uv` package manager
- Docker & Docker Compose
- Android Emulator / Physical Device

## Setup & Run

### 1. Database and Environment
Start the local infrastructure (PostgreSQL) using Docker Compose:
```bash
docker compose up -d
```

### 2. Backend (Spring Boot)
The backend manages the database migrations via Flyway automatically upon startup.
```bash
cd backend
./mvnw spring-boot:run
```
The backend will be available at `http://localhost:8080`.

### 3. AI Service (FastAPI)
The AI service requires Python 3.12 and `uv`.
```bash
cd ai-service
uv sync
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
The AI service will be available at `http://localhost:8000`.

### 4. Mobile (Flutter)
Ensure your emulator is running or device is connected.
```bash
cd mobile
flutter pub get
flutter run
```

## Testing

### Backend
```bash
cd backend
./mvnw test
```

### AI Service
```bash
cd ai-service
uv run pytest
```

### Mobile
```bash
cd mobile
flutter test
```
