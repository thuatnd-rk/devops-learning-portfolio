# 🎈 Streamlit + LLM Examples App

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/streamlit/llm-examples?quickstart=1)

Starter examples for building LLM apps with Streamlit.

## Overview of the App

This app showcases a growing collection of LLM minimum working examples.

Current examples include:

- Chatbot
- File Q&A
- Chat with Internet search
- LangChain Quickstart
- LangChain PromptTemplate
- Chat with user feedback

## Demo App

[![Streamlit App](https://static.streamlit.io/badges/streamlit_badge_black_white.svg)](https://llm-examples.streamlit.app/)

### Get an OpenAI API key

You can get your own OpenAI API key by following the following instructions:

1. Go to https://platform.openai.com/account/api-keys.
2. Click on the `+ Create new secret key` button.
3. Next, enter an identifier name (optional) and click on the `Create secret key` button.

### Enter the OpenAI API key in Streamlit Community Cloud

To set the OpenAI API key as an environment variable in Streamlit apps, do the following:

1. At the lower right corner, click on `< Manage app` then click on the vertical "..." followed by clicking on `Settings`.
2. This brings the **App settings**, next click on the `Secrets` tab and paste the API key into the text box as follows:

```sh
OPENAI_API_KEY='xxxxxxxxxx'
```

## Run it locally

### Prerequisites

- Python 3.12+
- [uv](https://github.com/astral-sh/uv) - Fast Python package installer and resolver

### Setup and Installation

```sh
# Initialize uv project (if not already done)
uv init -p <python-version>

# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate  # On Linux/Mac
# or
.venv\Scripts\activate     # On Windows

# Install dependencies
uv pip install -r requirements.txt

# Run the application
streamlit run Chatbot.py
```

### Alternative: Using uv run (no activation needed)

```sh
# Install dependencies and run in one command
uv run streamlit run Chatbot.py
```
