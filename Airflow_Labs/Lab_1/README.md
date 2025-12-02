## Customer Segmentation Lab 1 – Custom Airflow Implementation

This project contains a **custom implementation** of an Apache Airflow lab for
segmenting credit card customers with K-Means clustering. It is inspired by the
reference material in `MLOps/Labs/Airflow_Labs/Lab_1`, but the code, function
names, and DAG structure here are intentionally modified so that this version
is clearly distinct.

At a high level, the Airflow DAG orchestrates a four-step ML pipeline:

- **Extract** raw customer data from a CSV file.
- **Transform** selected columns into a standardized feature matrix.
- **Train** a K-Means clustering model over several choices of `k`.
- **Evaluate** the saved model and log an elbow-based suggestion for the number
  of clusters, then produce a prediction for a test sample.

---

## 1. Project Structure

This specific lab lives inside the `Lab_1` folder under `Airflow_Labs`:

```plaintext
Airflow_Labs/
└── Lab_1/
    ├── dags/
    │   ├── customer_segmentation_dag.py   # Custom Airflow DAG
    │   ├── data/
    │   │   ├── file.csv                   # Main dataset for training
    │   │   └── test.csv                   # Sample(s) for prediction
    │   ├── model/                         # Trained model files (created at runtime)
    │   └── src/
    │       └── customer_clustering.py     # Core ML and data-processing logic
    └── README.md                          # This documentation
```

The `Lab_1/dags` directory is what you mount into the Airflow container. The
`Lab_1/dags/model` directory can start empty; it is created automatically when
training runs.

---

## 2. Data Files

### 2.1 `file.csv`

This file contains a large number of credit card customers with columns such as:

- **`CUST_ID`** – anonymized customer identifier  
- **`BALANCE`** – account balance  
- **`PURCHASES`** – total purchases  
- **`CREDIT_LIMIT`** – credit limit  

There are additional columns describing payments, transaction counts, cash
advances, and frequencies. The custom lab here focuses on three core numeric
features for clustering:

- `BALANCE`
- `PURCHASES`
- `CREDIT_LIMIT`

### 2.2 `test.csv`

This smaller CSV is used for evaluation. It includes at least:

- `BALANCE`
- `PURCHASES`
- `CREDIT_LIMIT`

After the model is trained, the DAG will load this file and produce a cluster
label prediction for the first row.

---

## 3. Core Module – `customer_clustering.py`

The main ML logic lives in `dags/src/customer_clustering.py`. It defines four
functions, one for each logical step in the pipeline.

### 3.1 `extract_data()`

- Loads `file.csv` from the `data` directory into a pandas `DataFrame`.
- If the column `CUST_ID` exists, it **removes duplicate IDs**, keeping the last
  occurrence for each customer.
- Serializes the `DataFrame` with `pickle` and base64-encodes the result so it
  can be passed through Airflow XCom as a simple string.

**Return type:** base64-encoded string representing the pickled `DataFrame`.

### 3.2 `transform_data(serialized_df: str)`

- Decodes and unpickles the base64 string produced by `extract_data`.
- Selects the feature columns: `BALANCE`, `PURCHASES`, and `CREDIT_LIMIT`.
- Drops rows with missing values in those columns.
- Applies `StandardScaler` to standardize the features (mean 0, unit variance).
- Constructs a dictionary containing:
  - `"scaled"`: standardized feature matrix (NumPy array)
  - `"feature_columns"`: the list of column names used
- Serializes and base64-encodes that dictionary for downstream tasks.

**Return type:** base64-encoded string of a pickled dictionary with data and
metadata.

### 3.3 `train_kmeans_model(serialized_payload: str, model_name: str)`

- Decodes and unpickles the payload from `transform_data` to recover the
  standardized matrix.
- Defines a range of cluster counts `k`:
  - `k_values = [2, 3, 4, 5, 6, 7, 8, 9, 10]`
- For each `k` in that list:
  - Trains a `KMeans` model with:
    - `init="k-means++"`
    - `n_init=10`
    - `max_iter=300`
    - `random_state=7`
  - Records the sum of squared errors (`inertia_`) in an SSE list.
  - Keeps a reference to the last trained model (effectively the highest `k`).
- Ensures the `model` directory exists and saves the final fitted model as
  `model_name` (for example, `kmeans_custom.sav`) using `pickle`.

**Return type:** dictionary suitable for XCom, of the form:

```python
{"k_values": [...], "sse": [...]}
```

### 3.4 `evaluate_model(model_name: str, metrics: dict)`

- Loads the saved K-Means model from the `model` directory.
- Reads the `k_values` and `sse` lists from the `metrics` dictionary.
- If metrics are available, uses `KneeLocator` from the `kneed` package to
  compute an elbow-based suggestion for the optimal number of clusters and logs
  it to stdout.
- Loads `test.csv` and passes it to the model’s `.predict()` method.
- Returns the first predicted cluster label as a basic Python scalar (typically
  an `int`) that Airflow can store and display through XCom.

---

## 4. Airflow DAG – `customer_segmentation_dag.py`

The DAG is defined in `dags/customer_segmentation_dag.py` and ties together the
functions from `customer_clustering.py` via `PythonOperator` tasks.

### 4.1 DAG configuration

Key configuration details:

- **DAG ID:** `customer_segmentation_lab1`
- **Owner:** `custom_student`
- **Start date:** `2025-01-01`
- **Retries:** `1`
- **Retry delay:** 2 minutes
- **Schedule interval:** `"0 9 * * 1"` (every Monday at 09:00)
- **Catchup:** `False`

These values differ from the original reference lab to clearly mark this as a
separate implementation.

### 4.2 Tasks and dependencies

The DAG defines four Python tasks:

1. **`extract_customer_data`**  
   Calls `extract_data()`. Produces a base64-encoded string containing the
   entire cleaned dataset.

2. **`transform_for_clustering`**  
   Calls `transform_data()` with the previous task’s output. Produces a
   base64-encoded payload with standardized features and metadata.

3. **`train_kmeans_customer_model`**  
   Calls `train_kmeans_model()` using the transformed payload and a model name
   such as `"kmeans_custom.sav"`. Saves the model into the `model` directory
   and returns `"k_values"` and `"sse"` as a dictionary.

4. **`evaluate_customer_model`**  
   Calls `evaluate_model()` with the model filename and the metrics dictionary
   from training. Logs an elbow estimate and outputs the first predicted
   cluster label for the test sample.

The dependency chain is:

```text
extract_customer_data
        ↓
transform_for_clustering
        ↓
train_kmeans_customer_model
        ↓
evaluate_customer_model
```

When the DAG runs, tasks execute in this order and pass data between steps via
XCom.

---

## 5. Running the Lab in Airflow (Docker)

This project is intended to run inside a standard Apache Airflow environment,
such as the official Docker Compose setup.

### 5.1 Mounting the DAGs directory

In your `docker-compose.yaml` for Airflow, ensure the `dags` folder inside the
container points to the `Airflow_Labs/Lab_1/dags` directory on your host. For
example on Windows:

```yaml
services:
  airflow-webserver:
    # ...
    volumes:
      - C:\Assignment _6\Airflow_Labs\Lab_1\dags:/opt/airflow/dags
  airflow-scheduler:
    # ...
    volumes:
      - C:\Assignment _6\Airflow_Labs\Lab_1\dags:/opt/airflow/dags
```

Adjust the host paths according to your environment. The crucial piece is that
`/opt/airflow/dags` inside the container contains `customer_segmentation_dag.py`
along with the `data`, `src`, and `model` subdirectories.

### 5.2 Python dependencies

Inside the Airflow environment, you must have at least:

- `pandas`
- `scikit-learn`
- `kneed`

Depending on your image, you can either:

- Build a custom image with these in a `requirements.txt`, or
- Use an environment variable like `_PIP_ADDITIONAL_REQUIREMENTS` to install
  them at container startup.

### 5.3 Starting Airflow and triggering the DAG

1. From the directory containing your Airflow `docker-compose.yaml`, run:

   ```bash
   docker compose up
   ```

2. When the webserver is healthy, open:

   ```text
   http://localhost:8080
   ```

3. Log in with your configured credentials.
4. In the DAGs list, locate **`customer_segmentation_lab1`**.
5. Unpause/enable the DAG if it is paused.
6. Trigger a run using the UI and monitor the tasks in Graph or Grid view.

You can click on each task to inspect logs. The evaluation step will print the
elbow-based `k` suggestion and the predicted cluster for the test sample.

---

## 6. Extending the Lab

To customize this lab further, you could:

- Add more features to the clustering data (e.g., transaction frequencies,
  payment behavior).
- Implement additional preprocessing such as outlier removal or feature scaling
  per group.
- Save per-customer cluster assignments to a new CSV for downstream analysis.
- Introduce configuration via Airflow `Variables` or external config files so
  things like `k_values` or feature lists can be changed without modifying code.

These changes can be implemented incrementally while reusing the same DAG
structure and overall workflow.


