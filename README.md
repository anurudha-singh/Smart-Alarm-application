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
- snooze duration (default: 5 minutes)
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

**Snooze configuration**
Due to time constraint was not able to include this feature hence by default selected to 5min as per general standard value.


## Snooze test case is included.

**App Screenshots:-**
## 📱 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/17b16dd5-c00e-4a91-9818-74441e9c6ba7" alt="Screenshot 1" width="400"/>
  <img src="https://github.com/user-attachments/assets/511c35f8-b15c-4588-bee0-2d714326c68f" alt="Screenshot 2" width="400"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/d8f4fdb5-7571-43c6-b28b-65615031d6ba" alt="Screenshot 3" width="400"/>
  <img src="https://github.com/user-attachments/assets/0820dc53-1bef-4877-b299-ddd0248e797d" alt="Screenshot 4" width="400"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/c713dbaa-afb9-49c9-b1d2-07695e1481e4" alt="Screenshot 5" width="400"/>
  <img src="https://github.com/user-attachments/assets/95d01b9b-d857-4ee4-9578-36b0e13daa3d" alt="Screenshot 6" width="400"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/4228e231-f285-46da-b8b2-3f2f50b980fd" alt="Screenshot 7" width="400"/>
</p>










