#include <vector>
#include "scc.hpp"
#include ".\\..\\enums.hpp"
#include <stack>
#include ".\\..\\zad2\\topological_sort.hpp"

void mod_dfs_visit(std::vector<Node>& reversed_vertices, Node& u, std::vector<Node*>& current_scc, std::unordered_map<int, Node*>& node_map) {
  std::stack<std::pair<Node*, size_t>> stack;
  stack.push({ &u, 0 });
  u.color = Color::GRAY;
  current_scc.push_back(&u);

  while (!stack.empty()) {
    Node* curr = stack.top().first;
    size_t& i = stack.top().second;

    if (i < curr->adj_edges.size()) {    // which neighbour is chcecked now
      int adj_vertex_value = curr->adj_edges[i].second;
      i++;

      Node* vertex = node_map[adj_vertex_value];
      Node& adj_vertex = *vertex;

      if (adj_vertex.color == Color::WHITE) {
        adj_vertex.parent = curr;
        adj_vertex.color = Color::GRAY;
        current_scc.push_back(&adj_vertex);
        stack.push({ &adj_vertex, 0 });
      }
    } else {
      curr->color = Color::BLACK;
      stack.pop();
    }
  }
}

std::vector<std::vector<Node*>> mod_dfs(std::vector<Node*>& topological_vertices, std::vector<Node>& reversed_graph, std::unordered_map<int, Node*> node_map) {

  std::vector<std::vector<Node*>> scc_list;

  for (Node* u : topological_vertices) {
    int u_value = u->value;

    Node& u_node = reversed_graph[u_value - 1];

    if (u_node.color == Color::WHITE) {
      std::vector<Node*> current_scc_list;
      mod_dfs_visit(reversed_graph, u_node, current_scc_list, node_map);
      scc_list.push_back(current_scc_list);
    }
  }
  return scc_list;
}

std::vector<std::pair<int, int>> get_graph_with_reversed_edges(std::vector<std::pair<int, int>> edges) {
  for (auto& temp : edges) {

    int first = temp.first;
    int second = temp.second;

    temp.first = second;    // swap
    temp.second = first;
  }
  return edges;
}


std::vector<std::vector<Node*>> strongly_connected_components(std::vector<std::pair<int, int>>& edges, int num_of_v, bool directed) {
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

  return scc;
}


