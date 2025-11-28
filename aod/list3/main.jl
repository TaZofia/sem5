include("graph.jl")
include("dijkstra.jl")
include("read_file.jl")

using .Graphs: Graph, Node
using .Dijkstra
using .Read

function main()
    filename = ".\\USA-road-d.NY.gr"
    filename2 = ".\\my_graph.gr"
    graph = read_graph_from_file(filename2)

    shortest_paths = dijkstra(graph, graph.all_vertices[1])

    for element in shortest_paths
        println("shortest_path from ", graph.all_vertices[1], " to ", element.value, ": ", element.dist)
    end
    
end

main()