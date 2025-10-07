#include "get_graph.hpp"

std::vector<Node> get_vertices(std::vector<std::pair<int, int>> edges, int num_of_v, bool directed) {

	std::vector<Node> all_vertices;

	for (int i = 0; i < num_of_v; i++) {
		Node v(i+1, Color::WHITE, nullptr);
		all_vertices.push_back(v);          // index equals verticle value - 1
	}

	for (auto& edge : edges) {

		Node& current_v = all_vertices[edge.first - 1];
		current_v.adj_edges.push_back(edge);

		if (!directed) {
			Node& second_v = all_vertices[edge.second - 1];
			second_v.adj_edges.push_back({edge.second, edge.first});
		}
	}
	return all_vertices;
}