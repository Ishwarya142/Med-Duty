# Requirements Document

## Introduction

This document specifies requirements for redesigning the Edit Profile screen in the MedDuty Flutter application. The current screen (`lib/features/profile/edit_profile_screen.dart`) acts as a navigation hub with tappable cards that route to separate sub-screens. The redesign replaces this multi-screen hub with a single, fully-inline scrollable page organised into collapsible ExpansionTile sections. All profile data is edited directly on this one screen and saved via a single "Save Changes" button. Only `edit_profile_screen.dart` is modified; all other files remain unchanged.

## Glossary

- **EditProfileScreen**: The Flutter `StatefulWidget` at `lib/features/profile/edit_profile_screen.dart` that is the subject of this redesign.
- **ProfileProvider**: The existing `ChangeNotifier` at `lib/providers/profile_provider.dart` that persists data to Firebase Firestore. Its public API (`updateProfile()`, `uploadDocument()`, `uploadProfilePicture()`, `uploadCoverPicture()`, `addLanguage()`, `deleteLanguage()`, `addSkill()`, `deleteSkill()`) is consumed but not modified by the redesign.
- **AppColors**: The colour constants class at `lib/core/theme/app_colors.dart`. `AppColors.accent` (teal `0xFF0F766E`) is the only brand colour used for interactive elements in the redesigned screen.
- **ExpansionTile section**: A Flutter `ExpansionTile` widget used to group related form fields under a collapsible header within the EditProfileScreen.
- **Chip input**: An inline UI pattern where the user types a value, confirms it, and it appears as a removable `Chip` widget; used for Languages and Skills fields.
- **Country-code selector**: A bottom-sheet or dropdown that displays flag emoji and dial code prefix for phone number entry.
- **GPS auto-detect**: A device-level geolocation lookup triggered by a button press that populates address fields.
- **Maps pin-drop**: A Google Maps modal bottom sheet allowing the user to drag a map pin to set a latitude/longitude coordinate.
- **WillPopScope / PopScope**: Flutter mechanism to intercept the back-navigation gesture and show an unsaved-changes confirmation dialog.
- **Unsaved changes**: Any field value that differs from its initial value loaded from `ProfileProvider` at screen open time.

---

## Requirements

### Requirement 1 — Single-Page Layout

**User Story:** As a doctor, I want all my profile sections on one scrollable page, so that I can edit everything without navigating to separate screens.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL render as a single `Scaffold` containing one scrollable `ListView` (or `CustomScrollView`) with no sub-screen navigation routes inside it.
2. THE EditProfileScreen SHALL display a sticky AppBar with the title "Edit Profile" and a back arrow, using `AppColors.accent` tints consistent with the existing app theme.
3. THE EditProfileScreen SHALL display a "Save Changes" `ElevatedButton` fixed at the bottom of the screen, outside the scroll area, with background colour `AppColors.accent`.
4. WHEN the screen content height exceeds the visible viewport, THE EditProfileScreen SHALL remain scrollable without any `RenderFlex` overflow errors on Android, iOS, and Web.
5. WHILE the device software keyboard is open, THE EditProfileScreen SHALL keep the active text field visible by adjusting scroll position, using `resizeToAvoidBottomInset: true` on the `Scaffold`.

---

### Requirement 2 — Photo Header

**User Story:** As a doctor, I want to update my profile and cover photos from the top of the page, so that I can manage my visual identity without leaving the edit screen.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL display a rectangular cover-photo banner at the top of the scroll area, with a camera-icon overlay button in the bottom-right corner of the banner.
2. THE EditProfileScreen SHALL display a circular avatar overlapping the lower edge of the cover-photo banner, centred horizontally, with a camera-icon overlay button in the bottom-right of the avatar circle.
3. WHEN the user taps the cover-photo camera button, THE EditProfileScreen SHALL present a modal bottom sheet offering "Take Photo", "Choose from Gallery", and (if a cover photo exists) "Remove Photo" options.
4. WHEN the user taps the avatar camera button, THE EditProfileScreen SHALL present a modal bottom sheet offering "Take Photo", "Choose from Gallery", and (if a profile photo exists) "Remove Photo" options.
5. WHEN a photo upload is in progress, THE EditProfileScreen SHALL display a `CircularProgressIndicator` inside the relevant camera button and a `LinearProgressIndicator` below the photo header showing upload percentage.
6. IF a photo upload fails, THEN THE EditProfileScreen SHALL display an inline error message beneath the photo header using `AppColors.error` colour, without navigating away from the screen.
7. WHEN a photo upload completes successfully, THE EditProfileScreen SHALL display an inline success indicator beneath the photo header using `AppColors.accent` colour.
8. THE EditProfileScreen SHALL use `ProfileProvider.uploadProfilePicture()` and `ProfileProvider.uploadCoverPicture()` exclusively for photo uploads, without duplicating Firebase Storage logic.

---

### Requirement 3 — ExpansionTile Section Structure

**User Story:** As a doctor, I want the form sections to be collapsible, so that I can focus on the section I'm editing without scrolling past unrelated fields.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL organise form fields into exactly seven named ExpansionTile sections in this order: "Personal Info", "Professional Summary", "Availability", "Location", "Documents", "Achievements", "Social Links".
2. WHEN the EditProfileScreen first loads, THE EditProfileScreen SHALL render the "Personal Info" section in the expanded state and all other six sections in the collapsed state.
3. WHEN the user taps an ExpansionTile header, THE EditProfileScreen SHALL toggle that section between expanded and collapsed states independently of all other sections.
4. THE EditProfileScreen SHALL render each ExpansionTile header using `AppColors.accent` for the trailing expand/collapse icon, with no purple, orange, blue, or red icon colours used anywhere in the screen.

---

### Requirement 4 — Personal Info Section

**User Story:** As a doctor, I want to edit my basic personal details inline, so that I can update my name, contact, date of birth, and gender without leaving the page.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL include a "Full Name" `TextFormField` pre-populated with `ProfileProvider.name`, with validation that the value is not empty.
2. THE EditProfileScreen SHALL include an "Email" `TextFormField` pre-populated with `ProfileProvider.email`, with validation that the value matches a valid email format (`RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$')`).
3. THE EditProfileScreen SHALL include a phone entry composed of a country-code selector (flag emoji + dial code displayed in a prefix widget) and a number `TextFormField` pre-populated with `ProfileProvider.phone`.
4. WHEN the user taps the country-code selector, THE EditProfileScreen SHALL display a searchable modal bottom sheet listing country names with their flag emoji and dial code, allowing the user to select one.
5. THE EditProfileScreen SHALL include a "Date of Birth" read-only `TextFormField` pre-populated with `ProfileProvider.dateOfBirth` formatted as `dd/MM/yyyy`.
6. WHEN the user taps the Date of Birth field, THE EditProfileScreen SHALL invoke `showDatePicker` with `firstDate` of 1 January 1900 and `lastDate` of 18 years before the current date.
7. THE EditProfileScreen SHALL include a "Gender" field rendered as three radio-button options: "Male", "Female", "Other", pre-selected from `ProfileProvider.gender`.
8. IF the user submits the form with the Full Name field empty, THEN THE EditProfileScreen SHALL display the validation error message "Name is required" below the Full Name field and SHALL NOT call `ProfileProvider.updateProfile()`.
9. IF the user submits the form with an invalid email value, THEN THE EditProfileScreen SHALL display the validation error message "Enter a valid email address" below the Email field and SHALL NOT call `ProfileProvider.updateProfile()`.

---

### Requirement 5 — Professional Summary Section

**User Story:** As a doctor, I want to edit my professional bio and specialisation inline, so that my qualifications are always up to date.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL include a "Bio / Summary" `TextFormField` pre-populated with `ProfileProvider.bio`, configured as a multi-line field with a minimum of 3 visible lines.
2. THE EditProfileScreen SHALL include a "Specialisation" `TextFormField` pre-populated with `ProfileProvider.specialization`.
3. THE EditProfileScreen SHALL include a "Qualification" `TextFormField` pre-populated with `ProfileProvider.qualification`.
4. THE EditProfileScreen SHALL include an "Experience (years)" `TextFormField` pre-populated with `ProfileProvider.experience.toString()`, accepting only numeric input via `TextInputType.number`.
5. THE EditProfileScreen SHALL include a "Current Hospital" `TextFormField` pre-populated with `ProfileProvider.currentHospital`.

---

### Requirement 6 — Availability Section

**User Story:** As a doctor, I want to configure my availability inline, so that colleagues know when I am reachable for duty assignments.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL include an "Available for Duties" `Switch` pre-set from `ProfileProvider.availableForDuties`, using `AppColors.accent` as the active track colour.
2. THE EditProfileScreen SHALL include an "Emergency Available" `Switch` pre-set from `ProfileProvider.emergencyAvailable`, using `AppColors.accent` as the active track colour.
3. THE EditProfileScreen SHALL include a "Preferred Shift" dropdown (`DropdownButtonFormField`) with options: "Morning", "Afternoon", "Evening", "Night", "Any", pre-selected from `ProfileProvider.preferredShift`.
4. THE EditProfileScreen SHALL include a "Preferred Duty Distance (km)" `TextFormField` pre-populated with `ProfileProvider.preferredDutyDistance.toString()`, accepting only numeric input.
5. THE EditProfileScreen SHALL include a row of selectable day-chip buttons for Monday through Sunday that reflect `ProfileProvider.workingDays` and allow toggling individual days using `AppColors.accent` for the selected state.

---

### Requirement 7 — Languages and Skills (Chip Inputs)

**User Story:** As a doctor, I want to add and remove languages and skills as chips, so that my profile reflects my current capabilities without navigating to a separate screen.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL display existing languages from `ProfileProvider.languages` as removable `Chip` widgets inside the "Personal Info" section.
2. WHEN the user taps the delete icon on a language chip, THE EditProfileScreen SHALL call `ProfileProvider.deleteLanguage()` with that language name and remove the chip from the display.
3. THE EditProfileScreen SHALL display a text field with an "Add" icon button below the language chips, allowing the user to type a new language name and add it.
4. WHEN the user submits a non-empty language name via the "Add" button, THE EditProfileScreen SHALL call `ProfileProvider.addLanguage()` with a `LanguageWithProficiency` object using `Proficiency.fluent` as the default and add the new chip to the display.
5. THE EditProfileScreen SHALL display existing skills from `ProfileProvider.skills` as removable `Chip` widgets inside the "Professional Summary" section.
6. WHEN the user taps the delete icon on a skill chip, THE EditProfileScreen SHALL call `ProfileProvider.deleteSkill()` with that skill name and remove the chip from the display.
7. THE EditProfileScreen SHALL display a text field with an "Add" icon button below the skill chips, allowing the user to type a new skill name and add it.
8. WHEN the user submits a non-empty skill name via the "Add" button, THE EditProfileScreen SHALL call `ProfileProvider.addSkill()` with a `SkillWithProficiency` object using `Proficiency.fluent` as the default and add the new chip to the display.
9. IF the user attempts to add a language or skill name that is already present in the respective list, THEN THE EditProfileScreen SHALL display a SnackBar with the message "Already added" and SHALL NOT add a duplicate entry.

---

### Requirement 8 — Location Section

**User Story:** As a doctor, I want to enter my location manually or via GPS, and optionally pin it on a map, so that duty assignments can reach me accurately.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL include "Address", "City", "State", and "Country" `TextFormField` widgets pre-populated from `ProfileProvider.address`, `ProfileProvider.currentCity`, `ProfileProvider.state`, and `ProfileProvider.country` respectively.
2. THE EditProfileScreen SHALL include an "Auto-detect Location" button that, when tapped, triggers a device GPS lookup using the `geolocator` package and populates the address fields with the resolved location string.
3. WHEN the GPS lookup is in progress, THE EditProfileScreen SHALL display a `CircularProgressIndicator` inside the auto-detect button and disable the button until the lookup completes.
4. IF the GPS permission is denied, THEN THE EditProfileScreen SHALL display a SnackBar with the message "Location permission denied. Please enable it in settings." and SHALL NOT overwrite any address fields.
5. THE EditProfileScreen SHALL include a "Pin on Map" button that, when tapped, opens a Google Maps modal bottom sheet where the user can drag a pin to a location.
6. WHEN the user confirms a pin location in the map modal, THE EditProfileScreen SHALL store the selected latitude and longitude for submission via `ProfileProvider.updateProfile(currentLatitude:, currentLongitude:)`.

---

### Requirement 9 — Documents Section

**User Story:** As a doctor, I want to upload my professional documents inline, so that my credentials are verified without leaving the profile page.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL display a list of document type slots — at minimum: "Medical License", "Degree Certificate", "Government ID" — each with an upload button and a status indicator.
2. WHEN the user taps an upload button for a document type, THE EditProfileScreen SHALL call `ProfileProvider.uploadDocument()` with the corresponding document type string.
3. WHILE a document upload is in progress, THE EditProfileScreen SHALL display a per-document `LinearProgressIndicator` adjacent to the uploading slot and disable the upload button for that slot.
4. WHEN a document has been previously uploaded, THE EditProfileScreen SHALL show the document file name and a "Replace" action link instead of the upload button.
5. THE EditProfileScreen SHALL display the verification status badge ("Pending", "Verified", "Rejected") for each uploaded document using `DocumentVerificationStatus` from `ProfileProvider.documents`.

---

### Requirement 10 — Achievements Section

**User Story:** As a doctor, I want to list my awards and certifications inline, so that my profile highlights my professional accomplishments.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL display existing achievements from `ProfileProvider.achievements` as a list of removable `ListTile` or chip items inside the "Achievements" section.
2. THE EditProfileScreen SHALL include an "Add Achievement" text field with an "Add" icon button that appends a non-empty entry to the achievements list.
3. WHEN the user removes an achievement, THE EditProfileScreen SHALL call `ProfileProvider.updateAchievements()` with the updated list and remove the item from the display immediately.
4. WHEN the user adds an achievement, THE EditProfileScreen SHALL call `ProfileProvider.updateAchievements()` with the updated list immediately after the item is appended.

---

### Requirement 11 — Social Links Section

**User Story:** As a doctor, I want to provide my professional social links inline, so that colleagues can find my published work and profiles.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL include four `TextFormField` widgets labelled "LinkedIn URL", "ResearchGate URL", "ORCID URL", and "Website URL", pre-populated from `ProfileProvider.linkedinUrl`, `ProfileProvider.researchgateUrl`, `ProfileProvider.orcidUrl`, and `ProfileProvider.websiteUrl` respectively.
2. WHEN a URL field is not empty, THE EditProfileScreen SHALL validate that the value starts with `http://` or `https://` and display the validation error "Enter a valid URL" if it does not.
3. THE EditProfileScreen SHALL use `TextInputType.url` and `TextInputAction.next` for all URL fields.

---

### Requirement 12 — Save Changes

**User Story:** As a doctor, I want a single Save button that persists all edited fields, so that I have one clear action to commit my changes.

#### Acceptance Criteria

1. WHEN the user taps "Save Changes", THE EditProfileScreen SHALL call `_formKey.currentState!.validate()` and proceed only if validation passes.
2. WHEN validation passes, THE EditProfileScreen SHALL call `ProfileProvider.updateProfile()` with all modified text field values from the Personal Info, Professional Summary, Availability, Location, and Social Links sections.
3. WHILE the save operation is in progress, THE EditProfileScreen SHALL replace the "Save Changes" button label with a `CircularProgressIndicator` and disable the button to prevent duplicate submissions.
4. WHEN `ProfileProvider.updateProfile()` completes without error, THE EditProfileScreen SHALL show a `SnackBar` with the message "Profile updated successfully!" and pop the screen.
5. IF `ProfileProvider.updateProfile()` throws an exception, THEN THE EditProfileScreen SHALL show a `SnackBar` with the message "Failed to update profile: [error]" and remain on the screen with the form fields intact.
6. THE EditProfileScreen SHALL pass the country-dial-code prefix concatenated with the phone number text field value as the `phone` argument to `ProfileProvider.updateProfile()`.

---

### Requirement 13 — Unsaved Changes Detection

**User Story:** As a doctor, I want to be warned before losing unsaved edits when I press back, so that I do not accidentally discard my work.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL wrap navigation interception using `PopScope` (or `WillPopScope` on Flutter versions below 3.12) to detect back-press events before leaving the screen.
2. WHEN the user presses the back button or swipe-to-go-back gesture, THE EditProfileScreen SHALL compare current field values against values loaded from `ProfileProvider` at screen-open time.
3. IF any current field value differs from its initial value, THEN THE EditProfileScreen SHALL display an `AlertDialog` with the title "Discard changes?", the message "You have unsaved changes. Leave without saving?", and two actions: "Keep Editing" and "Discard".
4. WHEN the user selects "Discard" in the dialog, THE EditProfileScreen SHALL pop the screen without saving.
5. WHEN the user selects "Keep Editing" in the dialog, THE EditProfileScreen SHALL close the dialog and remain on the screen with all field values intact.
6. IF no field values differ from their initial values, THEN THE EditProfileScreen SHALL pop the screen immediately without displaying the dialog.

---

### Requirement 14 — Theme and Visual Consistency

**User Story:** As a user, I want the Edit Profile screen to match the rest of the MedDuty app visually, so that the redesign feels native rather than a foreign insertion.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL use only `AppColors.accent` (`0xFF0F766E`) as the interactive brand colour for buttons, active switch tracks, selected chips, focused field borders, and icon overlays; no purple, orange, red, or blue brand colours SHALL appear.
2. THE EditProfileScreen SHALL respect the active `ThemeData.brightness` by reading `isDark` from `Theme.of(context).brightness == Brightness.dark` and applying `AppColors.dark*` variants for dark mode and `AppColors.light*` variants for light mode.
3. THE EditProfileScreen SHALL use `AppColors.softShadow` for card-style containers and `AppColors.accentShadow` for the Save button shadow, matching the existing visual language in the app.
4. THE EditProfileScreen SHALL not use `withOpacity()` on `AppColors` constants; it SHALL use `withValues(alpha: x)` as used in the existing codebase.
5. THE EditProfileScreen SHALL apply `SafeArea` to the bottom bar containing the Save button so that the button is not obscured by device navigation bars or the iPhone home indicator.

---

### Requirement 15 — Responsive Layout and Accessibility

**User Story:** As a doctor using MedDuty on different devices, I want the Edit Profile screen to render correctly at any screen size and be accessible to assistive technologies.

#### Acceptance Criteria

1. THE EditProfileScreen SHALL use flexible layout widgets (`Expanded`, `Flexible`, `LayoutBuilder`) so that no widget has a fixed width that exceeds the screen width on any device.
2. THE EditProfileScreen SHALL assign `semanticsLabel` or `Semantics` wrappers to all interactive icon buttons (camera overlays, chip delete buttons, day-toggle chips) so that screen readers can announce their purpose.
3. WHEN the screen width exceeds 600 logical pixels (tablet or web breakpoint), THE EditProfileScreen SHALL render form fields in a two-column grid layout using `Wrap` or `GridView` to utilise the additional horizontal space.
4. THE EditProfileScreen SHALL set a minimum tap-target size of 48 × 48 logical pixels for all interactive elements, including chip delete icons and day-toggle chips, in accordance with Material Design accessibility guidelines.
