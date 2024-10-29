from flask import Flask, render_template_string
import psycopg2  # Or another library if you're using a different database

app = Flask(__name__)

# Database configuration
DB_HOST = "your_db_host"
DB_NAME = "your_db_name"
DB_USER = "your_db_user"
DB_PASS = "your_db_password"

# Template strings for the page
SUCCESS_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>DB Connection Status</title>
    <style>
        body { background-color: green; display: flex; justify-content: center; align-items: center; height: 100vh; color: white; font-size: 2em; }
    </style>
</head>
<body>
    😊 Database connection successful!
</body>
</html>
'''

FAILURE_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>DB Connection Status</title>
    <style>
        body { background-color: red; display: flex; justify-content: center; align-items: center; height: 100vh; color: white; font-size: 2em; }
    </style>
</head>
<body>
    😞 Database connection failed!
</body>
</html>
'''

@app.route("/")
def check_db_connection():
    try:
        # Attempt to connect to the database
        connection = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        connection.close()
        return render_template_string(SUCCESS_TEMPLATE)
    except Exception as e:
        print(f"Database connection error: {e}")
        return render_template_string(FAILURE_TEMPLATE)

if __name__ == "__main__":
    app.run(debug=True)

