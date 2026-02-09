# DataNeuron Portfolio Site

Personal portfolio and blog powered by Jekyll and the Minimal Mistakes theme.

**Live site**: [https://dataneuron.github.io/](https://dataneuron.github.io/)

## Features

### Portfolio Content Sync

Automatically sync your bio page with current projects from GitHub and professional information from LinkedIn:

- **GitHub Projects**: Display pinned repositories on homepage with clickable links
- **LinkedIn Profile**: Show complete professional profile on CV page
- **Manual Updates**: Trigger updates on-demand via GitHub Actions workflow

**Quick Start**: See [Portfolio Content Sync Quick Start Guide](specs/001-update-bio-content/quickstart.md)

**Documentation**:
- [Feature Specification](specs/001-update-bio-content/spec.md)
- [Implementation Plan](specs/001-update-bio-content/plan.md)
- [Data Model](specs/001-update-bio-content/data-model.md)

### Running Manual Updates

1. Go to repository **Actions** tab
2. Select "Update Bio Content" workflow
3. Click **"Run workflow"**
4. Choose update section: `projects` or `both`
5. Wait ~30 seconds for completion

For detailed setup and troubleshooting, see the [Quick Start Guide](specs/001-update-bio-content/quickstart.md).

## Theme

**[Minimal Mistakes](http://mmistakes.github.io/minimal-mistakes)** is a two column responsive Jekyll theme perfect for powering your GitHub hosted blog.

### Minimal Mistakes is all about:

* Responsive templates. Looking good on mobile, tablet, and desktop.
* Gracefully degrading in older browsers. Compatible with Internet Explorer 8+ and all modern browsers.
* Minimal embellishments -- content first.
* Optional large feature images for posts and pages.
* Simple and clear permalink structure.
* [Custom 404 page](http://mmistakes.github.io/minimal-mistakes/404.html) to get you started.
* Support for Disqus Comments

![screenshot of Minimal Mistakes theme](http://mmistakes.github.io/minimal-mistakes/images/mm-theme-post-600.jpg)

See a [live version of Minimal Mistakes](http://mmistakes.github.io/minimal-mistakes/) hosted on GitHub.

## Getting Started

Minimal Mistakes takes advantage of Sass and data files to make customizing easier. These features require Jekyll 2.x and will not work with older versions of Jekyll.

To learn how to install and use this theme check out the [Setup Guide](http://mmistakes.github.io/minimal-mistakes/theme-setup/) for more information.