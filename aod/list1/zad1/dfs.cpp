#include <vector>
#include "dfs.hpp"
#include ".\\..\\enums.hpp"

void dfs_visit(std::vector<Node>& vertices, Node& u, std::string& order, int& time) {
  order += "(" + std::to_string(u.value) + ") ";
  u.color = Color::GRAY;
  time += 1;
  u.d_time = time;

  for (const auto& edge : u.adj_edges) {
    int adj_vertex_value = edge.second;
    Node& adj_vertex = vertices[adj_vertex_value - 1];

    if (adj_vertex.color == Color::WHITE) {
      adj_vertex.parent = &u;
      dfs_visit(vertices, adj_vertex, order, time);
    }
  }
  u.color = Color::BLACK;
  time += 1;
  u.f_time = time;
}

std::string dfs(std::vector<Node>& vertices) {
  std::string order = "";

  int time = 0;

  for (auto& u : vertices) {
    if (u.color == Color::WHITE) {
      dfs_visit(vertices, u, order, time);
    }
  }

  return order;
}


