# Validation Checklist - Portfolio Content Sync Feature

**Feature**: 001-update-bio-content
**Date**: 2026-02-08
**Status**: Implementation Complete - Validation Pending

This document provides a comprehensive checklist for validating the portfolio content sync feature.

## Overview

All implementation tasks (T001-T073) are complete. The following validation tasks ensure the feature works correctly in both local and production environments.

## Prerequisites

Before starting validation:

- [ ] GitHub Personal Access Token created and added to repository secrets as `PORTFOLIO_SYNC_TOKEN`
- [ ] Ruby 2.7+ installed locally for testing
- [ ] Repository cloned locally
- [ ] Bundle dependencies installed: `bundle install`

## T074: Full Validation Checklist (Quick Start Section 7)

### 7.1 Check Data Files

```bash
# Navigate to repository
cd D:\ai_projects\DataNeuron.github.io

# Verify projects data exists and is valid
cat _data/projects.yml | head -20

# Verify profile data exists and is valid
cat _data/profile.yml | head -20

# Validate YAML syntax
ruby -e "require 'yaml'; puts YAML.load_file('_data/projects.yml').inspect"
ruby -e "require 'yaml'; puts YAML.load_file('_data/profile.yml').inspect"
```

**Expected Results**:
- ✅ Both files exist
- ✅ YAML syntax is valid (no errors)
- ✅ Files contain expected data structure

### 7.2 Preview Site Locally

```bash
# Start Jekyll server
bundle exec jekyll serve

# Open browser to http://localhost:4000
# Check that projects and profile sections display correctly
```

**Expected Results**:
- ✅ Server starts without errors
- ✅ Homepage displays with projects section
- ✅ CV page displays with profile sections
- ✅ No placeholder messages (or appropriate placeholder if data is pending)

### 7.3 Check Live Site

After pushing changes:

```bash
# Wait 1-2 minutes for GitHub Pages to rebuild

# Visit your site
# https://dataneuron.github.io/
```

**Expected Results**:
- ✅ Projects section shows pinned repos (or will after workflow run)
- ✅ CV page shows LinkedIn profile data
- ✅ No placeholder messages (unless workflow hasn't run yet)
- ✅ "Last updated" timestamp is recent

---

## T075: Verify Success Criteria (from spec.md)

### SC-001: Display Pinned GitHub Repositories

**Test Steps**:
1. Ensure you have at least one pinned repository on GitHub profile
2. Run "Update Bio Content" workflow with `projects` option
3. Wait for workflow to complete successfully
4. Visit homepage: https://dataneuron.github.io/

**Success Criteria**:
- [ ] Pinned repositories are displayed in a projects section
- [ ] Each project shows: name, description, language, stars, forks
- [ ] Project names are clickable links that open in new tabs
- [ ] Links point to correct GitHub repository URLs

### SC-002: Clickable Repository Links

**Test Steps**:
1. On homepage, click a project name link

**Success Criteria**:
- [ ] Link opens in new browser tab (`target="_blank"`)
- [ ] URL navigates to correct GitHub repository
- [ ] Link has `rel="noopener noreferrer"` for security

### SC-003: Display Professional Profile

**Test Steps**:
1. Ensure `_data/profile.yml` contains your LinkedIn data
2. Visit CV page: https://dataneuron.github.io/cv/

**Success Criteria**:
- [ ] Name and headline are displayed prominently
- [ ] Professional summary is shown
- [ ] All sections render: Experience, Skills, Certifications, Education
- [ ] Content matches `_data/profile.yml` data

### SC-004: Manual Update Trigger

**Test Steps**:
1. Go to repository Actions tab
2. Select "Update Bio Content" workflow
3. Click "Run workflow"
4. Choose branch: `master`
5. Select section: `projects`
6. Click green "Run workflow" button

**Success Criteria**:
- [ ] Workflow starts within 5 seconds
- [ ] Workflow completes successfully within 60 seconds
- [ ] Workflow summary shows update details
- [ ] No errors in workflow logs

### SC-005: Update Only Changed Content

**Test Steps**:
1. Note current `_data/projects.yml` content
2. Run workflow without changing pinned repos
3. Check git history

**Success Criteria**:
- [ ] If no repos changed, workflow creates no new commit
- [ ] If repos changed, only `_data/projects.yml` is committed
- [ ] Other files remain unchanged

### SC-006: Handle Missing/Empty Data Gracefully

**Test Steps**:
1. Test with empty `_data/projects.yml` (projects: [])
2. Visit homepage

**Success Criteria**:
- [ ] Page renders without errors
- [ ] Appropriate placeholder message is shown
- [ ] No broken layouts or console errors

**Test Steps**:
1. Temporarily rename `_data/profile.yml` to test missing data
2. Visit CV page

**Success Criteria**:
- [ ] Page renders without errors
- [ ] Appropriate placeholder message is shown
- [ ] No broken layouts or console errors

### SC-007: Preserve Jekyll Theme

**Test Steps**:
1. Check git history for modified files
2. Verify no changes to theme directories

**Success Criteria**:
- [ ] No files modified in `_layouts/`, `_includes/`, `_sass/`
- [ ] `_config.yml` unchanged
- [ ] All changes are in `_data/`, `scripts/`, `.github/workflows/`, and content files

---

## T076: Test Error States

### Error State 1: GitHub API Rate Limit

**Simulation**:
- Make 60+ API calls in quick succession (unlikely in normal use)
- Or wait for rate limit if you've been testing heavily

**Test Steps**:
1. Trigger workflow multiple times rapidly
2. Check workflow logs

**Expected Behavior**:
- [ ] Error message logged: "API rate limit exceeded"
- [ ] Workflow fails gracefully without corrupting data
- [ ] Error message includes rate limit reset time
- [ ] `_data/projects.yml` contains error metadata

### Error State 2: Invalid/Expired Token

**Simulation**:
1. Temporarily change `PORTFOLIO_SYNC_TOKEN` to invalid value
2. Run workflow

**Expected Behavior**:
- [ ] Error message: "Bad credentials" or similar
- [ ] Workflow fails gracefully
- [ ] `_data/projects.yml` contains error metadata
- [ ] No partial/corrupted data written

### Error State 3: Missing GitHub Token

**Simulation**:
1. Remove `PORTFOLIO_SYNC_TOKEN` secret
2. Run workflow

**Expected Behavior**:
- [ ] Error message: "GITHUB_TOKEN not found"
- [ ] Workflow fails with clear error message
- [ ] User is instructed to set token

### Error State 4: Network Timeout

**Expected Behavior** (if encountered):
- [ ] Timeout error logged
- [ ] `_data/projects.yml` contains error metadata
- [ ] User can retry workflow

### Error State 5: Invalid YAML Syntax

**Simulation**:
1. Manually edit `_data/profile.yml` with syntax error
2. Run Jekyll build

**Expected Behavior**:
- [ ] Jekyll build fails with clear YAML error
- [ ] Error message indicates file and line number
- [ ] User can fix and rebuild

### Error State 6: Missing Data File

**Simulation**:
1. Temporarily move `_data/profile.yml`
2. Build site locally

**Expected Behavior**:
- [ ] CV page shows placeholder message
- [ ] No Jekyll build errors
- [ ] Page structure remains intact

---

## T077: Final Local Preview

**Test Steps**:

```bash
# Ensure both data files are populated
cat _data/projects.yml
cat _data/profile.yml

# Start Jekyll server
bundle exec jekyll serve

# Visit http://localhost:4000
```

**Validation Checklist**:

### Homepage (http://localhost:4000/)
- [ ] Page title loads correctly
- [ ] Featured Projects section is visible
- [ ] Projects display with all metadata (name, description, language, stars, forks)
- [ ] Project cards are well-formatted
- [ ] Links are clickable
- [ ] Topics/tags display (if present)
- [ ] "Last updated" timestamp shows
- [ ] Page is responsive (test mobile view)

### CV Page (http://localhost:4000/cv/)
- [ ] Page title loads correctly
- [ ] Name and headline display prominently
- [ ] Professional summary renders correctly
- [ ] Experience section shows all jobs
- [ ] Each job shows: title, company, location, period, description
- [ ] Highlights display as bullet lists
- [ ] Skills section shows all categories and items
- [ ] Certifications section displays
- [ ] Education section displays
- [ ] Contact information and links work
- [ ] Page is responsive (test mobile view)

### Navigation
- [ ] Can navigate between homepage and CV page
- [ ] All internal links work
- [ ] All external links work and open in new tabs

### Console & Network
- [ ] No JavaScript errors in browser console
- [ ] No 404 errors in network tab
- [ ] No broken images or assets

---

## T078: Final Live Site Verification

**Prerequisites**:
- All changes committed and pushed to `master` branch
- Waited 2-3 minutes for GitHub Pages to rebuild

**Test Steps**:

### 1. Visit Live Homepage

```
https://dataneuron.github.io/
```

**Checklist**:
- [ ] Page loads without errors
- [ ] Featured Projects section is visible
- [ ] Projects data is current (matches GitHub pinned repos)
- [ ] All links work correctly
- [ ] Page renders correctly on desktop
- [ ] Page renders correctly on mobile (use device or DevTools)

### 2. Visit Live CV Page

```
https://dataneuron.github.io/cv/
```

**Checklist**:
- [ ] Page loads without errors
- [ ] Professional profile displays completely
- [ ] All sections render correctly
- [ ] Content matches `_data/profile.yml`
- [ ] Links to LinkedIn and GitHub work
- [ ] Page renders correctly on desktop
- [ ] Page renders correctly on mobile

### 3. Test Workflow Integration

1. Pin a different repository on GitHub (or swap pin order)
2. Go to repository Actions tab
3. Run "Update Bio Content" workflow
4. Wait for completion
5. Refresh homepage after 2-3 minutes

**Checklist**:
- [ ] Workflow completes successfully
- [ ] Changes appear on live site
- [ ] Project list updated to reflect pinned repos

### 4. Test Manual Data Update

1. Edit `_data/profile.yml` (add a test highlight)
2. Commit and push
3. Wait 2-3 minutes
4. Visit CV page

**Checklist**:
- [ ] Changes appear on live CV page
- [ ] No rendering issues
- [ ] All sections still display correctly

### 5. Performance Check

**Checklist**:
- [ ] Homepage loads in < 3 seconds
- [ ] CV page loads in < 3 seconds
- [ ] No render-blocking resources
- [ ] Images load properly

### 6. Cross-Browser Testing

Test on at least 2 browsers:

**Chrome/Edge**:
- [ ] Homepage renders correctly
- [ ] CV page renders correctly
- [ ] All links work

**Firefox**:
- [ ] Homepage renders correctly
- [ ] CV page renders correctly
- [ ] All links work

**Safari/Mobile** (if available):
- [ ] Homepage renders correctly
- [ ] CV page renders correctly
- [ ] All links work

---

## Summary

Once all checkboxes above are complete, the feature is **fully validated and production-ready**.

### Implementation Status

- **Total Tasks**: 78
- **Completed Implementation**: 66 (T001-T066)
- **Completed Polish**: 6 (T068-T073)
- **Validation Tasks**: 5 (T074-T078)
- **Remaining**: 5 validation tasks (manual user testing)

### Sign-Off

**Implementation Complete**: ✅ 2026-02-08

**Validation Complete**: ⏳ Pending user testing

**Feature Ready for Production**: ⏳ Pending validation sign-off

---

## Next Steps

1. Complete T074-T078 validation tasks above
2. Fix any issues discovered during validation
3. Mark feature as production-ready
4. Set up monthly maintenance reminders (see `.github/MAINTENANCE_SCHEDULE.md`)
5. Share updated portfolio link!

---

**For Support**: See [Quick Start Guide - Troubleshooting](quickstart.md#9-troubleshooting)
