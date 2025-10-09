#include <iostream>
#include <string>
#include ".\\..\\read_file.hpp"
#include ".\\..\\zad2\\topological_sort.hpp"
#include "modified_dfs.hpp"
#include <unordered_map>


// g++ .\..\read_file.cpp .\..\get_graph.cpp .\..\zad2\topological_sort.cpp modified_dfs.cpp main.cpp -o main.exe

std::vector<std::pair<int, int>> get_graph_with_reversed_edges(std::vector<std::pair<int, int>> edges) {
  for (auto& temp : edges) {

    int first = temp.first;
    int second = temp.second;

    temp.first = second;    // swap
    temp.second = first;
  }
  return edges;
}



int main() {

    std::string filename = "K:\\studia\\sem5\\aod\\list1\\aod_testy1\\3\\g3-6.txt";

    FileReader reader(filename);

    bool directed = false;
    if (reader.is_directed() == 'U') {
        directed = false;
    } else if (reader.is_directed() == 'D') {
        directed = true;
    }
    int num_of_v = reader.number_of_vertices();

    std::vector<std::pair<int, int>> edges = reader.get_edges();
    std::vector<Node> graph = get_vertices(edges, num_of_v, directed);

    std::unordered_map<int, Node*> node_map;

    std::vector<std::pair<int, int>> reversed_edges = get_graph_with_reversed_edges(edges);
    std::vector<Node> reversed_graph = get_vertices(reversed_edges, num_of_v, directed);


	for (Node& node : reversed_graph) {
    	node_map[node.value] = &node;
	}


    bool back_edges = false;    // in this program useless
    std::vector<Node*> list_topological_order = topological_sort(graph, back_edges);

	std::vector<std::vector<Node*>> scc = mod_dfs(list_topological_order, reversed_graph, node_map);

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