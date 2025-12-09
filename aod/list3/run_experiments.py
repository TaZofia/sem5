import os
import subprocess
import random

input_dir = "ch9-1.1/inputs/Random4-C"

# Lista algorytmów do uruchomienia
algorithms = ["dijkstra", "dial", "radixheap"]

for filename in os.listdir(input_dir):
    if filename.endswith(".gr"):
        graph_path = os.path.join(input_dir, filename)
        print(f"==> Testing file: {graph_path}")

        splitted_filename = filename.split('.')
        i = splitted_filename[1]

        n = 2^i         # number of vertices

        random_numbers = []
        for _ in range(5):
            num = random.randint(1, n)
            random_numbers.append(num)

        """
        for algo in algorithms:
            cmd = ["julia", "main.jl", algo, "-d", graph_path]
            print(f"Run: {' '.join(cmd)}")
            subprocess.run(cmd)
        """