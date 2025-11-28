module MyProject

include("graph.jl")
include("read_file.jl")
include("dijkstra.jl")

using .Graphs
using .Dijkstra
using .Read

export Graph, Node, dijkstra, read_graph_from_file

end