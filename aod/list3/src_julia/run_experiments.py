import os
import subprocess
import random

def random4n_simulation():

    single_source = "single_source_smallest_value.ss"

    input_dir = "./../ch9-1.1/inputs/Random4-n"
    random_sources_dir = "./../five_random_vertices/Random4-n"

    # Lista algorytmów do uruchomienia
    algorithms = ["dijkstra", "dial", "radixheap"]

    print("Random4-n")
    for filename in os.listdir(input_dir):
        if filename.endswith(".gr"):
            graph_path = os.path.join(input_dir, filename)
            print(f"==> Testing file: {graph_path}")

            splitted_filename = filename.split('.')
            i = splitted_filename[1]

            n = 2**int(i)        # liczba wierzchołków

            random_numbers = []     
            for _ in range(5):
                num = random.randint(1, n)
                random_numbers.append(num)

            random_src_filename = filename.replace(".gr", ".ss")  
            random_src_path = os.path.join(random_sources_dir, random_src_filename)

            with open(random_src_path, "w") as f:
                f.write("p aux sp ss {}\n".format(len(random_numbers)))
                for num in random_numbers:
                    f.write("s {}\n".format(num))
            print("Created: ", random_src_path)

            without_format = filename.replace(".gr", "")

            for algo in algorithms:
                
                cmd = ["julia", "main.jl", algo, "-d", graph_path, "-ss", single_source, "-oss", f"{algo}_single_src_{without_format}.ss.res"]
                print(f"Run: {' '.join(cmd)}")
                subprocess.run(cmd)

                cmd2 = ["julia", "main.jl", algo, "-d", graph_path, "-ss", random_src_path, "-oss", f"{algo}_random_src_{without_format}.ss.res"]
                print(f"Run: {' '.join(cmd2)}")
                subprocess.run(cmd2)
        
random4n_simulation()

#################

def random4C_simulation():

    single_source = "single_source_smallest_value.ss"

    input_dir = "./../ch9-1.1/inputs/Random4-C"
    random_sources_dir = "./../five_random_vertices/Random4-C"

    # Lista algorytmów do uruchomienia
    algorithms = ["dijkstra", "dial", "radixheap"]

    n = 2**20
    random_numbers = []     
    for _ in range(5):
        num = random.randint(1, n)
        random_numbers.append(num)

    random_src_path = os.path.join(random_sources_dir, "Random4-C.ss")

    with open(random_src_path, "w") as f:
        f.write("p aux sp ss {}\n".format(len(random_numbers)))
        for num in random_numbers:
            f.write("s {}\n".format(num))
    print("Created: ", random_src_path)


    print("Random4-C")
    for filename in os.listdir(input_dir):
        if filename.endswith(".gr"):
            graph_path = os.path.join(input_dir, filename)
            print(f"==> Testing file: {graph_path}")

    
            without_format = filename.replace(".gr", "")

            for algo in algorithms:
                
                cmd = ["julia", "main.jl", algo, "-d", graph_path, "-ss", single_source, "-oss", f"{algo}_single_src_{without_format}.ss.res"]
                print(f"Run: {' '.join(cmd)}")
                subprocess.run(cmd)

                cmd2 = ["julia", "main.jl", algo, "-d", graph_path, "-ss", random_src_path, "-oss", f"{algo}_random_src_{without_format}.ss.res"]
                print(f"Run: {' '.join(cmd2)}")
                subprocess.run(cmd2)

random4C_simulation()