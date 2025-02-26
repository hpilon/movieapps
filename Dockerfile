FROM python:3.8.0-slim
WORKDIR /app
ADD app.py /app/app.py
ADD create_db_collection.py /app/create_db_collection.py
ADD delete_user_db.py /app/delete_user_db.py
ADD static /app/static/
ADD templates /app/templates/
ADD .env /app/.env
ADD Procfile /app/Procfile
ADD requirements.txt /app/requirements.txt

RUN pip install --upgrade pip
RUN pip install pymongo
RUN pip install load_dotenv
RUN pip install -r requirements.txt
CMD gunicorn app:app --bind 0.0.0.0:5000 --reload
