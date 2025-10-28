#include <iostream>
#include <string>
#include ".\\..\\read_file.hpp"
#include "scc.hpp"
#include <unordered_map>



// g++ .\..\read_file.cpp .\..\get_graph.cpp .\..\zad2\topological_sort.cpp scc.cpp main.cpp -o main.exe

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

	  std::vector<std::vector<Node*>> scc = strongly_connected_components(edges, num_of_v, directed);

    std::cout << filename << std::endl;
    std::cout << "Number of strongly connected components: " << scc.size() << std::endl;

    std::string output = "";

    if(num_of_v <= 200) {
      for(std::vector<Node*> vertices_in_one_scc : scc) {
        output += "Size of component: " + std::to_string(vertices_in_one_scc.size()) + ", Elements: [";
        for(Node* element : vertices_in_one_scc) {
          output += std::to_string(element->value) + ", ";
        }
        output.erase(output.size() - 2);
        output += "]\n";
      }
    } else {
      for(std::vector<Node*> vertices_in_one_scc : scc) {
        output += "Size: " + std::to_string(vertices_in_one_scc.size()) + "\n";
      }
    }

    std::cout << output << std::endl;
    return 0;
}