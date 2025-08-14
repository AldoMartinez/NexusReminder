# Nexus Reminder – Never Miss a Nexus Assignment Deadline

**Get notified before your Nexus activities are due — one day and one hour in advance.**

## Overview
**Nexus Reminder** is a cross-platform mobile app that helps you stay on top of your pending activities from the Nexus platform. It sends timely reminders so you can submit your work before the deadline.  
Simply log in with your **SIASE** account to start receiving reminders and managing your upcoming tasks.

Available on both **iOS** and **Android**.

## Features
- **Deadline Notifications** – Receive reminders one day and one hour before your Nexus activity due dates.
- **SIASE Login** – Securely access your account with your SIASE credentials.
- **Activity List** – View all your upcoming assignments in one place.
- **Notification Settings** – Customize when and how you get notified.
- **SIASE Information Access** – Check your academic information including enrolled programs, Kardex, and schedules.

## Who Is It For?
- Students using the **Nexus** platform.
- Anyone who wants an easy way to track and manage academic deadlines.
- Users who want a centralized place to check their academic data.

## API
Nexus Reminder uses a **custom API** developed specifically for the app.  
This API:
- Retrieves academic and activity data from the **SIASE** platform
- Makes the data available to the mobile app in a clean, structured format
- Is built using **Python** with:
  - **Flask** for the web framework
  - **BeautifulSoup** for HTML parsing and data extraction

By offloading data scraping and formatting to the API, the mobile app can remain fast, lightweight, and focused on user experience.

## Technologies Used
### iOS
- **Language:** Swift, SwiftUI
- **Notifications:** UserNotifications Framework
- **API Communication:** URLSession

### Android
- **Framework:** Ionic
- **Frontend:** Angular + TypeScript
- **Notifications:** Firebase Cloud Messaging

## Screenshots
<img width="1000"  alt="Nexus Reminder Banner" src="https://github.com/user-attachments/assets/87d85445-781a-4fcf-84cf-1de23f0b6f02" />

## Requirements
- Active **SIASE** account

## Installation
Nexus Reminder is available on both the **App Store** and **Google Play**:

- [Download on the App Store](https://apps.apple.com/us/app/nexus-reminder/id1537701396) 
- [Get it on Google Play](https://play.google.com/store/apps/details?id=com.aldomartinez.nexusreminder&hl=en_US)

