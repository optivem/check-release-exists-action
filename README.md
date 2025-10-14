# Check Release Exists Action

A GitHub Action that checks if a specific version release exists in a repository. This action is useful for validating releases in CI/CD workflows, ensuring proper version management, and preventing duplicate releases.

## Features

- ✅ Validates if a release tag exists in the repository
- 🔍 Uses GitHub CLI for reliable release checking
- 📤 Provides outputs for conditional workflow logic
- 🛡️ Proper error handling and informative logging
- 🌐 Cross-platform compatible (Windows, Linux, macOS)

## Usage

### Basic Example

```yaml
name: Check Release
on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to check'
        required: true
        type: string

jobs:
  check-release:
    runs-on: ubuntu-latest
    steps:
      - name: Check if release exists
        id: check-release
        uses: optivem/check-release-exists-action@v1
        with:
          version: ${{ inputs.version }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Handle release exists
        if: steps.check-release.outputs.exists == 'true'
        run: echo "Release ${{ steps.check-release.outputs.tag }} exists!"
      
      - name: Handle release doesn't exist
        if: steps.check-release.outputs.exists == 'false'
        run: echo "Release ${{ inputs.version }} does not exist"
```

### Advanced Example with Conditional Logic

```yaml
name: Deploy if Release Exists
on:
  push:
    branches: [main]

jobs:
  check-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Get version from package.json
        id: version
        run: echo "version=v$(jq -r '.version' package.json)" >> $GITHUB_OUTPUT
      
      - name: Check if release exists
        id: check-release
        uses: optivem/check-release-exists-action@v1
        with:
          version: ${{ steps.version.outputs.version }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Deploy to production
        if: steps.check-release.outputs.exists == 'true'
        run: |
          echo "Deploying release ${{ steps.check-release.outputs.tag }} to production"
          # Your deployment commands here
      
      - name: Skip deployment
        if: steps.check-release.outputs.exists == 'false'
        run: echo "No release found for ${{ steps.version.outputs.version }}, skipping deployment"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | Release version to validate (e.g., `v1.0.4`, `v2.1.0-rc`) | ✅ Yes | - |
| `github-token` | GitHub token for API access | ✅ Yes | `${{ github.token }}` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `exists` | Whether the release exists (`true`/`false`) | `true` |
| `tag` | The validated release tag (only set if exists) | `v1.0.4` |

## Requirements

- The action uses GitHub CLI (`gh`) which is pre-installed on GitHub-hosted runners
- Requires a valid GitHub token with repository read access

## Error Handling

The action will:
- ✅ Exit with code 0 if the release exists
- ❌ Exit with code 1 if the release doesn't exist or if there's an error
- 📝 Provide detailed logging for debugging

## Use Cases

- **Release Validation**: Ensure a release exists before deploying
- **Version Checking**: Validate version tags in CI/CD pipelines
- **Conditional Workflows**: Execute different steps based on release existence
- **Quality Gates**: Prevent actions on non-existent releases

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/optivem/check-release-exists-action/issues).
