# Streamlit + AWS Lambda + Terraform Demo

This project is built around three main components:

1. **Frontend – Streamlit App**  
   Provides a simple web UI that sends HTTP requests to the backend.

2. **Backend – AWS Lambda (Python)**  
   Receives HTTP requests from the API Gateway and returns a text response.

3. **Infrastructure as Code – Terraform**  
   Automatically provisions the required AWS resources (Lambda and API Gateway).

---

### 🧩 How It Works
The user opens the Streamlit app and enters their name.  
Streamlit sends an HTTP request to the API Gateway, which forwards it to the Lambda function.  
The Lambda processes the request and responds with:

"Hello <name> from AWS Lambda!"

---

### 🎯 Purpose
This project demonstrates how to connect a local frontend to a serverless backend using cloud infrastructure managed by Terraform.

#### Instructions
To install streamlit --> pip install streamlit requests

