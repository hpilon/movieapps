from flask import Flask, render_template, request, redirect
from flask_pymongo import PyMongo
from bson import ObjectId
from dotenv import load_dotenv
from pymongo.errors import OperationFailure
import os
# import sys


app = Flask(__name__)

# Load environment variables from .env file
load_dotenv()

# Step 1: Load environment variables (set default values where appropriate)
MONGO_HOST_1 = os.getenv("MONGO_HOST_1")  # Default to localhost
MONGO_HOST_2 = os.getenv("MONGO_HOST_2")  # Default to localhost
MONGO_PORT_1 = os.getenv("MONGO_PORT_1")  # Default to 27117
MONGO_PORT_2 = os.getenv("MONGO_PORT_2")  # Default to 27118
MONGO_ADMIN_DB_USER = os.getenv("MONGO_ADMIN_DB_USER")  # MongoDB username (must be set in .env or environment)
MONGO_ADMIN_DB_PASS = os.getenv("MONGO_ADMIN_DB_PASS")  # MongoDB password (must be set in .env or environment)
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME")  # Default MongoDB database name (from .env)
MONGO_APP_DB_USER = os.getenv("MONGO_APP_DB_USER")
MONGO_APP_DB_PASS = os.getenv("MONGO_APP_DB_PASS")
APP_VERSION = os.getenv("APP_VERSION")
APP_RELEASE_DATE = os.getenv("APP_RELEASE_DATE")

# Ensure required variables are set
if not all([MONGO_ADMIN_DB_USER, MONGO_ADMIN_DB_PASS, MONGO_HOST_1, MONGO_PORT_1, MONGO_HOST_2, MONGO_PORT_2, MONGO_APP_DB_PASS, MONGO_APP_DB_USER, APP_VERSION, APP_RELEASE_DATE]):
    print("Missing required environment variables for MongoDB connection or user creation.")
    exit(1)

# db_name_arg = sys.argv[1] if len(sys.argv) > 1 else None

# db_name = db_name_arg or MONGO_DB_NAME

# if not db_name:
#    print("Database name not provided. Set MONGO_DB_NAME in the environment or pass it as an argument.")
#    exit(1)
#
#
# Troubleshooting area
#
# print(f"db_name '{db_name}'")
print(f"MONGO_DB_NAME '{MONGO_DB_NAME}'")

print(f"MONGO_HOST_1 '{MONGO_HOST_1}'")
print(f"MONGO_PORT_1 '{MONGO_PORT_1}'")
print(f"MONGO_HOST_2 '{MONGO_HOST_2}'")
print(f"MONGO_PORT_2 '{MONGO_PORT_2}'")

print(f"MONGO_APP_DB_USER '{MONGO_APP_DB_USER}'")
print(f"MONGO_APP_DB_PASS '{MONGO_APP_DB_PASS}'")

print(f"APP_VERSION '{APP_VERSION}'")
print(f"APP_RELEASE_DATE '{APP_RELEASE_DATE}'")

# Configure MongoDB URI
app.config["MONGO_URI"] = (
    f"mongodb://{MONGO_APP_DB_USER}:{MONGO_APP_DB_PASS}@{MONGO_HOST_1}:{MONGO_PORT_1},"
    f"{MONGO_HOST_2}:{MONGO_PORT_2}/{MONGO_DB_NAME}"
)

# Initialize PyMongo
try:
    mongo = PyMongo(app)
    print("Successfully connected to MongoDB.")
except OperationFailure as e:
    print(f"Failed to connect to MongoDB: {e}")
    exit(1)


# Reference to the movies collection
movies_collection = mongo.db.movies


# Home page - Display list of movies
@app.route('/')
def index():
    movies = list(movies_collection.find().sort([("title", 1), ("format", 1)]))  # Fetch movies sorted by date
    return render_template('index.html', movies=movies, app_version=APP_VERSION, app_release_date=APP_RELEASE_DATE)


# Add movie page
@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':
        form_data = request.form
        movie = {
            "title": form_data['title'],
            "format": form_data['format'],
            "director": form_data['director'],
            "location": form_data['location'],
            "comments": form_data['comments']
        }
        try:
            movies_collection.insert_one(movie)
            return redirect('/')
        except Exception as e:
            return f"There was an error adding the movie: {e}"
    return render_template('add.html')


# Edit movie page
@app.route('/edit/<id>', methods=['GET', 'POST'])
def edit(id):
    # Validate ObjectId format
    if not ObjectId.is_valid(id):
        return render_template('edit.html', error="Invalid movie ID.")

    mov = movies_collection.find_one({"_id": ObjectId(id)})
    if not mov:
        return render_template('edit.html', error="movie not found.")

    if request.method == 'POST':
        updated_data = {
            "title": request.form['title'],
            "format": request.form['format'],
            "director": request.form['director'],
            "location": request.form['location'],
            "comments": request.form['comments']
        }
        try:
            movies_collection.update_one({"_id": ObjectId(id)}, {"$set": updated_data})
            return redirect('/')
        except Exception as e:
            return f"There was an error updating the movie: {e}"

    return render_template('edit.html', mov=mov)


# Delete movie page
@app.route('/delete/<id>', methods=['GET', 'POST'])
def delete(id):
    # Validate ObjectId format
    if not ObjectId.is_valid(id):
        return render_template('index.html', error="Invalid movie ID.")

    try:
        result = movies_collection.delete_one({"_id": ObjectId(id)})
        if result.deleted_count == 0:
            return render_template('index.html', error="movie not found.")
        return redirect('/')
    except Exception as e:
        return f"There was an error deleting the movie: {e}"


if __name__ == '__main__':
    app.run(host='0.0.0.0')
