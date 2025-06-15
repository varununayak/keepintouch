# Circles

A cross-platform mobile application that helps you maintain meaningful relationships by tracking and reminding you to stay in touch with your network.

## 🎯 Project Goals

Circles is designed to help users maintain their social connections by:
- Tracking relationships with different tiers of closeness
- Providing timely reminders for reaching out
- Integrating with Google Calendar for seamless scheduling
- Offering a simple, intuitive interface for managing contacts

## ✅ Core Features

### 1. Friend Management
- Add, edit, and delete friends
- Assign closeness tiers:
  - Close → Weekly check-ins
  - Medium → Monthly check-ins
  - Distant → Every 2-3 months
- Store contact notes and last interaction dates

### 2. Smart Reminders
- Automated reminder scheduling based on relationship tier
- Local push notifications
- Optional tracking of last contact

### 3. Google Calendar Integration
- OAuth2 authentication
- Automatic calendar event creation
- Recurring reminder scheduling
- Future: Calendar conflict detection

### 4. Dashboard
- Upcoming reminders view
- Overdue contacts list
- Relationship status overview

## 🧱 Technical Stack

| Area | Technology |
|------|------------|
| Framework | Flutter (Dart) |
| State Management | Riverpod/Provider |
| Local Database | Drift/Hive |
| Notifications | flutter_local_notifications + Workmanager |
| Calendar Integration | Google Calendar REST API + googleapis |
| Authentication | google_sign_in for Flutter |

## 📁 Project Structure

```
lib/
├── models/             # Data models (Friend, Tier enum, etc.)
├── services/           # External services (Google Calendar, Notifications)
├── data/              # Local database and repositories
├── screens/           # UI screens
├── widgets/           # Reusable UI components
├── viewmodels/        # Business logic and state management
└── main.dart          # Application entry point
```

## 🛠️ Development Requirements

- Flutter SDK
- Android Studio or VSCode with Flutter plugin
- Firebase project (for OAuth2)
- Google Cloud Console project (Calendar API access)

## 📅 Development Roadmap

### Week 1: Foundation & Friend Management
- [ ] Project setup (Flutter + Android/iOS)
- [ ] Friend list and management screens
- [ ] Local database implementation
- [ ] Closeness tier system

### Week 2: Reminder System
- [ ] Reminder scheduling logic
- [ ] Local notification implementation
- [ ] Contact tracking features

### Week 3: Calendar Integration
- [ ] Google Sign-In implementation
- [ ] Calendar API integration
- [ ] Timezone and preference handling
- [ ] Error handling

### Week 4: Polish & Launch
- [ ] Privacy policy and onboarding
- [ ] Cross-platform testing
- [ ] Store assets preparation
- [ ] App store submission

## 🔮 Future Enhancements

- WhatsApp/SMS/Call integration
- Smart contact detection via Google activity
- Cross-device synchronization
- Usage analytics
- Custom reminder frequencies
- Contact import/export

## 📱 Getting Started

*Development setup instructions will be added as the project progresses*

## 📄 License

*License information to be added*

## 🤝 Contributing

*Contribution guidelines to be added*
