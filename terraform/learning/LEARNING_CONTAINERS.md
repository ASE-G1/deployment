# Module 2: Containerization (Docker) and Azure Container Registry (ACR)

Now that you understand the "Ground" (Infrastructure), let's talk about the "Cargo" (your Code). In modern deployment, we don't just "copy files"; we package them into **Containers**.

## 1. Why Containers?
Imagine trying to ship an engine, a piano, and a pile of glass across the ocean. If you put them all in a standard shipping container, they are protected and easy to move.
- **Consistency**: "It works on my machine" becomes "It works in the container."
- **Isolation**: The backend and frontend don't interfere with each other.

## 2. The Dockerfile: The Blueprint
A `Dockerfile` is a list of instructions on how to build your container image.

- **Look at your code**: Open [scm_backend/Dockerfile](file:///Users/jayanandenm/Desktop/ASE/codebase/scm_backend/Dockerfile).
  - `FROM python:3.9`: Start with a computer that already has Python.
  - `WORKDIR /app`: Create a folder for the code.
  - `COPY requirements.txt .`: Copy the "shopping list" of libraries.
  - `RUN pip install ...`: Install the libraries.
  - `CMD ["python", "manage.py", "runserver"]`: The command to start the app.

## 3. Azure Container Registry (ACR): The Warehouse
Once you build an image, where do you put it? You "push" it to ACR.
- **In your code**: [acr.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/acr.tf) creates this private warehouse.
- **Commands to remember**:
  - `docker build`: Creates the image.
  - `az acr login`: Authenticates your computer to your Azure warehouse.
  - `docker push`: Sends the image to the warehouse.

## 4. Expert Insight: Tags
In your [deploy_backend_manual.sh](file:///Users/jayanandenm/Desktop/ASE/codebase/deploy_backend_manual.sh), you see `TAG="latest"`.
- **Warning**: Using `latest` is common for testing, but experts use version numbers (like `v1.0.1`) or timestamps. This allows you to "rollback" to an older version if the new code breaks.

## 5. Knowledge Check
Open [deploy_backend_manual.sh](file:///Users/jayanandenm/Desktop/ASE/codebase/deploy_backend_manual.sh) and find the `docker build` command. 
- Can you identify the `--platform=linux/amd64` flag? 
- **Why it's there**: Most Azure servers run on AMD64 chips. If you build on a MacBook (M1/M2/M3 chips), you MUST use this flag, or the server won't be able to "read" your container.

---
**Next Module**: [Module 3: Orchestration (AKS & Kubernetes)](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/LEARNING_K8S.md)
