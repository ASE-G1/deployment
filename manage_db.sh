#!/bin/bash
set -e

# Get repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    echo "Usage: $0 [migrate|createsuperuser|shell|import-users]"
    exit 1
}

if [ "$#" -ne 1 ]; then
    show_usage
fi

ACTION=$1

# Get Django pod name
POD_NAME=$(kubectl get pods -n scm-app -l app=django-api -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "Error: Could not find django-api pod in scm-app namespace."
    exit 1
fi

case "$ACTION" in
    migrate)
        echo "Running migrations..."
        kubectl exec -n scm-app -it "$POD_NAME" -- python manage.py migrate
        ;;
    createsuperuser)
        echo "Creating superuser..."
        kubectl exec -n scm-app -it "$POD_NAME" -- python manage.py createsuperuser
        ;;
    shell)
        echo "Opening Django shell..."
        kubectl exec -n scm-app -it "$POD_NAME" -- python manage.py shell
        ;;
    import-users)
        echo "Importing users from deployment/create_users.py..."
        kubectl exec -n scm-app -it "$POD_NAME" -- python -c "$(cat $SCRIPT_DIR/create_users.py)"
        ;;
    *)
        show_usage
        ;;
esac
