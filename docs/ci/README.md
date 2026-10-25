# Application CI references

These files are snapshots of the workflows in the local application checkouts, captured on 8 November 2026. They document the application's build and test pipelines alongside the infrastructure setup.

| Reference | Active workflow |
| --- | --- |
| [Frontend CI](frontend-ci.yaml) | https://github.com/Hostel-Hive/hostelhive-frontend/blob/develop/.github/workflows/frontend-ci.yml |
| [Backend CI](backend-ci.yaml) | https://github.com/Hostel-Hive/hostelhive-backend/blob/develop/.github/workflows/backend-ci.yml |

GitHub Actions runs workflow files from .github/workflows. These reference copies are stored under docs/ci and therefore remain documentation. The frontend workflow expects the web directory and Node configuration in its repository. The backend workflow expects Go source, migrations and Firebase rules in its repository.

Edit and test application workflows in their owning repositories, then refresh these snapshots. Compare with the linked source before relying on a copy because local checkouts can differ from develop.

The infrastructure repository runs its own .github/workflows/infra-ci.yml to validate infrastructure configuration and scripts.