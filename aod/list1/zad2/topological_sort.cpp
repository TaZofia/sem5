#include "topological_sort.hpp"
#include <algorithm>
#include <functional>
#include <string>
#include <stack>

void modified_dfs_visit(std::vector<Node>& vertices, Node& u, int& time, bool& back_edges, std::vector<Node*>& order) {

    std::stack<Node*> stack;
    std::stack<size_t> adj_index;

    stack.push(&u);
    adj_index.push(0);
    u.color = Color::GRAY;
    time += 1;
    u.d_time = time;

    while (!stack.empty()) {
        Node* u = stack.top();
        size_t& i = adj_index.top();

        if (i < u->adj_edges.size()) {
            int adj_vertex_value = u->adj_edges[i].second;
            i++;

            Node& v = vertices[adj_vertex_value - 1];
            if (v.color == Color::WHITE) {
                v.parent = u;
                v.color = Color::GRAY;
                time += 1;
                v.d_time = time;

                stack.push(&v);
                adj_index.push(0);
            } else if (v.color == Color::GRAY) {
                back_edges = true;
            }
        } else {
            stack.pop();
            adj_index.pop();

            u->color = Color::BLACK;
            time += 1;
            u->f_time = time;
            order.push_back(u);
        }
    }
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



