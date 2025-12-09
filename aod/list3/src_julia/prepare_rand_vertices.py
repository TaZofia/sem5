import os
import subprocess
import random


def prepare1():
    # Mapa: katalog wejściowy -> odpowiadający katalog w five_random_vertices
    mapping = {
        "./../ch9-1.1/inputs/Random4-n": "./../five_random_vertices/Random4-n",
        "./../ch9-1.1/inputs/Long-n":    "./../five_random_vertices/Long-n",
        "./../ch9-1.1/inputs/Square-n":  "./../five_random_vertices/Square-n",
    }

    for input_dir, random_sources_dir in mapping.items():
        # upewnij się, że katalog wynikowy istnieje
        os.makedirs(random_sources_dir, exist_ok=True)

        if not os.path.isdir(input_dir):
            print(f"Warning: input directory not found: {input_dir}")
            continue

        for filename in os.listdir(input_dir):
            if not filename.endswith(".gr"):
                continue

            splitted = filename.split('.')
            # zabezpieczenie na wypadek nietypowego formatu nazwy
            if len(splitted) < 2 or not splitted[1].isdigit():
                print(f"Skipping file with unexpected name format: {filename}")
                continue

            i = int(splitted[1])
            n = 2 ** i

            random_numbers = [random.randint(1, n) for _ in range(5)]

            random_src_filename = filename.replace(".gr", ".ss")
            random_src_path = os.path.join(random_sources_dir, random_src_filename)

            with open(random_src_path, "w") as f:
                f.write("p aux sp ss {}\n".format(len(random_numbers)))
                for num in random_numbers:
                    f.write("s {}\n".format(num))

            print("Created:", random_src_path)

prepare1()





