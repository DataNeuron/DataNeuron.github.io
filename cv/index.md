---
layout: page
title: Curriculum Vitae
---

{% if site.data.profile %}

# {{ site.data.profile.name }}

## {{ site.data.profile.headline }}

{{ site.data.profile.summary }}

---

## Experience

{% for job in site.data.profile.experience %}
### {{ job.title }}

**{% if job.company_url %}<a href="{{ job.company_url }}" target="_blank">{{ job.company }}</a>{% else %}{{ job.company }}{% endif %}** | {{ job.location }} | {{ job.period }}

{{ job.description }}

{% if job.highlights and job.highlights.size > 0 %}
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

{% if site.data.profile.certifications and site.data.profile.certifications.size > 0 %}
## Certifications

{% for cert in site.data.profile.certifications %}
- **{{ cert.name }}** — {{ cert.issuer }}{% if cert.issued_date %}, {{ cert.issued_date }}{% endif %}{% if cert.expiry_date %} (Expires: {{ cert.expiry_date }}){% endif %}
{% endfor %}
{% endif %}

## Education

{% for edu in site.data.profile.education %}
**{{ edu.degree }}**{% if edu.field_of_study %} in {{ edu.field_of_study }}{% endif %}
{{ edu.institution }}{% if edu.location %}, {{ edu.location }}{% endif %} | {{ edu.graduation_year }}
{% if edu.gpa %}
*GPA: {{ edu.gpa }}*
{% endif %}
{% if edu.honors %}
*{{ edu.honors }}*
{% endif %}

{% endfor %}

{% if site.data.profile.contact %}
## Connect

{% if site.data.profile.contact.linkedin_url %}
- [LinkedIn]({{ site.data.profile.contact.linkedin_url }})
{% endif %}
{% if site.data.profile.contact.github_url %}
- [GitHub]({{ site.data.profile.contact.github_url }})
{% endif %}
{% if site.data.profile.contact.location %}
- **Location:** {{ site.data.profile.contact.location }}
{% endif %}
{% endif %}

---

*Last updated: {{ site.data.profile.metadata.last_updated | date: "%B %d, %Y" }}*

{% else %}
<div class="placeholder" style="padding: 2em; background-color: #f6f8fa; border-radius: 6px; text-align: center;">
  <p style="color: #586069;">Professional profile information is temporarily unavailable. Please check back later.</p>
</div>
{% endif %}
