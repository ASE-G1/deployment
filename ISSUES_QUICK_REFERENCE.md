# GitHub Issues Tool - Quick Reference

## Basic Commands

```bash
# List all open issues
python list_issues.py --owner ASE-G1 --repo deployment

# List all issues (open and closed)
python list_issues.py --owner ASE-G1 --repo deployment --state all

# List closed issues only
python list_issues.py --owner ASE-G1 --repo deployment --state closed
```

## Filtering

```bash
# Filter by labels
python list_issues.py --owner ASE-G1 --repo deployment --labels "bug,urgent"

# Filter by assignee
python list_issues.py --owner ASE-G1 --repo deployment --assignee username

# Filter by creator
python list_issues.py --owner ASE-G1 --repo deployment --creator username

# Filter by date (issues updated after this date)
python list_issues.py --owner ASE-G1 --repo deployment --since 2024-01-01
```

## Sorting & Pagination

```bash
# Sort by last updated (most recent first)
python list_issues.py --owner ASE-G1 --repo deployment --sort updated

# Sort by number of comments
python list_issues.py --owner ASE-G1 --repo deployment --sort comments

# Change sort direction (ascending)
python list_issues.py --owner ASE-G1 --repo deployment --direction asc

# Get more results per page (max 100)
python list_issues.py --owner ASE-G1 --repo deployment --per-page 100

# Navigate to specific page
python list_issues.py --owner ASE-G1 --repo deployment --page 2
```

## Authentication

```bash
# Use environment variable (recommended)
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx
python list_issues.py --owner ASE-G1 --repo deployment

# Or pass token directly
python list_issues.py --owner ASE-G1 --repo deployment --token ghp_xxxxxxxxxxxx
```

## JSON Output

```bash
# Get raw JSON for programmatic processing
python list_issues.py --owner ASE-G1 --repo deployment --json

# Combine with jq for advanced filtering
python list_issues.py --owner ASE-G1 --repo deployment --json | jq '.[] | {number, title, state}'

# Export to CSV
python list_issues.py --owner ASE-G1 --repo deployment --json | \
  jq -r '.[] | [.number, .state, .title, .user.login, .created_at] | @csv' > issues.csv
```

## Required Parameters

| Parameter | Description |
|-----------|-------------|
| `--owner` | Repository owner (e.g., ASE-G1) |
| `--repo` | Repository name (e.g., deployment) |

## All Available Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `--owner` | string | required | Repository owner |
| `--repo` | string | required | Repository name |
| `--token` | string | None | GitHub personal access token |
| `--state` | open/closed/all | open | Filter by state |
| `--labels` | string | None | Comma-separated labels |
| `--assignee` | string | None | Filter by assignee |
| `--creator` | string | None | Filter by creator |
| `--mentioned` | string | None | Filter by mentioned user |
| `--since` | date | None | ISO 8601 date (YYYY-MM-DD) |
| `--sort` | created/updated/comments | created | Sort field |
| `--direction` | asc/desc | desc | Sort direction |
| `--per-page` | number | 30 | Results per page (max 100) |
| `--page` | number | 1 | Page number |
| `--json` | flag | false | Output raw JSON |

## Common Use Cases

### Find all bug issues
```bash
python list_issues.py --owner ASE-G1 --repo deployment --labels bug
```

### Find recently updated issues
```bash
python list_issues.py --owner ASE-G1 --repo deployment --sort updated --since 2024-01-01
```

### Find unassigned open issues
```bash
python list_issues.py --owner ASE-G1 --repo deployment --assignee none
```

### Complex query
```bash
python list_issues.py \
  --owner ASE-G1 \
  --repo deployment \
  --state all \
  --labels "bug,urgent" \
  --sort updated \
  --direction desc \
  --per-page 50
```

## Getting Help

```bash
# Show all available options
python list_issues.py --help

# Run test suite
python test_list_issues.py
```
