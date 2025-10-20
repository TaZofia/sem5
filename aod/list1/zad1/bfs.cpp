#include <vector>
#include "bfs.hpp"
#include <queue>

std::string bfs(std::vector<Node>& vertices, Node& start) {

  std::string order = "";
  order += "(" + std::to_string(start.value) + ") ";

  std::queue<Node*> my_queue;

  start.color = Color::GRAY;
  start.d_time = 0;
  start.parent = nullptr;

  my_queue.push(&start);

  while (!my_queue.empty()) {
    Node* current_v = my_queue.front();
    my_queue.pop();

    for (const auto& edge : current_v->adj_edges) {
      int adj_vertex_value = edge.second;
      Node& adj_vertex = vertices[adj_vertex_value - 1];

      if (adj_vertex.color == Color::WHITE) {
        adj_vertex.color = Color::GRAY;
        adj_vertex.d_time = current_v->d_time + 1;
        adj_vertex.parent = current_v;
        my_queue.push(&adj_vertex);

        order += "(" + std::to_string(adj_vertex_value) + ") ";
      }
    }
    current_v->color = Color::BLACK;
  }

  return order;
}
