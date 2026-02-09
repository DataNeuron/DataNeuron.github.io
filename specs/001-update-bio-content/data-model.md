# Data Model: Portfolio Content Sync

**Feature**: 001-update-bio-content
**Date**: 2026-02-08
**Purpose**: Define YAML data structures for Jekyll data files

## Overview

This document specifies the exact YAML schema for the two data files that will store fetched content:
- `_data/projects.yml` - GitHub pinned repositories
- `_data/profile.yml` - LinkedIn professional profile

## 1. Projects Data Model

**File**: `_data/projects.yml`

### Schema

```yaml
# Metadata about the data fetch
fetch_metadata:
  last_updated: "2026-02-08T14:30:00Z"        # ISO 8601 timestamp
  fetch_status: "success"                      # success | error
  error_message: null                          # Error description if status=error
  source: "github"                             # Data source identifier
  github_username: "DataNeuron"                # Username fetched from

# Array of pinned projects
projects:
  - id: "MDEwOlJlcG9zaXRvcnk..."              # GitHub repository ID
    name: "project-name"                       # Repository name
    full_name: "DataNeuron/project-name"       # Owner/repo format
    description: "Brief project description"    # Can be null if no description
    url: "https://github.com/DataNeuron/..."   # Repository URL
    homepage_url: "https://example.com"        # Project homepage (can be null)
    language:
      name: "Python"                           # Primary language (can be null)
      color: "#3572A5"                         # GitHub language color hex
    stars: 42                                  # Star count (integer)
    forks: 12                                  # Fork count (integer)
    created_at: "2023-01-15T10:30:00Z"        # ISO 8601 timestamp
    updated_at: "2026-01-20T08:15:00Z"        # ISO 8601 timestamp
    topics:                                    # Repository topics/tags
      - "machine-learning"
      - "python"
    is_archived: false                         # Boolean - archived status
    is_fork: false                             # Boolean - is it a fork
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `fetch_metadata.last_updated` | String (ISO 8601) | Yes | Timestamp of last successful fetch |
| `fetch_metadata.fetch_status` | Enum | Yes | "success" or "error" |
| `fetch_metadata.error_message` | String/Null | No | Error details if fetch failed |
| `fetch_metadata.source` | String | Yes | Always "github" for projects |
| `fetch_metadata.github_username` | String | Yes | GitHub username |
| `projects` | Array | Yes | List of pinned repositories (max 6) |
| `projects[].id` | String | Yes | GitHub internal repository ID |
| `projects[].name` | String | Yes | Repository name |
| `projects[].full_name` | String | Yes | Full name (owner/repo) |
| `projects[].description` | String/Null | No | Repository description |
| `projects[].url` | String (URL) | Yes | GitHub repository URL |
| `projects[].homepage_url` | String (URL)/Null | No | Project homepage |
| `projects[].language.name` | String/Null | No | Primary programming language |
| `projects[].language.color` | String (hex)/Null | No | GitHub language color |
| `projects[].stars` | Integer | Yes | Star count |
| `projects[].forks` | Integer | Yes | Fork count |
| `projects[].created_at` | String (ISO 8601) | Yes | Repository creation date |
| `projects[].updated_at` | String (ISO 8601) | Yes | Last update date |
| `projects[].topics` | Array[String] | No | Repository topics |
| `projects[].is_archived` | Boolean | Yes | Archived status |
| `projects[].is_fork` | Boolean | Yes | Fork status |

### Example Data

```yaml
fetch_metadata:
  last_updated: "2026-02-08T14:30:00Z"
  fetch_status: "success"
  error_message: null
  source: "github"
  github_username: "DataNeuron"

projects:
  - id: "R_kgDOH8qZMA"
    name: "enterprise-workflow-agent"
    full_name: "DataNeuron/enterprise-workflow-agent"
    description: "AI-powered workflow automation platform using LangGraph and AWS Bedrock"
    url: "https://github.com/DataNeuron/enterprise-workflow-agent"
    homepage_url: null
    language:
      name: "Python"
      color: "#3572A5"
    stars: 15
    forks: 3
    created_at: "2024-11-10T08:00:00Z"
    updated_at: "2026-02-07T16:45:00Z"
    topics:
      - "langchain"
      - "aws-bedrock"
      - "workflow-automation"
    is_archived: false
    is_fork: false

  - id: "R_abc123"
    name: "data-analysis-toolkit"
    full_name: "DataNeuron/data-analysis-toolkit"
    description: "Machine learning tools for data analysis"
    url: "https://github.com/DataNeuron/data-analysis-toolkit"
    homepage_url: "https://toolkit.example.com"
    language:
      name: "Jupyter Notebook"
      color: "#DA5B0B"
    stars: 28
    forks: 7
    created_at: "2023-06-20T12:30:00Z"
    updated_at: "2025-12-15T09:20:00Z"
    topics:
      - "data-science"
      - "machine-learning"
    is_archived: false
    is_fork: false
```

### Error State Example

```yaml
fetch_metadata:
  last_updated: "2026-02-08T14:30:00Z"
  fetch_status: "error"
  error_message: "GitHub API rate limit exceeded. Try again in 45 minutes."
  source: "github"
  github_username: "DataNeuron"

projects: []  # Empty when fetch fails
```

### Validation Rules

- **Maximum 6 projects**: GitHub allows max 6 pinned repos
- **Required fields must not be null**: name, url, full_name, id
- **Timestamps must be ISO 8601 format**: YYYY-MM-DDTHH:MM:SSZ
- **URLs must be valid HTTPS**: start with https://
- **Stars/forks must be non-negative integers**: >= 0
- **Booleans must be true/false**: not "yes"/"no" or 1/0

## 2. Profile Data Model

**File**: `_data/profile.yml`

### Schema

```yaml
# Personal Information
name: "Your Full Name"
headline: "Professional Title/Headline"
summary: |
  Multi-line professional summary from LinkedIn.
  Can include multiple paragraphs and details about
  your background, expertise, and career goals.

# Professional Experience
experience:
  - title: "Job Title"
    company: "Company Name"
    company_url: "https://company.com"       # Optional
    location: "City, State/Country"
    period: "Month YYYY - Present"           # e.g., "Jan 2020 - Present"
    duration: "2 years 3 months"             # Optional, calculated
    description: |
      Detailed description of role and responsibilities.
      Can be multi-line.
    highlights:                               # Optional
      - "Achievement 1"
      - "Achievement 2"

# Skills
skills:
  - category: "Programming Languages"
    items:
      - "Python"
      - "JavaScript"
      - "Ruby"

  - category: "Frameworks & Tools"
    items:
      - "React"
      - "Django"
      - "Docker"

# Certifications
certifications:
  - name: "Certification Name"
    issuer: "Issuing Organization"
    issued_date: "Month YYYY"               # e.g., "Jan 2023"
    expiry_date: null                       # or "Month YYYY" if expires
    credential_id: "ABC123"                 # Optional
    credential_url: "https://verify.com"    # Optional

# Education
education:
  - degree: "Degree Name"
    field_of_study: "Field of Study"
    institution: "University/School Name"
    location: "City, Country"
    graduation_year: "YYYY"                 # e.g., "2018"
    gpa: "3.8/4.0"                          # Optional
    honors: "Cum Laude"                     # Optional
    activities: |                           # Optional
      Relevant activities or achievements

# Contact & Links
contact:
  email: "your.email@example.com"           # Optional (might not want public)
  linkedin_url: "https://linkedin.com/in/username"
  github_url: "https://github.com/username"
  twitter_url: "https://twitter.com/username"  # Optional
  website_url: "https://yourwebsite.com"    # Optional
  location: "City, State/Country"

# Metadata
metadata:
  last_updated: "2026-02-08"
  last_manual_sync: "2026-02-08"
  data_source: "manual_entry"
  linkedin_profile_version: "v1"            # Track profile changes
```

### Field Descriptions

| Section | Field | Type | Required | Description |
|---------|-------|------|----------|-------------|
| **Personal** | name | String | Yes | Full name |
| | headline | String | Yes | Professional headline |
| | summary | String (multiline) | Yes | Professional summary |
| **Experience** | title | String | Yes | Job title |
| | company | String | Yes | Company name |
| | company_url | String (URL) | No | Company website |
| | location | String | Yes | Job location |
| | period | String | Yes | Date range (formatted) |
| | duration | String | No | Length of employment |
| | description | String (multiline) | No | Role description |
| | highlights | Array[String] | No | Key achievements |
| **Skills** | category | String | Yes | Skill category |
| | items | Array[String] | Yes | Skills in that category |
| **Certifications** | name | String | Yes | Certification name |
| | issuer | String | Yes | Issuing organization |
| | issued_date | String | Yes | Issue date |
| | expiry_date | String/Null | No | Expiration date |
| | credential_id | String | No | Credential ID |
| | credential_url | String (URL) | No | Verification URL |
| **Education** | degree | String | Yes | Degree type |
| | field_of_study | String | No | Major/field |
| | institution | String | Yes | School name |
| | location | String | No | School location |
| | graduation_year | String | Yes | Graduation year |
| | gpa | String | No | GPA if notable |
| | honors | String | No | Honors/awards |
| | activities | String (multiline) | No | Activities |
| **Contact** | email | String | No | Email address |
| | linkedin_url | String (URL) | Yes | LinkedIn profile |
| | github_url | String (URL) | No | GitHub profile |
| | twitter_url | String (URL) | No | Twitter profile |
| | website_url | String (URL) | No | Personal website |
| | location | String | No | Current location |
| **Metadata** | last_updated | String (date) | Yes | Last update date |
| | data_source | String | Yes | Always "manual_entry" |

### Example Data

```yaml
name: "Jane Doe"
headline: "Senior Machine Learning Engineer | AI & Data Science"
summary: |
  Experienced ML engineer with 8+ years in developing and deploying
  production machine learning systems. Passionate about solving complex
  problems with data-driven solutions.

experience:
  - title: "Senior ML Engineer"
    company: "TechCorp"
    company_url: "https://techcorp.com"
    location: "San Francisco, CA"
    period: "Jan 2020 - Present"
    duration: "6 years 2 months"
    description: |
      Lead ML infrastructure development and model deployment.
    highlights:
      - "Reduced model training time by 60% through optimization"
      - "Deployed 15+ ML models to production serving 1M+ users"

  - title: "ML Engineer"
    company: "DataStartup"
    location: "Austin, TX"
    period: "Jun 2018 - Dec 2019"
    duration: "1 year 7 months"
    description: "Built recommendation systems and data pipelines."

skills:
  - category: "Machine Learning"
    items:
      - "TensorFlow"
      - "PyTorch"
      - "Scikit-learn"

  - category: "Programming"
    items:
      - "Python"
      - "SQL"
      - "Scala"

  - category: "Cloud & DevOps"
    items:
      - "AWS"
      - "Docker"
      - "Kubernetes"

certifications:
  - name: "AWS Certified Machine Learning - Specialty"
    issuer: "Amazon Web Services"
    issued_date: "Mar 2023"
    expiry_date: null
    credential_id: "AWS-ML-12345"
    credential_url: "https://aws.amazon.com/verification/ABC123"

  - name: "TensorFlow Developer Certificate"
    issuer: "Google"
    issued_date: "Aug 2022"
    expiry_date: "Aug 2025"

education:
  - degree: "M.S. Computer Science"
    field_of_study: "Machine Learning"
    institution: "Stanford University"
    location: "Stanford, CA"
    graduation_year: "2018"
    gpa: "3.9/4.0"
    honors: "Distinction in Research"

  - degree: "B.S. Computer Science"
    field_of_study: "Computer Science"
    institution: "UC Berkeley"
    graduation_year: "2016"

contact:
  email: "jane.doe@example.com"
  linkedin_url: "https://linkedin.com/in/janedoe"
  github_url: "https://github.com/janedoe"
  twitter_url: "https://twitter.com/janedoe"
  website_url: "https://janedoe.com"
  location: "San Francisco, CA"

metadata:
  last_updated: "2026-02-08"
  last_manual_sync: "2026-02-08"
  data_source: "manual_entry"
  linkedin_profile_version: "v2"
```

### Validation Rules

- **Name, headline, summary are required**
- **At least one experience entry** should be present
- **Skills must be grouped by category**
- **Dates must be formatted consistently**: "Month YYYY" or "YYYY"
- **URLs must be valid HTTPS**
- **Email must be valid format** (if provided)
- **Metadata.last_updated must be ISO date**: YYYY-MM-DD

## 3. Template Access Patterns

### Accessing Projects Data

```liquid
{# Check if data exists #}
{% if site.data.projects %}

  {# Access metadata #}
  <p>Last updated: {{ site.data.projects.fetch_metadata.last_updated | date: "%B %d, %Y" }}</p>

  {# Check fetch status #}
  {% if site.data.projects.fetch_metadata.fetch_status == "success" %}

    {# Iterate over projects #}
    {% for project in site.data.projects.projects %}
      <h3><a href="{{ project.url }}">{{ project.name }}</a></h3>
      <p>{{ project.description | default: "No description available" }}</p>

      {# Safe language access #}
      {% if project.language %}
        <span style="color: {{ project.language.color }}">{{ project.language.name }}</span>
      {% endif %}

      <p>⭐ {{ project.stars }} | 🍴 {{ project.forks }}</p>
    {% endfor %}

  {% else %}
    {# Error state #}
    <p>{{ site.data.projects.fetch_metadata.error_message }}</p>
  {% endif %}

{% else %}
  <p>Content temporarily unavailable, please check back later.</p>
{% endif %}
```

### Accessing Profile Data

```liquid
{% if site.data.profile %}

  <h1>{{ site.data.profile.name }}</h1>
  <p class="headline">{{ site.data.profile.headline }}</p>
  <div class="summary">{{ site.data.profile.summary }}</div>

  {# Experience #}
  {% if site.data.profile.experience %}
    <h2>Experience</h2>
    {% for job in site.data.profile.experience %}
      <div class="job">
        <h3>{{ job.title }}</h3>
        <p>{{ job.company }} | {{ job.location }} | {{ job.period }}</p>
        {% if job.description %}
          <p>{{ job.description }}</p>
        {% endif %}
        {% if job.highlights %}
          <ul>
            {% for highlight in job.highlights %}
              <li>{{ highlight }}</li>
            {% endfor %}
          </ul>
        {% endif %}
      </div>
    {% endfor %}
  {% endif %}

  {# Skills #}
  {% if site.data.profile.skills %}
    <h2>Skills</h2>
    {% for skill_group in site.data.profile.skills %}
      <div class="skill-category">
        <h4>{{ skill_group.category }}</h4>
        <ul>
          {% for skill in skill_group.items %}
            <li>{{ skill }}</li>
          {% endfor %}
        </ul>
      </div>
    {% endfor %}
  {% endif %}

{% endif %}
```

## 4. Data File Size Constraints

- **projects.yml**: ~2-10 KB (6 projects × ~300-500 bytes each + metadata)
- **profile.yml**: ~5-20 KB (depends on experience detail level)
- **Total**: Well within Jekyll/GitHub Pages limits (<100 KB)

## 5. Update Frequency Expectations

- **projects.yml**: Updated manually when pinned repos change (weekly/monthly)
- **profile.yml**: Updated manually when LinkedIn profile changes (monthly/quarterly)
- **Both**: Low frequency, no performance concerns

## Summary

- **Two YAML files** in `_data/` directory
- **projects.yml**: Fetched from GitHub GraphQL API
- **profile.yml**: Manually maintained
- **Both include metadata** for tracking updates and errors
- **Schema is flexible** but validates required fields
- **Graceful degradation** with null checks in templates

**Next Steps**: Create API contract and quickstart guide.
