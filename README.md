StudyCraft - base project
========================

This is a minimal base skeleton for the StudyCraft Flutter app.
It includes:
- pubspec.yaml with project dependencies
- lib/main.dart starter app shell
- codemagic.yaml for cloud builds
- .gitignore

NEXT STEPS (I'll add these in subsequent steps):
- Full models folder (Subject/Unit/Chapter/Topic/Subtopic)
- Services: DBService (sqflite), SchedulerService, NotificationService, UsageMonitor
- UI pages and widgets
- Export/Import and Mock Test features

How to use:
1. Create a GitHub repo named `studycraft`.
2. Extract this ZIP and commit all files to the repo.
3. Connect the repo to Codemagic and run a Flutter build (Codemagic will need a full Flutter environment).


## Improvements added by assistant (StudyCraft improved)
- Wrapped app with Provider and auto-load of subjects.
- Added 'Import Sample Topics' button on home screen to populate sample data.
- Improved Material theme for cleaner look.
- Added codemagic workflow already present — ready for upload to GitHub and Codemagic.
- To publish:
  1. Create a GitHub repo and push all files in this folder.
  2. Connect repo to Codemagic (codemagic.io) and use the existing `codemagic.yaml` to build an Android APK.
  3. For iOS builds, add appropriate iOS signing config in Codemagic and update `codemagic.yaml` if needed.

