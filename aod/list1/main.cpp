#include <iostream>
#include <string>
#include "get_graph.hpp"
#include "read_file.hpp"

int main() {
  std::string filename = "K:\\studia\\sem5\\aod\\list1\\aod_testy_moje\\1\\g1a.txt";

  FileReader reader(filename);

  reader.is_directed();
  reader.number_of_vertices();
  reader.number_of_edges();
  reader.get_edges();

  std::cout << "//////////////////////////////////////////////" << std::endl;

  bool directed = false;
  if (reader.is_directed() == 'U') {
    directed = false;
  } else if (reader.is_directed() == 'D') {
    directed = true;
  }

  std::vector<Node> all_vertices = get_vertices(reader.get_edges(), reader.number_of_vertices(), directed);

  for (Node vertex : all_vertices) {
    std::cout << "value: " << vertex.value << "  adj_edges: " << std::endl;
    for (auto& e : vertex.adj_edges) {
      std::cout << e.first << " " << e.second << std::endl;
    }
  }

  return 0;
}

