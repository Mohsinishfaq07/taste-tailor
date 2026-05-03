# Privacy Policy — Bawarchi App

**Last updated:** 03 May 2026  

This Privacy Policy describes how **Mohsin Ishfaq** (“**we**”, “**us**”, “**our**”) collects, uses, stores, and shares information when you use the **Bawarchi App** mobile application (the “**App**”; the project codebase may reference “Taste Tailor”) and related services.

By using the App, you agree to this Privacy Policy. If you do not agree, please do not use the App.

**Contact (privacy-related requests):** [mohsin.ishfaq.raja@gmail.com](mailto:mohsin.ishfaq.raja@gmail.com)

---

## 1. Information we collect

### 1.1 Account and profile information

When you register or use the App, we may collect:

- **Personal details:** name, email address, phone number  
- **Role:** whether you use the App as a **Client** (“user”) or **Chef** (stored in our backend as role `chief` for chefs)  
- **Authentication:** identifiers and credentials are handled through **Firebase Authentication** (currently oriented around email/password sign-in flows)

**Chef profiles only (additional fields):** specialties, experience, certifications, profile/certificate imagery you upload, city/address-related text, and related profile fields displayed in the App.

**Clients:** optional profile image and address/contact details as you enter them during signup.

### 1.2 Location data

To **suggest addresses** when you choose to **use current location**, the App may ask for permission to access **approximate or precise location** via the device’s operating system (for example `Geolocator` with reverse geocoding). Location is **not** used for continuous background tracking—you can **always type your address manually** instead.

### 1.3 Media you upload

The App lets you choose photos (**image picker**) for profile pictures and chef-related uploads. These files may be stored in **Firebase Storage** and referenced from your **Firestore** profile and related documents.

### 1.4 Requests, bookings, and service data

Depending on how you use the App, Firestore-backed data may include:

- Food / event requests and orders (collections such as `requests` / `food_orders`), including dish details, dates, times, guests, ingredients, fare, statuses, assignments, chef responses/offers (`chef_offers`), and timestamps  
- If you **book a specific chef**, we store identifiers and display information needed to route requests and show them in the UI  
- **Ratings/reviews** you submit (`chef_ratings` and related naming as implemented)

### 1.5 Messaging data

When you chat in the App, we store **conversation metadata** (`conversations`) and **message content** (`conversations/{id}/messages`) in Firebase Firestore. Messages are available to conversation participants consistent with App rules.

### 1.6 Push notifications (FCM)

If you grant notification permission, the App obtains a **Firebase Cloud Messaging device token**. We merge that token (and metadata such as server timestamp fields) onto your **`allusers` document**. **Chefs** may be subscribed to a broadcast topic (**`chef_alerts`**) for relevant alerts. **On logout**, cleanup routines attempt to unsubscribe and clear stored token references.

### 1.7 Local device preferences

We use **`SharedPreferences`** (or equivalent app storage on your device) for session/UI preferences (for example remembering whether you appeared logged-in before refresh). Authentication state is anchored to Firebase; local store can be stale and is cleared appropriately on logout and account deletion.

### 1.8 Advertising (**Google Mobile Ads / AdMob**)

The App integrates **Google Mobile Ads** SDK and may display **interstitial** ads (with lightweight frequency/session limits wired in client code).

AdMob and its partners may process **device identifiers** (such as advertising identifiers where available), IP addresses, coarse usage signals, and similar **technical/ad delivery data**. You can commonly limit ad personalization and reset identifiers from **your device settings**.

---

## 2. Third-party services

Primary infrastructure is **Google**:

| Service                        | Typical use in the App                                                  |
|-------------------------------|-------------------------------------------------------------------------|
| **Firebase Authentication**   | Accounts, verification, deletion by re-entering password                |
| **Cloud Firestore**           | Profiles, orders/requests, chat, ratings, offers, notifications fields |
| **Firebase Storage**           | Hosted images/media linked from profiles/certificates                     |
| **Firebase Cloud Messaging**   | Push notification tokens/topics                                         |
| **Google Mobile Ads (AdMob)** | Interstitial advertisements                                            |

Their processing follows **Google’s policies** ([Google Privacy Policy](https://policies.google.com/privacy)).

Third-party Flutter packages (examples: **`geolocator`**, **`geocoding`**, **`image_picker`**) delegate to OS-level permissions and APIs; they do **not** give us standalone copies of raw location beyond what flows into addresses you ultimately save unless we store that text explicitly.

---

## 3. How we use information

We use this information to operate the App—for example accounts, discovering chefs/cities as shown in the UI, creating and tracking requests/offers/chats/notifications—and to comply with reasonable security and abuse-prevention obligations. We **do not sell** personal information.

---

## 4. Data retention & account deletion

**Retention.** We retain data generally **while your account exists** so the Service can operate.

**In-app deletion (Google Play):** Clients and chefs can initiate permanent deletion from **`Profile → Delete my account`** (localized label equivalent). Flow requires verifying your identity with your **Firebase email/password**.

The App’s deletion routine (**best‑effort** under Firestore security rules):

- Deletes your **`allusers`** profile document (`uid`)  
- Removes linked **conversations & messages**, **chef ratings/offers**, and legacy naming variants referenced in deletion code (**`chef_ratings`**, **`chef_offers`**, **`ratings`**, **`food_orders`**, **`requests`**, etc.—where IDs match yours)  
- Deletes the **Firebase Authentication** user  

Some writes may fail silently if backend rules disallow a batch (**best-effort**). **Firebase Storage** files historically uploaded against your UID may survive unless separate storage cleanup/deletion is implemented serverside—we will assist on written request via the email above within reason.

Backed-up/logging copies elsewhere on Google/systems follow Google’s customary retention—not under our sole control.

---

## 5. Security

Traffic between the App and Google services travels over encrypted transport (**HTTPS/TLS**) under normal operation. Stored data sits on Firebase infrastructure with access controls—but **no electronic system is flawless**—please use a strong password and protect your device.

---

## 6. Children’s privacy

The App is **not intended for children under 13**. We don’t knowingly collect personal data from children. If you believe we have collected a child’s data, contact **`mohsin.ishfaq.raja@gmail.com`** with details so we can **delete** qualifying records.

---

## 7. Your rights / regional disclosures

Depending on where you live, you may have rights to **access**, **correct**, **export**, **object to**, or **delete** processing. Contact **`mohsin.ishfaq.raja@gmail.com`**. Identity verification may apply.

Firebase and Google infrastructure may involve **international transfers** of data; their safeguards are described in Google and Firebase documentation.

---

## 8. Third-party policies & disclaimer

Ads, maps-like OS lookups, Play Store distributions, etc. invoke additional vendors under **their** terms. This document is **general information**, not legal advice—consider counsel for Pakistan, EU/UK GDPR, U.S. state laws, etc.

---

## 9. Changes to this policy

We may update this Privacy Policy from time to time. The **“Last updated”** date will change when we do. Material changes may be highlighted in-app or on the store listing where practical; continued use after publication may constitute acceptance where local law allows.

---

**End of Privacy Policy**
