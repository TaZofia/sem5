#include <fstream>
#include "draw_graph.hpp"

// make a simple .dot file so graphiz could draw a graph

void draw_graph(const std::vector<Node>& vertices, std::string graph_filename, std::string algorithm_name) {

  std::string filename = ".\\dot_files\\";

  // Delete path
  size_t last_slash = graph_filename.find_last_of("\\/");
  std::string name = (last_slash == std::string::npos) ? graph_filename : graph_filename.substr(last_slash + 1);

  // Delete extension
  size_t last_dot = name.find_last_of('.');
  std::string name_without_ext = (last_dot == std::string::npos) ? name : name.substr(0, last_dot);


  filename = filename + algorithm_name + "_" + name_without_ext + ".dot";

  std::ofstream file(filename);
  file << "digraph " << name_without_ext << "{\n";

  for (const auto& v : vertices) {
    if (v.parent != nullptr) {
      file << v.value << " -> " << v.parent->value << "\n";
    }
  }

  file << "}\n";
  file.close();
}