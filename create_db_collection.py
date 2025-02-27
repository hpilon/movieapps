import os
# import sys
from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.errors import OperationFailure  # Import for handling OperationFailure

# Load environment variables from .env file
load_dotenv()

# Step 1: Load environment variables (set default values where appropriate)
MONGO_HOST_1 = os.getenv("MONGO_HOST_1")  # Default to localhost
MONGO_HOST_2 = os.getenv("MONGO_HOST_2")  # Default to localhost
MONGO_PORT_1 = os.getenv("MONGO_PORT_1")  # Default to 27117
MONGO_PORT_2 = os.getenv("MONGO_PORT_2")  # Default to 27117
MONGO_ADMIN_DB_USER = os.getenv("MONGO_ADMIN_DB_USER")  # MongoDB username (must be set in .env or environment)
MONGO_ADMIN_DB_PASS = os.getenv("MONGO_ADMIN_DB_PASS")  # MongoDB password (must be set in .env or environment)
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME")  # Default MongoDB database name (from .env)
MONGO_APP_DB_USER = os.getenv("MONGO_APP_DB_USER")  # New user for the app
MONGO_APP_DB_PASS = os.getenv("MONGO_APP_DB_PASS")  # New user's password


# Ensure required variables are set
if not all([MONGO_ADMIN_DB_USER, MONGO_ADMIN_DB_PASS,  MONGO_HOST_1, MONGO_HOST_2, MONGO_PORT_1, MONGO_PORT_2, MONGO_APP_DB_USER, MONGO_APP_DB_PASS]):
    print("Missing required environment variables for MongoDB connection or user creation.")
    exit(1)

# Step 2: Allow database name to be passed dynamically via a command-line argument
# If provided, use the argument, otherwise use the environment variable
# db_name_arg = sys.argv[1] if len(sys.argv) > 1 else None
#
# db_name = db_name_arg or MONGO_DB_NAME

#
# Troubleshooting area
#
print(f"MONGO_DB_NAME '{MONGO_DB_NAME}'")
print(f"MONGO_HOST_1 '{MONGO_HOST_1}'")
print(f"MONGO_HOST_2 '{MONGO_HOST_2}'")
print(f"MONGO_PORT_1 '{MONGO_PORT_1}'")
print(f"MONGO_PORT_2 '{MONGO_PORT_2}'")
print(f"MONGO_ADMIN_DB_USER '{MONGO_ADMIN_DB_USER}'")
print(f"MONGO_APP_DB_USER '{MONGO_APP_DB_USER}'")

if not MONGO_DB_NAME:
    print("Database name not provided. Set MONGO_DB_NAME in the environment (.env) file.")
    exit(1)

# Step 3: Build the connection string
connection_string = (
    f"mongodb://{MONGO_ADMIN_DB_USER}:{MONGO_ADMIN_DB_PASS}@{MONGO_HOST_1}:{MONGO_PORT_1},"
    f"{MONGO_HOST_2}:{MONGO_PORT_2}"
)

# Step 4: Connect to MongoDB
try:
    client = MongoClient(connection_string)
    print("Connected to MongoDB successfully!")
except Exception as e:
    print(f"Failed to connect to MongoDB: {e}")
    exit(1)

# Step 5: Create or reference the database
try:
    db = client[MONGO_DB_NAME]
    print(f"Database '{MONGO_DB_NAME}' is ready!, and used user '{MONGO_ADMIN_DB_USER}'")
except Exception as e:
    print(f"Failed to access or create database: {e}")
    exit(1)

# Step 6: Insert a record (this will create the database if it doesn't exist)
movies_collection = db["movies"]
movies_collection.insert_one({
    "title": "01 - NEW database",
    "format": "Blu-Ray",
    "director": MONGO_APP_DB_USER,
    "location": "Basement",
    "comments": "database and collection got re-created/initialize"
})
print("Database and collection created successfully!")


# Step 7: Create an app user for the database
try:
    # Check if the user exists
    existing_user = db.command("usersInfo", MONGO_APP_DB_USER)

    if existing_user["users"]:
        print(f"User '{MONGO_APP_DB_USER}' already exists.")
    else:
        # Create user if it does not exist
        db.command("createUser", MONGO_APP_DB_USER,
                   pwd=MONGO_APP_DB_PASS,
                   roles=[{"role": "dbOwner", "db": MONGO_DB_NAME}])
        print(f"User '{MONGO_APP_DB_USER}' created successfully, and granted the role of readWrite")

except OperationFailure as e:
    print(f"Failed to check or create user: {e}")
