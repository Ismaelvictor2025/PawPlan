# PawPlan — Happy paws. Every day.

A production-quality native iOS application designed for first-time dog parents in Sydney, Australia. Built with modern **SwiftUI**, **Clean Architecture**, and an **Electric Ocean** dark-mode visual design system.

---

## 1. Product Overview

- **App Name:** PawPlan: Dog Care & Routine
- **Subtitle:** Sydney Dog Care & Routines
- **Tagline:** *"Happy paws. Every day."*
- **Primary Platform:** iOS 17.0+ (Universal iPhone, optimized for Super Retina XDR displays)
- **Author:** Vicky Neves Rohr
- **Bundle Identifier:** `com.vicky.PawPlan`
- **App Group Identifier:** `group.com.vicky.PawPlan`

### Product Mission
Bringing a dog home changes your life, but managing vaccinations, feeding schedules, council registrations, and urban emergencies can quickly become overwhelming for first-time owners. PawPlan unifies daily care routines, veterinary medical records, Sydney off-leash exploration, and NSW regulatory compliance into one private, on-device iOS app.

---

## 2. Key Features

1. **Today Dashboard:** High-level summary of upcoming care activities, quick one-tap task logging (+ Walk, + Feeding, + Care Task), care shortcut grid, and 7-day adherence/streak scoring.
2. **Smart Schedule & Recurrence:** Calendar timeline with daily, weekday, weekend, weekly, and monthly recurrence rules that automatically advance upon completion.
3. **Health & Medical Vault:** Comprehensive medical records, weight trajectory tracking, vaccination certificate tracking, medication dosages, and vet appointment logs.
4. **Sydney Pet Guide:** Curated directory of Sydney's premier off-leash dog beaches (Sirius Cove, Rose Bay), fenced dog parks (Sydney Park, Centennial Park), pet-friendly cafes, and 24/7 emergency veterinary clinics (SASH, UVTHS, ARH) with one-tap calling and directions.
5. **Puppy Academy:** Structured 12-week stage-based development roadmap covering developmental milestones, socialization windows, and foundation commands.
6. **Pet Care Expense Tracker:** Monthly care budgets with visual progress indicators, categorized spending (food, vet, grooming, medications), and one-tap itemized CSV export for insurance claims.
7. **Document Vault:** Secure on-device digital storage for microchip registration, NSW Pet Registry IDs, desexing certificates, and insurance policies.
8. **NSW Pet Regulations:** Quick-reference guide explaining the *NSW Companion Animals Act 1998*, council lifetime registration, microchipping deadlines, and paralysis tick seasons.
9. **Multi-Dog Management:** Seamless profile switcher supporting multiple pets with isolated routines, medical histories, and metrics.
10. **100% On-Device Privacy:** Zero remote accounts, zero third-party trackers, zero advertising. All data resides in Apple Core Data.

---

## 3. Electric Ocean Design System

PawPlan features a custom design language tailored for OLED displays and low-light pet parenting:

| Design Token | Hex Code | Semantic Purpose |
|---|---|---|
| `oceanNavy` | `#080F20` | Primary app background; prevents visual fatigue and OLED power draw |
| `oceanCard` | `#0D1A35` | Card surface container |
| `cardBorder` | `#1A3258` | Subtle translucent stroke border |
| `electricBlue` | `#125BCE` | Structural primary accent and badges |
| `electricTurquoise` | `#15D9D2` | Interactive controls, active tabs, progress rings (9.2:1 contrast) |
| `lightCyan` | `#85F4FF` | Secondary highlights and glowing borders |
| `walkActivity` | `#22C55E` | Walking & exercise routines |
| `feedActivity` | `#F59E0B` | Feeding & dietary events |
| `groomActivity` | `#A855F7` | Grooming & hygiene care |
| `vetHealth` | `#EF4444` | Veterinary & medical alerts |
| `trainingSkill` | `#3B82F6` | Puppy Academy training sessions |
| `medicationCare` | `#EC4899` | Preventative medications & prescriptions |

---

## 4. Architecture & Engineering Standards

The codebase adheres strictly to **Clean Architecture** and **MVVM** principles:

```
PawPlan/
├── Presentation/                      # UI & View Layer
│   ├── Composition/                   # Composition root & Dependency Injection
│   │   ├── AppDependencyContainer.swift   # @MainActor Composition Root
│   │   └── DevelopmentDemoData.swift      # Pre-seeded Archie & Bella demo data
│   ├── Models/                        # Presentation Design Tokens
│   │   └── PawPlanTheme.swift             # Electric Ocean color & gradient palette
│   └── Views/                         # SwiftUI Views & Reusable Components
│       ├── Components/                # Cards, Hero, Modal Pickers, Shortcuts
│       ├── TodayView.swift            # Home dashboard
│       ├── ScheduleView.swift         # Daily timeline & recurrence
│       ├── HealthView.swift           # Health records & weight logs
│       ├── ExploreView.swift          # Map & Sydney dog places
│       ├── MoreView.swift             # Hub for Academy, Expenses, Regulations
│       ├── PuppyAcademyView.swift     # 12-week development curriculum
│       ├── ExpensesTrackerView.swift  # Financial budget & CSV export
│       ├── DocumentVaultView.swift    # Digital record management
│       ├── EmergencyHubView.swift     # 24/7 Sydney emergency vet routing
│       └── NSWPetRegulationsView.swift# Companion Animals Act guide
├── Domain/                            # Pure Swift Business Logic (Framework-independent)
│   ├── Models/                        # Domain entities (Dog, CareTask, Expense, etc.)
│   ├── Errors/                        # Typed domain error enums
│   ├── Repositories/                  # Abstract repository protocols
│   ├── Services/                      # NotificationSchedulingService
│   └── UseCases/                      # Isolated business use cases
└── Data/                              # Persistence & Infrastructure Layer
    ├── CoreData/                      # NSPersistentContainer & Schema
    │   ├── PawPlan.xcdatamodeld       # 8 Relational Entities
    │   ├── CoreDataMappers.swift      # ManagedObject <-> Domain Struct Mappers
    │   ├── PersistenceController.swift# Core Data stack configuration
    │   └── Repositories/              # Concrete Core Data Repository Implementations
    └── Widget/                        # App Group Shared Persistence
        └── WidgetSnapshotStore.swift  # group.com.vicky.PawPlan store
```

### Core Data Schema (8 Relational Entities)
- **`DogEntity`**: Core profile (name, breed, birthDate, weight, microchip, councilReg, notes, photoData).
- **`CareTaskEntity`**: Scheduled routines with recurrence rules, category, and reminder flags.
- **`CareCompletionEntity`**: Historical completion timestamps for consistency calculations.
- **`VetAppointmentEntity`**: Past and upcoming veterinary exams, clinic names, and reason logs.
- **`HealthRecordEntity`**: Vaccinations, medications, allergy alerts, and recorded weights.
- **`TrainingProgressEntity`**: Puppy Academy milestones, mastery ratings, and completion dates.
- **`ExpenseEntity`**: Categorized financial transactions (food, vet, grooming, toys, gear).
- **`DocumentRecordEntity`**: Digital document metadata and stored attachments.

---

## 5. Verification & Testing

### Unit Test Suite
PawPlan includes comprehensive unit tests built with the modern **Swift Testing** framework in `PawPlanTests/PawPlanTests.swift`:
- `testDogCreationAndValidation`: Confirms valid profile initialization.
- `testDogValidationFailures`: Validates rejection of empty names and negative weights.
- `testMultipleDogsAndDeletion`: Validates multi-dog repository isolation and cascading delete.
- `testDailyTaskCompletionRecurrence`: Validates next-day rescheduling for daily tasks.
- `testNonRecurringTaskCompletion`: Verifies non-recurring tasks remain marked complete.
- `testCareConsistencyCalculation`: Tests 7-day adherence scoring and streak counters.
- `testExpenseSummaryAndBudgetCalculation`: Verifies category summation and budget limit warnings.
- `testNegativeExpenseValidation`: Confirms validation against negative currency entries.
- `testExpenseCSVExportFormat`: Validates RFC 4180 RFC-compliant CSV string generation.
- `testSydneyPetPlacesFiltering`: Tests geocoding and category filters for Sydney parks and beaches.
- `testWidgetCareSnapshotEncoding`: Verifies JSON serialization for App Group widget sharing.

**Run Unit Tests:**
```bash
xcodebuild test \
  -project PawPlan.xcodeproj \
  -scheme PawPlan \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro" \
  -only-testing:PawPlanTests
```
*Result: 11 of 11 tests passed (0 failures).*

### Automated UI Tests & Screenshot Capture
Native UI automation in `PawPlanUITests/PawPlanUITests.swift` handles system permission prompts, tests all navigation tabs, and captures App Store marketing screenshots directly into `AppStore/Screenshots/`.

---

## 6. App Store Launch Package

All launch deliverables are organized in the `AppStore/` directory:
- `Metadata.json`: App titles, subtitles, keywords, description, categories, and support URLs.
- `Screenshots_Plan.md`: Detailed visual storyboard and device dimensions.
- `Screenshots/`: High-resolution PNG captures of all primary application tabs.
- `App_Preview_Storyboard.md`: 30-second App Store preview video script and scene timings.
- `Privacy_Policy.md`: On-device privacy policy and App Privacy questionnaire responses.
- `Accessibility_Audit.md`: WCAG 2.2 AAA contrast audit and Dynamic Type verification.
- `Support_FAQ.md`: Troubleshooting and Sydney pet ownership FAQ guide.
- `Whats_New_v1.0.md`: Release notes for Version 1.0.0.
- `App_Store_Submission_Checklist.md`: 25-point Apple App Store review readiness checklist.

---

## 7. Assessment Documentation

The comprehensive PDF technical assessment report is generated at:
- **`PawPlan_Assessment_Documentation.pdf`**
- Includes Problem Statement, Design Justification, Architecture Diagrams, and an 840-word Reflective Report covering engineering trade-offs, Swift Concurrency, and Apple HIG compliance.

---

### 8. Development and Quality Assurance

PawPlan was developed using SwiftUI and a layered architecture incorporating domain use cases, repository abstractions and Core Data persistence.

The development process included iterative implementation, debugging, automated unit and UI testing, accessibility improvements and verification against Apple Human Interface Guidelines.

The project includes documented engineering decisions, test results and technical implementation details to support reproducibility and future maintenance.
