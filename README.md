# 🐳 skullsneeze/docker-ci

**Reusable PHP + Node.js CI runner image**
Built for modern PHP projects that also depend on Node-based frontends.

Supports multiple PHP and Node.js versions for maximum compatibility across legacy and modern projects.

---

## Features

- ✅ PHP 8.1 - 8.3 support
- ✅ Node 14 - 20 support
- ✅ Multi-arch builds (`linux/amd64` + `linux/arm64`)
- ✅ Common extensions pre-installed (`gd`, `intl`, `mbstring`, `pdo_*`, `zip`, etc.)
- ✅ Composer 2 with Deployer 7
- ✅ PNPM + Yarn
- ✅ SSH, Git, lftp - ready for CI/CD deployments
- ✅ Built and published automatically via GitHub Actions

---

## Available Images

| PHP | Node | Tag |
|-----|------|--------------|
| 8.3 | 20 | `ghcr.io/skullsneeze/docker-ci:php8.3-node20` |
| 8.3 | 18 | `ghcr.io/skullsneeze/docker-ci:php8.3-node18` |
| 8.3 | 14 | `ghcr.io/skullsneeze/docker-ci:php8.3-node14` |
| 8.2 | 20 | `ghcr.io/skullsneeze/docker-ci:php8.2-node20` |
| 8.2 | 18 | `ghcr.io/skullsneeze/docker-ci:php8.2-node18` |
| 8.2 | 14 | `ghcr.io/skullsneeze/docker-ci:php8.2-node14` |
| 8.1 | 20 | `ghcr.io/skullsneeze/docker-ci:php8.1-node20` |
| 8.1 | 18 | `ghcr.io/skullsneeze/docker-ci:php8.1-node18` |
| 8.1 | 14 | `ghcr.io/skullsneeze/docker-ci:php8.1-node14` |


### Latest build

To track the latest build with the most recent stable versions, use the `latest` tag: ghcr.io/skullsneeze/docker-ci:latest.

Currently this uses PHP 8.3 and Node.js 20.

### Edge builds

Latest development images (built from the `main` branch):

ghcr.io/skullsneeze/docker-ci:php8.3-node20-edge

These include all recent Dockerfile updates before a tagged release and should be used for development purposes only.

---

## 🧾 License

MIT © [Martijn Swinkels](https://github.com/Skullsneeze)
