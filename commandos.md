

kubectl create secret generic django-secret \                                                       
  -n scm-app \
  --from-literal=DJANGO_SECRET_KEY="django-insecure-%21ov1m*9+y8m4hr9=3$$yi##q#jtarbs7cpsf*a69lgo0hx#&" \
  --dry-run=client -o yaml | kubectl apply -f -



kubectl get secrets -n scm-app           

kubectl describe secret django-secret -n scm-app


kubectl get secret <secret-name> -n scm-app -o jsonpath="{.data}" | jq -r 'to_entries[] | "\(.key)=\(.value|@base64d)"'


kubectl rollout restart deployment django-api -n scm-app   


docker build --platform=linux/amd64 \
  -t asescmacr.azurecr.io/scm-backend:v2 \
  -f Dockerfile .

kubectl describe pod -n scm-app django-api-5b7d97d446-25r5r


az acr repository list -n asescmacr -o table 


az acr repository show-tags \
  -n asescmacr \
  --repository scm-backend \
  -o table


az acr repository delete \
  -n asescmacr \
  --repository scm-backend \
  -y


kubectl logs -n scm-app deploy/django-api --tail=50

kubectl get pod -n scm-app -o wide


kubectl describe pod <pod-name> -n scm-app | grep Image


kubectl get ingress -n scm-app

kubectl delete ingress scm-ingress -n scm-app 

kubectl apply -f django-api.yaml 


kubectl rollout restart deploy/django-api -n scm-app

az acr login --name asescmacr

kubectl exec -it -n scm-app deploy/django-api -- sh -c "cd /app && python manage.py makemigrations"
kubectl exec -it -n scm-app deploy/django-api -- sh -c "cd /app && python manage.py migrate"

kubectl create secret generic scm-db-secret \
  -n scm-app \
  --from-literal=DB_HOST="scm-postgres.postgres.database.azure.com" \
  --from-literal=DB_NAME="scm" \
  --from-literal=DB_USER="scmadmin" \
  --from-literal=DB_PASSWORD="Password@123" \
  --from-literal=DB_PORT="5432" \
  --from-literal=DB_SSLMODE="require" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl exec -it -n scm-app deploy/django-api -- sh -c "cd /app && python manage.py shell"

from django.db import connection
print(connection.settings_dict)

from django.db import connections
print(connections['default'].settings_dict)


kubectl exec -it -n scm-app deploy/django-api -- python manage.py showmigrations

az aks stop --name scm-aks --resource-group scm-rg   

kubectl exec -it -n scm-app deploy/django-api -- sh -c "cd /app && python manage.py shell"

from django.db import connection
print(connection.settings_dict)

with connection.cursor() as cursor:
    cursor.execute("SELECT 1;")
    print(cursor.fetchone())
