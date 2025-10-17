import streamlit as st
import requests

# Streamlit turns Python scripts into interactive web apps.
# requests lets you make HTTP calls (e.g., to an AWS Lambda URL).

st.title("Lambda Greeting Demo")

# Text input for the user's name
name = st.text_input("Enter your name:")

# Button to simulate sending a request
if st.button("Send"):
    # Build the URL that would be sent to AWS, including the name parameter
    api_url = "https://qonm1uqilc.execute-api.eu-west-1.amazonaws.com"

    # Call the real Lambda endpoint
    response = requests.get(f"{api_url}/?name={name}")
    
    # Show the URL on the page
    st.write(f"Request sent to: {api_url}")

    # Show a success message
    st.success(f"Hello {name or 'World'} from AWS Lambda!")




