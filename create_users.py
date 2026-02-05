from django.contrib.auth import get_user_model
User = get_user_model()

users = [
    {"username": "analyst", "email": "singhalkartik72@gmail.com", "password": "Password@123", "is_staff": False},
    {"username": "manager", "email": "binua@tcd.ie", "password": "Password@123", "is_staff": False},
    {"username": "provider", "email": "", "password": "Password@123", "is_staff": False},
    # Ensure admin has the correct email if not already set
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
        
        # Only set password if creating or if you want to force reset it.
        # Uncomment the next line to force reset passwords for existing users too.
        user.set_password(password)
        
        user.save()
        status = "Created" if created else "Updated"
        print(f"{status} user: {username} ({email})")
        
    except Exception as e:
        print(f"Error handling user {username}: {e}")

print("User import complete.")
