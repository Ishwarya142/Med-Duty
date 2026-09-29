# Implementation Plan: Edit Profile Screen Redesign

## Overview

Full rewrite of `lib/features/profile/edit_profile_screen.dart` into a single-page, inline-scrollable `Scaffold` with seven collapsible `ExpansionTile` sections. All editing happens on this one screen; data is persisted via the existing `ProfileProvider` API. No other files are modified.

---

## Tasks

- [ ] 1. Scaffold, AppBar, and PopScope skeleton
  - [ ] 1.1 Create the new `EditProfileScreen` StatefulWidget with `_EditProfileScreenState`
    - Declare all `TextEditingController` instances (name, email, phone, bio, specialisation, qualification, experience, currentHospital, address, city, state, country, linkedin, researchgate, orcid, website, addLanguage, addSkill, addAchievement, dutyDistance)
    - Declare auxiliary state: `_selectedGender`, `_selectedDob`, `_selectedDialCode`, `_selectedCountryFlag`, `_selectedDays`, `_availableForDuties`, `_emergencyAvailable`, `_preferredShift`, `_pinnedLatitude`, `_pinnedLongitude`, `_isGpsLoading`, `_isSaving`, `_expansionStates` (List of 7 bools, index 0 = true rest false), `_initialValues` map
    - Populate all controllers from `ProfileProvider` in `initState`; capture `_initialValues` snapshot
    - Dispose all controllers in `dispose()`
    - _Requirements: 1.1, 13.1, 13.2_

  - [ ] 1.2 Implement `_hasUnsavedChanges()` helper
    - Compare every controller text, switch bools, gender, dob, dial code, selected days, preferred shift, and pinned lat/lng against `_initialValues`
    - Return `true` if any field differs
    - _Requirements: 13.2_

  - [ ] 1.3 Implement `PopScope` with unsaved-changes dialog
    - Wrap the `Scaffold` in `PopScope(canPop: false, onPopInvokedWithResult: ...)`
    - If `_hasUnsavedChanges()` returns false, call `Navigator.pop(context)` immediately
    - If true, show `AlertDialog` with "Discard changes?" title, body text, "Keep Editing" (closes dialog) and "Discard" (pops screen) actions
    - _Requirements: 13.1, 13.3, 13.4, 13.5, 13.6_

  - [ ] 1.4 Build main `Scaffold` with AppBar and bottom Save bar
    - `Scaffold(resizeToAvoidBottomInset: true)` with AppBar title "Edit Profile" using `AppColors.accent` tints
    - Body: `Form(key: _formKey)` wrapping a `ListView` of all sections
    - Bottom bar outside scroll area: `SafeArea`-wrapped `ElevatedButton` "Save Changes" with `AppColors.accent` background and `AppColors.accentShadow`; shows `CircularProgressIndicator` while `_isSaving`
    - _Requirements: 1.2, 1.3, 1.5, 12.3, 14.3, 14.5_

- [ ] 2. Photo header
  - [ ] 2.1 Implement `_buildPhotoHeader()`
    - `Stack` with a 180 px `ClipRRect` cover banner (`Image.network` or placeholder), camera overlay button bottom-right calling `_showImagePickerSheet(isProfilePic: false)`; wrapped in `Semantics(label: 'Change cover photo')`
    - 110 px `CircleAvatar` centred, offset –50 px from banner bottom via `Transform.translate`; camera overlay button bottom-right calling `_showImagePickerSheet(isProfilePic: true)`; wrapped in `Semantics(label: 'Change profile photo')`
    - Conditional `LinearProgressIndicator` + status text row below avatar when upload in progress or error/success state
    - Use `withValues(alpha:)` for any colour transparency, never `withOpacity()`
    - _Requirements: 2.1, 2.2, 2.5, 2.6, 2.7, 14.4, 15.2_

  - [ ] 2.2 Implement `_showImagePickerSheet({required bool isProfilePic})`
    - `showModalBottomSheet` with `SafeArea`-wrapped `Column` of "Take Photo", "Choose from Gallery", and conditionally "Remove Photo"
    - Calls `profileProvider.uploadProfilePicture(source: ...)` or `profileProvider.uploadCoverPicture(source: ...)` accordingly
    - _Requirements: 2.3, 2.4, 2.8_

- [ ] 3. ExpansionTile section structure and responsive field row helper
  - [ ] 3.1 Implement `_buildExpansionSection(int index, String title, IconData icon, List<Widget> children)`
    - Themed `ExpansionTile` with `initiallyExpanded: _expansionStates[index]`; trailing icon `AppColors.accent`; container decorated with `AppColors.softShadow` and border `AppColors.lightBorder` / `AppColors.darkBorder`
    - Independent expand/collapse via `onExpansionChanged` updating `_expansionStates[index]` in `setState`
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ] 3.2 Implement `_buildFieldRow(List<Widget> fields)` responsive helper
    - `LayoutBuilder`: when `constraints.maxWidth > 600` use `Wrap(spacing: 16, runSpacing: 12)` with each child sized to `(maxWidth - 16) / 2`; otherwise `Column`
    - _Requirements: 15.1, 15.3_

- [ ] 4. Personal Info section
  - [ ] 4.1 Build Personal Info `ExpansionTile` content
    - "Full Name" `TextFormField` pre-populated from `ProfileProvider.name`; validator: non-empty → "Name is required"
    - "Email" `TextFormField` pre-populated from `ProfileProvider.email`; validator: email regex → "Enter a valid email address"; `TextInputType.emailAddress`
    - Phone row: country-code prefix widget (`_selectedCountryFlag + _selectedDialCode`, tappable → `_showCountryCodeSheet()`) + number `TextFormField` pre-populated from `ProfileProvider.phone`; min tap target 48 × 48
    - "Date of Birth" read-only `TextFormField` pre-populated from `ProfileProvider.dateOfBirth` as `dd/MM/yyyy`; onTap calls `showDatePicker(firstDate: 1900-01-01, lastDate: today – 18 yrs)`
    - Gender: three `RadioListTile` widgets ("Male", "Female", "Other") pre-selected from `ProfileProvider.gender`, group value `_selectedGender`
    - Language chips via `_buildChipInput`
    - Apply `_buildFieldRow` for name/email pair and phone/dob pair
    - _Requirements: 4.1–4.9, 7.1–7.4_

  - [ ]* 4.2 Write property test for email validation (Property 2)
    - **Property 2: Email validation rejects all non-email strings**
    - **Validates: Requirements 4.2, 4.9**
    - Use `flutter_test` to generate arbitrary strings not matching the email regex and assert the validator returns a non-null error

  - [ ]* 4.3 Write property test for DOB formatting (Property 3)
    - **Property 3: Date of Birth formatted as `dd/MM/yyyy`**
    - **Validates: Requirements 4.5**
    - For generated `DateTime` values assert the displayed string equals `DateFormat('dd/MM/yyyy').format(date)`

- [ ] 5. Country code selector
  - [ ] 5.1 Implement `_showCountryCodeSheet()`
    - Static constant list of `{name, flag, dialCode}` maps defined at the top of the file (no new packages)
    - `showModalBottomSheet` with a `TextField` to filter the list and a `ListView.builder` of country tiles
    - On selection, `setState` to update `_selectedDialCode` and `_selectedCountryFlag`
    - _Requirements: 4.3, 4.4_

- [ ] 6. Professional Summary section
  - [ ] 6.1 Build Professional Summary `ExpansionTile` content
    - "Bio / Summary" multiline `TextFormField` (minLines: 3) from `ProfileProvider.bio`
    - "Specialisation" field from `ProfileProvider.specialization`
    - "Qualification" field from `ProfileProvider.qualification`
    - "Experience (years)" numeric field from `ProfileProvider.experience.toString()`
    - "Current Hospital" field from `ProfileProvider.currentHospital`
    - Skills chips via `_buildChipInput`
    - Apply `_buildFieldRow` for specialisation/qualification pair
    - _Requirements: 5.1–5.5, 7.5–7.8_

  - [ ]* 6.2 Write property test for duplicate chip entries (Property 4)
    - **Property 4: Duplicate chip entries are rejected**
    - **Validates: Requirements 7.9**
    - For any language or skill name already in the list, assert adding the same name shows "Already added" SnackBar and does not mutate the list

- [ ] 7. Chip input helper
  - [ ] 7.1 Implement `_buildChipInput(List<String> items, void Function(String) onAdd, void Function(String) onDelete, String addLabel)`
    - `Wrap` of `InputChip` widgets with `deleteIconSemanticLabel`, `onDeleted` calling `onDelete`; chip bg `AppColors.accent.withValues(alpha: 0.12)`
    - Row with `TextFormField` and `IconButton(Icons.add_circle_outline)` for adding; disables "Add" button when text is empty
    - Duplicate-check: if already present show SnackBar "Already added"
    - Minimum 48 × 48 tap target on delete icons via `Semantics`
    - _Requirements: 7.1–7.9, 15.2, 15.4_

- [ ] 8. Availability section
  - [ ] 8.1 Build Availability `ExpansionTile` content
    - "Available for Duties" `SwitchListTile` from `ProfileProvider.availableForDuties`, activeColor `AppColors.accent`
    - "Emergency Available" `SwitchListTile` from `ProfileProvider.emergencyAvailable`, activeColor `AppColors.accent`
    - "Preferred Shift" `DropdownButtonFormField` with options ["Morning", "Afternoon", "Evening", "Night", "Any"] from `ProfileProvider.preferredShift`
    - "Preferred Duty Distance (km)" numeric `TextFormField` from `ProfileProvider.preferredDutyDistance.toString()`
    - Working days row: `Wrap` of `FilterChip` for Mon–Sun; selected state `AppColors.accent`, semantics label per chip; min 48 × 48 tap target
    - _Requirements: 6.1–6.5, 14.1, 15.2, 15.4_

- [ ] 9. Location section
  - [ ] 9.1 Build Location `ExpansionTile` content
    - "Address", "City", "State", "Country" `TextFormField` widgets pre-populated from `ProfileProvider`
    - "Auto-detect Location" `ElevatedButton.icon`; shows `CircularProgressIndicator` while `_isGpsLoading`; disabled during loading
    - "Pin on Map" `OutlinedButton.icon` that calls `_showMapPinSheet()`
    - Apply `_buildFieldRow` for city/state and address/country pairs
    - _Requirements: 8.1, 8.2, 8.3, 8.5, 8.6_

  - [ ] 9.2 Implement `_autoDetectLocation()`
    - Use `geolocator` to `checkPermission()` then `requestPermission()` if denied
    - If denied/deniedForever show SnackBar "Location permission denied. Please enable it in settings." and return
    - On success: `setState(() => _isGpsLoading = true)`, `getCurrentPosition()`, populate `_addressController` with `"${lat}, ${lng}"`, set `_pinnedLatitude` / `_pinnedLongitude`, then `setState(() => _isGpsLoading = false)`
    - Catch errors and show SnackBar "Could not detect location. Please try again."
    - _Requirements: 8.2, 8.3, 8.4_

  - [ ] 9.3 Implement `_showMapPinSheet()`
    - `showModalBottomSheet(isScrollControlled: true)` with `SizedBox(height: 70% of screen)`
    - `GoogleMap` centred on `_pinnedLatitude/_pinnedLongitude` (or 0,0 fallback), zoom 14
    - `onCameraMove` tracks `_tempPinnedLat/_tempPinnedLng`; draggable `Marker` at pin
    - "Confirm Location" button updates `_pinnedLatitude/_pinnedLongitude` in `setState` and closes sheet
    - Dismissing without confirm leaves coordinates unchanged
    - _Requirements: 8.5, 8.6_

- [ ] 10. Documents section
  - [ ] 10.1 Implement `_buildDocumentSlot(String type, String label)` and build Documents `ExpansionTile` content with three slots: "Medical License", "Degree Certificate", "Government ID"
    - Look up matching `Document` from `profileProvider.documents` by type
    - Not uploaded: `OutlinedButton.icon(Icons.upload_file)` → calls `profileProvider.uploadDocument(type)`
    - Uploaded: filename `Text` + `TextButton('Replace')` → calls `profileProvider.replaceDocument(documentId, type)`
    - Status badge `Chip` keyed on `DocumentVerificationStatus`: pending → `AppColors.warning`, verified → `AppColors.success`, rejected → `AppColors.error`
    - Uploading: disabled button + `LinearProgressIndicator`
    - _Requirements: 9.1–9.5_

  - [ ]* 10.2 Write property test for verification status badge (Property 7)
    - **Property 7: Verification status badge matches document status**
    - **Validates: Requirements 9.5**
    - For each `DocumentVerificationStatus` value assert the rendered badge text matches the corresponding label

- [ ] 11. Achievements section
  - [ ] 11.1 Build Achievements `ExpansionTile` content
    - `ListView` of existing `ProfileProvider.achievements` as `ListTile` with trailing delete `IconButton` (semanticsLabel "Remove achievement")
    - `TextFormField` + `IconButton(Icons.add_circle_outline)` to add new entries
    - On delete: update local list, call `profileProvider.updateAchievements(updatedList)`
    - On add: append non-empty entry, call `profileProvider.updateAchievements(updatedList)`, clear field
    - _Requirements: 10.1–10.4, 15.2_

- [ ] 12. Social Links section
  - [ ] 12.1 Build Social Links `ExpansionTile` content
    - "LinkedIn URL", "ResearchGate URL", "ORCID URL", "Website URL" `TextFormField` widgets pre-populated from `ProfileProvider`
    - `TextInputType.url`, `TextInputAction.next` for all four fields
    - Validator: non-empty value must start with `http://` or `https://` → "Enter a valid URL"
    - _Requirements: 11.1–11.3_

  - [ ]* 12.2 Write property test for URL validation (Property 5)
    - **Property 5: URL fields reject non-HTTP(S) values**
    - **Validates: Requirements 11.2**
    - For generated non-empty strings not starting with `http://` or `https://` assert the validator returns non-null error

- [ ] 13. Save Changes and theme polish
  - [ ] 13.1 Implement `_saveProfile()` async method
    - Call `_formKey.currentState!.validate()`; abort if invalid
    - `setState(() => _isSaving = true)`
    - Call `profileProvider.updateProfile(...)` with all field values; phone = `'$_selectedDialCode${_phoneController.text.trim()}'`
    - On success: SnackBar "Profile updated successfully!", `Navigator.pop(context)`
    - On error: SnackBar "Failed to update profile: $e", stay on screen
    - `finally`: `setState(() => _isSaving = false)` guarded by `mounted`
    - _Requirements: 12.1–12.6_

  - [ ]* 13.2 Write property test for phone concatenation (Property 6)
    - **Property 6: Phone number passed as dial-code concatenated with number**
    - **Validates: Requirements 12.6**
    - For arbitrary dial-code prefix and phone number strings assert the `phone` argument equals their concatenation (trimmed)

  - [ ] 13.3 Apply full theme and colour consistency pass
    - Audit every colour reference in the file; replace any `withOpacity()` with `withValues(alpha:)`; confirm only `AppColors.accent` is used for brand colour
    - Verify `isDark` branch applied throughout for all bg/surface/text/border colours
    - Confirm `AppColors.softShadow` on cards, `AppColors.accentShadow` on Save button
    - Confirm `AppColors.accent` on all active switches, focused borders, selected chips
    - _Requirements: 14.1–14.4_

- [ ] 14. Checkpoint — All sections wired and tests passing
  - Wire all `_buildExpansionSection` calls in `ListView` order: Personal Info (index 0, expanded), Professional Summary (1), Availability (2), Location (3), Documents (4), Achievements (5), Social Links (6)
  - Ensure no hanging/orphaned helper methods
  - Ensure all controllers properly disposed
  - Ensure all `Semantics` labels present on camera buttons, chip deletes, day chips
  - Ensure all tests pass, ask the user if questions arise.
  - _Requirements: 1.1, 3.1, 3.2, 15.2_

  - [ ]* 14.1 Write property test for provider data reflected in fields (Property 1)
    - **Property 1: Provider data reflected in displayed fields**
    - **Validates: Requirements 4.1, 5.1, 5.2, 5.3, 5.5, 6.1, 6.2, 7.1, 7.5, 8.1, 10.1**
    - For a mocked `ProfileProvider` with arbitrary field values assert each corresponding controller/state variable matches after `initState`

  - [ ]* 14.2 Write property test for two-column layout (Property 8)
    - **Property 8: Two-column layout applied for wide screens**
    - **Validates: Requirements 15.3**
    - For constraints where `maxWidth > 600` assert `_buildFieldRow` returns a `Wrap` with children sized ≤ half the available width

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- All code changes are confined to `lib/features/profile/edit_profile_screen.dart`
- No new packages are added; `geolocator` and `google_maps_flutter` are assumed already present in `pubspec.yaml`
- The static country-code list is defined as a file-level constant, not a separate file
- `withValues(alpha:)` is used throughout; `withOpacity()` is forbidden per `AppColors` conventions
- Each task references specific requirements for traceability

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "1.3", "1.4"] },
    { "id": 2, "tasks": ["2.1", "3.1", "3.2"] },
    { "id": 3, "tasks": ["2.2", "5.1", "7.1"] },
    { "id": 4, "tasks": ["4.1", "6.1", "8.1", "9.1", "10.1", "11.1", "12.1"] },
    { "id": 5, "tasks": ["4.2", "4.3", "6.2", "9.2", "9.3", "10.2", "12.2", "13.1"] },
    { "id": 6, "tasks": ["13.2", "13.3"] },
    { "id": 7, "tasks": ["14.1", "14.2"] }
  ]
}
```
