import os
import sys
import subprocess

def main():

    files_folders = {
        "zad1": ".\\aod_testy_moje\\1",
        "zad2": ".\\aod_testy1\\2",
        "zad3": ".\\aod_testy1\\3",
        "zad4": ".\\aod_testy1\\4"
    }

    executable_files = {
        "zad1": ".\\zad1\\main.exe",
        "zad2": ".\\zad2\\main.exe",
        "zad3": ".\\zad3\\main.exe",
        "zad4": ".\\zad4\\main.exe"
    }

    exercise = sys.argv[1]
    print_tree = False
    if exercise == "zad1" and len(sys.argv) > 2 and sys.argv[2] == "t":
        print_tree = True

    directory = files_folders[exercise]
    files = []

    for item in os.listdir(directory):
        path = os.path.join(directory, item)
        if os.path.isfile(path):
            files.append(path)

    executable = executable_files[exercise]

    for file in files:
        if exercise == "zad1" and print_tree == True:
            subprocess.run([executable, file, "t"])
        else:
            subprocess.run([executable, file])

if __name__ == "__main__":
    main()
