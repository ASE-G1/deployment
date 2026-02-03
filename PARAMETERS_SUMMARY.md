# Parameters Summary for GitHub Issues Listing Tool

## Required Parameters

These parameters MUST be provided for the script to work:

1. **`--owner`** (string)
   - Repository owner (username or organization name)
   - Example: `ASE-G1`

2. **`--repo`** (string)
   - Repository name
   - Example: `deployment`

## Optional Parameters

These parameters are optional and provide filtering, sorting, and output options:

### Authentication
3. **`--token`** (string)
   - GitHub personal access token for authentication
   - Can also be set via `GITHUB_TOKEN` environment variable
   - Required for private repositories
   - Recommended for higher rate limits (5000 vs 60 requests/hour)
   - Example: `ghp_xxxxxxxxxxxx`

### Filtering Options
4. **`--state`** (string)
   - Filter issues by state
   - Options: `open`, `closed`, `all`
   - Default: `open`
   - Example: `--state all`

5. **`--labels`** (string)
   - Comma-separated list of labels to filter by
   - Example: `--labels "bug,urgent,high-priority"`

6. **`--assignee`** (string)
   - Filter by assignee username
   - Use `none` for unassigned issues
   - Example: `--assignee john`

7. **`--creator`** (string)
   - Filter by issue creator username
   - Example: `--creator jane`

8. **`--mentioned`** (string)
   - Filter by username mentioned in the issue
   - Example: `--mentioned alice`

9. **`--since`** (string)
   - Filter issues updated after this date
   - Format: ISO 8601 (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ)
   - Example: `--since 2024-01-01`

### Sorting Options
10. **`--sort`** (string)
    - Field to sort by
    - Options: `created`, `updated`, `comments`
    - Default: `created`
    - Example: `--sort updated`

11. **`--direction`** (string)
    - Sort direction
    - Options: `asc` (ascending), `desc` (descending)
    - Default: `desc`
    - Example: `--direction asc`

### Pagination Options
12. **`--per-page`** (integer)
    - Number of results per page
    - Range: 1-100
    - Default: 30
    - Example: `--per-page 50`

13. **`--page`** (integer)
    - Page number for pagination
    - Minimum: 1
    - Default: 1
    - Example: `--page 2`

### Output Options
14. **`--json`** (flag)
    - Output raw JSON instead of formatted text
    - No value needed (it's a flag)
    - Useful for programmatic processing
    - Example: `--json`

## Parameter Combinations

### Most Common Use Cases

**Basic usage (all open issues):**
```bash
--owner ASE-G1 --repo deployment
```

**All issues with filters:**
```bash
--owner ASE-G1 --repo deployment --state all --labels bug
```

**Recent issues:**
```bash
--owner ASE-G1 --repo deployment --sort updated --since 2024-01-01
```

**Authenticated request:**
```bash
--owner ASE-G1 --repo deployment --token ghp_xxxxxxxxxxxx
```

**JSON output for scripting:**
```bash
--owner ASE-G1 --repo deployment --json
```

**Complex query:**
```bash
--owner ASE-G1 --repo deployment --state all --labels "bug,urgent" \
  --sort updated --direction desc --per-page 50 --since 2024-01-01
```

## Getting Help

To see all parameters and their descriptions directly from the script:
```bash
python list_issues.py --help
```
