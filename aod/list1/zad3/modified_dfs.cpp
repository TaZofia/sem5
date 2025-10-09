#include <vector>
#include "modified_dfs.hpp"
#include ".\\..\\enums.hpp"


void mod_dfs_visit(std::vector<Node>& reversed_vertices, Node& u, std::vector<Node*>& current_scc, std::unordered_map<int, Node*>& node_map) {
  u.color = Color::GRAY;
  current_scc.push_back(&u);

  for (std::pair<int, int> edge : u.adj_edges) {
    int adj_vertex_value = edge.second;
    Node* vertex = node_map[adj_vertex_value];		// pointer to vertex
    Node& adj_vertex = *vertex;			// now we have this object

    if (adj_vertex.color == Color::WHITE) {
      adj_vertex.parent = &u;
      mod_dfs_visit(reversed_vertices, adj_vertex, current_scc, node_map);
    }
  }
  u.color = Color::BLACK;
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


