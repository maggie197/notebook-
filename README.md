# Create a simple GitHub Actions pipeline for a Jupyter Notebook

1. Create a GitHub repository
2. Set up a requirements.txt file for dependencies
   ```
    pandas
    matplotlib
    jupyter
    nbconvert

   ```

3. Create a GitHub Actions workflow:
In your repository, create a .github/workflows directory

4. Create a .ipynb
   * Install jupyter
     ```
     python3 -m pip install jupyter

     ```
   * Launch jupyter
     ```
     jupyter notebook

     ```
   * If jupyter Still Isn’t Recognized:
     ```
     python -m notebook
     ```
   * In the Jupyter Notebook interface, click on New
   * Select Python 3 to create a new notebook.
   * Rename the notebook
   * Add Some Code to the Notebook
     ```
     print("Hello, GitHub Actions!")
     ```
    * Click on File → Save
    * Verify the File Exists
     
5.  Write the pipeline in notebook-pipeline.yml:
    ```
    name: Jupyter Notebook Pipeline

    on:
    push:
        branches:
        - main
    pull_request:
        branches:
        - main

    jobs:
    notebook:
        runs-on: ubuntu-latest

        steps:
        - name: Checkout repository
        uses: actions/checkout@v2

        - name: Set up Python
        uses: actions/setup-python@v2
        with:
            python-version: 3.8

        - name: Install dependencies
        run: |
            python -m pip install --upgrade pip
            pip install -r requirements.txt
            pip install jupyter nbconvert 
            
        - name: Run Jupyter Notebook
        run: |
            jupyter nbconvert --execute --to notebook --inplace my_notebook.ipynb

    ```

7. Commit and Push Changes
   ```
    git add .
    git commit -m "Add notebook pipeline"
    git push origin main

   ```


# Authenticate GitHub Actions with Google Cloud using OIDC (OpenID Connect)

1. Enable OIDC on Google Cloud
    * Login to Google Cloud:

        ```
        gcloud auth login

        ```
    
    * Set Your Project:

        ```
        gcloud config set project your-project-ID  # Change values

        ```
    
    * Enable Required APIs:

        ```
        gcloud services enable iamcredentials.googleapis.com
        gcloud services enable cloudresourcemanager.googleapis.com

        ```

2. Create a Service Account for GitHub Actions

    * Create the Service Account:
        
        ```
            gcloud iam workload-identity-pools create "github-actions-pool" \
            --location="global" \
            --display-name="GitHub Actions Pool"  

        ```

    * Create OIDC Provider:

        ```
            gcloud iam workload-identity-pools providers create-oidc "github" \
            --location="global" \
            --workload-identity-pool="github-actions-pool" \
            --display-name="GitHub Provider" \
            --issuer-uri="https://token.actions.githubusercontent.com" \
            --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
            --attribute-condition="assertion.repository=='<your_github_user>/<your_repo>'"   # change values

        ```
    
    * Grant Access to OIDC Identity:

        ```
            gcloud iam service-accounts add-iam-policy-binding \
           YOUR-SERVICE-ACCOUNT \
            --role="roles/iam.workloadIdentityUser" \
            --member="principalSet://iam.googleapis.com/projects/227644934353/locations/global/workloadIdentityPools/github-action-pool/attribute.repository/<your_github_user>/<your_repo>"  

         # change values: YOUR-SERVICE-ACCOUNT, <your_github_user>/<your_repo>
            
        ```

3. Update GitHub Workflow Configuration

In your .github/workflows/main.yml file, add the following steps:

```
name: Jupyter Notebook Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  contents: 'read'
  id-token: 'write'  # Required for OIDC Authentication

jobs:
  notebook:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install jupyter nbconvert 
          
    - name: Run Jupyter Notebook
      run: |
        jupyter nbconvert --execute --to notebook --inplace my_notebook.ipynb

#  Authenticate with Google Cloud using OIDC

    - name: Authenticate with GCP using OIDC
      id: 'auth'
      uses: 'google-github-actions/auth@v1'
      with:
        workload_identity_provider: 'projects/227644934353/locations/global/workloadIdentityPools/github-action-pool/providers/github'
        service_account: 'YOUR_SERVICE_ACCOUNT'

    - name: Set up gcloud CLI
      uses: google-github-actions/setup-gcloud@v1
      with:
        project_id: your-project-ID

    - name: Run Jupyter Notebook
      run: |
        jupyter nbconvert --execute --to notebook --inplace my_notebook.ipynb

    # Optional: Run GCloud Commands After Notebook Execution
    - name: Verify GCP Authentication
      run: |
        gcloud auth list
        gcloud projects list

```

4. Commit and Push the Workflow

    ```
    git add .github/workflows/your-main.yml
    git commit -m "Add GitHub Actions OIDC to authenticate GCP"
    git push origin main

    ```
    To Verify: Check your GitHub Actions logs.