"""
Apache Beam Text Analysis Pipeline - Executable Script
This script runs the enhanced text analysis pipeline and displays results.
"""

import apache_beam as beam
import re
import os
import glob

# Configuration
# Use specific file path for Windows compatibility
inputs_pattern = 'data/kinglear.txt'
outputs_prefix = 'outputs/word_counts'
word_length_output = 'outputs/word_lengths'
top_words_output = 'outputs/top_words'
char_output = 'outputs/char_frequency'

# Ensure output directory exists
os.makedirs('outputs', exist_ok=True)

# Define common stop words to filter out
STOP_WORDS = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 
              'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'been',
              'be', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
              'could', 'should', 'may', 'might', 'must', 'can', 'this', 'that',
              'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they',
              'his', 'her', 'its', 'our', 'their', 'my', 'your', 'me', 'him',
              'us', 'them', 'what', 'which', 'who', 'whom', 'whose', 'where',
              'when', 'why', 'how', 'all', 'each', 'every', 'both', 'few',
              'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not',
              'only', 'own', 'same', 'so', 'than', 'too', 'very', 's', 't',
              'can', 'will', 'just', 'don', 'should', 'now'}

print("=" * 70)
print("APACHE BEAM TEXT ANALYSIS PIPELINE")
print("=" * 70)
print("\nStarting pipeline execution...\n")

# Running locally in the DirectRunner.
with beam.Pipeline() as pipeline:
    # Step 1: Read and extract words (case-insensitive)
    words = (
        pipeline
        | 'Read lines' >> beam.io.ReadFromText(inputs_pattern)
        | 'Extract words' >> beam.FlatMap(
            lambda line: re.findall(r"[a-zA-Z']+", line.lower())
        )
        | 'Filter empty' >> beam.Filter(lambda word: len(word) > 0)
    )
    
    # Step 2: Count words (case-insensitive)
    word_counts = (
        words
        | 'Pair with count' >> beam.Map(lambda word: (word, 1))
        | 'Sum counts' >> beam.CombinePerKey(sum)
    )
    
    # Step 3: Filter out stop words and short words
    meaningful_words = (
        word_counts
        | 'Filter stop words' >> beam.Filter(
            lambda word_count: word_count[0] not in STOP_WORDS and len(word_count[0]) > 2
        )
    )
    
    # Step 4: Calculate word length statistics
    word_lengths = (
        words
        | 'Get word lengths' >> beam.Map(lambda word: len(word))
        | 'Pair length with count' >> beam.Map(lambda length: (length, 1))
        | 'Count by length' >> beam.CombinePerKey(sum)
    )
    
    # Step 5: Get top 50 most frequent meaningful words
    top_words = (
        meaningful_words
        | 'Sort by count' >> beam.combiners.Top.Of(50, key=lambda x: x[1])
        | 'Flatten top list' >> beam.FlatMap(lambda x: x)
    )
    
    # Write outputs
    (
        meaningful_words
        | 'Format word counts' >> beam.Map(
            lambda word_count: f"{word_count[0]}: {word_count[1]}"
        )
        | 'Write word counts' >> beam.io.WriteToText(outputs_prefix)
    )
    
    (
        word_lengths
        | 'Format lengths' >> beam.Map(
            lambda length_count: f"Length {length_count[0]}: {length_count[1]} words"
        )
        | 'Write lengths' >> beam.io.WriteToText(word_length_output)
    )
    
    (
        top_words
        | 'Format top words' >> beam.Map(
            lambda word_count: f"{word_count[0]}: {word_count[1]}"
        )
        | 'Write top words' >> beam.io.WriteToText(top_words_output)
    )

print("Pipeline execution completed!\n")

# Display results from output files
def read_output_file(pattern, max_lines=30):
    """Read and display output file contents."""
    files = glob.glob(f"{pattern}-*-of-*")
    if not files:
        files = glob.glob(f"{pattern}-*")
    
    if files:
        with open(files[0], 'r', encoding='utf-8') as f:
            lines = f.readlines()[:max_lines]
            for line in lines:
                print(line.strip())
    else:
        print(f"No output file found matching: {pattern}")

# Display Top Words
print("=" * 70)
print("TOP 30 MOST FREQUENT MEANINGFUL WORDS:")
print("=" * 70)
read_output_file(top_words_output, 30)

# Display Word Length Distribution
print("\n" + "=" * 70)
print("WORD LENGTH DISTRIBUTION (first 20):")
print("=" * 70)
read_output_file(word_length_output, 20)

# Character frequency analysis
print("\n" + "=" * 70)
print("RUNNING CHARACTER FREQUENCY ANALYSIS...")
print("=" * 70)

with beam.Pipeline() as pipeline:
    char_freq = (
        pipeline
        | 'Read lines for chars' >> beam.io.ReadFromText(inputs_pattern)
        | 'Extract characters' >> beam.FlatMap(
            lambda line: [char.lower() for char in line if char.isalpha()]
        )
        | 'Pair char with count' >> beam.Map(lambda char: (char, 1))
        | 'Sum char counts' >> beam.CombinePerKey(sum)
        | 'Format char frequency' >> beam.Map(
            lambda char_count: f"{char_count[0]}: {char_count[1]}"
        )
        | 'Write char frequency' >> beam.io.WriteToText(char_output)
    )

print("Character frequency analysis completed!\n")

# Display Character Frequency
print("=" * 70)
print("CHARACTER FREQUENCY ANALYSIS (A-Z):")
print("=" * 70)
read_output_file(char_output, 26)

print("\n" + "=" * 70)
print("PIPELINE EXECUTION SUCCESSFUL!")
print("=" * 70)
print("\nOutput files created in 'outputs/' directory:")
print(f"  - {outputs_prefix}-*.txt")
print(f"  - {word_length_output}-*.txt")
print(f"  - {top_words_output}-*.txt")
print(f"  - {char_output}-*.txt")


