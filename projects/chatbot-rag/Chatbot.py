import streamlit as st
import boto3
from botocore.exceptions import BotoCoreError, ClientError
import os
import uuid
import logging
from dotenv import load_dotenv
import requests
import json
from datetime import datetime

# Load .env only for local development
if os.path.exists('.env'):
    load_dotenv()
    logger_msg = "Loaded .env file for local development"
else:
    logger_msg = "No .env file found, using environment variables (ECS/production mode)"

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.info(logger_msg)

def send_chat_to_api(session_id, message, sender):
    """Send chat message to API endpoint"""
    try:
        api_url = os.getenv('API_ENDPOINT_URL')
        if not api_url:
            logger.warning("API_ENDPOINT_URL not set, skipping API logging")
            return

        payload = {
            "sessionId": session_id,
            "message": message,
            "sender": sender
        }
        
        response = requests.post(api_url, json=payload)
        response.raise_for_status()
        logger.info(f"Successfully logged {sender} message to API for session {session_id}")
    except Exception as e:
        logger.error(f"Failed to send message to API: {str(e)}")
        # Don't raise the exception to prevent disrupting the chat flow

# Get AWS configuration (using default credential chain)
def get_aws_config():
    """Get AWS configuration using default credential chain for security"""
    config = {
        'aws_region': os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION", "ap-southeast-1"),
        'agent_id': os.getenv("AGENT_ID"),
        'alias_id': os.getenv("ALIAS_ID")
    }

    # Log configuration status (without exposing sensitive data)
    logger.info(f"AWS Region: {config['aws_region']}")
    logger.info(f"Agent ID: {'✅ Set' if config['agent_id'] else '❌ Missing'}")
    logger.info(f"Alias ID: {'✅ Set' if config['alias_id'] else '❌ Missing'}")
    logger.info("AWS Credentials: Using default credential chain (AWS CLI/Instance Profile)")

    return config

# Get configuration
aws_config = get_aws_config()
aws_region = aws_config['aws_region']
agent_id = aws_config['agent_id']
alias_id = aws_config['alias_id']

def create_bedrock_client(aws_region):
    """
    Create Bedrock client using default credential chain for security
    """
    try:
        # Use default credential chain (IAM roles, AWS CLI, environment variables, etc.)
        logger.info("Creating Bedrock client with default credential chain")
        client = boto3.client(
            "bedrock-agent-runtime",
            region_name=aws_region
        )

        logger.info("Bedrock client created successfully")
        return client

    except Exception as e:
        logger.error(f"Failed to create Bedrock client: {str(e)}")
        raise e

def invoke_agent_streaming(client, agent_id, alias_id, prompt, session_id):
    """
    Invoke Bedrock agent with streaming response
    """
    try:
        logger.info(f"Invoking agent - Agent ID: {agent_id}, Alias ID: {alias_id}, Session ID: {session_id}")
        logger.info(f"Prompt length: {len(prompt)} characters")

        # Validate input parameters
        if not agent_id or not alias_id:
            raise ValueError("Agent ID and Alias ID are required")
        if not prompt:
            raise ValueError("Prompt cannot be empty")

        response = client.invoke_agent(
            agentId=agent_id,
            agentAliasId=alias_id,
            enableTrace=True,
            sessionId=session_id,
            inputText=prompt,
            streamingConfigurations={
                "applyGuardrailInterval": 20,
                "streamFinalResponse": True
            }
        )

        if not response or "completion" not in response:
            raise ValueError("Invalid response from Bedrock Agent")

        logger.info("Agent invocation successful, processing response stream...")
        completion = ""
        chunk_count = 0
        has_content = False

        for event in response.get("completion"):
            # Collect agent output
            if 'chunk' in event:
                text = event["chunk"]["bytes"].decode()
                if text.strip():  # Only add non-empty chunks
                    completion += text
                    chunk_count += 1
                    has_content = True
                    logger.debug(f"Received chunk {chunk_count}: {len(text)} characters")
                    yield text

            # Log trace events for debugging
            if 'trace' in event:
                trace_event = event.get("trace")
                logger.debug(f"Trace event: {trace_event}")

        if not has_content:
            raise ValueError("Agent returned empty response")

        logger.info(f"Streaming completed. Total chunks: {chunk_count}, Total length: {len(completion)}")
        return completion

    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', 'Unknown')
        error_message = e.response.get('Error', {}).get('Message', str(e))
        logger.error(f"AWS Client error: {error_code} - {error_message}")
        
        # Specific error handling
        if error_code == 'AccessDeniedException':
            raise Exception("Không có quyền truy cập Bedrock Agent. Vui lòng kiểm tra IAM permissions.")
        elif error_code == 'ResourceNotFoundException':
            raise Exception("Không tìm thấy Agent. Vui lòng kiểm tra Agent ID và Alias ID.")
        elif error_code == 'ValidationException':
            raise Exception("Input không hợp lệ. Vui lòng kiểm tra lại prompt.")
        else:
            raise Exception(f"Lỗi AWS: {error_message}")
            
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise Exception(f"Lỗi không xác định: {str(e)}")

def fetch_chat_history():
    """Fetch chat history from API endpoint"""
    try:
        api_url = os.getenv('API_ENDPOINT_URL')
        if not api_url:
            logger.warning("API_ENDPOINT_URL not set, skipping API fetch")
            return {}

        logger.info(f"Fetching chat history from: {api_url}")
        response = requests.get(api_url)
        response.raise_for_status()
        
        # Parse the response body which contains the JSON string
        response_data = response.json()
        
        # Check if response is a list (direct history) or has a body field (API Gateway response)
        if isinstance(response_data, list):
            history = response_data
        elif isinstance(response_data, dict) and 'body' in response_data:
            history = json.loads(response_data['body'])
        else:
            logger.error(f"Unexpected response format: {type(response_data)}")
            return {}
        
        if not history:
            logger.warning("No chat history found")
            return {}
            
        # Group messages by session
        sessions = {}
        for msg in history:
            if not isinstance(msg, dict):
                logger.error(f"Invalid message format: {msg}")
                continue
                
            session_id = msg.get("sessionId")
            if not session_id:
                logger.error(f"Message missing sessionId: {msg}")
                continue
                
            if session_id not in sessions:
                sessions[session_id] = []
            sessions[session_id].append(msg)
        
        # Sort messages within each session by timestamp
        for session_id in sessions:
            sessions[session_id].sort(key=lambda x: x.get("timestamp", ""))
            
        return sessions
    except Exception as e:
        logger.error(f"Failed to fetch chat history: {str(e)}")
        return {}

# Initialize session state for selected session
if "selected_session" not in st.session_state:
    st.session_state["selected_session"] = None

# Fetch chat history
chat_history = fetch_chat_history()

# Sidebar with session list
with st.sidebar:
    # st.header("💬 Chat Sessions")
        # Add logo at the top
    st.image("logo.png", use_container_width =True)
    # Add custom CSS for buttons
    st.markdown("""
        <style>
        /* Style for New Chat button */
        # div[data-testid="stButton"] button[data-testid="baseButton-secondary"] {
        #     text-align: center;
        # }
        /* Style for session buttons */
        div[data-testid="stButton"] button:not([data-testid="baseButton-secondary"]) {
            text-align: left !important;
            padding-left: 1rem !important;
            white-space: nowrap !important;
            overflow: hidden !important;
            text-overflow: ellipsis !important;
            display: block !important;
            width: 100% !important;
            justify-content: flex-start !important;
        }
        </style>
    """, unsafe_allow_html=True)
    
    # Add New Chat button at the top with full width
    if st.button("🆕 New Chat", key="new_chat", use_container_width=True):
        st.session_state["selected_session"] = None
        st.session_state["messages"] = [{"role": "assistant", "content": "Xin chào! Tôi là trợ lý ảo hành chính của CMC TS. Bạn cần hỗ trợ gì?"}]
        st.session_state["session_id"] = str(uuid.uuid4())
        st.rerun()
    
    st.header("💬 Chat Sessions")

    st.divider()
    
    # Create a container for session buttons
    session_container = st.container()
    
    # Display session list
    with session_container:
        for session_id in chat_history.keys():
            # Get first user message from the session
            first_user_message = None
            for msg in chat_history[session_id]:
                if msg.get("sender") == "user":
                    # Truncate message to 30 characters
                    message = msg.get("message", "")
                    first_user_message = message[:30] + "..." if len(message) > 30 else message
                    break
            
            # If no user message found, use a default text
            button_text = first_user_message if first_user_message else f"Session {session_id[:8]}..."
            
            # Create button with custom styling
            if st.button(button_text, key=session_id, use_container_width=True):
                st.session_state["selected_session"] = session_id
                st.session_state["messages"] = []
                for msg in chat_history[session_id]:
                    st.session_state["messages"].append({
                        "role": msg["sender"],
                        "content": msg["message"]
                    })
                st.rerun()

    st.divider()

# Main chat interface
st.title("🤖 Trợ lý ảo hành chính CMC TS")

# Initialize messages if not exists
if "messages" not in st.session_state:
    st.session_state["messages"] = [{"role": "assistant", "content": "Xin chào! Tôi là trợ lý ảo. Bạn cần hỗ trợ gì?"}]

# Display chat messages
for msg in st.session_state.messages:
    st.chat_message(msg["role"]).write(msg["content"])

# Only show chat input if not viewing a session history
if not st.session_state.get("selected_session"):
    if "session_id" not in st.session_state:
        st.session_state["session_id"] = str(uuid.uuid4())
        logger.info(f"New session created: {st.session_state['session_id']}")

    if prompt := st.chat_input("Nhập câu hỏi của bạn"):
        # Validate environment variables
        missing_vars = []
        if not agent_id:
            missing_vars.append("AGENT_ID")
        if not alias_id:
            missing_vars.append("ALIAS_ID")

        if missing_vars:
            st.error(f"❌ Thiếu biến môi trường: {', '.join(missing_vars)}")
            logger.error(f"Missing environment variables: {missing_vars}")
            st.stop()

        logger.info(f"Processing user input: {prompt[:100]}...")

        # Hiển thị câu hỏi người dùng
        st.session_state["messages"].append({"role": "user", "content": prompt})
        st.chat_message("user").write(prompt)

        # Log user message to API
        send_chat_to_api(st.session_state["session_id"], prompt, "user")

        try:
            logger.info("Creating Bedrock client...")
            client = create_bedrock_client(aws_region)

            # Create a placeholder for streaming response
            full_response = ""

            # Stream the response
            with st.chat_message("assistant"):
                message_placeholder = st.empty()
                message_placeholder.markdown("🤔 Đang suy nghĩ...")

                try:
                    for chunk in invoke_agent_streaming(
                        client,
                        agent_id,
                        alias_id,
                        prompt,
                        st.session_state["session_id"]
                    ):
                        full_response += chunk
                        message_placeholder.markdown(full_response + "▌")

                    message_placeholder.markdown(full_response)

                    if not full_response.strip():
                        st.warning("⚠️ Agent trả về phản hồi trống. Vui lòng thử lại.")
                        logger.warning("Agent returned empty response")
                    else:
                        logger.info(f"Response completed successfully. Length: {len(full_response)}")
                        # Log bot response to API
                        send_chat_to_api(st.session_state["session_id"], full_response, "bot")

                except Exception as stream_error:
                    logger.error(f"Streaming error: {str(stream_error)}")
                    message_placeholder.markdown("❌ Có lỗi xảy ra khi xử lý phản hồi")
                    st.error(f"Lỗi streaming: {str(stream_error)}")
                    st.stop()

            # Add the complete response to session state
            if full_response.strip():
                st.session_state["messages"].append({"role": "assistant", "content": full_response})

        except (BotoCoreError, ClientError) as e:
            error_code = getattr(e, 'response', {}).get('Error', {}).get('Code', 'Unknown')
            error_message = getattr(e, 'response', {}).get('Error', {}).get('Message', str(e))

            st.error(f"❌ Lỗi AWS: {error_code} - {error_message}")
            logger.error(f"AWS Error - Code: {error_code}, Message: {error_message}")

            # Specific error handling
            if error_code == 'AccessDeniedException':
                st.info("💡 Kiểm tra quyền truy cập Bedrock Agent trong IAM")
            elif error_code == 'ResourceNotFoundException':
                st.info("💡 Kiểm tra Agent ID và Alias ID có đúng không")
            elif error_code == 'ValidationException':
                st.info("💡 Kiểm tra định dạng input và cấu hình agent")

        except Exception as e:
            st.error(f"❌ Lỗi không xác định: {str(e)}")
            logger.error(f"Unexpected error: {str(e)}", exc_info=True)
