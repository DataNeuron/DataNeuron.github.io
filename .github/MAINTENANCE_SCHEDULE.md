# Portfolio Content Maintenance Schedule

This document provides a recommended schedule for keeping your portfolio content up-to-date.

## Content Update Frequency

| Content Type | Recommended Frequency | Update Method | Estimated Time |
|--------------|----------------------|---------------|----------------|
| **GitHub Pinned Projects** | Weekly or when pinning new repos | GitHub Actions workflow | 2 minutes |
| **LinkedIn Profile Data** | Monthly or when profile changes | Manual edit of `_data/profile.yml` | 15-30 minutes |

## Monthly Checklist

### First Monday of Each Month

- [ ] Review LinkedIn profile for any changes
  - New job position or responsibilities
  - New skills or certifications
  - Updated professional summary
  - New achievements or highlights

- [ ] Update `_data/profile.yml` if needed
  - Edit the file with new information
  - Update `metadata.last_updated` to current date
  - Validate YAML syntax: `ruby -e "require 'yaml'; YAML.load_file('_data/profile.yml')"`
  - Preview locally: `bundle exec jekyll serve`
  - Commit and push changes

- [ ] Verify GitHub pinned repositories are current
  - Go to your GitHub profile
  - Ensure your 6 best/most recent projects are pinned
  - Unpin outdated projects if needed

- [ ] Run bio content update workflow
  - Go to repository Actions tab
  - Select "Update Bio Content"
  - Click "Run workflow" → `projects` → Run
  - Verify workflow completes successfully

- [ ] Verify live site display
  - Visit [https://dataneuron.github.io/](https://dataneuron.github.io/)
  - Check projects section shows current pinned repos
  - Visit [https://dataneuron.github.io/cv/](https://dataneuron.github.io/cv/)
  - Verify CV page shows updated profile information
  - Check "Last updated" timestamps are recent

## Ad-Hoc Updates

### When You Pin a New Repository

1. Immediately run the "Update Bio Content" workflow
2. Verify the new repo appears on your homepage within 2-3 minutes
3. Share the updated portfolio link

### When You Update LinkedIn

1. Copy changes to `_data/profile.yml` within 48 hours
2. Test locally before committing
3. Deploy and verify

### When Token Expires (Every 90 Days)

GitHub Personal Access Tokens expire based on the expiration you set during creation.

**Recommended**: Set a calendar reminder for 7 days before expiration

Steps to renew:
1. Generate new token at [GitHub Settings → Tokens](https://github.com/settings/tokens)
2. Scope: `public_repo` (same as before)
3. Update repository secret `PORTFOLIO_SYNC_TOKEN`
4. Test workflow to confirm it works

## Calendar Reminders

Set these recurring reminders:

1. **Monthly LinkedIn Sync** (First Monday of month, 9:00 AM)
   - "Review and update portfolio LinkedIn data"
   - Link: https://github.com/DataNeuron/DataNeuron.github.io/blob/master/_data/profile.yml

2. **Token Expiration** (Based on your token creation date)
   - "Renew GitHub Personal Access Token for portfolio sync"
   - Link: https://github.com/settings/tokens

3. **Quarterly Portfolio Review** (Every 3 months)
   - "Review overall portfolio presentation and update projects"
   - Consider unpinning old projects and highlighting new work

## Quick Links

- **Run Workflow**: [GitHub Actions - Update Bio Content](https://github.com/DataNeuron/DataNeuron.github.io/actions/workflows/update-bio.yml)
- **Edit Profile**: [_data/profile.yml](https://github.com/DataNeuron/DataNeuron.github.io/blob/master/_data/profile.yml)
- **Edit Projects**: Pin/unpin on [GitHub Profile](https://github.com/DataNeuron)
- **Live Site**: [https://dataneuron.github.io/](https://dataneuron.github.io/)
- **Documentation**: [Quick Start Guide](../specs/001-update-bio-content/quickstart.md)

## Troubleshooting

If updates aren't appearing:

1. Check workflow run status in Actions tab
2. Review error messages if workflow failed
3. Verify YAML syntax if editing manually
4. Clear browser cache and hard refresh (Ctrl+Shift+R)
5. Wait 2-3 minutes for GitHub Pages to rebuild

For detailed troubleshooting, see [Quick Start Guide - Section 9](../specs/001-update-bio-content/quickstart.md#9-troubleshooting).

---

**Last Updated**: 2026-02-08
**Next Review**: First Monday of March 2026
