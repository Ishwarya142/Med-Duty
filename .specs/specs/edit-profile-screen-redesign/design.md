# Design Document

## Edit Profile Screen Redesign

### Overview

The Edit Profile screen is redesigned from a navigation-hub pattern (tappable cards routing to sub-screens) into a single, fully-inline scrollable page. All profile data is edited directly on one `Scaffold` and saved with a single "Save Changes" button. Only `lib/features/profile/edit_profile_screen.dart` is modified; every other file remains unchanged.

The screen consumes `ProfileProvider` via `Provider.of<ProfileProvider>(context)` for reads and mutations, and derives all visual constants from `AppColors` in `lib/core/theme/app_colors.dart`.

---

### Architecture

```
EditProfileScreen (StatefulWidget)
  └── _EditProfileScreenState (State)
        ├── State
        │    ├── Form key + all TextEditingControllers (name, email, phone,
        │    │   bio, specialisation, qualification, experience, currentHospital,
        │    │   address, city, state, country, linkedin, researchgate, orcid, website,
        │    │   addLanguage, addSkill, addAchievement)
        │    ├── _selectedGender (String?)
        │    ├── _selectedDob (DateTime?)
        │    ├── _selectedDialCode / _selectedCountryFlag (String)
        │    ├── _selectedDays (List<String>)
        │    ├── _availableForDuties, _emergencyAvailable (bool)
        │    ├── _preferredShift (String?)
        │    ├── _pinnedLatitude / _pinnedLongitude (double?)
        │    ├── _isGpsLoading, _isSaving (bool)
        │    ├── _expansionStates [7] (List<bool>)
        │    └── initial-value snapshots (Map<String, dynamic> _initialValues)
        │
        ├── Helpers
        │    ├── _hasUnsavedChanges() → bool
        │    ├── _saveProfile() → Future<void>
        │    ├── _showImagePickerSheet(isProfilePic) → Future<void>
        │    ├── _showCountryCodeSheet() → Future<void>
        │    ├── _autoDetectLocation() → Future<void>
        │    ├── _showMapPinSheet() → Future<void>
        │    └── _showUnsavedChangesDialog() → Future<bool>
        │
        └── Build tree
              ├── PopScope (canPop: false, onPopInvokedWithResult)
              └── Scaffold
                    ├── AppBar ("Edit Profile", back arrow)
                    ├── Body: Form → ListView
                    │    ├── _buildPhotoHeader()
                    │    ├── _buildExpansionSection(0) — Personal Info
                    │    │    ├── Full Name field
                    │    │    ├── Email field
                    │    │    ├── Phone (dialCode prefix + number)
                    │    │    ├── Date of Birth (tap to showDatePicker)
                    │    │    ├── Gender (RadioListTile × 3)
                    │    │    └── Language chips + add field
                    │    ├── _buildExpansionSection(1) — Professional Summary
                    │    │    ├── Bio/Summary (multiline, minLines: 3)
                    │    │    ├── Specialisation
                    │    │    ├── Qualification
                    │    │    ├── Experience (years, numeric)
                    │    │    ├── Current Hospital
                    │    │    └── Skills chips + add field
                    │    ├── _buildExpansionSection(2) — Availability
                    │    │    ├── Available for Duties Switch
                    │    │    ├── Emergency Available Switch
                    │    │    ├── Preferred Shift Dropdown
                    │    │    ├── Preferred Duty Distance (numeric)
                    │    │    └── Working Days (FilterChip row)
                    │    ├── _buildExpansionSection(3) — Location
                    │    │    ├── Address, City, State, Country fields
                    │    │    ├── Auto-detect GPS button
                    │    │    └── Pin on Map button
                    │    ├── _buildExpansionSection(4) — Documents
                    │    │    └── _buildDocumentSlot() × 3
                    │    ├── _buildExpansionSection(5) — Achievements
                    │    │    └── Achievement chips + add field
                    │    └── _buildExpansionSection(6) — Social Links
                    │         ├── LinkedIn URL
                    │         ├── ResearchGate URL
                    │         ├── ORCID URL
                    │         └── Website URL
                    └── Bottom bar: Save Changes ElevatedButton (SafeArea)
```

---

### Components

#### `_buildPhotoHeader()`

Renders a `SizedBox` with an overlapping cover + avatar layout using a `Stack`:

1. **Cover banner** — 180 px tall, `ClipRRect(borderRadius: 20)`, shows `profileProvider.coverPic` via `Image.network` (or local path fallback). Camera overlay button bottom-right triggers `_showImagePickerSheet(isProfilePic: false)`.
2. **Avatar** — 110 px diameter `CircleAvatar` centred, offset –50 px from banner bottom using a `Transform.translate`. Camera overlay button bottom-right triggers `_showImagePickerSheet(isProfilePic: true)`.
3. **Upload state row** — conditionally shown `LinearProgressIndicator` + status text immediately below the avatar.

Both camera buttons use `Semantics(label: '...')` wrappers.

#### `_buildExpansionSection(int index, String title, IconData icon, List<Widget> children)`

Returns a themed `ExpansionTile` using a `ValueNotifier<bool>` per section rather than relying on the default controller, so each section expands/collapses independently. Header uses `AppColors.accent` for the expand icon (`trailing: Icon(Icons.expand_more, color: AppColors.accent)`).

The section container is wrapped in a `Container` with `AppColors.softShadow` and a border using `AppColors.lightBorder` / `AppColors.darkBorder`.

#### `_buildFieldRow(List<Widget> fields)` — Responsive Layout

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      // Tablet: two-column Wrap
      return Wrap(
        spacing: 16,
        runSpacing: 12,
        children: fields.map((f) =>
          SizedBox(width: (constraints.maxWidth - 16) / 2, child: f)
        ).toList(),
      );
    }
    // Phone: vertical Column
    return Column(children: fields);
  },
)
```

#### `_buildChipInput(List<String> items, void Function(String) onAdd, void Function(String) onDelete)`

A `Wrap` of `InputChip` widgets (each with `onDeleted`, `deleteIconSemanticLabel`) followed by a `Row` containing a `TextFormField` and an `IconButton(Icons.add_circle_outline)`. The chip background is `AppColors.accent.withValues(alpha: 0.12)`, label colour `AppColors.accent`.

#### `_buildDocumentSlot(String type, String label)`

Looks up `profileProvider.documents.firstWhere((d) => d.type == type, orElse: ...)`:

- **Not uploaded**: `OutlinedButton.icon(Icons.upload_file, 'Upload $label')` — calls `profileProvider.uploadDocument(type)`.
- **Uploaded**: shows filename `Text` + `TextButton('Replace')` — calls `profileProvider.replaceDocument(documentId, type)`.
- **Status badge**: uses `DocumentVerificationStatus` to render a `Chip` with the appropriate colour: pending → `AppColors.warning`, verified → `AppColors.success`, rejected → `AppColors.error`.
- **Uploading in progress**: shows a slim `LinearProgressIndicator` row and disabled upload button.

#### `_showImagePickerSheet({required bool isProfilePic})`

`showModalBottomSheet` with a `SafeArea`-wrapped `Column` listing "Take Photo", "Choose from Gallery", and conditionally "Remove Photo" (only if a photo exists). Each option invokes the respective `ProfileProvider` method.

#### `_showCountryCodeSheet()`

`showModalBottomSheet` that renders a `ListView` of countries (static constant list of `{name, flag, dialCode}` maps defined in the file). A `TextField` at the top filters the list. On selection, updates `_selectedDialCode` and `_selectedCountryFlag` in `setState`.

#### `_autoDetectLocation()`

Uses `geolocator` package:

```dart
final permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Location permission denied. Please enable it in settings.')
  ));
  return;
}
setState(() => _isGpsLoading = true);
final pos = await Geolocator.getCurrentPosition();
// populate address fields from lat/long
setState(() => _isGpsLoading = false);
```

Because reverse-geocoding requires an additional package, the implementation populates `_addressController` with `"${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}"` and sets `_pinnedLatitude` / `_pinnedLongitude` directly. This stays within the existing package footprint.

#### `_showMapPinSheet()`

`showModalBottomSheet` with `isScrollControlled: true` renders a `SizedBox(height: MediaQuery.of(context).size.height * 0.7)` containing a `GoogleMap` widget centred on either `_pinnedLatitude/_pinnedLongitude` or the device's last known position. A draggable marker is used via `onCameraMove` to track the selected position. A "Confirm Location" button at the bottom of the sheet confirms and closes:

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(_pinnedLatitude ?? 0, _pinnedLongitude ?? 0),
    zoom: 14,
  ),
  onCameraMove: (pos) => _tempPinnedLat = pos.target.latitude,
  markers: { Marker(markerId: MarkerId('pin'), position: ...) },
)
```

#### `_hasUnsavedChanges()` → bool

Compares all current controller values and state booleans against the `_initialValues` snapshot captured in `initState`. Returns `true` if any differ.

#### `_saveProfile()` → Future\<void\>

```dart
if (!_formKey.currentState!.validate()) return;
setState(() => _isSaving = true);
try {
  await profileProvider.updateProfile(
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    phone: '$_selectedDialCode${_phoneController.text.trim()}',
    bio: _bioController.text.trim(),
    specialization: _specialisationController.text.trim(),
    qualification: _qualificationController.text.trim(),
    experience: int.tryParse(_experienceController.text) ?? 0,
    currentHospital: _currentHospitalController.text.trim(),
    gender: _selectedGender,
    dateOfBirth: _selectedDob,
    availableForDuties: _availableForDuties,
    emergencyAvailable: _emergencyAvailable,
    workingDays: _selectedDays,
    preferredShift: _preferredShift,
    preferredDutyDistance: int.tryParse(_dutyDistanceController.text) ?? 50,
    address: _addressController.text.trim(),
    currentCity: _cityController.text.trim(),
    state: _stateController.text.trim(),
    country: _countryController.text.trim(),
    currentLatitude: _pinnedLatitude,
    currentLongitude: _pinnedLongitude,
    linkedinUrl: _linkedinController.text.trim(),
    researchgateUrl: _researchgateController.text.trim(),
    orcidUrl: _orcidController.text.trim(),
    websiteUrl: _websiteController.text.trim(),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Profile updated successfully!')),
  );
  Navigator.pop(context);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to update profile: $e')),
  );
} finally {
  if (mounted) setState(() => _isSaving = false);
}
```

---

### Data Models

All data models already exist in `profile_provider.dart`. No new model classes are introduced. The screen uses the following directly:

| Model | Used For |
|---|---|
| `LanguageWithProficiency` | `addLanguage()` call with `Proficiency.fluent` default |
| `SkillWithProficiency` | `addSkill()` call with `Proficiency.fluent` default |
| `Document` | Slot lookup by `type`, `name`, `verificationStatus` |
| `DocumentVerificationStatus` | Status badge rendering |

---

### Interfaces

**Input**: `ProfileProvider` via `Provider.of<ProfileProvider>(context)` — read at build time and mutated via async calls.

**Output**: 
- `profileProvider.updateProfile(...)` — main profile save
- `profileProvider.uploadProfilePicture(source: ...)` — avatar upload
- `profileProvider.uploadCoverPicture(source: ...)` — cover upload
- `profileProvider.uploadDocument(type)` — document upload
- `profileProvider.replaceDocument(id, type)` — document replace
- `profileProvider.addLanguage(LanguageWithProficiency)` — add language chip
- `profileProvider.deleteLanguage(name)` — remove language chip
- `profileProvider.addSkill(SkillWithProficiency)` — add skill chip
- `profileProvider.deleteSkill(name)` — remove skill chip
- `profileProvider.updateAchievements(List<String>)` — update achievements

**Navigation**: `Navigator.pop(context)` only (no push to sub-screens).

---

### Error Handling

| Scenario | Handling |
|---|---|
| `updateProfile()` throws | SnackBar "Failed to update profile: [error]", screen stays, form intact |
| Photo upload fails | `profileProvider.uploadError` shown inline below photo header in `AppColors.error` |
| GPS permission denied | SnackBar "Location permission denied. Please enable it in settings." |
| GPS lookup error | SnackBar "Could not detect location. Please try again." |
| Map pin modal dismissed without confirm | `_pinnedLatitude` / `_pinnedLongitude` remain unchanged |
| Duplicate language/skill | SnackBar "Already added" |
| Empty language/skill add | No-op (ignored silently, button disabled when text empty) |
| Form validation failure on save | Inline field error messages, `updateProfile()` not called |

---

### State Management

`_EditProfileScreenState` owns all transient UI state (controllers, booleans, expansion states). `ProfileProvider` (via `Provider`) owns persisted profile data. The two are bridged at:

1. **`initState`** — controllers populated from provider values; `_initialValues` snapshot captured.
2. **Save** — controller values flushed back to provider via `updateProfile()`.
3. **Chip mutations** — `addLanguage`, `deleteLanguage`, `addSkill`, `deleteSkill`, `updateAchievements` are called immediately (live, not batched) so provider stays in sync without waiting for the Save button.

---

### Theme and Colours

All colour references follow the pattern below (no `withOpacity()` used anywhere):

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor     = isDark ? AppColors.darkBackground   : AppColors.lightBackground;
final surfaceColor = isDark ? AppColors.darkSurface      : AppColors.lightSurface;
final textColor    = isDark ? AppColors.darkText         : AppColors.lightText;
final subTextColor = isDark ? AppColors.darkTextSecondary: AppColors.lightTextSecondary;
final borderColor  = isDark ? AppColors.darkBorder       : AppColors.lightBorder;
```

Interactive brand colour: `AppColors.accent` (`0xFF0F766E`) only.  
Button shadow: `AppColors.accentShadow`.  
Card shadows: `AppColors.softShadow`.

---

### Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Provider data reflected in displayed fields

*For any* `ProfileProvider` state loaded into the screen, each text field, chip list, switch, and selector widget displayed to the user SHALL reflect the corresponding value from the provider at screen open time.

**Validates: Requirements 4.1, 5.1, 5.2, 5.3, 5.5, 6.1, 6.2, 7.1, 7.5, 8.1, 10.1**

---

### Property 2: Email validation rejects all non-email strings

*For any* string that does not match `RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$')`, the email field's validator SHALL return a non-null error string, and `updateProfile()` SHALL NOT be called.

**Validates: Requirements 4.2, 4.9**

---

### Property 3: Date of Birth formatted as dd/MM/yyyy

*For any* valid `DateTime` value selected via the date picker, the Date of Birth read-only field SHALL display it formatted as `dd/MM/yyyy` using `intl`'s `DateFormat`.

**Validates: Requirements 4.5**

---

### Property 4: Duplicate chip entries are rejected

*For any* language or skill name already present in the respective list, submitting that same name via the add-chip text field SHALL result in a SnackBar with the message "Already added" and the list SHALL remain unchanged (no duplicate entry added).

**Validates: Requirements 7.9**

---

### Property 5: URL fields reject non-HTTP(S) values

*For any* non-empty URL field value that does not start with `http://` or `https://`, the URL validator SHALL return a non-null error string, and `updateProfile()` SHALL NOT be called.

**Validates: Requirements 11.2**

---

### Property 6: Phone number passed as dial-code concatenated with number

*For any* selected dial code prefix and phone number text, the `phone` argument passed to `ProfileProvider.updateProfile()` SHALL equal the dial code string concatenated with the trimmed phone number text.

**Validates: Requirements 12.6**

---

### Property 7: Verification status badge matches document status

*For any* `Document` in `ProfileProvider.documents`, the rendered status badge in the Documents section SHALL display "Pending", "Verified", or "Rejected" corresponding to the document's `DocumentVerificationStatus` value, with no status label mapped to a different value.

**Validates: Requirements 9.5**

---

### Property 8: Two-column layout applied for wide screens

*For any* screen width greater than 600 logical pixels, `LayoutBuilder` SHALL render form field pairs side-by-side in a two-column arrangement (each column width ≤ half the available width minus spacing), rather than stacking them vertically.

**Validates: Requirements 15.3**
