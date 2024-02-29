# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Python script into the container
COPY app.py .
COPY requirements.txt .

# Update the package lists and upgrade installed packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    pip install --no-cache-dir -r requirements.txt

# Specify the command to run when the container starts
CMD ["python3", "app.py"]