---
layout: home
excerpt: "Random ramblings from a economist"
---

## Featured Projects

{% if site.data.projects and site.data.projects.projects.size > 0 %}
  {% if site.data.projects.fetch_metadata.fetch_status == "success" %}
    <div class="projects-section">
      {% for project in site.data.projects.projects %}
      <div class="project-card" style="margin-bottom: 2em; padding: 1em; border-left: 3px solid #0366d6;">
        <h3 style="margin-top: 0;">
          <a href="{{ project.url }}" target="_blank" rel="noopener noreferrer" style="text-decoration: none; color: #0366d6;">
            {{ project.name }}
          </a>
        </h3>

        {% if project.description %}
          <p>{{ project.description }}</p>
        {% else %}
          <p style="color: #6a737d; font-style: italic;">No description provided</p>
        {% endif %}

        <div class="project-meta" style="margin-top: 1em; color: #586069; font-size: 0.9em;">
          {% if project.language %}
            <span class="language" style="color: {{ project.language.color }}; font-weight: bold;">
              ● {{ project.language.name }}
            </span>
          {% endif %}

          {% if project.stars %}
            <span class="stars" style="margin-left: 1em;">
              ⭐ {{ project.stars }}
            </span>
          {% endif %}

          {% if project.forks %}
            <span class="forks" style="margin-left: 1em;">
              🍴 {{ project.forks }}
            </span>
          {% endif %}
        </div>

        {% if project.topics and project.topics.size > 0 %}
          <div class="topics" style="margin-top: 0.5em;">
            {% for topic in project.topics limit:5 %}
              <span style="display: inline-block; background-color: #f1f8ff; color: #0366d6; padding: 0.2em 0.6em; margin-right: 0.5em; border-radius: 3px; font-size: 0.85em;">
                {{ topic }}
              </span>
            {% endfor %}
          </div>
        {% endif %}
      </div>
      {% endfor %}

      <p style="color: #586069; font-size: 0.85em; margin-top: 2em;">
        <em>Last updated: {{ site.data.projects.fetch_metadata.last_updated | date: "%B %d, %Y at %I:%M %p UTC" }}</em>
      </p>
    </div>
  {% else %}
    <div class="placeholder" style="padding: 2em; background-color: #f6f8fa; border-radius: 6px; text-align: center;">
      <p style="color: #586069;">{{ site.data.projects.fetch_metadata.error_message | default: "Content temporarily unavailable, please check back later." }}</p>
    </div>
  {% endif %}
{% else %}
  <div class="placeholder" style="padding: 2em; background-color: #f6f8fa; border-radius: 6px; text-align: center;">
    <p style="color: #586069;">Content temporarily unavailable, please check back later.</p>
  </div>
{% endif %}