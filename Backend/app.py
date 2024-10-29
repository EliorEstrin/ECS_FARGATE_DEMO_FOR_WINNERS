import os
from flask import Flask, render_template_string, request, redirect, url_for
import psycopg2

app = Flask(__name__)

# Default database configuration
DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "admin")
DB_USER = os.getenv("DB_USER", "admin")
DB_PASS = os.getenv("DB_PASS", "admin")

# HTML templates with retry and configuration buttons
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>DB Connection Status</title>
    <style>
        body { display: flex; justify-content: center; align-items: center; flex-direction: column; height: 100vh; font-size: 1.5em; color: white; margin: 0; }
        .success { background-color: #4CAF50; } /* Green */
        .failure { background-color: #F44336; } /* Red */
        button { margin-top: 20px; padding: 10px 20px; font-size: 1em; cursor: pointer; background-color: #333; color: white; border: none; border-radius: 5px; }
        button:hover { background-color: #555; }
    </style>
</head>
<body class="{{ status_class }}">
    <div>{{ message }}</div>
    <form action="/" method="post">
        <button type="submit" name="action" value="retry">Retry</button>
    </form>
    <form action="/config" method="get">
        <button type="submit">Configure DB Credentials</button>
    </form>
</body>
</html>
'''

CONFIG_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Configure DB Credentials</title>
    <style>
        body { display: flex; justify-content: center; align-items: center; flex-direction: column; height: 100vh; background-color: #f0f4f8; font-family: Arial, sans-serif; margin: 0; color: #333; }
        h2 { color: #333; }
        form { background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1); }
        input { margin: 10px 0; padding: 10px; width: 100%; border-radius: 5px; border: 1px solid #ccc; }
        button { margin-top: 20px; padding: 10px 20px; font-size: 1em; cursor: pointer; background-color: #4CAF50; color: white; border: none; border-radius: 5px; }
        button:hover { background-color: #45a049; }
    </style>
</head>
<body>
    <h2>Enter Database Credentials</h2>
    <form action="/config" method="post">
        <label>Host:</label>
        <input type="text" name="DB_HOST" value="{{ DB_HOST }}">
        <label>Name:</label>
        <input type="text" name="DB_NAME" value="{{ DB_NAME }}">
        <label>User:</label>
        <input type="text" name="DB_USER" value="{{ DB_USER }}">
        <label>Password:</label>
        <input type="password" name="DB_PASS" value="{{ DB_PASS }}">
        <button type="submit">Save & Retry</button>
    </form>
</body>
</html>
'''

# Function to attempt database connection
def check_db_connection():
    try:
        connection = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        connection.close()
        return True, "😊 Database connection successful!", "success"
    except Exception as e:
        print(f"Database connection error: {e}")
        return False, "😞 Database connection failed!", "failure"

@app.route("/", methods=["GET", "POST"])
def home():
    if request.method == "POST" and request.form.get("action") == "retry":
        # Retry connection with current credentials
        success, message, status_class = check_db_connection()
    else:
        # Initial check
        success, message, status_class = check_db_connection()
    return render_template_string(HTML_TEMPLATE, message=message, status_class=status_class)

@app.route("/config", methods=["GET", "POST"])
def configure():
    global DB_HOST, DB_NAME, DB_USER, DB_PASS
    if request.method == "POST":
        # Update credentials with user input
        DB_HOST = request.form.get("DB_HOST", DB_HOST)
        DB_NAME = request.form.get("DB_NAME", DB_NAME)
        DB_USER = request.form.get("DB_USER", DB_USER)
        DB_PASS = request.form.get("DB_PASS", DB_PASS)
        return redirect(url_for("home"))  # Redirect to retry connection
    return render_template_string(CONFIG_TEMPLATE, DB_HOST=DB_HOST, DB_NAME=DB_NAME, DB_USER=DB_USER, DB_PASS=DB_PASS)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)

