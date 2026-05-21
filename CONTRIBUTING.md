# Contributing to flutter-data_gov_gr

Hey there! 👋 Thanks so much for taking the time to read this. Whether you're here to fix a small typo in a doc, add support for a brand new dataset, or optimize network calls, we're really glad to have you!

This SDK is built to make accessing Hellenic open data (from `data.gov.gr`) easy, type-safe, and pleasant for Flutter/Dart developers. Here's a quick guide on how to get up and running, and how we keep the codebase clean.

---

## 🚀 Getting Set Up

To get started, fork the repository, clone it locally, and pull the dependencies:

```bash
git clone https://github.com/georgetzan/flutter-data_gov_gr.git
cd flutter-data_gov_gr
dart pub get
```

If you want to run or work on the example app:
```bash
cd example
flutter pub get
```

---

## ✍️ Writing Great Commit Messages

We care a lot about keeping our Git history clean, readable, and easy to search. Good commit messages make it easy to figure out *why* a change was made six months down the line, and they help us write clean changelogs!

Think of your commit message as a quick summary of your changes written for a fellow developer. Here's how we structure them:

### 1. The Subject Line (First Line)
* **Keep it short**: Try to keep the first line under 50–60 characters.
* **Use prefix categories**: We recommend starting with a prefix to categorize the change:
  - `feat:` for new features (e.g., adding a new dataset service)
  - `fix:` for bug fixes (e.g., correcting an API parser)
  - `docs:` for documentation updates (e.g., README fixes)
  - `refactor:` for code changes that don't add features or fix bugs (e.g., renaming a variable, restructuring a class)
  - `chore:` for build tools, dependencies, or git configs
* **Imperative mood**: Write it like a command (e.g., `fix: map inbound traffic fields` instead of `fixed mapping` or `fixes mapping`).

### 2. The Body (Optional, but highly recommended for non-trivial changes)
* Leave a blank line after the subject line.
* Use bullet points to list the key changes. Write in plain, conversational English explaining **what** changed and **why**.

---

### Good vs. Bad Examples

❌ **Bad (Vague and unhelpful)**:
> fix bug
> updates
> final code changes
> working on app screen

**Good (Clear, structured, and informative)**:
> fix: correct out-of-bounds error on datastore pagination
> 
> - Added check for empty records array in CkanCompatibilityInterceptor.
> - Handled empty responses gracefully instead of throwing a RangeError.
> - Added a unit test to verify this behavior under bad network connectivity.

---

## 🛠 Project Architecture

Our codebase is designed to be simple and backward-compatible:
* **The Core SDK** is inside [lib/](lib).
* **The Example App** is inside [example/](example).
* **The Compatibility Interceptor** ([ckan_compatibility_interceptor.dart](lib/src/interceptors/ckan_compatibility_interceptor.dart)) sits between our code and the new CKAN API. We use it to map legacy REST URLs to CKAN actions so we don't break existing apps using this SDK.

---

## 🧪 Testing Your Changes

Before submitting your pull request, please make sure your changes don't break anything. 

Run local unit tests (uses mock/stub data, no internet required):
```bash
dart test
```

Run live integration tests (queries the real production `data.gov.gr` portal):
```bash
DATA_GOV_GR_TOKEN="your_actual_api_token" dart test test/integration_test.dart
```

Ensure formatting is tidy and there are no analyzer warnings:
```bash
dart format .
flutter analyze
```

---

## 🙌 Submitting a Pull Request

* **Keep it small**: Try to address one issue or feature per pull request. It makes review times faster and much easier.
* **Update documentation**: If you change any public-facing API signatures, please update `README.md` or code comments.
* **Be patient and kind**: We'll review your pull request as soon as we can. Let's make this library great together!

