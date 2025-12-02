import os
import base64
import pickle
from typing import List, Dict, Any

import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from kneed import KneeLocator


# Resolve important directories relative to this file
_HERE = os.path.dirname(__file__)
_DATA_DIR = os.path.join(_HERE, "..", "data")
_MODEL_DIR = os.path.join(_HERE, "..", "model")
_OUTPUT_DIR = os.path.join(_HERE, "..", "output")


def extract_data() -> str:
    """
    Load the raw credit card data and return it as a base64-encoded pickle string.

    Differences from the reference lab:
    - Function name changed (extract_data vs load_data).
    - Drops duplicate CUST_ID entries if present (keeps the last one).
    """
    csv_path = os.path.join(_DATA_DIR, "file.csv")
    df = pd.read_csv(csv_path)

    # Custom twist: ensure each CUST_ID appears only once
    if "CUST_ID" in df.columns:
        df = df.drop_duplicates(subset=["CUST_ID"], keep="last")

    payload = pickle.dumps(df)
    return base64.b64encode(payload).decode("ascii")


def transform_data(serialized_df: str) -> str:
    """
    Decode the raw dataset, select a subset of numeric features, scale them
    using StandardScaler, and return a base64-encoded pickle payload.

    The payload is a dictionary with:
    - "scaled": 2D numpy array of standardized features
    - "feature_columns": list of feature names used
    """
    # Decode -> bytes -> DataFrame
    data_bytes = base64.b64decode(serialized_df.encode("ascii"))
    df = pickle.loads(data_bytes)

    feature_cols = ["BALANCE", "PURCHASES", "CREDIT_LIMIT"]
    features = df[feature_cols].dropna()

    scaler = StandardScaler()
    scaled = scaler.fit_transform(features)

    payload: Dict[str, Any] = {
        "scaled": scaled,
        "feature_columns": feature_cols,
    }

    serialized_payload = pickle.dumps(payload)
    return base64.b64encode(serialized_payload).decode("ascii")


def train_kmeans_model(serialized_payload: str, model_name: str) -> Dict[str, List[float]]:
    """
    Train a KMeans model on the transformed data and save it to disk.

    Differences from the reference lab:
    - Uses StandardScaler (already applied in transform_data).
    - Searches k in the range [2, 10] instead of [1, 50].
    - Returns a dictionary with both k_values and SSE values.
    """
    data_bytes = base64.b64decode(serialized_payload.encode("ascii"))
    payload = pickle.loads(data_bytes)
    X = payload["scaled"]

    k_values = list(range(2, 11))
    kmeans_params = {
        "init": "k-means++",
        "n_init": 10,
        "max_iter": 300,
        "random_state": 7,
    }

    sse: List[float] = []
    best_model = None

    for k in k_values:
        model = KMeans(n_clusters=k, **kmeans_params)
        model.fit(X)
        sse.append(model.inertia_)
        best_model = model

    os.makedirs(_MODEL_DIR, exist_ok=True)
    model_path = os.path.join(_MODEL_DIR, model_name)
    with open(model_path, "wb") as f:
        pickle.dump(best_model, f)

    # JSON-serializable structure for XCom
    return {"k_values": k_values, "sse": sse}


def evaluate_model(model_name: str, metrics: Dict[str, List[float]]) -> int:
    """
    Load the saved KMeans model, log the elbow-based suggested k,
    and return the first cluster prediction for the test sample.
    """
    model_path = os.path.join(_MODEL_DIR, model_name)
    with open(model_path, "rb") as f:
        model = pickle.load(f)

    k_values = metrics.get("k_values", [])
    sse = metrics.get("sse", [])

    if k_values and sse:
        kl = KneeLocator(k_values, sse, curve="convex", direction="decreasing")
        elbow_k = kl.elbow
        print(f"[evaluate_model] Suggested optimal k from elbow: {elbow_k}")
    else:
        elbow_k = None
        print("[evaluate_model] No metrics provided to compute elbow.")

    test_path = os.path.join(_DATA_DIR, "test.csv")
    test_df = pd.read_csv(test_path)

    # test.csv already matches the features expected by the model
    prediction = model.predict(test_df)[0]

    # Ensure XCom-friendly primitive
    if hasattr(prediction, "item"):
        prediction_value = prediction.item()
    else:
        try:
            prediction_value = int(prediction)
        except Exception:
            prediction_value = prediction

    # Also save the result to an output file for easy inspection outside Airflow
    os.makedirs(_OUTPUT_DIR, exist_ok=True)
    output_path = os.path.join(_OUTPUT_DIR, "result.txt")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("Customer Segmentation Lab 1 Result\n")
        f.write("---------------------------------\n")
        f.write(f"Predicted cluster for first test row: {prediction_value}\n")
        if elbow_k is not None:
            f.write(f"Elbow-based suggested k: {elbow_k}\n")
        else:
            f.write("Elbow-based suggested k: N/A (insufficient metrics)\n")

    return prediction_value


