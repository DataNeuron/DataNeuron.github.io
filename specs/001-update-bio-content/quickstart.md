# Quick Start Guide: Portfolio Content Sync

**Feature**: 001-update-bio-content
**Date**: 2026-02-08
**For**: Setting up and using the bio page content sync system

## Overview

This guide covers:
1. Initial setup (one-time)
2. Creating LinkedIn profile data manually
3. Running manual updates
4. Integrating data into pages
5. Troubleshooting

**Time to Complete**: ~30 minutes for initial setup

## Prerequisites

- GitHub Personal Access Token (PAT) with `public_repo` scope
- Access to DataNeuron.github.io repository
- Ruby 2.7+ installed (for local testing)
- Basic familiarity with YAML and Liquid templates

## 1. Initial Setup (One-Time)

### 1.1 Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set name: "DataNeuron Portfolio Sync"
4. Select scope: `public_repo` (read-only access to public repositories)
5. Set expiration: 90 days (recommended for security)
6. Click "Generate token"
7. **Copy the token immediately** (you won't see it again)

### 1.2 Configure GitHub Actions Secret

1. Go to repository: `https://github.com/DataNeuron/DataNeuron.github.io`
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `PORTFOLIO_SYNC_TOKEN`
5. Value: Paste your Personal Access Token
6. Click "Add secret"

**Note**: The default `GITHUB_TOKEN` works too, but a dedicated token is clearer.

### 1.3 Create Data Directory

```bash
# If _data/ directory doesn't exist
mkdir -p _data
```

### 1.4 Create Scripts Directory

```bash
mkdir -p scripts
```

## 2. Create LinkedIn Profile Data (Manual Entry)

### 2.1 Create Profile YAML File

Create `_data/profile.yml`:

```yaml
name: "Your Full Name"
headline: "Your Professional Title"
summary: |
  Write your professional summary here.
  This comes from your LinkedIn "About" section.
  Can be multiple paragraphs.

experience:
  - title: "Current Job Title"
    company: "Company Name"
    company_url: "https://company.com"
    location: "City, State"
    period: "Month YYYY - Present"
    description: |
      What you do in this role.
    highlights:
      - "Key achievement 1"
      - "Key achievement 2"

skills:
  - category: "Technical Skills"
    items:
      - "Skill 1"
      - "Skill 2"

certifications:
  - name: "Certification Name"
    issuer: "Issuing Organization"
    issued_date: "Month YYYY"

education:
  - degree: "Your Degree"
    institution: "University Name"
    graduation_year: "YYYY"

contact:
  linkedin_url: "https://linkedin.com/in/your-profile"
  github_url: "https://github.com/DataNeuron"
  location: "Your Location"

metadata:
  last_updated: "2026-02-08"
  data_source: "manual_entry"
```

### 2.2 Copy from LinkedIn

1. Open your LinkedIn profile
2. Copy each section to corresponding YAML fields:
   - **Name & headline**: Top of profile
   - **Summary**: "About" section
   - **Experience**: Each job in "Experience" section
   - **Skills**: "Skills" section (group by category)
   - **Certifications**: "Licenses & certifications"
   - **Education**: "Education" section

**Tip**: Keep it concise. You don't need to copy everything—highlight what's most relevant.

### 2.3 Validate YAML Syntax

```bash
# Test YAML syntax
ruby -e "require 'yaml'; YAML.load_file('_data/profile.yml')"

# Should print the data structure if valid
# Error if syntax is wrong
```

### 2.4 Commit Profile Data

```bash
git add _data/profile.yml
git commit -m "Add LinkedIn profile data"
git push
```

## 3. Set Up GitHub Projects Fetch Script

### 3.1 Create Fetch Script

Create `scripts/fetch-github-projects.rb`:

```ruby
#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'yaml'

# Configuration
GITHUB_USERNAME = 'DataNeuron'
GITHUB_TOKEN = ENV['GITHUB_TOKEN'] || ENV['PORTFOLIO_SYNC_TOKEN']
OUTPUT_FILE = File.join(__dir__, '..', '_data', 'projects.yml')

# GitHub GraphQL query
QUERY = <<~GRAPHQL
  query GetPinnedRepositories($username: String!) {
    user(login: $username) {
      pinnedItems(first: 6, types: REPOSITORY) {
        totalCount
        edges {
          node {
            ... on Repository {
              id
              name
              description
              url
              homepageUrl
              stargazerCount
              forkCount
              primaryLanguage {
                name
                color
              }
              createdAt
              updatedAt
              repositoryTopics(first: 10) {
                nodes {
                  topic {
                    name
                  }
                }
              }
              isArchived
              isFork
            }
          }
        }
      }
    }
  }
GRAPHQL

def fetch_pinned_repos
  uri = URI('https://api.github.com/graphql')

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.path, {
    'Authorization' => "bearer #{GITHUB_TOKEN}",
    'Content-Type' => 'application/json'
  })

  request.body = {
    query: QUERY,
    variables: { username: GITHUB_USERNAME }
  }.to_json

  response = http.request(request)
  JSON.parse(response.body)
rescue => e
  { 'errors' => [{ 'message' => "Network error: #{e.message}" }] }
end

def transform_response(response)
  if response['errors']
    return {
      'fetch_metadata' => {
        'last_updated' => Time.now.utc.iso8601,
        'fetch_status' => 'error',
        'error_message' => response['errors'].first['message'],
        'source' => 'github',
        'github_username' => GITHUB_USERNAME
      },
      'projects' => []
    }
  end

  pinned_items = response.dig('data', 'user', 'pinnedItems', 'edges') || []

  projects = pinned_items.map do |edge|
    node = edge['node']
    {
      'id' => node['id'],
      'name' => node['name'],
      'full_name' => "#{GITHUB_USERNAME}/#{node['name']}",
      'description' => node['description'],
      'url' => node['url'],
      'homepage_url' => node['homepageUrl'],
      'language' => node['primaryLanguage'] ? {
        'name' => node['primaryLanguage']['name'],
        'color' => node['primaryLanguage']['color']
      } : nil,
      'stars' => node['stargazerCount'],
      'forks' => node['forkCount'],
      'created_at' => node['createdAt'],
      'updated_at' => node['updatedAt'],
      'topics' => node.dig('repositoryTopics', 'nodes')&.map { |t| t.dig('topic', 'name') } || [],
      'is_archived' => node['isArchived'],
      'is_fork' => node['isFork']
    }
  end

  {
    'fetch_metadata' => {
      'last_updated' => Time.now.utc.iso8601,
      'fetch_status' => 'success',
      'error_message' => nil,
      'source' => 'github',
      'github_username' => GITHUB_USERNAME
    },
    'projects' => projects
  }
end

# Main execution
puts "Fetching pinned repositories for #{GITHUB_USERNAME}..."

if GITHUB_TOKEN.nil? || GITHUB_TOKEN.empty?
  puts "ERROR: GITHUB_TOKEN not found in environment"
  exit 1
end

response = fetch_pinned_repos
data = transform_response(response)

# Write to file
File.write(OUTPUT_FILE, YAML.dump(data))

if data['fetch_metadata']['fetch_status'] == 'success'
  puts "✅ Successfully fetched #{data['projects'].length} pinned repositories"
  puts "📝 Written to #{OUTPUT_FILE}"
else
  puts "❌ Error: #{data['fetch_metadata']['error_message']}"
  exit 1
end
```

### 3.2 Make Script Executable

```bash
chmod +x scripts/fetch-github-projects.rb
```

### 3.3 Test Script Locally

```bash
# Set environment variable
export GITHUB_TOKEN="your_token_here"

# Run script
ruby scripts/fetch-github-projects.rb

# Check output
cat _data/projects.yml
```

You should see your pinned repositories in YAML format.

## 4. Set Up GitHub Actions Workflow

### 4.1 Create Workflow File

Create `.github/workflows/update-bio.yml`:

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
          - both
        default: 'projects'

permissions:
  contents: write

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
          GITHUB_TOKEN: ${{ secrets.PORTFOLIO_SYNC_TOKEN }}
        run: |
          ruby scripts/fetch-github-projects.rb

      - name: Commit updated data
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add _data/
          git diff --quiet && git diff --staged --quiet || (
            git commit -m "Update bio content via workflow [skip ci]" &&
            git push
          )

      - name: Summary
        run: |
          echo "### Update Complete ✅" >> $GITHUB_STEP_SUMMARY
          echo "Updated section: ${{ inputs.update_section }}" >> $GITHUB_STEP_SUMMARY
          echo "Timestamp: $(date -u)" >> $GITHUB_STEP_SUMMARY
```

### 4.2 Commit Workflow

```bash
git add .github/workflows/update-bio.yml scripts/fetch-github-projects.rb
git commit -m "Add bio content update workflow"
git push
```

## 5. Integrate Data into Pages

### 5.1 Update Homepage (index.md)

Add projects section:

```liquid
---
layout: home
title: "Welcome"
---

## Featured Projects

{% if site.data.projects and site.data.projects.projects.size > 0 %}
  <div class="projects-grid">
    {% for project in site.data.projects.projects limit:6 %}
      <div class="project-card">
        <h3><a href="{{ project.url }}">{{ project.name }}</a></h3>

        {% if project.description %}
          <p>{{ project.description }}</p>
        {% else %}
          <p class="no-description">No description available</p>
        {% endif %}

        <div class="project-meta">
          {% if project.language %}
            <span class="language" style="color: {{ project.language.color }}">
              ● {{ project.language.name }}
            </span>
          {% endif %}

          <span class="stars">⭐ {{ project.stars }}</span>
          <span class="forks">🍴 {{ project.forks }}</span>
        </div>

        {% if project.topics.size > 0 %}
          <div class="topics">
            {% for topic in project.topics limit:3 %}
              <span class="topic-tag">{{ topic }}</span>
            {% endfor %}
          </div>
        {% endif %}
      </div>
    {% endfor %}
  </div>

  <p class="metadata">
    Last updated: {{ site.data.projects.fetch_metadata.last_updated | date: "%B %d, %Y" }}
  </p>
{% else %}
  <div class="placeholder">
    <p>Project information is temporarily unavailable. Please check back later.</p>
  </div>
{% endif %}
```

### 5.2 Update CV Page (cv.md)

Add professional profile:

```liquid
---
layout: page
title: "Curriculum Vitae"
---

{% if site.data.profile %}

# {{ site.data.profile.name }}

## {{ site.data.profile.headline }}

{{ site.data.profile.summary }}

---

## Experience

{% for job in site.data.profile.experience %}
### {{ job.title }}
**{{ job.company }}** | {{ job.location }} | {{ job.period }}

{{ job.description }}

{% if job.highlights %}
**Key Achievements:**
{% for highlight in job.highlights %}
- {{ highlight }}
{% endfor %}
{% endif %}

---
{% endfor %}

## Skills

{% for skill_group in site.data.profile.skills %}
**{{ skill_group.category }}:**
{{ skill_group.items | join: ', ' }}

{% endfor %}

## Certifications

{% for cert in site.data.profile.certifications %}
- **{{ cert.name }}** — {{ cert.issuer }}, {{ cert.issued_date }}
{% endfor %}

## Education

{% for edu in site.data.profile.education %}
**{{ edu.degree }}**{% if edu.field_of_study %} in {{ edu.field_of_study }}{% endif %}
{{ edu.institution }} | {{ edu.graduation_year }}
{% if edu.honors %}*{{ edu.honors }}*{% endif %}

{% endfor %}

{% endif %}
```

## 6. Running Manual Updates

### 6.1 Via GitHub Actions (Recommended)

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Select "Update Bio Content" from the left sidebar
4. Click **"Run workflow"** button (right side)
5. Choose branch: `master`
6. Select update section: `projects` or `both`
7. Click green **"Run workflow"**
8. Wait ~30 seconds for completion
9. Check the workflow run for success/errors

### 6.2 Via Local Script

```bash
# From repository root
cd DataNeuron.github.io

# Set token
export GITHUB_TOKEN="your_token_here"

# Fetch projects
ruby scripts/fetch-github-projects.rb

# Preview changes
bundle exec jekyll serve

# Visit http://localhost:4000

# Commit if satisfied
git add _data/projects.yml
git commit -m "Update GitHub projects data"
git push
```

### 6.3 Updating LinkedIn Profile Data

LinkedIn data is **manual only**:

```bash
# 1. Edit the file
vim _data/profile.yml
# or use your favorite editor

# 2. Update sections that changed on LinkedIn

# 3. Update the metadata date
metadata:
  last_updated: "2026-02-09"  # today's date

# 4. Validate YAML
ruby -e "require 'yaml'; YAML.load_file('_data/profile.yml')"

# 5. Preview locally
bundle exec jekyll serve

# 6. Commit and push
git add _data/profile.yml
git commit -m "Update LinkedIn profile data"
git push
```

## 7. Verification & Testing

### 7.1 Check Data Files

```bash
# Verify projects data exists and is valid
cat _data/projects.yml | head -20

# Verify profile data exists and is valid
cat _data/profile.yml | head -20

# Validate YAML syntax
ruby -e "require 'yaml'; puts YAML.load_file('_data/projects.yml').inspect"
ruby -e "require 'yaml'; puts YAML.load_file('_data/profile.yml').inspect"
```

### 7.2 Preview Site Locally

```bash
# Install dependencies (first time only)
bundle install

# Start Jekyll server
bundle exec jekyll serve

# Open browser to http://localhost:4000
# Check that projects and profile sections display correctly
```

### 7.3 Check Live Site

After pushing changes:

```bash
# Wait 1-2 minutes for GitHub Pages to rebuild

# Visit your site
open https://dataneuron.github.io/

# Verify:
# - Projects section shows pinned repos
# - CV page shows LinkedIn profile data
# - No placeholder messages (unless data fetch failed)
# - "Last updated" timestamp is recent
```

## 8. Maintenance Schedule

**Recommended update frequency:**

| Content | Frequency | Trigger | Method |
|---------|-----------|---------|--------|
| GitHub Projects | Weekly or when pinning new repos | Pin/unpin a repo | GitHub Actions workflow |
| LinkedIn Profile | Monthly or when profile changes | Update LinkedIn | Manual edit of `profile.yml` |

**Setting reminders:**

- Set calendar reminder for monthly LinkedIn sync
- Update projects immediately after pinning new repo
- Check data freshness if site looks stale (timestamp > 1 month old)

## 9. Troubleshooting

### Issue: "GITHUB_TOKEN not found"

**Solution**:
```bash
# Check if secret is set (GitHub Actions)
# Go to Settings → Secrets → Check PORTFOLIO_SYNC_TOKEN exists

# For local testing
echo $GITHUB_TOKEN
# If empty, export it:
export GITHUB_TOKEN="ghp_your_token_here"
```

### Issue: Workflow fails with "Bad credentials"

**Solution**:
- Token may have expired (check expiration date)
- Generate new token with `public_repo` scope
- Update `PORTFOLIO_SYNC_TOKEN` secret in repository settings

### Issue: "User not found" error

**Solution**:
- Verify GITHUB_USERNAME in script matches your account: `DataNeuron`
- GitHub username is case-sensitive

### Issue: Projects don't appear on site

**Checklist**:
1. Verify `_data/projects.yml` exists and has content
2. Check `fetch_status: "success"` in metadata
3. Verify Liquid template includes `{% if site.data.projects %}`
4. Rebuild site: `bundle exec jekyll serve`
5. Check browser console for errors

### Issue: Placeholder message shows despite data existing

**Solution**:
```liquid
# Check template logic
{% if site.data.projects %}  # Correct
{% if site.data.projects.projects %}  # Also correct
{% if site.data.projects.size > 0 %}  # WRONG - checks metadata, not projects array

# Fix: Use correct conditional
{% if site.data.projects and site.data.projects.projects.size > 0 %}
```

### Issue: YAML syntax error

**Symptoms**: `Psych::SyntaxError` when running Jekyll

**Solution**:
```bash
# Find the error line
ruby -e "require 'yaml'; YAML.load_file('_data/profile.yml')"

# Common issues:
# - Unquoted colons in strings: description: "Role: Developer"  # Fix: Use quotes
# - Inconsistent indentation: Use 2 spaces, not tabs
# - Missing quotes around URLs with special chars
# - Incorrect multiline syntax: Use |  or >
```

### Issue: Rate limit exceeded

**Symptoms**: Error message "API rate limit exceeded"

**Solution**:
- Wait until rate limit resets (shown in error message)
- For authenticated requests: 5,000 points/hour
- Manual updates use ~1 point, so shouldn't hit limit
- If hit repeatedly: check for runaway script or cron job

## 10. Next Steps

After setup is complete:

- [ ] Pin your best 6 repositories on GitHub
- [ ] Run first manual update via GitHub Actions
- [ ] Verify projects appear on homepage
- [ ] Update `_data/profile.yml` with current LinkedIn info
- [ ] Verify CV page displays correctly
- [ ] Set monthly calendar reminder for LinkedIn sync
- [ ] Bookmark GitHub Actions page for quick access to manual trigger

## Support & Documentation

- **Feature Spec**: See `specs/001-update-bio-content/spec.md`
- **Implementation Plan**: See `specs/001-update-bio-content/plan.md`
- **Data Model**: See `specs/001-update-bio-content/data-model.md`
- **API Contract**: See `specs/001-update-bio-content/contracts/github-api.yml`
- **GitHub GraphQL Docs**: https://docs.github.com/en/graphql
- **Jekyll Data Files**: https://jekyllrb.com/docs/datafiles/

---

**Setup Complete!** You can now manually update your bio page content from GitHub and LinkedIn.
