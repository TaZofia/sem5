#ifndef DFS_HPP
#define DFS_HPP

#include ".\\..\\get_graph.hpp"
#include <string>
#include <unordered_map>

std::vector<std::vector<Node*>> mod_dfs(std::vector<Node*>& original_graph_top_order, std::vector<Node>& reversed_graph, std::unordered_map<int, Node*> node_map);
std::vector<std::vector<Node*>> strongly_connected_components(std::vector<std::pair<int, int>>& edges, int num_of_v, bool directed);

#endif