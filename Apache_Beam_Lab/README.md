# Apache Beam Text Analysis Pipeline

This lab demonstrates an enhanced text analysis pipeline using Apache Beam. It extends the basic word count example with advanced features for comprehensive text analysis.

## Features

### 1. Case-Insensitive Word Counting
- All words are normalized to lowercase for accurate frequency analysis
- Prevents duplicate counts for words with different capitalizations

### 2. Stop Word Filtering
- Removes common English stop words (the, a, an, and, or, etc.)
- Filters out words shorter than 3 characters
- Focuses analysis on meaningful content words

### 3. Word Length Analysis
- Calculates distribution of word lengths in the text
- Provides insights into vocabulary complexity
- Outputs frequency of each word length

### 4. Top N Word Extraction
- Identifies the most frequent meaningful words
- Uses Apache Beam's Top combiners for efficient sorting
- Default: Top 50 words (configurable)

### 5. Character Frequency Analysis
- Analyzes letter frequency in the text
- Useful for linguistic analysis and text processing
- Case-insensitive character counting

## Output Files

The pipeline generates four output files:

1. **word_counts-*.txt**: All meaningful words with their frequencies (excluding stop words)
2. **word_lengths-*.txt**: Distribution of word lengths
3. **top_words-*.txt**: Top 50 most frequent meaningful words
4. **char_frequency-*.txt**: Frequency of each letter in the text

## Differences from Original Lab

1. **Enhanced Processing**: Multiple analysis pipelines instead of simple word count
2. **Stop Word Removal**: Filters out common words for better insights
3. **Case Normalization**: All analysis is case-insensitive
4. **Multiple Outputs**: Generates multiple analysis files
5. **Word Length Statistics**: Additional dimension of analysis
6. **Character Analysis**: Extended analysis beyond word-level
7. **Better Formatting**: Improved output format with descriptive labels
8. **Standalone Script**: Includes `run_pipeline.py` for easy execution

## Requirements

- Python 3.7+
- Apache Beam (install via `pip install apache-beam` or use `requirements.txt`)

## Installation

```bash
pip install -r requirements.txt
```

## Usage

### Option 1: Run the Python Script (Recommended)
```bash
python run_pipeline.py
```

### Option 2: Run the Jupyter Notebook
1. Open `Enhanced_Text_Analysis_Pipeline.ipynb` in Jupyter
2. Run all cells sequentially
3. Check the `outputs/` directory for results

## Example Output

```
======================================================================
TOP 30 MOST FREQUENT MEANINGFUL WORDS:
======================================================================
king: 311
lear: 253
thou: 219
kent: 175
gloucester: 167
...

======================================================================
WORD LENGTH DISTRIBUTION (first 20):
======================================================================
Length 4: 7181 words
Length 3: 5777 words
Length 6: 2375 words
...

======================================================================
CHARACTER FREQUENCY ANALYSIS (A-Z):
======================================================================
e: 14398
t: 10433
o: 9460
a: 8790
...
```

## Project Structure

```
Apache_Beam_Lab/
├── Enhanced_Text_Analysis_Pipeline.ipynb  # Main notebook
├── run_pipeline.py                         # Executable script
├── requirements.txt                       # Python dependencies
├── README.md                              # This file
├── data/
│   └── kinglear.txt                       # Input text file
└── outputs/                                # Generated output files
    ├── word_counts-*.txt
    ├── word_lengths-*.txt
    ├── top_words-*.txt
    └── char_frequency-*.txt
```

## Notes

- The pipeline uses DirectRunner for local execution
- Results are written to multiple output files for different analyses
- All transformations are performed in parallel where possible
- The pipeline is designed to be easily extensible for additional analyses
- Input file path is set to `data/kinglear.txt` (modify in script if using different file)
