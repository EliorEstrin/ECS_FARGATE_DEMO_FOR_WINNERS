docker build -t db_check_app .

docker run -p 5000:5000 db_check_app
