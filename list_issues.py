#!/usr/bin/env python3
"""
GitHub Issues Listing Tool

This script lists issues from a GitHub repository with various filtering options.

Required Parameters:
    --owner: Repository owner (username or organization)
    --repo: Repository name

Optional Parameters:
    --token: GitHub personal access token (can also use GITHUB_TOKEN env var)
    --state: Filter by state (open, closed, all) [default: open]
    --labels: Comma-separated list of labels to filter by
    --assignee: Filter by assignee username
    --creator: Filter by issue creator username
    --mentioned: Filter by mentioned username
    --since: Filter issues updated after this date (ISO 8601 format: YYYY-MM-DD)
    --sort: Sort by (created, updated, comments) [default: created]
    --direction: Sort direction (asc, desc) [default: desc]
    --per-page: Number of results per page (max 100) [default: 30]
    --page: Page number for pagination [default: 1]

Example Usage:
    # List all open issues
    python list_issues.py --owner ASE-G1 --repo deployment
    
    # List closed issues with specific labels
    python list_issues.py --owner ASE-G1 --repo deployment --state closed --labels "bug,urgent"
    
    # List issues assigned to a specific user
    python list_issues.py --owner ASE-G1 --repo deployment --assignee username
    
    # List issues created after a specific date
    python list_issues.py --owner ASE-G1 --repo deployment --since 2024-01-01
"""

import argparse
import os
import sys
import json
from urllib import request, error, parse
from datetime import datetime


def fetch_issues(owner, repo, params, token=None):
    """
    Fetch issues from GitHub API
    
    Args:
        owner: Repository owner
        repo: Repository name
        params: Dictionary of query parameters
        token: GitHub API token (optional)
    
    Returns:
        List of issues
    """
    # Build URL
    base_url = f"https://api.github.com/repos/{owner}/{repo}/issues"
    query_string = parse.urlencode(params)
    url = f"{base_url}?{query_string}"
    
    # Build request
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28"
    }
    
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    req = request.Request(url, headers=headers)
    
    try:
        with request.urlopen(req) as response:
            data = response.read()
            return json.loads(data)
    except error.HTTPError as e:
        print(f"Error: HTTP {e.code} - {e.reason}", file=sys.stderr)
        print(f"URL: {url}", file=sys.stderr)
        if e.code == 401:
            print("Hint: You may need to provide a GitHub token with --token", file=sys.stderr)
        elif e.code == 404:
            print("Hint: Check that the repository owner and name are correct", file=sys.stderr)
        sys.exit(1)
    except error.URLError as e:
        print(f"Error: {e.reason}", file=sys.stderr)
        sys.exit(1)


def format_issue(issue):
    """Format a single issue for display"""
    number = issue.get('number', 'N/A')
    title = issue.get('title', 'No title')
    state = issue.get('state', 'unknown')
    user = issue.get('user', {}).get('login', 'unknown')
    created_at = issue.get('created_at', '')
    labels = [label.get('name', '') for label in issue.get('labels', [])]
    
    # Format labels
    labels_str = f"[{', '.join(labels)}]" if labels else "[]"
    
    # Format date
    if created_at:
        try:
            dt = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
            created_str = dt.strftime('%Y-%m-%d %H:%M')
        except (ValueError, AttributeError):
            created_str = created_at
    else:
        created_str = 'unknown'
    
    return f"#{number:4d} [{state:6s}] {title[:60]:<60s} by {user:15s} {labels_str} ({created_str})"


def main():
    parser = argparse.ArgumentParser(
        description='List GitHub issues with various filtering options',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    # Required arguments
    parser.add_argument('--owner', required=True, help='Repository owner (username or organization)')
    parser.add_argument('--repo', required=True, help='Repository name')
    
    # Optional arguments
    parser.add_argument('--token', help='GitHub personal access token (or set GITHUB_TOKEN env var)')
    parser.add_argument('--state', choices=['open', 'closed', 'all'], default='open',
                        help='Filter by state (default: open)')
    parser.add_argument('--labels', help='Comma-separated list of labels to filter by')
    parser.add_argument('--assignee', help='Filter by assignee username')
    parser.add_argument('--creator', help='Filter by issue creator username')
    parser.add_argument('--mentioned', help='Filter by mentioned username')
    parser.add_argument('--since', help='Filter issues updated after this date (ISO 8601: YYYY-MM-DD)')
    parser.add_argument('--sort', choices=['created', 'updated', 'comments'], default='created',
                        help='Sort by (default: created)')
    parser.add_argument('--direction', choices=['asc', 'desc'], default='desc',
                        help='Sort direction (default: desc)')
    parser.add_argument('--per-page', type=int, default=30, help='Number of results per page (max 100, default: 30)')
    parser.add_argument('--page', type=int, default=1, help='Page number for pagination (default: 1)')
    parser.add_argument('--json', action='store_true', help='Output raw JSON instead of formatted text')
    
    args = parser.parse_args()
    
    # Get token from args or environment
    token = args.token or os.environ.get('GITHUB_TOKEN')
    
    # Build query parameters
    params = {
        'state': args.state,
        'sort': args.sort,
        'direction': args.direction,
        'per_page': min(args.per_page, 100),
        'page': args.page
    }
    
    # Add optional filters
    if args.labels:
        params['labels'] = args.labels
    if args.assignee:
        params['assignee'] = args.assignee
    if args.creator:
        params['creator'] = args.creator
    if args.mentioned:
        params['mentioned'] = args.mentioned
    if args.since:
        params['since'] = args.since
    
    # Fetch issues
    print(f"Fetching issues from {args.owner}/{args.repo}...", file=sys.stderr)
    issues = fetch_issues(args.owner, args.repo, params, token)
    
    # Output results
    if args.json:
        print(json.dumps(issues, indent=2))
    else:
        print(f"\nFound {len(issues)} issue(s):\n")
        print(f"{'#':>5s} {'State':7s} {'Title':<60s} {'Creator':<15s} {'Labels':<30s} {'Created'}")
        print("-" * 150)
        for issue in issues:
            print(format_issue(issue))
        
        if len(issues) == params['per_page']:
            print(f"\n(Showing page {args.page}, use --page to see more)")


if __name__ == '__main__':
    main()
