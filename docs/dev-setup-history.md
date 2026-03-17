# Date App Development Setup History

## Overview

This note summarizes the main setup steps completed so far, the issues we hit, and how each one was resolved.

## Steps Completed

### 1. Restarted the local project

- Started the backend locally at `http://localhost:8080`
- Started the admin locally at `http://localhost:5173`
- Ran the Flutter app locally for testing

### 2. Installed the Flutter Windows toolchain

- Installed `Visual Studio Build Tools 2022`
- Added the C++ desktop workload
- Brought `flutter doctor` back to a clean state so Windows desktop builds could work

### 3. Added user directory fields

- Added `birthDate`, `country`, `prefecture`, and `datingReason`
- Added the corresponding database migration
- Updated the admin user list to show the requested columns
- Updated the app register and update flows to match the new data shape
- Added fixed user ID generation with the `3 digits + 5 letters` format

### 4. Set up local PostgreSQL

- Installed PostgreSQL locally
- Created the `date_app` database
- Connected the backend local environment to the local database
- Verified user data through SQL queries

### 5. Installed pgAdmin 4

- Set up `pgAdmin 4` for local database inspection
- Confirmed the local database was running on the local PostgreSQL instance
- Verified tables such as `users`, `matches`, and `refresh_tokens`

### 6. Improved the admin UI

- Added the `新規登録` modal popup
- Removed the inline create and edit form from the user list page
- Opened edit in the same modal flow as create
- Updated the admin background and right content area colors
- Added row and column borders to the user list table
- Added pagination with page size options `10`, `20`, `50`, and `100`

### 7. Added simple CI/CD support

- Added the GitHub Actions workflow for one-click Render deploys
- Documented the required repository secrets
- Brought the deploy workflow onto `develop` and `main`

### 8. Standardized the branch workflow

- Finished work is committed and pushed immediately
- When a feature branch is merged into `develop`, the feature branch is deleted locally and remotely

### 9. Built the mobile login screen

- Added the `ログイン` screen
- Added email and password validation based on the requested Japanese copy
- Disabled the login button until the form becomes valid
- Added show and hide password support
- Added Enter to submit
- Added a loading overlay
- Added the remember-login checkbox

### 10. Refactored the mobile and web app structure

- Split the app into `LoginScreen`, `AuthShell`, `DiscoverScreen`, `MatchesScreen`, and `AccountScreen`
- Moved API models and client code out of `main.dart`
- Reduced the responsibilities of `main.dart`
- Cleaned up the auth flow so future features are easier to add

### 11. Synced the mobile branch with newer admin and backend changes

- Found that the mobile feature branch had newer mobile code but older admin and backend code
- Synced the required admin and backend files from `develop` into the working branch
- Rebuilt and restarted the local services

### 12. Built and served the Flutter web app locally

- Built the Flutter web release output
- Served it locally on `http://localhost:8081`
- Connected it to the local backend at `http://localhost:8080`

## Issues And Resolutions

### 1. Flutter Windows desktop would not build

- Cause: missing Visual Studio desktop toolchain
- Resolution: installed `Visual Studio Build Tools` and the C++ desktop workload

### 2. Backend could not use a local database

- Cause: PostgreSQL was not installed or not running
- Resolution: installed PostgreSQL, created `date_app`, and connected the backend to it

### 3. Needed a browser-based way to inspect the database

- Cause: PostgreSQL does not expose a normal website like the admin app
- Resolution: installed `pgAdmin 4` and connected it to the local database

### 4. A user created in admin could not log into the local app

- Cause: the user was not being created in the same local backend and database used by the local app
- Resolution: added `admin/.env.local` so the local admin points to `http://localhost:8080`

### 5. The local admin UI did not match the latest UI changes

- Cause: the current mobile branch contained older admin code
- Resolution: synced the newer admin code from `develop` into the working branch

### 6. Creating a user in local admin failed

- Cause: the older admin payload shape did not match the newer backend schema
- Resolution: synced the matching admin and backend code, then rebuilt and restarted both services

### 7. Flutter web opened with a blank page or file resource errors

- Cause: the build was opened incorrectly via file access or an old cached worker
- Resolution: served the web build through a local HTTP server and refreshed through `http://localhost:8081`

### 8. Flutter web showed `Cannot load profiles`

- Cause: either the backend was down or the browser was blocked by CORS
- Resolution:
  - restarted the local backend when needed
  - updated the backend allowed origins to include `http://localhost:8081` and `http://127.0.0.1:8081`

### 9. The auth refactor temporarily broke the login UI

- Cause: login was previously coupled to `AccountScreen` and `main.dart`
- Resolution: restructured auth around `LoginScreen` and `AuthShell`

### 10. Some local build steps were blocked during execution

- Cause: tool execution and build subprocess restrictions
- Resolution: reran the necessary commands with the required permissions and verified the outputs

## Current Local State

- Backend local: `http://localhost:8080`
- Admin local: `http://localhost:5173`
- App web local: `http://localhost:8081`
- Admin local points to backend local
- Backend local allows the app web origin on port `8081`
- The mobile auth flow is now structured for easier future development

## Key Recent Commits

- `cecd3d7` Refactor mobile auth flow into separate screens
- `c0c834b` Ignore admin local env overrides
- `ab392eb` Sync admin and backend updates into mobile branch
- `cabd074` Allow local web build origin in backend CORS
