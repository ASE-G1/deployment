# What Parameters Do You Need for the GitHub Issues Listing Tool?

## Quick Answer

To list GitHub issues, you need **2 required parameters** and have **12 optional parameters** available:

### Required (Must Provide)
1. `--owner` - Repository owner (e.g., ASE-G1)
2. `--repo` - Repository name (e.g., deployment)

### Optional (For Filtering, Sorting & Output)
3. `--token` - GitHub token for authentication
4. `--state` - Filter by state (open/closed/all)
5. `--labels` - Filter by labels
6. `--assignee` - Filter by assignee
7. `--creator` - Filter by creator
8. `--mentioned` - Filter by mentioned user
9. `--since` - Filter by date
10. `--sort` - Sort field (created/updated/comments)
11. `--direction` - Sort direction (asc/desc)
12. `--per-page` - Results per page
13. `--page` - Page number
14. `--json` - Output as JSON

## Minimal Example
```bash
python list_issues.py --owner ASE-G1 --repo deployment
```

## With Options Example
```bash
python list_issues.py --owner ASE-G1 --repo deployment --state all --labels bug
```

## Full Details

See the following documentation files:
- **[PARAMETERS_SUMMARY.md](PARAMETERS_SUMMARY.md)** - Complete list with descriptions
- **[ISSUES_TOOL_README.md](ISSUES_TOOL_README.md)** - Full documentation
- **[ISSUES_QUICK_REFERENCE.md](ISSUES_QUICK_REFERENCE.md)** - Quick commands
