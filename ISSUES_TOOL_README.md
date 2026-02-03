# GitHub Issues Listing Tool

A simple Python script to list and filter GitHub issues from any repository.

## Overview

This tool allows you to query GitHub issues with various filtering options directly from the command line, without needing to navigate to the GitHub web interface.

## Requirements

- Python 3.6 or higher
- No external dependencies (uses only Python standard library)
- Optional: GitHub Personal Access Token (for private repositories or higher rate limits)

## Parameters

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `--owner` | Repository owner (username or organization) | `ASE-G1` |
| `--repo` | Repository name | `deployment` |

### Optional Parameters

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `--token` | GitHub personal access token | `None` | `ghp_xxxxxxxxxxxx` |
| `--state` | Filter by state: `open`, `closed`, `all` | `open` | `--state closed` |
| `--labels` | Comma-separated list of labels | `None` | `--labels "bug,urgent"` |
| `--assignee` | Filter by assignee username | `None` | `--assignee john` |
| `--creator` | Filter by issue creator username | `None` | `--creator jane` |
| `--mentioned` | Filter by mentioned username | `None` | `--mentioned alice` |
| `--since` | Filter issues updated after date (ISO 8601) | `None` | `--since 2024-01-01` |
| `--sort` | Sort by: `created`, `updated`, `comments` | `created` | `--sort updated` |
| `--direction` | Sort direction: `asc`, `desc` | `desc` | `--direction asc` |
| `--per-page` | Results per page (max 100) | `30` | `--per-page 50` |
| `--page` | Page number for pagination | `1` | `--page 2` |
| `--json` | Output raw JSON instead of formatted text | `False` | `--json` |

## Usage Examples

### Basic Usage

List all open issues in a repository:
```bash
python list_issues.py --owner ASE-G1 --repo deployment
```

### Filter by State

List all closed issues:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --state closed
```

List both open and closed issues:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --state all
```

### Filter by Labels

List issues with specific labels:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --labels "bug,urgent"
```

### Filter by User

List issues assigned to a specific user:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --assignee username
```

List issues created by a specific user:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --creator username
```

### Filter by Date

List issues updated after a specific date:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --since 2024-01-01
```

### Sorting and Pagination

Sort by most recently updated:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --sort updated
```

Get more results per page:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --per-page 100
```

Navigate to a specific page:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --page 2
```

### Complex Queries

Combine multiple filters:
```bash
python list_issues.py \
  --owner ASE-G1 \
  --repo deployment \
  --state all \
  --labels "bug" \
  --sort updated \
  --direction desc \
  --since 2024-01-01 \
  --per-page 50
```

### JSON Output

Get raw JSON output for programmatic processing:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --json
```

## Authentication

### Using Environment Variable (Recommended)

Set the `GITHUB_TOKEN` environment variable:
```bash
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx
python list_issues.py --owner ASE-G1 --repo deployment
```

### Using Command Line Argument

Pass the token directly:
```bash
python list_issues.py --owner ASE-G1 --repo deployment --token ghp_xxxxxxxxxxxx
```

### When to Use Authentication

- **Public repositories**: Authentication is optional but recommended for higher rate limits (60 requests/hour without auth, 5000 with auth)
- **Private repositories**: Authentication is required

## Creating a GitHub Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Issue Listing Tool")
4. Select scopes:
   - For public repositories: `public_repo`
   - For private repositories: `repo`
5. Click "Generate token" and copy the token immediately

## Output Format

The default output shows:
- Issue number
- State (open/closed)
- Title (truncated to 60 characters)
- Creator username
- Labels
- Creation date

Example output:
```
Found 5 issue(s):

    # State   Title                                                        Creator         Labels                         Created
------------------------------------------------------------------------------------------------------------------------------------------------------
#  123 [open  ] Fix deployment script for production environment            john            [bug, urgent]                  (2024-03-15 14:30)
#  122 [closed] Update documentation for Azure setup                        jane            [documentation]                (2024-03-14 10:15)
#  121 [open  ] Add support for Redis clustering                            alice           [enhancement, redis]           (2024-03-13 09:20)
```

## Troubleshooting

### HTTP 401 - Unauthorized
- You need a GitHub token for this repository
- Check that your token is valid and has the correct permissions

### HTTP 404 - Not Found
- Verify the repository owner and name are correct
- For private repositories, ensure your token has the `repo` scope

### HTTP 403 - Rate Limit Exceeded
- Use authentication to get higher rate limits
- Wait for the rate limit to reset (shown in error message)

## Integration with Other Tools

### Use with jq for JSON processing
```bash
python list_issues.py --owner ASE-G1 --repo deployment --json | jq '.[] | {number, title, state}'
```

### Export to CSV
```bash
python list_issues.py --owner ASE-G1 --repo deployment --json | \
  jq -r '.[] | [.number, .state, .title, .user.login, .created_at] | @csv' > issues.csv
```

### Count issues by state
```bash
python list_issues.py --owner ASE-G1 --repo deployment --state all --json | \
  jq 'group_by(.state) | map({state: .[0].state, count: length})'
```

## License

This tool is provided as-is for convenience. Use freely within your organization.

## Support

For questions or issues with this tool, please contact the infrastructure team or create an issue in the deployment repository.
