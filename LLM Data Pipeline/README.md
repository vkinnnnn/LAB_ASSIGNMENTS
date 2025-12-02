# LLM Data Pipeline - Lab 2

## Overview

This project implements an **Enhanced Streaming Language Modeling Data Pipeline** using Hugging Face Datasets. The lab demonstrates how to build a true streaming language model pipeline that processes large-scale text corpora efficiently without loading the entire dataset into memory.

### Project Objectives

- Demonstrate streaming data processing for language modeling
- Process data without loading the entire dataset into RAM
- Tokenize text on-the-fly using transformer models
- Concatenate and chunk text into fixed-length blocks for training
- Produce batches ready for PyTorch training
- Monitor memory usage and analyze data characteristics

## Key Features & Enhancements

This implementation includes several enhancements over the original lab:

### 1. **Different Dataset**
- **Original**: WikiText-2 (smaller dataset)
- **Enhanced**: WikiText-103 (larger, more diverse content)
- Provides more training data while maintaining compatibility

### 2. **Different Model**
- **Original**: GPT-2 tokenizer
- **Enhanced**: DistilGPT-2 tokenizer
- Faster processing with smaller model size while maintaining good performance
- Vocabulary size: 50,257 tokens

### 3. **Larger Block Size**
- **Original**: 128 tokens per block
- **Enhanced**: 256 tokens per block
- Allows models to see longer sequences for better context understanding

### 4. **Larger Batch Size**
- **Original**: Batch size of 8
- **Enhanced**: Batch size of 16
- More efficient training with larger batches

### 5. **Enhanced Monitoring & Analysis**
- **Memory Usage Tracking**: Monitors RAM consumption throughout processing
- **Dataset Statistics**: Analyzes sample texts and average lengths
- **Token Frequency Analysis**: Identifies most common tokens in batches
- **Batch Statistics**: Tracks total tokens processed and batch metrics

## Installation

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Dependencies

Install all required packages using the provided requirements file:

```bash
pip install -r requirements.txt
```

### Required Packages

- `datasets>=2.0.0` - Hugging Face datasets library
- `transformers>=4.20.0` - Hugging Face transformers library
- `torch>=1.12.0` - PyTorch deep learning framework
- `psutil>=5.8.0` - System and process utilities for memory tracking

### Manual Installation

If you prefer to install packages individually:

```bash
pip install datasets transformers torch psutil
```

## Usage

### Running the Notebook

1. **Open Jupyter Notebook or JupyterLab**:
   ```bash
   jupyter notebook
   # or
   jupyter lab
   ```

2. **Navigate to the project folder** and open `Lab2.ipynb`

3. **Run all cells** sequentially:
   - Use `Cell > Run All` from the menu
   - Or run cells individually with `Shift + Enter`

### Expected Outputs

The notebook will demonstrate:

1. **Dataset Loading**: Streaming WikiText-103 dataset
2. **Dataset Analysis**: Sample texts and statistics
3. **Tokenizer Initialization**: DistilGPT-2 tokenizer setup
4. **Memory Tracking**: Initial memory usage after tokenizer load
5. **Tokenization**: On-the-fly tokenization of streaming data
6. **Batch Processing**: 
   - Batch shapes: `torch.Size([16, 256])`
   - Total tokens processed: 20,480+ tokens
   - Memory usage tracking
7. **Validation**: 
   - Data type verification
   - Token ID range validation
   - Top 10 most frequent tokens analysis

### Sample Output

```
Sample streaming batches:
Testing with 5 batches (batch_size=16, block_size=256)...
Batch 0 -> input_ids shape: torch.Size([16, 256])
         -> Total tokens: 4096
         -> attention_mask shape: torch.Size([16, 256])
         -> labels shape: torch.Size([16, 256])

Batch Statistics:
  Average batch size: 16.0
  Total tokens processed: 20,480
  Memory usage after processing: 537.17 MB
  Memory increase: 77.39 MB
```

## File Structure

```
LLM Data Pipeline/
├── README.md                 # This file - project documentation
├── Lab2.ipynb               # Main notebook with code
├── Lab2_executed.ipynb      # Executed notebook with results
└── requirements.txt         # Python dependencies
```

### File Descriptions

- **`Lab2.ipynb`**: Main Jupyter notebook containing all code cells
  - 14 cells total
  - Includes dataset loading, tokenization, batching, and analysis
  
- **`Lab2_executed.ipynb`**: Pre-executed version showing results
  - Contains all outputs from running the notebook
  - Useful for reference without re-running
  
- **`requirements.txt`**: List of Python package dependencies
  - Specifies minimum versions for compatibility

## Technical Details

### Streaming Data Processing

The pipeline uses **true streaming** to process data:

- **IterableDataset**: Data is loaded as an iterator, not loaded entirely into memory
- **Lazy Evaluation**: Tokenization and processing happen on-demand
- **Memory Efficient**: Only processes what's needed, when needed

### Tokenization Approach

1. **Raw Token Sequences**: No padding or truncation during initial tokenization
2. **Flexible Concatenation**: Tokens can be concatenated across documents
3. **Fixed-Length Chunking**: Rolling buffer creates consistent 256-token blocks

### Block Size & Batch Configuration

- **Block Size**: 256 tokens
  - Provides longer context windows
  - Better for understanding longer dependencies
  
- **Batch Size**: 16 samples
  - More efficient GPU/CPU utilization
  - Better gradient estimates during training

### Memory Efficiency Features

- **Streaming Mode**: Dataset never fully loaded into RAM
- **Memory Tracking**: Monitors usage at key stages
- **Efficient Buffering**: Rolling buffer minimizes memory overhead

### Architecture Components

1. **StreamingLMIterableDataset**: Custom PyTorch IterableDataset wrapper
2. **Rolling Buffer**: Maintains leftover tokens between chunks
3. **Collate Function**: Converts batches to PyTorch tensors
4. **DataLoader**: Manages batch creation and iteration

## Results

### Performance Metrics

- **Processing Speed**: Efficient streaming without memory bottlenecks
- **Memory Usage**: 
  - Initial: ~460 MB (after tokenizer load)
  - After 5 batches: ~537 MB
  - Increase: ~77 MB (minimal for large-scale processing)
  
- **Batch Statistics**:
  - Average batch size: 16.0
  - Total tokens per batch: 4,096 tokens
  - Sequence length: 256 tokens

### Validation Results

All validation tests pass successfully:

- ✅ Input IDs and labels have matching shapes
- ✅ Sequence length matches block size (256)
- ✅ All token IDs are valid (≥ 0)
- ✅ Token IDs within vocabulary range (< 50,257)
- ✅ Data types correct (torch.int64)
- ✅ Token frequency analysis completed

### Token Analysis

The pipeline includes token frequency analysis showing:
- Most common token IDs in sample batches
- Decoded token representations
- Occurrence counts

## Key Differences from Original

| Feature | Original Lab | Enhanced Lab |
|---------|-------------|--------------|
| **Dataset** | WikiText-2 | WikiText-103 |
| **Tokenizer** | GPT-2 | DistilGPT-2 |
| **Block Size** | 128 tokens | 256 tokens |
| **Batch Size** | 8 | 16 |
| **Memory Tracking** | ❌ | ✅ |
| **Dataset Analysis** | ❌ | ✅ |
| **Token Analysis** | ❌ | ✅ |
| **Statistics** | Basic | Enhanced |

## Technical Stack

- **Python**: Core programming language
- **Hugging Face Datasets**: Dataset loading and streaming
- **Hugging Face Transformers**: Tokenization and model access
- **PyTorch**: Deep learning framework and tensor operations
- **psutil**: System monitoring and memory tracking

## Notes

- The notebook is designed to work with streaming datasets, making it suitable for very large corpora
- Memory usage remains low even with large datasets due to streaming approach
- All enhancements maintain compatibility with the original pipeline structure
- The executed notebook (`Lab2_executed.ipynb`) can be used as a reference without re-running

## License

This project is part of a lab assignment and is for educational purposes.

## Author

Lab Assignment 6 - Enhanced LLM Data Pipeline Implementation

---

**Last Updated**: December 2025

