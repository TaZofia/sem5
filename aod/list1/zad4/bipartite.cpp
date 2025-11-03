#include "bipartite.hpp"
#include <queue>

bool is_bipartite(int num_of_vertices, std::vector<Node>& all_vertices, std::vector<int>& V0, std::vector<int>& V1) {

  std::vector<int> colour (num_of_vertices, -1);
  for (int start = 0; start < num_of_vertices; start++) {
    if (colour[start] != -1) continue;

    std::queue<int> q;
    q.push(start);
    colour[start] = 0;

    while (!q.empty()) {
      int current_index = q.front();
      q.pop();

      Node& curr_node = all_vertices[current_index];
      std::vector<int> adj_vertex_index;

      for(const auto& adj_vertex : curr_node.adj_edges) {
        int adj_vertex_value = adj_vertex.second;
        adj_vertex_index.push_back(adj_vertex_value - 1);
      }

      for (int x : adj_vertex_index) {
        if (colour[x] == -1) {
          q.push(x);
          if (colour[current_index] == 1) {
            colour[x] = 0;
          } else {
            colour[x] = 1;
          }
        } else {
          if (colour[x] == colour[current_index]) {
            return false;
          }
        }
      }
    }
  }
  if(num_of_vertices <= 200) {
    V0.clear();
    V1.clear();
    for(int i = 0; i < num_of_vertices; i++) {
      if(colour[i] == 0) V0.push_back(i+1);
      else V1.push_back(i+1);
    }
  }
  return true;
}