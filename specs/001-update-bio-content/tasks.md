# Tasks: Portfolio Content Sync

**Feature**: 001-update-bio-content
**Input**: Design documents from `/specs/001-update-bio-content/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Per Constitution III (No Testing), this feature includes NO automated test tasks. All validation is manual via `bundle exec jekyll serve`.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are absolute or relative to repository root

## Path Conventions

This is a Jekyll static site at repository root:
- **Data files**: `_data/` directory
- **Pages**: Root and `_pages/` directory
- **Scripts**: `scripts/` directory
- **Workflows**: `.github/workflows/` directory
- **NO theme modifications allowed** (Constitution II)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and directory structure

- [x] T001 [P] Create `_data/` directory if it doesn't exist
- [x] T002 [P] Create `scripts/` directory if it doesn't exist
- [x] T003 [P] Create `.github/workflows/` directory if it doesn't exist
- [x] T004 Verify Jekyll and Minimal Mistakes theme are properly configured (no modifications allowed)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Create GitHub Personal Access Token with `public_repo` scope (documented in quickstart.md) ✅ USER COMPLETED
- [x] T006 Add `PORTFOLIO_SYNC_TOKEN` secret to repository Settings → Secrets → Actions ✅ USER COMPLETED
- [x] T007 [P] Document token setup process in local `.env` file template for local development
- [x] T008 Verify existing pages (`index.md`, `cv/index.md`) are accessible and editable

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 + 3 - GitHub Projects Display (Priority: P1) 🎯 MVP

**Combined Stories**:
- **US1**: View Current GitHub Projects
- **US3**: Access Project Links (integrated - same template, clickable URLs)

**Goal**: Display pinned GitHub repositories on the bio page with clickable links, fetched via GitHub GraphQL API and manual workflow trigger

**Independent Test**: Visit `https://dataneuron.github.io/`, verify pinned repositories are displayed with names, descriptions, languages, stars, and clickable links that open in new tabs

### Data Structure for User Story 1+3

- [x] T009 [P] [US1] Create `_data/projects.yml` with initial empty structure per data-model.md
- [x] T010 [P] [US1] Add fetch_metadata section to `_data/projects.yml` with placeholder values
- [x] T011 [P] [US1] Add empty projects array to `_data/projects.yml`

### GitHub Fetch Script for User Story 1+3

- [x] T012 [US1] Create `scripts/fetch-github-projects.rb` Ruby script skeleton
- [x] T013 [US1] Implement GitHub GraphQL query in `scripts/fetch-github-projects.rb` per contracts/github-api.yml
- [x] T014 [US1] Implement authentication with Personal Access Token in `scripts/fetch-github-projects.rb`
- [x] T015 [US1] Implement response parsing and data transformation in `scripts/fetch-github-projects.rb`
- [x] T016 [US1] Implement error handling (rate limits, auth errors, network errors) in `scripts/fetch-github-projects.rb`
- [x] T017 [US1] Implement YAML file writing with atomic file operations in `scripts/fetch-github-projects.rb`
- [x] T018 [US1] Add success/error logging and console output in `scripts/fetch-github-projects.rb`
- [x] T019 [US1] Make `scripts/fetch-github-projects.rb` executable (`chmod +x`)

### Manual Update Workflow for User Story 1+3

- [x] T020 [P] [US1] Create `.github/workflows/update-bio.yml` workflow file skeleton
- [x] T021 [US1] Add workflow_dispatch trigger with input parameters in `.github/workflows/update-bio.yml`
- [x] T022 [US1] Add checkout and Ruby setup steps in `.github/workflows/update-bio.yml`
- [x] T023 [US1] Add GitHub projects fetch step using token secret in `.github/workflows/update-bio.yml`
- [x] T024 [US1] Add git commit and push steps with bot credentials in `.github/workflows/update-bio.yml`
- [x] T025 [US1] Add workflow summary generation in `.github/workflows/update-bio.yml`

### Homepage Integration for User Story 1+3

- [x] T026 [US1] [US3] Update `index.md` to add Projects section header
- [x] T027 [US1] [US3] Add Liquid template to check `site.data.projects` exists in `index.md`
- [x] T028 [US1] [US3] Add Liquid loop to iterate over `site.data.projects.projects` in `index.md`
- [x] T029 [US1] [US3] Display project name, description, language, stars, forks in `index.md`
- [x] T030 [US1] [US3] Add clickable project URLs with `target="_blank"` in `index.md` (FR-003, US3)
- [x] T031 [US1] [US3] Add conditional rendering for missing descriptions and language in `index.md`
- [x] T032 [US1] [US3] Add placeholder message for empty/error state per FR-014 in `index.md`
- [x] T033 [US1] [US3] Display "Last updated" timestamp from fetch_metadata in `index.md` (FR-012)

### Manual Validation for User Story 1+3

- [ ] T034 [US1] Test fetch script locally: `export GITHUB_TOKEN=<token>; ruby scripts/fetch-github-projects.rb`
- [ ] T035 [US1] Verify `_data/projects.yml` contains fetched pinned repositories with correct structure
- [ ] T036 [US1] [US3] Preview site locally: `bundle exec jekyll serve`
- [ ] T037 [US1] [US3] Verify projects section displays on `http://localhost:4000` with all fields
- [ ] T038 [US1] [US3] Verify project links are clickable and open in new tabs
- [ ] T039 [US1] [US3] Test placeholder message by creating error state in projects.yml
- [ ] T040 [US1] Trigger GitHub Actions workflow manually from Actions tab
- [ ] T041 [US1] Verify workflow completes successfully and commits updated projects.yml
- [ ] T042 [US1] [US3] Verify live site at `https://dataneuron.github.io/` displays projects correctly

**Checkpoint**: At this point, User Stories 1 and 3 should be fully functional - visitors can see pinned projects with clickable links

---

## Phase 4: User Story 2 - Professional Profile Display (Priority: P2)

**Goal**: Display complete LinkedIn professional profile (experience, skills, certifications, education) on the CV page via manual YAML entry

**Independent Test**: Visit `https://dataneuron.github.io/cv/`, verify professional profile sections (headline, summary, experience, skills, certifications, education) are displayed with accurate information from `_data/profile.yml`

### Data Structure for User Story 2

- [x] T043 [P] [US2] Create `_data/profile.yml` file with structure per data-model.md
- [x] T044 [US2] Add personal information section (name, headline, summary) to `_data/profile.yml`
- [x] T045 [US2] Add experience array with first job entry to `_data/profile.yml`
- [x] T046 [US2] Add skills array grouped by category to `_data/profile.yml`
- [x] T047 [US2] Add certifications array to `_data/profile.yml`
- [x] T048 [US2] Add education array to `_data/profile.yml`
- [x] T049 [US2] Add contact information and metadata to `_data/profile.yml`

### CV Page Integration for User Story 2

- [x] T050 [US2] Update `cv/index.md` to add name and headline from `site.data.profile`
- [x] T051 [US2] Add professional summary section in `cv/index.md`
- [x] T052 [US2] Add Experience section with Liquid loop over `site.data.profile.experience` in `cv/index.md`
- [x] T053 [US2] Display job title, company, location, period, description for each experience in `cv/index.md`
- [x] T054 [US2] Display highlights list for each job (if present) in `cv/index.md`
- [x] T055 [US2] Add Skills section with Liquid loop over `site.data.profile.skills` in `cv/index.md`
- [x] T056 [US2] Display skill categories and items in `cv/index.md`
- [x] T057 [US2] Add Certifications section with Liquid loop over `site.data.profile.certifications` in `cv/index.md`
- [x] T058 [US2] Add Education section with Liquid loop over `site.data.profile.education` in `cv/index.md`
- [x] T059 [US2] Add conditional rendering for optional fields (GPA, honors, highlights) in `cv/index.md`
- [x] T060 [US2] Add placeholder message if `site.data.profile` doesn't exist in `cv/index.md`

### Manual Validation for User Story 2

- [ ] T061 [US2] Copy LinkedIn profile information to `_data/profile.yml` following data-model.md structure
- [ ] T062 [US2] Validate YAML syntax: `ruby -e "require 'yaml'; YAML.load_file('_data/profile.yml')"`
- [ ] T063 [US2] Preview site locally: `bundle exec jekyll serve`
- [ ] T064 [US2] Verify CV page displays at `http://localhost:4000/cv/` with all profile sections
- [ ] T065 [US2] Verify experience, skills, certifications, education sections render correctly
- [ ] T066 [US2] Commit `_data/profile.yml` and updated `cv.md` to repository
- [ ] T067 [US2] Verify live CV page at `https://dataneuron.github.io/cv/` displays correctly

**Checkpoint**: At this point, User Story 2 should be fully functional - visitors can see complete professional profile on CV page

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements, documentation, and validation

- [x] T068 [P] Add usage documentation to repository README.md (link to quickstart.md)
- [x] T069 [P] Verify all YAML files follow 2-space indentation (Constitution I: Clean Code)
- [x] T070 [P] Verify no theme files modified in `_layouts/`, `_includes/`, `_sass/` (Constitution II)
- [x] T071 [P] Verify `_config.yml` unchanged (Constitution II: Framework Preservation)
- [x] T072 Create maintenance schedule reminder for monthly LinkedIn profile sync
- [x] T073 Document workflow trigger process in quickstart.md
- [ ] T074 Run full validation checklist from quickstart.md Section 7
- [ ] T075 Verify success criteria SC-001 through SC-007 from spec.md
- [ ] T076 Test error states (API rate limit, missing data) per edge cases from spec.md
- [ ] T077 Final local preview with both projects and profile data: `bundle exec jekyll serve`
- [ ] T078 Final live site verification at `https://dataneuron.github.io/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup (Phase 1) completion - BLOCKS all user stories
- **User Stories (Phase 3, 4)**: All depend on Foundational (Phase 2) completion
  - Phase 3 (US1+US3) can proceed in parallel with Phase 4 (US2) - they work on different files
  - Or sequentially in priority order: Phase 3 (P1) → Phase 4 (P2)
- **Polish (Phase 5)**: Depends on all desired user stories (Phase 3, 4) being complete

### User Story Dependencies

- **User Story 1+3 (P1)** - Phase 3: Can start after Foundational (Phase 2) - No dependencies on other stories
  - US1 and US3 combined (same templates, both P1 priority)
- **User Story 2 (P2)** - Phase 4: Can start after Foundational (Phase 2) - Completely independent of US1/US3 (different files)

### Within Each User Story

- **Phase 3 (US1+US3)**:
  1. Data structure tasks (T009-T011) - can run in parallel
  2. Fetch script implementation (T012-T019) - sequential
  3. Workflow creation (T020-T025) - can run in parallel with fetch script
  4. Homepage integration (T026-T033) - depends on data structure existing
  5. Validation (T034-T042) - sequential, after all implementation

- **Phase 4 (US2)**:
  1. Data structure tasks (T043-T049) - can run in parallel
  2. CV page integration (T050-T060) - depends on data structure existing
  3. Validation (T061-T067) - sequential, after implementation

### Parallel Opportunities

- **Setup (Phase 1)**: All 4 tasks can run in parallel (all marked [P])
- **Foundational (Phase 2)**: T007 can run in parallel with T005-T006
- **Phase 3 (US1+US3)**:
  - T009, T010, T011 (data structure) in parallel
  - T020 (workflow skeleton) in parallel with T012-T019 (fetch script)
  - T026-T028 (homepage) in parallel after data structure exists
- **Phase 4 (US2)**:
  - T043-T049 (data structure) in parallel
  - T050-T060 (CV integration) in parallel after data structure
- **Phase 5 (Polish)**: T068-T071 all marked [P], can run in parallel

**Key Insight**: **Phase 3 (US1+US3) and Phase 4 (US2) are COMPLETELY INDEPENDENT and can run in parallel** by different team members or sequentially by a single developer.

---

## Parallel Example: User Story 1+3 (Phase 3)

```bash
# Launch data structure tasks together:
Task: "Create _data/projects.yml with initial empty structure"
Task: "Add fetch_metadata section to _data/projects.yml"
Task: "Add empty projects array to _data/projects.yml"

# While working on fetch script, can simultaneously work on workflow:
Task: "Create .github/workflows/update-bio.yml workflow file skeleton"
# AND
Task: "Create scripts/fetch-github-projects.rb Ruby script skeleton"
```

---

## Parallel Example: Phase 3 + Phase 4 Together

```bash
# Developer A works on Phase 3 (US1+US3):
Task: "Create _data/projects.yml"
Task: "Create scripts/fetch-github-projects.rb"
Task: "Update index.md with projects section"

# Developer B works on Phase 4 (US2) AT THE SAME TIME:
Task: "Create _data/profile.yml"
Task: "Update cv.md with profile sections"

# NO CONFLICTS - completely different files
```

---

## Implementation Strategy

### MVP First (User Stories 1+3 Only)

This is the **recommended approach** for initial deployment:

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T008) - CRITICAL
3. Complete Phase 3: User Stories 1+3 (T009-T042)
4. **STOP and VALIDATE**: Test US1+US3 independently via manual validation tasks
5. Deploy to production - visitors can see pinned projects
6. **MVP DELIVERED** ✅

At this point, you have a working feature that displays GitHub projects!

### Full Feature (Add User Story 2)

After MVP is live and validated:

1. Complete Phase 4: User Story 2 (T043-T067)
2. **VALIDATE**: Test US2 independently via manual validation tasks
3. Deploy to production - visitors can now see professional profile
4. Complete Phase 5: Polish (T068-T078)
5. **FULL FEATURE DELIVERED** ✅

### Incremental Delivery Benefits

- **After Phase 3**: Bio page shows GitHub projects (core value delivered)
- **After Phase 4**: Bio page adds professional profile (complete portfolio)
- **After Phase 5**: Everything polished and documented

Each phase adds value without breaking previous functionality!

### Parallel Team Strategy

With 2 developers available:

1. **Together**: Complete Phase 1 (Setup) + Phase 2 (Foundational)
2. **Split**:
   - Developer A: Phase 3 (US1+US3) - GitHub projects
   - Developer B: Phase 4 (US2) - LinkedIn profile
3. **Merge**: Both stories integrate independently
4. **Together**: Phase 5 (Polish)

**Time savings**: ~50% reduction by parallelizing Phase 3 and Phase 4

---

## Notes

- **[P] tasks** = different files or independent components, no dependencies, safe to parallelize
- **[Story] label** = maps task to specific user story (US1, US2, US3) for traceability
- **NO test tasks** per Constitution III - all validation is manual via Jekyll preview
- **Constitution compliance**:
  - No `_config.yml` modifications (Principle II)
  - No theme overrides (Principle II)
  - No test frameworks (Principle III)
  - Clean YAML formatting (Principle I)
- **Manual validation checkpoints** after each user story ensure independent functionality
- **Atomic deployments**: Each user story can be deployed independently
- **File conflicts**: None - US1+US3 work on index.md, US2 works on cv.md, completely separate
- **Success criteria**: Validate SC-001 through SC-007 from spec.md in Phase 5 (T075)

---

## Task Count Summary

- **Phase 1 (Setup)**: 4 tasks
- **Phase 2 (Foundational)**: 4 tasks (1 blocking checkpoint)
- **Phase 3 (US1+US3)**: 34 tasks (MVP)
- **Phase 4 (US2)**: 25 tasks
- **Phase 5 (Polish)**: 11 tasks

**Total**: 78 tasks

**Parallel opportunities**: 17 tasks marked [P] can run simultaneously
**Independent stories**: US1+US3 (34 tasks) and US2 (25 tasks) are fully independent

**MVP scope**: Phase 1 + 2 + 3 = 42 tasks to deliver core value (GitHub projects display)
**Full feature**: All 78 tasks for complete portfolio sync

---

## Validation Criteria

### After Phase 3 (US1+US3) - MVP Ready
- [ ] Run `bundle exec jekyll serve` successfully
- [ ] Visit `http://localhost:4000/` and see Projects section
- [ ] All pinned GitHub repos displayed with name, description, language, stars
- [ ] Project links are clickable and open GitHub in new tab
- [ ] "Last updated" timestamp is visible
- [ ] Placeholder message appears when projects.yml has error status
- [ ] GitHub Actions workflow can be triggered manually
- [ ] Workflow successfully fetches and commits updated projects.yml
- [ ] Live site `https://dataneuron.github.io/` displays projects correctly

### After Phase 4 (US2) - Full Feature Ready
- [ ] All Phase 3 validations still pass (US1+US3 not broken)
- [ ] Run `bundle exec jekyll serve` successfully
- [ ] Visit `http://localhost:4000/cv/` and see professional profile
- [ ] Name, headline, summary displayed correctly
- [ ] Experience section shows all jobs with details
- [ ] Skills grouped by category and displayed
- [ ] Certifications listed with issuer and dates
- [ ] Education section shows degrees and institutions
- [ ] Live site `https://dataneuron.github.io/cv/` displays profile correctly

### After Phase 5 (Polish) - Production Ready
- [ ] All Phase 3 and 4 validations pass
- [ ] README.md links to quickstart guide
- [ ] All YAML files use 2-space indentation
- [ ] No theme files modified (`git status` shows only data/content changes)
- [ ] `_config.yml` unchanged (verify with `git diff _config.yml`)
- [ ] Success criteria SC-001 through SC-007 validated
- [ ] Error states tested (rate limit, missing data)
- [ ] Full site preview looks professional
- [ ] Live site fully functional

**Definition of Done**: All validation criteria met, Constitution principles satisfied, manual validation successful ✅
