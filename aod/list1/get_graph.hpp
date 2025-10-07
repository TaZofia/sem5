#ifndef GET_GRAPH_HPP
#define GET_GRAPH_HPP

#include <vector>
#include "enums.hpp"
class Node {
public:
	int value;
	Color color;
	Node* parent;
	int d_time;		// time when vertex becomes GRAY - visited first time
	int f_time;		// time when vertex becomes BLACK - adj list finished , especially needed with dfs

	std::vector<std::pair<int, int>> adj_edges;
public:
	Node() = default;
	Node(int value, Color color = Color::WHITE, Node* parent = nullptr, int d_time = -1, int f_time = -1)
	 : value(value), color(color), parent(parent), d_time(d_time), f_time(f_time) {}
};

std::vector<Node> get_vertices(std::vector<std::pair<int, int>> edges, int num_of_v, bool directed);

#endif