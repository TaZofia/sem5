#include "read_file.hpp"
#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <sstream>


char FileReader::is_directed() {
  std::ifstream file(filename);
  if (!file.is_open()) {
      std::cerr << "Can't open file: " << filename << std::endl;
      return '\0';
  }

  char c;
  if (file.get(c)) {
    if (c != 'U' && c != 'D') {
      std::cerr << "Wrong letter. Should be U/D" << std::endl;
      return '\0';
    }
    return c;
  } else {
    return '\0';
  }
}
int FileReader::number_of_vertices() {
  std::ifstream file(filename);
  if (!file.is_open()) {
    std::cerr << "Can't open file: " << filename << std::endl;
    return '\0';
  }
  std::string line;
  std::getline(file, line);		// skip first line

  std::string line2;
  std::getline(file, line2);

  try {
    int x = stoi(line2);
    return x;
  } catch (const std::invalid_argument&) {
    std::cout << "Invalid argument" << std::endl;
    return -1;
  } catch (const std::out_of_range&) {
    std::cout << "Out of range" << std::endl;
    return -1;
  }
}
int FileReader::number_of_edges() {
  std::ifstream file(filename);
  if (!file.is_open()) {
    std::cerr << "Can't open file: " << filename << std::endl;
    return '\0';
  }
  std::string line;
  std::getline(file, line);		// skip first line
  std::string line2;
  std::getline(file, line2);

  std::string line3;
  std::getline(file, line3);

  try {
    int x = stoi(line3);
    return x;
  } catch (const std::invalid_argument&) {
    std::cout << "Invalid argument" << std::endl;
    return -1;
  } catch (const std::out_of_range&) {
    std::cout << "Out of range" << std::endl;
    return -1;
  }
}

std::vector<std::pair<int, int>> FileReader::get_edges() {
  std::ifstream file(filename);
  std::string line;
  std::getline(file, line);
  std::getline(file, line);
  std::getline(file, line);	// skip first 3 lines

  std::vector<std::pair<int, int>> graph;

  while (std::getline(file, line)) {
    std::istringstream ss(line);
    std::pair<int, int> edge;

    std::string vertex1;
    std::string vertex2;

    ss >> vertex1 >> vertex2;

    int int_vertex1 = stoi(vertex1);
    int int_vertex2 = stoi(vertex2);

    edge.first = int_vertex1;
    edge.second = int_vertex2;

    graph.push_back(edge);
  }
  return graph;
}
