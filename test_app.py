import pytest
from app import app, mongo
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Step 1: Load environment variables (set default values where appropriate)
MONGO_HOST_1 = os.getenv("MONGO_HOST_1")  # not using localhost
MONGO_HOST_2 = os.getenv("MONGO_HOST_2")  # not using  localhost
MONGO_PORT_1 = os.getenv("MONGO_PORT_1")  # Default to 27117
MONGO_PORT_2 = os.getenv("MONGO_PORT_2")  # Default to 27118
MONGO_ADMIN_DB_USER = os.getenv("MONGO_ADMIN_DB_USER")  # MongoDB username
MONGO_ADMIN_DB_PASS = os.getenv("MONGO_ADMIN_DB_PASS")  # MongoDB password
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME")  # Default MongoDB database name
MONGO_APP_DB_USER = os.getenv("MONGO_APP_DB_USER")
MONGO_APP_DB_PASS = os.getenv("MONGO_APP_DB_PASS")
APP_VERSION = os.getenv("APP_VERSION")
APP_RELEASE_DATE = os.getenv("APP_RELEASE_DATE")


# Ensure required variables are set
if not all([
    MONGO_ADMIN_DB_USER, MONGO_ADMIN_DB_PASS, MONGO_HOST_1, MONGO_PORT_1,
    MONGO_HOST_2, MONGO_PORT_2, MONGO_APP_DB_PASS, MONGO_APP_DB_USER,
    APP_VERSION, APP_RELEASE_DATE
]):
    print("Missing required environment variables for MongoDB connection or user creation.")
    exit(1)


# Configure MongoDB URI
app.config["MONGO_URI"] = (
    f"mongodb://{MONGO_APP_DB_USER}:{MONGO_APP_DB_PASS}@{MONGO_HOST_1}:{MONGO_PORT_1},"
    f"{MONGO_HOST_2}:{MONGO_PORT_2}/{MONGO_DB_NAME}"
)


@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


# Clear all collections after each test
def truncateDB():
    """Truncate database collections before each test."""
    with app.app_context():
        mongo.db.movies.delete_many({})  # Delete all documents from movies collection


def test_index_response(client):
    """Test that the index page loads correctly."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Movie Portal" in response.data  # Adjust based on actual title in index page


def test_add(client):
    """Test adding a movie entry."""
    test_data = {
        "title": "02-Adding a test record to the database",
        "format": "Blu-Ray",
        "director": "unknown at this time",
        "location": "Basement",
        "comments": "PYTEST-ADD-001,Adding a record using pytest"
    }

    response = client.post('/add', data=test_data, follow_redirects=True)
#    Flask redirects after a successful form submission, so expect 302 Found
#    assert response.status_code == 302
    assert response.status_code == 200
    # Check if the movie exists in the database
    movie = mongo.db.movies.find_one({"title": "02-Adding a test record to the database"})
    assert movie is not None
    assert movie["format"] == "Blu-Ray"


def test_edit(client):
    """Test editing a movie entry."""
    # Insert a test movie
    test_movie = {
        "title": "03-Editing a test record ",
        "format": "DVD",
        "director": "Jane Doe",
        "location": "Basement",
        "comments": "PYTEST-EDIT-002, Editing test using pytest"
    }
    movie_id = mongo.db.movies.insert_one(test_movie).inserted_id

    updated_data = {
        "title": "04-Editing / Updated Movie Title",
        "format": "Blu-Ray",
        "director": "Jane Doe",
        "location": "Basement",
        "comments": "PYTEST-EDIT-003, Updated record using pytest, PYTEST-EDIT-002 should not be present"
    }

    response = client.post(f'/edit/{movie_id}', data=updated_data, follow_redirects=True)
    assert response.status_code == 200

    # Verify the update in the database
    updated_movie = mongo.db.movies.find_one({"_id": movie_id})
    assert updated_movie["title"] == "04-Editing / Updated Movie Title"


def test_delete(client, capfd):
    """Test deleting a movie entry."""
#    # Insert a test movie
    test_movie = {
        "title": "05-Delete Test Movie record",
        "format": "DVD",
        "director": "John Doe",
        "location": "Office",
        "comments": "PYTEST-DELETE-004, Delete record using pytest"
    }
    movie_id = mongo.db.movies.insert_one(test_movie).inserted_id
    # movie_id_str = str(movie_id)
    # print(f'Troubleshooting: movie_id={movie_id}, movie_id_str={movie_id_str}')

    # Ensure the movie was inserted
    assert mongo.db.movies.find_one({"_id": movie_id}) is not None, "Movie was not inserted properly!"

    # Send delete request
    # response = client.post('/delete', data={"movie_id": movie_id_str}, follow_redirects=True)
    response = client.post(f'/delete/{movie_id}', follow_redirects=True)

    # Debugging: Print the response text
    # print(response.data.decode())

    # Capture the output and display it
    # captured = capfd.readouterr()
    # print(captured.out)  # Forces pytest to show the captured output
    assert response.status_code == 200, f"Unexpected status code: {response.status_code}"


def test_add2(client):
    """Index, added , edit and delete the record"""
    test_data = {
        "title": "06-Looks good now from pytest side",
        "format": "Blu-Ray",
        "director": "unknown at this time",
        "location": "Basement",
        "comments": "PYTEST-ADD-005, Index, add, edit and delete the record successfully using pytest, PYTEST-DELETE-004 should not be present"
    }

    response = client.post('/add', data=test_data, follow_redirects=True)
    assert response.status_code == 200
    # Check if the movie exists in the database
    movie = mongo.db.movies.find_one({"title": "06-Looks good now from pytest side"})
    assert movie is not None
    assert movie["format"] == "Blu-Ray"
