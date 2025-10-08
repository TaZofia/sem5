#include "topological_sort.hpp"
#include <algorithm>
#include <functional>
#include <string>

void modified_dfs_visit(std::vector<Node>& vertices, Node& u, int& time, bool& back_edges, std::vector<Node*>& order) {

  u.color = Color::GRAY;
  time += 1;
  u.d_time = time;

  for (auto& edge : u.adj_edges) {
    int adj_vertex_value = edge.second;
    Node& adj_vertex = vertices[adj_vertex_value - 1];

    if (adj_vertex.color == Color::WHITE) {
      adj_vertex.parent = &u;
      modified_dfs_visit(vertices, adj_vertex, time, back_edges, order);
    }
    if (adj_vertex.color == Color::GRAY) {
      back_edges = true;		// back edge is when program tries to reach a GRAY vertex
    }
  }
  u.color = Color::BLACK;
  time += 1;
  u.f_time = time;
  order.push_back(&u);
}

std::vector<Node*> modified_dfs(std::vector<Node>& vertices, bool& back_edges) {

  std::vector<Node*> order;

  int time = 0;
  for (auto& u : vertices) {
    if (u.color == Color::WHITE) {
      modified_dfs_visit(vertices, u, time, back_edges, order);
    }
  }
  return order;
}

std::vector<Node*> topological_sort(std::vector<Node>& vertices, bool& back_edges) {

  back_edges = false;		// if there is no back edges graph is acyclic - default: false

  std::vector<Node*> topological_order = modified_dfs(vertices, back_edges);

  std::reverse(topological_order.begin(), topological_order.end());
  return topological_order;
}



