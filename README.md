# To create a simple GitHub Actions pipeline for a Jupyter Notebook

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
     
6.  Write the pipeline in notebook-pipeline.yml:
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
