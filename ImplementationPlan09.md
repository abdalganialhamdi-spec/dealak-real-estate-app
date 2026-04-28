# Implementation Plan 09: QA Fixes & Architectural Standardization

This plan addresses the issues identified in the QA Audit Report (April 2026).

## Phase 1: Network & Error Handling Standardization (Frontend)
Goal: Centralize error handling and eliminate technical error messages.

- [x] **1.1 Standardize Base Repository:**
  - Create a `BaseRepository` class that includes the `_handleError` logic currently duplicated/missing across repositories.
  - Update all repositories (`PropertyRepository`, `DealRepository`, etc.) to extend `BaseRepository`.
- [x] **1.2 Update DioClient:**
  - Standardized via `BaseRepository` and `safeCall` pattern across all repositories.
- [x] **1.3 UI Error Feedback:**
  - Implement a helper to extract and display validation errors in `CustomTextField`.
  - Update `PropertyCreateScreen` to show field-specific errors.

## Phase 2: Pagination & State Management Refactor (Frontend)
Goal: Fix the broken infinite scroll and list management.

- [x] **2.1 Replace FutureProvider with AsyncNotifier:**
  - Refactor `propertyProvider` (renamed to `propertiesProvider`) to use `AsyncNotifier` which can maintain a list state and handle `fetchNextPage` logic.
  - Ensure the provider handles appending data to the existing list.
- [x] **2.2 Update UI Screens:**
  - Update `PropertyListScreen` to use the new `AsyncNotifier` methods for loading more data.
  - Add a dedicated loader widget for "load more" state at the bottom of lists.

## Phase 3: API Contract Standardization (Backend)
Goal: Ensure consistent response structures across all endpoints.

- [x] **3.1 Unified Response Wrapper:**
  - Audit `PropertyController`, `DealController`, and `UserController`.
  - Ensure all single resource responses are wrapped in `data` (or consistent key).
  - Ensure all collection responses use `ResourceCollection` to maintain identical `meta` fields.
- [x] **3.2 Fix Metadata Inconsistency:**
  - Update `featured` and `similar` methods in `PropertyController` to return the same pagination metadata structure as the main `index` route.

## Phase 4: UX & Robustness Improvements
- [x] **4.1 Atomic Property Creation:**
  - Modify `PropertyRepository.createProperty` to handle image uploads more robustly by creating as `DRAFT` first and only marking `AVAILABLE` after successful upload.
- [x] **4.2 Data Type Cleanup:**
  - Enforce strict typing in Laravel Resources (e.g., cast all numeric fields to `float` or `int` explicitly) to reduce the need for `tryParse` in Flutter.

## Success Criteria
- [x] Infinite scroll works smoothly on `PropertyListScreen` without reloading the whole list.
- [x] Validation errors from the backend are displayed next to their respective fields in the frontend.
- [x] No raw `DioException` strings are visible in snackbars.
- [x] All API endpoints return a predictable JSON structure.
