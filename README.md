# Streamlit + AWS Lambda + Terraform Demo

This project demonstrates how to build a simple serverless application that connects  
a local frontend (Streamlit) to a cloud backend (AWS Lambda) managed through Terraform.

---

## Architecture Overview

1. **Frontend – Streamlit App**  
   Provides a simple web UI where the user can enter their name.  
   Sends HTTP requests to the backend via an API endpoint.

2. **Backend – AWS Lambda (Python)**  
   Receives HTTP requests from API Gateway and returns a dynamic text response.

3. **Infrastructure as Code – Terraform**  
   Automatically provisions the AWS Lambda function and API Gateway using code.

---

## How It Works

1. The user opens the Streamlit app and enters their name.  
2. Streamlit sends an HTTP request to the API Gateway.  
3. The API Gateway forwards the request to the AWS Lambda.  
4. The Lambda processes the input and returns:  
```

Hello <name> from AWS Lambda!

````

---

## Purpose

To demonstrate the full connection between:
- a local frontend (Streamlit),
- a serverless backend (AWS Lambda),
- and cloud infrastructure management (Terraform).

This setup is ideal for learning serverless architectures and Infrastructure as Code concepts.

---

## Quick Start

### 1. Install dependencies
```bash
pip install streamlit requests
````

### 2. Run the Streamlit app

```bash
cd streamlit_app
streamlit run app.py
```

### 3. Deploy the Lambda and API Gateway (optional)

```bash
cd terraform
terraform init
terraform apply
```

---

## 📁 Project Structure

```
streamlit-lambda-terraform-demo/
│
├── lambda/
│   └── lambda_function.py
│
├── streamlit_app/
│   └── app.py
│
└── terraform/
    ├── provider.tf
    ├── main.tf
    └── outputs.tf
```

---

## 🧹 Cleanup

When you're done testing:

```bash
terraform destroy
```

This removes all AWS resources to avoid unnecessary costs.

```
