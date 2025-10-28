#include <iostream>
#include <string>
#include ".\\..\\read_file.hpp"
#include ".\\bipartite.hpp"


// g++ .\..\read_file.cpp .\..\get_graph.cpp .\bipartite.cpp main.cpp -o main.exe

int main(int argc, char * argv[]) {

  if(argc != 2){
    std::cout << "[ERROR] Wrong number of arguments\n" << std::endl;
    return -1;
  }

  std::string filename = argv[1];

  FileReader reader(filename);

  bool directed = false;
  if (reader.is_directed() == 'U') {
    directed = false;
  } else if (reader.is_directed() == 'D') {
    directed = true;
  }
  int num_of_v = reader.number_of_vertices();

  std::vector<std::pair<int, int>> edges = reader.get_edges();
  std::vector<Node> all_vertices = get_vertices(edges, num_of_v, directed);

  std::vector<int> V0, V1;

  bool is_graph_bipartite = false;
  is_graph_bipartite = is_bipartite(num_of_v, all_vertices, V0, V1);

  std::cout << filename << std::endl;
  if (is_graph_bipartite) {
    std::cout << "YES" << std::endl;
    if(num_of_v <= 200) {
      std::cout << "V0: ";
      for(int v : V0) std::cout << v << " ";
      std::cout << std::endl;

      std::cout << "V1: ";
      for(int v : V1) std::cout << v << " ";
      std::cout << std::endl;
    }
  } else {
    std::cout << "NO" << std::endl;
  }
  std::cout << std::endl;
  return 0;
}