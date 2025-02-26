import os
from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.errors import OperationFailure

# Load environment variables
load_dotenv()

# Load required environment variables
MONGO_HOST_1 = os.getenv("MONGO_HOST_1")
MONGO_HOST_2 = os.getenv("MONGO_HOST_2")
MONGO_PORT_1 = os.getenv("MONGO_PORT_1")
MONGO_PORT_2 = os.getenv("MONGO_PORT_2")
MONGO_ADMIN_DB_USER = os.getenv("MONGO_ADMIN_DB_USER")
MONGO_ADMIN_DB_PASS = os.getenv("MONGO_ADMIN_DB_PASS")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME")
MONGO_APP_DB_USER = os.getenv("MONGO_APP_DB_USER")
MONGO_APP_DB_PASS = os.getenv("MONGO_APP_DB_PASS")


# Ensure all required variables are set
if not all([MONGO_HOST_1, MONGO_HOST_2, MONGO_PORT_1, MONGO_PORT_2,
            MONGO_ADMIN_DB_USER, MONGO_ADMIN_DB_PASS, MONGO_APP_DB_USER, MONGO_APP_DB_PASS]):
    print("Missing required environment variables for MongoDB connection or user creation.")
    exit(1)


if not MONGO_DB_NAME:
    print("Database name not provided. Set MONGO_DB_NAME in the environment (.env) file.")
    exit(1)

# Build the connection string
connection_string = (
    f"mongodb://{MONGO_ADMIN_DB_USER}:{MONGO_ADMIN_DB_PASS}@{MONGO_HOST_1}:{MONGO_PORT_1},"
    f"{MONGO_HOST_2}:{MONGO_PORT_2}"
)

# Connect to MongoDB
try:
    client = MongoClient(connection_string)
    print("Connected to MongoDB successfully!")
except Exception as e:
    print(f"Failed to connect to MongoDB: {e}")
    exit(1)

# Access the specified database
try:
    db = client[MONGO_DB_NAME]
    print(f"Database '{MONGO_DB_NAME}' is ready!")
except Exception as e:
    print(f"Failed to access or create database: {e}")
    exit(1)

db_list = client.list_database_names()


# Drop the database
try:
    if MONGO_DB_NAME in db_list:
        client.drop_database(MONGO_DB_NAME)
        print(f"Database '{MONGO_DB_NAME}' dropped successfully using user '{MONGO_ADMIN_DB_USER}'")
    else:
        print(f"Database '{MONGO_DB_NAME}' does NOT exist.")
except Exception as e:
    print(f"Failed to drop the database: {e}")


# Delete the app user
try:
    existing_user = db.command("usersInfo", MONGO_APP_DB_USER)
    if existing_user["users"]:
        db.command("dropUser", MONGO_APP_DB_USER)
        print(f"User '{MONGO_APP_DB_USER}' deleted successfully from database '{MONGO_DB_NAME}' using user '{MONGO_ADMIN_DB_USER}'")
    else:
        print(f"User '{MONGO_APP_DB_USER}' does not exist, no need to delete it.")

except OperationFailure as e:
    print(f"Failed to check or delete user '{MONGO_APP_DB_USER}': {e}")


# Delete the admin user
# try:
#    existing_user = db.command("usersInfo", MONGO_ADMIN_DB_USER)
#    if existing_user["users"]:
#        db.command("dropUser", MONGO_ADMIN_DB_USER)
#        print(f"User '{MONGO_ADMIN_DB_USER}' deleted successfully from database '{MONGO_DB_NAME}' using user '{MONGO_ADMIN_DB_USER}'")
#    else:
#        print(f"User '{MONGO_ADMIN_DB_USER}' does not exist, no need to delete it.")
#
# except OperationFailure as e:
#    print(f"Failed to check or delete user '{MONGO_ADMIN_DB_USER}': {e}")
