# Implementation Plan: Portfolio Content Sync

**Branch**: `001-update-bio-content` | **Date**: 2026-02-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-update-bio-content/spec.md`

## Summary

Automatically sync the GitHub Pages bio site with current project information from GitHub (pinned repositories) and professional profile data from LinkedIn. The system will support manual on-demand updates to refresh bio page content while preserving the existing Jekyll/Minimal Mistakes theme structure.

**Primary Requirement**: Display pinned GitHub repositories and full LinkedIn professional profile on the bio page.

**Technical Approach**: Jekyll data files + GitHub Actions workflow for manual trigger + GitHub API integration for pinned repos + manual LinkedIn data entry.

## Technical Context

**Language/Version**: Ruby 2.7+ (Jekyll 4.x), Markdown, Liquid templates, YAML
**Primary Dependencies**: Jekyll 4.x, Minimal Mistakes theme (remote), GitHub Pages gem, GitHub API (REST v3)
**Storage**: YAML data files (`_data/` directory), Markdown content files
**Testing**: Manual validation via `bundle exec jekyll serve` and visual inspection (per Constitution III)
**Target Platform**: GitHub Pages (static hosting)
**Project Type**: Static website (Jekyll-based portfolio)
**Performance Goals**: Page load under 3 seconds, update process under 5 minutes
**Constraints**: No theme modification allowed, no new Jekyll plugins, GitHub API rate limits (60/hr unauthenticated, 5000/hr authenticated)
**Scale/Scope**: Small portfolio site (~5-20 projects, single professional profile, <10 static pages)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Principle I: Clean Code
- All YAML data files will use 2-space indentation
- Markdown content will follow proper heading hierarchy
- File naming: lowercase, hyphen-separated (e.g., `projects-data.yml`)
- No trailing whitespace or excessive blank lines
- **STATUS**: Compliant - standard Jekyll data file patterns

### ✅ Principle II: Framework Preservation (NON-NEGOTIABLE)
- No modifications to `_config.yml` theme settings
- No new Jekyll plugins beyond existing `Gemfile`
- No theme overrides in `_layouts/`, `_includes/`, or `_sass/`
- Remote theme `mmistakes/minimal-mistakes` remains unchanged
- Content will use existing theme capabilities (data files + includes)
- **STATUS**: Compliant - using Jekyll data files and existing front matter, no theme changes

### ✅ Principle III: No Testing (NON-NEGOTIABLE)
- No test frameworks, test suites, or test runners
- No automated testing CI/CD pipelines
- Validation via manual local preview only
- This plan will omit all test-related tasks and phases
- **STATUS**: Compliant - manual validation workflow only

**OVERALL GATE STATUS**: ✅ PASS - All principles satisfied, no violations

## Project Structure

### Documentation (this feature)

```text
specs/001-update-bio-content/
├── spec.md              # Feature specification
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output (research findings)
├── data-model.md        # Phase 1 output (data structures)
├── quickstart.md        # Phase 1 output (setup guide)
├── contracts/           # Phase 1 output (API schemas)
│   └── github-api.yml   # GitHub API contract
└── tasks.md             # Phase 2 output (/speckit.tasks - NOT created yet)
```

### Source Code (repository root - existing Jekyll structure)

```text
DataNeuron.github.io/
├── _config.yml          # Jekyll config (DO NOT MODIFY per Constitution II)
├── _data/               # Data files (CREATE/MODIFY)
│   ├── projects.yml     # GitHub pinned repos data
│   └── profile.yml      # LinkedIn professional data
├── _posts/              # Blog posts (existing)
├── _pages/              # Static pages (existing)
├── images/              # Assets (existing)
├── index.md             # Homepage (MODIFY to include project data)
├── cv.md                # CV page (MODIFY to include profile data)
├── .github/
│   └── workflows/
│       └── update-bio.yml  # Manual trigger workflow (CREATE)
└── scripts/             # Update scripts (CREATE)
    ├── fetch-github-projects.rb    # Fetch pinned repos
    └── update-bio-data.sh           # Orchestration script
```

**Structure Decision**: Using standard Jekyll data files (`_data/`) to store fetched content. Existing pages will reference data via Liquid templates. GitHub Actions workflow for manual update trigger. No modifications to theme or config files.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations detected. All constitution principles are satisfied.

## Phase 0: Research & Investigation

### Research Tasks

1. **GitHub API for Pinned Repositories**
   - **Question**: How to retrieve pinned repositories via GitHub API?
   - **Investigation**: GitHub REST API v3 endpoints, authentication requirements, rate limits
   - **Output**: API endpoint documentation, authentication approach, data structure

2. **LinkedIn Data Strategy**
   - **Question**: How to obtain LinkedIn professional profile data given API restrictions?
   - **Investigation**: Manual data entry vs scraping vs third-party services
   - **Output**: Recommended approach with implementation steps
   - **Note**: Spec clarification incomplete - assuming manual entry approach

3. **Manual Update Trigger Mechanism**
   - **Question**: How to implement manual on-demand updates for bio page?
   - **Investigation**: GitHub Actions workflow_dispatch, local script execution, combination approach
   - **Output**: Trigger mechanism design and workflow specification

4. **Jekyll Data File Integration**
   - **Question**: How to integrate dynamic data into existing Jekyll pages without theme modification?
   - **Investigation**: Jekyll data files, Liquid template best practices, front matter extensions
   - **Output**: Integration pattern and example templates

5. **Error Handling & Placeholders**
   - **Question**: How to implement placeholder messages when data unavailable?
   - **Investigation**: Conditional Liquid logic, default values, error state display patterns
   - **Output**: Error handling template patterns

### Deferred to Phase 1

- Specific data schemas (will be defined in data-model.md)
- API contract details (will be defined in contracts/)
- Exact file locations and naming (will be defined in quickstart.md)

## Phase 1: Design & Contracts

**Prerequisites**: research.md complete with all questions answered

### Outputs Required

1. **data-model.md**: Define YAML structure for projects.yml and profile.yml
2. **contracts/github-api.yml**: GitHub API endpoint contract (OpenAPI format)
3. **quickstart.md**: Setup and manual update execution guide

### Design Scope

- YAML data schemas for projects and profile
- GitHub API integration points
- LinkedIn data manual entry format
- Update script workflow
- Liquid template integration patterns
- Error state handling logic

## Phase 2: Task Generation

**Prerequisites**: Phase 0 and Phase 1 complete

Execute `/speckit.tasks` to generate actionable task list from this plan.

Tasks will be ordered by dependency and marked with:
- Priority (P0/P1/P2)
- Estimated effort
- Dependencies
- **NO test tasks** (per Constitution III)

## Notes

- **Constitution Compliance**: This plan strictly adheres to all three core principles
- **Testing**: All testing sections explicitly excluded per Constitution III
- **Theme Preservation**: All changes use data files and content only, no theme modifications
- **Clarification Gaps**: LinkedIn data access method not fully clarified but proceeding with manual entry assumption
- **Manual Validation**: All changes will be previewed with `bundle exec jekyll serve` before deployment
