# PawPlan — Privacy Policy & App Privacy Questionnaire Responses

**Effective Date:** October 9, 2026  
**Last Updated:** October 9, 2026

PawPlan ("we", "our", or "the app") is committed to protecting your privacy and the security of your personal data. We believe your pet care routines and private records belong solely to you.

---

## 1. Zero Data Collection Architecture
PawPlan operates under an on-device first architecture:
- **No Remote Account Required:** You do not need to register an email address, phone number, or password to use PawPlan.
- **Local Persistence Only:** All pet profiles, photos, care tasks, vet appointments, medical histories, and expense records are stored locally on your device via Apple Core Data (`NSPersistentContainer`).
- **No Third-Party Analytics or Trackers:** PawPlan does not integrate Google Firebase, Meta SDK, Adjust, AppsFlyer, or any commercial ad/tracking networks.
- **No Cloud Synchronization Without Consent:** PawPlan does not transmit any pet information to external cloud servers. Backups are managed exclusively via standard encrypted iOS device backups and user-controlled iCloud device settings.

---

## 2. On-Device System Permissions

### A. Notifications (`UNUserNotificationCenter`)
- **Purpose:** Used strictly to fire local scheduled reminders for upcoming walks, feedings, medication administration, and vet appointments.
- **Privacy Guarantee:** Notification triggers are generated on-device. No push tokens are harvested or transmitted to external servers.

### B. Photos & Documents (`PHPickerViewController` / `UIDocumentPickerViewController`)
- **Purpose:** Allows you to attach photos of your pet or import digital PDF vaccination certificates and council licenses into the Document Vault.
- **Privacy Guarantee:** Files remain strictly within your application sandbox.

### C. Map & Location (`MapKit`)
- **Purpose:** Displays Sydney dog parks, beaches, and emergency veterinary clinics.
- **Privacy Guarantee:** Map display uses native Apple Maps framework. PawPlan does not log, track, or store your geographic coordinates.

---

## 3. Apple App Privacy Questionnaire Responses

| Category | Questionnaire Question | PawPlan Response | Rationale |
|---|---|---|---|
| **Data Collection** | Do you or your third-party partners collect data from this app? | **No** | All data remains strictly on the user's iOS device. |
| **Data Tracking** | Do you use data for tracking purposes? | **No** | Zero third-party trackers, zero advertising identifiers (IDFA). |
| **Data Linked to User** | Is data linked to the user's identity? | **No** | No user account or cross-device identification exists. |
| **Contact Info** | Name, Email, Phone Number | **Not Collected** | Never requested. |
| **Health & Fitness** | Pet Health & Medical Records | **Not Collected Remotely** | Stored strictly in local SQLite / Core Data sandbox. |
| **Financial Info** | Expense Tracking Records | **Not Collected Remotely** | Kept on device; exported only as local CSV files by user action. |
| **Location** | Precise or Coarse Location | **Not Collected** | Location is never retained or sent to any server. |

---

## 4. Compliance with Australian Privacy Principles (APPs) & GDPR
PawPlan complies with the *Privacy Act 1988 (Cth)* and the Australian Privacy Principles (APPs). Because no personal information is transferred off-device, your rights under APP 6 (use and disclosure), APP 8 (cross-border data flows), and APP 11 (data security) are inherently protected by cryptographic on-device sandboxing.

---

## 5. Contact Information
For questions regarding this Privacy Policy:
- **Email:** privacy@pawplan.app
- **Website:** https://pawplan.app/privacy
- **Developer:** Vicky Neves Rohr, Sydney, NSW, Australia
