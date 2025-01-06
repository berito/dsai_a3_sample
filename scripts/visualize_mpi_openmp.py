import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

# Define paths for data files
data_dir = "data"
mpi_file = os.path.join(data_dir, "data_strong_scaling_mpi_only.csv")
hybrid_file = os.path.join(data_dir, "data_strong_scaling_hybrid.csv")

# Load data from CSV files
mpi_data = pd.read_csv(mpi_file)
hybrid_data = pd.read_csv(hybrid_file)

# Filter data to include only processes 2, 4, and 8
filtered_mpi_data = mpi_data[mpi_data['process'].isin([2, 4, 8])]
filtered_hybrid_data = hybrid_data[hybrid_data['process'].isin([2, 4, 8])]

# Extract unique threads in hybrid data
threads_hybrid = sorted(filtered_hybrid_data['threads'].unique())

# Create subplots
fig, axes = plt.subplots(1, 2, figsize=(14, 6), sharey=True)

# Define bar width and colors
bar_width = 0.2
colors = ['skyblue', 'orange', 'green', 'purple']

# Plot MPI-only data
x_mpi = np.arange(len(filtered_mpi_data))
axes[0].bar(x_mpi, filtered_mpi_data['gflops'], color='skyblue', width=bar_width, label="MPI-Only")
axes[0].set_title("MPI-Only Performance")
axes[0].set_xlabel("MPI Processes")
axes[0].set_ylabel("GFlops")
axes[0].set_xticks(x_mpi)
axes[0].set_xticklabels(filtered_mpi_data['process'])
axes[0].grid(axis='y', linestyle='--', alpha=0.7)

# Add values on top of bars for MPI-only
for i, gflops in enumerate(filtered_mpi_data['gflops']):
    axes[0].text(x_mpi[i], gflops, f"{gflops:.2f}", ha='center', va='bottom')

# Plot Hybrid data
x_hybrid = np.arange(len(filtered_hybrid_data['process'].unique()))  # Base x positions
for i, thread in enumerate(threads_hybrid):
    thread_data = filtered_hybrid_data[filtered_hybrid_data['threads'] == thread]
    bar_positions = x_hybrid + i * bar_width
    axes[1].bar(bar_positions, thread_data['gflops'], color=colors[i % len(colors)], width=bar_width,
                label=f"{thread} Threads")
    # Add values on top of bars
    for j, gflops in enumerate(thread_data['gflops']):
        axes[1].text(bar_positions[j], gflops, f"{gflops:.2f}", ha='center', va='bottom')

axes[1].set_title("Hybrid MPI+OpenMP Performance")
axes[1].set_xlabel("MPI Processes")
axes[1].set_xticks(x_hybrid + (len(threads_hybrid) - 1) * bar_width / 2)
axes[1].set_xticklabels(thread_data['process'].unique())
axes[1].grid(axis='y', linestyle='--', alpha=0.7)
axes[1].legend(title="Threads")

# Adjust layout and save the plot
plt.tight_layout()
output_dir = "figures"
output_file = os.path.join(output_dir, "mpi_mp_gflops_comparison.png")
plt.savefig(output_file)

print(f"Bar graph with threads saved to {output_file}")
