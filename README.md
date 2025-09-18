# ⏰ Smart Alarm App (Flutter)

A production-ready Flutter alarm application built with **Hive persistence**, **BLoC state management**, and the `alarm` package for reliable cross-platform scheduling.  

## ✨ Features

- Create, edit, delete, and toggle alarms (CRUD) with Hive (`AlarmModel`)
- Custom repeat rules:
  - Selected weekdays
  - Every X hours
  - Every Y days
- Custom ringtone selection (file picker) with default asset fallback
- Full-screen **Ringing UI** with Stop and Snooze options
- Configurable snooze duration (default: 5 minutes)
- Notification Stop integration (auto-dismiss ringing screen)
- Dashboard with:
  - Search, filter, sort
  - Next-occurrence chips
- Adaptive indicators and empty state handling
- Polished, professional card-based UI

---

## 🚀 Setup Instructions

- Please follow the standard github practices and should be able to run the app

## Current Limitations

**Android**
- All scenarios (**foreground**, **background**, and **terminated**) function correctly with full ringing screen and snooze/stop actions.


**iOS**
- **Foreground**: Alarms work correctly with full ringing screen (Stop/Snooze).  
- **Background**: Currently limited to vibration only. The ringing screen appears once the app is reopened.  
- **Terminated (Killed State)**: Behavior still under verification. Requires IPA build testing.  

## Snooze test case is included.





