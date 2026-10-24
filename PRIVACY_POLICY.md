# Privacy Policy for MineAI

**Effective Date**: October 24, 2026  
**Application Version**: 1.0.0 (First Official Release)  
**Developer Contact**: support@mineai.app  

---

## 1. Introduction
Welcome to **MineAI** ("we," "our," or "us"). We are committed to protecting your personal privacy. This Privacy Policy outlines our standards and practices regarding the collection, storage, and processing of your personal information when using our mobile application.

---

## 2. Information We Collect

### A. Information You Provide Directly
- **Account Details**: Your email address, username, full name, profile avatar, and optional phone number registered through our authentication service (Supabase).
- **User Content**: Diary entries, personal task notes, email drafts, expense amounts, budget thresholds, and vault credentials.

### B. Information Processed Locally on Your Device
- **Private Vault**: All stored credentials, passwords, confidential notes, and sensitive files are encrypted locally on your device via hardware-backed platform storage (`flutter_secure_storage`). We do not have access to your vault passwords.
- **Biometric Data**: If you enable biometric authentication (Fingerprint / Face ID) for your vault or diary, this verification is handled strictly by your device operating system (Android Keystore / iOS Keychain). Biometric templates never leave your hardware.

### C. Device Permissions
- **Microphone & Speech Recognition**: Used solely when you trigger the Voice Task Assistant or record diary voice notes. Audio streams are transcribed in real time and are not recorded or sold to advertisers.
- **Location**: Used strictly to suggest your current city for localized city news and local weather insights. We do not track continuous background GPS movement.
- **Photos & Media Storage**: Used only when you select attachments for your personal diary, vault, or profile avatar.
- **Notifications**: Used to deliver task reminders and budget threshold alerts.

---

## 3. Third-Party Services & AI Processing

MineAI leverages select enterprise APIs to provide advanced features:
- **Large Language Model (LLM) APIs** (e.g. Google Gemini): Used to process user-initiated tasks, email compositions, and queries. Prompts are transmitted over encrypted TLS connections and are subject to enterprise data privacy agreements prohibiting the use of customer prompts for public model training.
- **News Syndication**: City news is retrieved via public RSS feeds from verified national publishers (The Hindu, Times of India). No personal user data is transmitted to news syndicators.
- **Authentication & Database**: Handled via Supabase (PostgreSQL with Row Level Security).

---

## 4. Data Retention & Deletion Rights
You have complete control over your data:
- You may export your expenses (as Excel or PDF) and diary entries at any time.
- You can edit or delete individual tasks, expenses, diary posts, and vault items directly within the app.
- You can request complete account deletion by contacting support@mineai.app or using the account deletion option in settings.

---

## 5. Children's Privacy
MineAI does not knowingly collect personal data from children under the age of 13. If you believe a child has provided us with personal information, please contact us immediately.

---

## 6. Updates to This Policy
We may periodically update this Privacy Policy. The latest version will always be accessible within the app Settings and linked in our Google Play Store listing.

---

## 7. Contact Us
For questions, support, or privacy requests:  
**MineAI Support Team**  
Email: support@mineai.app
