# Iván Szkiba's website and resume

Source of [ivan.szkiba.hu](https://ivan.szkiba.hu).

Everything is generated from [`resume.yaml`](resume.yaml), written in the [JSON Resume](https://jsonresume.org/schema) format:

- **Website**: built with [Astro](https://astro.build) from `src/`
- **PDF**: typeset with [Typst](https://typst.app) from [`cv/resume.typ`](cv/resume.typ)

## Development

Requirements: Node.js 22.12+ and the [Typst CLI](https://github.com/typst/typst#installation).

```sh
npm install
npm run dev        # site at http://localhost:4321
npm run pdf:watch  # rebuild public/resume.pdf on changes
npm run build      # PDF + site into dist/
```

## Deployment

Every push to `master` is built and deployed to GitHub Pages by [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).
Pull requests are built but not deployed.

The repository's **Settings → Pages → Source** must be set to **GitHub Actions**.
