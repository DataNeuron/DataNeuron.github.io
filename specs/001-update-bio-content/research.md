# Research Findings: Portfolio Content Sync

**Feature**: 001-update-bio-content
**Date**: 2026-02-08
**Purpose**: Resolve technical unknowns before Phase 1 design

## Overview

This document consolidates research findings for implementing portfolio content synchronization from GitHub and LinkedIn to the Jekyll-based bio site.

## 1. GitHub API for Pinned Repositories

### Decision

**Use GitHub GraphQL API** to retrieve pinned repositories.

### Rationale

- GitHub REST API v3 does NOT support pinned repositories
- GraphQL API is the **only official method** via the `pinnedItems` field
- Provides rich metadata in a single query
- Future-proof as GitHub invests heavily in GraphQL
- Complies with GitHub's terms of service (no scraping needed)

### Implementation Details

**Endpoint**: `https://api.github.com/graphql`

**Authentication**:
- Personal Access Token (PAT) required (GraphQL requires auth)
- Include in header: `Authorization: bearer YOUR_TOKEN`
- Basic read permissions sufficient for public repos

**Rate Limits**:
- 5,000 points/hour for authenticated users
- This query costs minimal points (~1-2 points)
- Far below daily limit for manual updates

**GraphQL Query**:
```graphql
query {
  user(login: "DataNeuron") {
    pinnedItems(first: 6, types: REPOSITORY) {
      totalCount
      edges {
        node {
          ... on Repository {
            name
            description
            url
            stargazerCount
            forkCount
            primaryLanguage {
              name
              color
            }
            updatedAt
          }
        }
      }
    }
  }
}
```

**Response Structure**:
```json
{
  "data": {
    "user": {
      "pinnedItems": {
        "edges": [
          {
            "node": {
              "name": "repo-name",
              "description": "Project description",
              "url": "https://github.com/DataNeuron/repo-name",
              "stargazerCount": 42,
              "primaryLanguage": {
                "name": "Python",
                "color": "#3572A5"
              }
            }
          }
        ]
      }
    }
  }
}
```

### Alternatives Considered

- **REST API v3**: No endpoint exists for pinned repos
- **Web scraping**: Fragile, violates ToS, unreliable
- **Third-party wrappers**: Add unnecessary dependencies, just wrap GraphQL anyway

### Ruby Implementation Approach

Use `net/http` or `httparty` gem for GraphQL requests:

```ruby
require 'net/http'
require 'json'

def fetch_pinned_repos(username, token)
  uri = URI('https://api.github.com/graphql')
  query = {
    query: "query { user(login: \"#{username}\") { pinnedItems(first: 6, types: REPOSITORY) { edges { node { ... on Repository { name description url stargazerCount primaryLanguage { name color } } } } } } }"
  }

  request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  request['Authorization'] = "bearer #{token}"
  request.body = query.to_json

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  JSON.parse(response.body)
end
```

## 2. LinkedIn Data Access Strategy

### Decision

**Manual data entry** via YAML configuration file.

### Rationale

- LinkedIn API requires partnership approval (not accessible to individuals)
- Web scraping violates LinkedIn's Terms of Service
- Third-party services are unreliable and costly
- Manual entry gives full control over content
- Aligns with manual update mechanism (user updates when they change LinkedIn profile)
- Low update frequency (professional profiles change infrequently)

### Implementation Details

**Approach**: Create `_data/profile.yml` with LinkedIn information manually entered by the user.

**Data Structure**:
```yaml
name: "Your Name"
headline: "Professional Headline"
summary: |
  Professional summary paragraph from LinkedIn.
  Can span multiple lines.

experience:
  - title: "Senior Developer"
    company: "Company Name"
    location: "City, State"
    period: "Jan 2020 - Present"
    description: "Role description"

  - title: "Developer"
    company: "Previous Company"
    period: "Jan 2018 - Dec 2019"

skills:
  - "Python"
  - "Machine Learning"
  - "System Design"

certifications:
  - name: "AWS Certified Solutions Architect"
    issuer: "Amazon Web Services"
    date: "2023"

education:
  - degree: "B.S. Computer Science"
    institution: "University Name"
    year: "2018"

linkedin_url: "https://linkedin.com/in/username"
```

**Update Process**:
1. User manually updates `_data/profile.yml` when LinkedIn changes
2. Commits to repository
3. Site rebuilds with new profile data

### Alternatives Considered

- **LinkedIn Official API**: Requires partnership approval (not viable)
- **LinkedIn Unofficial API**: Violates ToS, could break anytime
- **Third-party scraping services**: $$/month, unreliable, still violates ToS
- **Phantom Buster/Automation tools**: Against ToS, high risk

### Future Enhancement Option

If LinkedIn profile changes frequently, consider browser automation for personal use (not distributed), but current manual approach is most sustainable.

## 3. Manual Update Trigger Mechanism

### Decision

**GitHub Actions workflow_dispatch** with optional local script fallback.

### Rationale

- Native GitHub integration (no external services)
- Simple UI trigger from GitHub Actions tab
- Can pass parameters (which repos, what sections)
- Logs all executions for auditing
- Can be extended to scheduled triggers later
- Free on GitHub (within Actions minutes quota)

### Implementation Details

**Primary Method**: GitHub Actions with `workflow_dispatch` trigger

**Workflow File** (`.github/workflows/update-bio.yml`):
```yaml
name: Update Bio Content

on:
  workflow_dispatch:
    inputs:
      update_section:
        description: 'Which section to update'
        required: true
        type: choice
        options:
          - projects
          - profile
          - both
        default: 'both'

jobs:
  update-content:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'

      - name: Fetch GitHub projects
        if: ${{ inputs.update_section == 'projects' || inputs.update_section == 'both' }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          ruby scripts/fetch-github-projects.rb

      - name: Commit updated data
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add _data/
          git diff --quiet && git diff --staged --quiet || git commit -m "Update bio content via workflow"
          git push
```

**Triggering**:
1. Navigate to GitHub repository
2. Click "Actions" tab
3. Select "Update Bio Content" workflow
4. Click "Run workflow"
5. Choose which section to update
6. Click green "Run workflow" button

**Local Script Fallback** (`scripts/update-bio-data.sh`):
```bash
#!/bin/bash
# For local development/testing
ruby scripts/fetch-github-projects.rb
bundle exec jekyll serve
```

### Alternatives Considered

- **Scheduled cron trigger**: Wasteful if no changes, user has no control
- **GitHub webhooks**: Complex setup, requires external service
- **Manual local script only**: Works but no audit trail, harder for non-technical users
- **Third-party automation (Zapier)**: Costs money, adds complexity

### Input Parameters

- `update_section`: Choose what to update (projects/profile/both)
- Future: Could add `test_mode` (dry run), `deploy` (auto-deploy after update)

## 4. Jekyll Data File Integration

### Decision

Use Jekyll's native `_data/` directory with YAML files + Liquid templates.

### Rationale

- Built-in Jekyll feature (no plugins needed - complies with Constitution II)
- Clean separation of content and presentation
- Easy to update programmatically
- No theme modification required
- Standard Jekyll pattern

### Implementation Details

**Data Files**:
- `_data/projects.yml` - GitHub pinned repos
- `_data/profile.yml` - LinkedIn professional info

**Template Integration** (in existing pages like `index.md`):
```liquid
## Projects

{% if site.data.projects %}
  {% for project in site.data.projects %}
  <div class="project-card">
    <h3><a href="{{ project.url }}">{{ project.name }}</a></h3>
    {% if project.description %}
      <p>{{ project.description }}</p>
    {% endif %}
    <p class="metadata">
      {% if project.language %}<span class="language">{{ project.language }}</span>{% endif %}
      {% if project.stars %}<span class="stars">⭐ {{ project.stars }}</span>{% endif %}
    </p>
  </div>
  {% endfor %}
{% else %}
  <p>Projects information is currently unavailable. Please check back later.</p>
{% endif %}
```

**Conditional Rendering**:
```liquid
{% if site.data.profile.experience %}
  {% for job in site.data.profile.experience %}
    <div class="experience-item">
      <h4>{{ job.title }} at {{ job.company }}</h4>
      <p class="period">{{ job.period }}</p>
      {% if job.description %}
        <p>{{ job.description }}</p>
      {% endif %}
    </div>
  {% endfor %}
{% endif %}
```

### Best Practices Applied

- **Check existence before iteration**: `{% if site.data.projects %}`
- **Fallback content**: Show placeholder when data unavailable
- **Safe navigation**: Check nested fields (`{% if project.description %}`)
- **Minimal logic**: Keep templates simple, avoid complex conditionals

## 5. Error Handling & Placeholders

### Decision

**Defensive template design** with placeholder messages and graceful degradation.

### Rationale

- Matches spec requirement (FR-014): display placeholder when data unavailable
- Maintains site functionality even when external services fail
- Clear communication to visitors
- Aligns with "Content temporarily unavailable" pattern from spec clarification

### Implementation Details

**Pattern 1: Missing Entire Data File**
```liquid
{% if site.data.projects and site.data.projects.size > 0 %}
  {# Render projects #}
{% else %}
  <div class="placeholder">
    <p>Content temporarily unavailable, please check back later.</p>
  </div>
{% endif %}
```

**Pattern 2: Missing Individual Fields**
```liquid
{% for project in site.data.projects %}
  <h3>{{ project.name | default: "Untitled Project" }}</h3>
  <p>{{ project.description | default: "No description provided" }}</p>
{% endfor %}
```

**Pattern 3: Last Updated Timestamp**
```yaml
# In data file (_data/projects.yml)
last_updated: "2026-02-08T14:30:00Z"
projects:
  - name: "..."
```

```liquid
{% if site.data.projects.last_updated %}
  <p class="metadata">Last updated: {{ site.data.projects.last_updated | date: "%B %d, %Y" }}</p>
{% endif %}
```

**Pattern 4: Error State Indicator**
```yaml
# If fetch fails, script writes:
fetch_status: "error"
error_message: "GitHub API rate limit exceeded"
projects: []
```

```liquid
{% if site.data.projects.fetch_status == "error" %}
  <div class="alert">
    <p>{{ site.data.projects.error_message }}</p>
    <p>Last successful update: {{ site.data.projects.last_successful_update | date: "%B %d, %Y" }}</p>
  </div>
{% endif %}
```

### Edge Cases Covered

- **Empty array**: Check `.size > 0`
- **Missing field**: Use `| default` filter
- **Stale data**: Display `last_updated` timestamp
- **Fetch failure**: Show error message + last good data
- **No pinned repos**: Specific message "No projects pinned"

## Summary

All technical unknowns have been resolved:

1. ✅ **GitHub API**: Use GraphQL with Personal Access Token
2. ✅ **LinkedIn Data**: Manual YAML entry (practical given API restrictions)
3. ✅ **Update Trigger**: GitHub Actions workflow_dispatch
4. ✅ **Data Integration**: Jekyll _data/ directory + Liquid templates
5. ✅ **Error Handling**: Defensive templates with placeholders

**Next Phase**: Proceed to Phase 1 (Design & Contracts) to create:
- `data-model.md` - YAML schemas
- `contracts/github-api.yml` - API contract
- `quickstart.md` - Setup guide

**No Blockers**: All approaches comply with Constitution (no theme changes, no testing framework, clean code patterns).
