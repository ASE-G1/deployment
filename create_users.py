import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'SustainableCityManagement.settings')
django.setup()

from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
User = get_user_model()

users = [
    {"username": "analyst", "email": "singhalkartik72@gmail.com", "password": "Password@123", "is_staff": False, "group": "Data Analyst"},
    {"username": "manager", "email": "binua@tcd.ie", "password": "Password@123", "is_staff": False, "group": "City Manager"},
    {"username": "provider", "email": "", "password": "Password@123", "is_staff": False, "group": "Mobility Provider"},
    {"username": "admin", "email": "sdeshmuk@tcd.ie", "password": "Password@123", "is_staff": True, "is_superuser": True},
]

print("Starting user import...")

for u_data in users:
    username = u_data["username"]
    email = u_data["email"]
    password = u_data["password"]
    is_staff = u_data["is_staff"]

    try:
        user, created = User.objects.get_or_create(username=username)
        user.email = email
        user.is_staff = is_staff
        if "is_superuser" in u_data:
            user.is_superuser = u_data["is_superuser"]
        user.set_password(password)
        user.save()

        if "group" in u_data:
            group, _ = Group.objects.get_or_create(name=u_data["group"])
            user.groups.set([group])

        status = "Created" if created else "Updated"
        print(f"{status} user: {username} ({email}) -> {u_data.get('group', 'admin')}")

    except Exception as e:
        print(f"Error handling user {username}: {e}")

print("User import complete.")
