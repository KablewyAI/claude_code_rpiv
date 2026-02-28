---
description: Implment tests for Test Driven Development workflow
---

Implement the following feature using strict test-driven development. DO NOT write any implementation code until the tests exist and fail.

Feature: $ARGUMENTS

Phase 1 — Test Design: Research the codebase to understand existing patterns, then write comprehensive test cases covering happy path, edge cases, and error scenarios. Run tests to confirm they all FAIL (red). Commit with message 'test: add failing tests for [feature]'.

Phase 2 — Minimal Implementation: Write the minimum code to make each test pass, one at a time. After each change, run the FULL test suite (not just new tests). If any existing test breaks, fix the regression before continuing. Commit after each group of tests goes green.

Phase 3 — Refactor & Harden: With all tests passing, refactor for production quality. Check for: TypeScript strict mode compliance, proper error handling that surfaces to UI, no race conditions in async flows, correct imports (check MCP SDK version). Run full test suite one final time.

Phase 4 — Validation Report: List every file changed, every test added, final test suite results, and any architectural decisions made. Flag anything that needs manual browser testing.