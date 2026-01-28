# 1. Pull the official MySQL base image from Docker Hub
FROM mysql:8.0

# 2. Set the mandatory Root password for the database
ENV MYSQL_ROOT_PASSWORD=my-secret-pw

# 3. Automatically create a specific database and user on startup
ENV MYSQL_DATABASE=mydb
ENV MYSQL_USER=myuser
ENV MYSQL_PASSWORD=mypassword

# 4. Document that the container listens on the default MySQL port
EXPOSE 3306