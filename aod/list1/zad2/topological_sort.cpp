#include "topological_sort.hpp"
#include ".\\..\\zad1\\dfs.hpp"
#include <algorithm>

std::vector<Node> topological_sort(std::vector<Node>& vertices) {


	dfs(vertices);

  // TO DO : implement

	return vertices;
}
