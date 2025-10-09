#include "topological_sort.hpp"
#include <iostream>
#include <string>
#include ".\\..\\read_file.hpp"

int main() {

  std::string filename = "K:\\studia\\sem5\\aod\\list1\\aod_testy1\\2\\g2b-6.txt";

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

  std::cout << "Does graph include directed cycle?" << std::endl;

  if(back_edges) {
    output = "YES";
  }
  if(!back_edges) {
    output = "NO";
    std::cout << output << std::endl;
    if(num_of_v <= 200) {
      output = "";
      for(Node* node : list_topological_order) {
        output += std::to_string(node->value) + " -> ";
      }
      output.erase(output.size() - 4);
      std::cout << output << std::endl;
    }
  }
  return 0;
}