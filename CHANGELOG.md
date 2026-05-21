# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-21

### Added
- Complete type-safe Dart SDK wrapping the Greek Government Open Data portal (data.gov.gr).
- Type-safe sub-services:
  - `fuel`: Detailed liquid fuel station pricing and prefecture queries.
  - `health`: COVID-19 vaccination stats and demographics.
  - `procurement`: KIMDIS decision lookups (`khmdhs_decisions`).
  - `telecom`: GR-IX Internet traffic monitoring.
  - `environment`: Forest fire metrics.
  - `business`: State budget, revenues, and debt metrics.
  - `justice`: Road accidents and traffic statistics.
  - `education`: University metrics.
  - `society`: Labor market statistics.
  - `technology`: Internet usage indicators.
  - `transport`: Public transport and airport metrics.
- Universal `generic` query DSL matching any custom dataset key with auto-pagination.
- Interactive high-fidelity Flutter example app featuring real-time monitor dashboards, a searchable data catalog, and reactive rate limit status bars.
- Mock client interface (`DataGovMockClient`) with pre-populated stubs for testing offline.

### Fixed
- Migrated legacy REST endpoints to the new CKAN Action API v3 backend using a custom HTTP interceptor (`CkanCompatibilityInterceptor`).
- Implemented in-memory response caching for datastore queries to reduce server overhead.
