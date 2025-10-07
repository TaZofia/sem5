#include <iostream>
#include ".\\..\\read_file.hpp"
#include ".\\..\\get_graph.hpp"
#include "bfs.hpp"
#include "dfs.hpp"

int main() {

  std::string filename = "K:\\studia\\sem5\\aod\\list1\\aod_testy_moje\\1\\g1a.txt";

  FileReader reader(filename);

  bool directed = false;
  if (reader.is_directed() == 'U') {
    directed = false;
  } else if (reader.is_directed() == 'D') {
    directed = true;
  }

  // all_vertices are actually our graph because they are nodes with adj_vertices (edges)
  std::vector<Node> all_vertices = get_vertices(reader.get_edges(), reader.number_of_vertices(), directed);

  Node& start = all_vertices[0];

  std::string bfs_order = bfs(all_vertices, start);
  std::cout << "---- BFS ----" << std::endl;
  std::cout << bfs_order << std::endl;

  for (auto& v : all_vertices) {
    v.color = Color::WHITE;
    v.parent = nullptr;
    v.d_time = -1;
    v.f_time = -1;
  }

  std::string dfs_order = dfs(all_vertices);
  std::cout << "---- DFS ----" << std::endl;
  std::cout << dfs_order << std::endl;

  return 0;
}