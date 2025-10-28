#include "topological_sort.hpp"
#include <iostream>
#include <string>
#include ".\\..\\read_file.hpp"

//g++ .\..\read_file.cpp .\..\get_graph.cpp topological_sort.cpp main.cpp -o main.exe

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

  bool back_edges = false;

  int num_of_v = reader.number_of_vertices();

  std::vector<Node> all_vertices = get_vertices(reader.get_edges(), num_of_v, directed);

  std::vector<Node*> list_topological_order = topological_sort(all_vertices, back_edges);

  std::string output = "";

  std::cout << filename << std::endl;
  std::cout << "Does this graph include directed cycle?" << std::endl;

  if(back_edges) {
    output = "YES";
  }
  else {
    output = "NO\n";
    if(num_of_v <= 200) {
      for(Node* node : list_topological_order) {
        output += std::to_string(node->value) + " -> ";
      }
      output.erase(output.size() - 4);
    }
  }
  std::cout << output << std::endl << std::endl;
  return 0;
}