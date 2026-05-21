# Contributing to data_gov_gr

Hey there! Thanks so much for taking the time to read this. Whether you're here to fix a small typo, add support for a brand new dataset, or help optimize code, we're really glad to have your help. 

This SDK is built to make accessing Hellenic open data (from `data.gov.gr`) easy and pleasant. Below is a quick guide on how to get set up and how we work together.

---

## 🚀 Getting Set Up

To get started, clone the repository and fetch the dependencies:

```bash
git clone https://github.com/yourusername/data_gov_gr.git
cd data_gov_gr
dart pub get
```

If you want to run or test the example app:
```bash
cd example
flutter pub get
```

---

## ✍️ Writing Commit Messages

We care about having a clean, readable Git history. When writing commit messages, please keep them friendly, understandable, and structured. 

### Commit Message Guidelines:
1. **Be Descriptive**: Write a clear, action-oriented title in the imperative mood (e.g., "Migrate SDK base URL" or "Fix internet traffic parsing").
2. **List Key Changes**: Use bullet points to list the main things you changed. This makes it easy for other developers (and future you!) to scan the history and see what was accomplished.
3. **Avoid Generic Messages**: Messages like "fixes", "updates", "working on stuff", or "final patch" are hard to read and track. Tell us *what* you did.

### Example of a Good Commit Message:
```text
Resolve internet traffic loading issues and add prefecture mock support

- Optimized datastore queries by caching records in ckan_compatibility_interceptor.
- Mapped raw avg_in and avg_out fields to inbound and outbound for InternetTraffic objects.
- Generated mock fuel price data for all 51 prefectures to prevent empty UI displays.
```

---

## 🛠 Project Architecture

Our codebase is designed to be simple and backward-compatible:
* **The Core SDK** is inside `lib/`.
* **The Example App** is inside `example/`.
* **The Compatibility Interceptor** (`lib/src/interceptors/ckan_compatibility_interceptor.dart`) sits between our code and `data.gov.gr`'s new CKAN API. We use it to map legacy REST URLs to CKAN actions so we don't break existing apps using this SDK.

---

## 🧪 Testing Your Changes

Before submitting your pull request, please make sure your changes don't break anything. 

Run local tests (uses mock/stub data, no internet required):
```bash
dart test
```

Run live integration tests (reaches out to the real production data.gov.gr portal):
```bash
DATA_GOV_GR_TOKEN="your_key" dart test test/integration_test.dart
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
