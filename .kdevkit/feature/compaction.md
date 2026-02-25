# Feature: Compaction

## Purpose

This feature aims to reduce the verbosity of the markdown files in the `src` directory.
It also includes investigating whether the coding agent is reading all files unnecessarily, and if so, preventing it.

## User Story

- **As a developer using kdevkit,** I want to compact the markdown files to make them less verbose.
- **As a developer using kdevkit,** I want to ensure the agent is not reading all files if the project context is already in `.kdevkit/project.md` to improve efficiency.
