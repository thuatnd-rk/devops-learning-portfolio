# Use Python 3.12 slim image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Default AWS region (override at runtime)
ENV AWS_DEFAULT_REGION="ap-southeast-1"

# Switch to root to install system dependencies
USER root

# Install curl, wget, and uv for package management, then clean up
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      wget \
      build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install --no-cache-dir uv

# Copy project files for uv
COPY pyproject.toml .python-version ./
COPY requirements.txt ./

# Install dependencies using uv
RUN uv pip install --no-cache -r requirements.txt

# Copy application code
COPY . .

# Create a non-root user and adjust ownership
RUN useradd --create-home --shell /bin/bash app \
 && chown -R app:app /app

# Switch back to non-root user
USER app

# Expose application port
EXPOSE 8501

# Run the application using Streamlit
CMD ["streamlit", "run", "Chatbot.py", "--server.port=8501", "--server.address=0.0.0.0"]