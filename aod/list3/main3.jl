include("my_project.jl")
using .MyProject

function main()
    filename = ".\\USA-road-d.NY.gr"
    filename2 = ".\\my_graph2.gr"
    graph, vertices, edges, min_weight, max_weight = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]
    finish = graph.all_vertices[4]

    shortest_paths = MyProject.dijkstra_for_pairs(graph, start, finish)

    println("dijkstra: ", shortest_paths)

    graph, vertices, edges, min_weight, max_weight = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]
    finish = graph.all_vertices[4]

    sp = MyProject.dial_for_pairs(graph, start, finish, 6)

    println("dial: ", sp)

    graph, vertices, edges, min_weight, max_weight = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]
    finish = graph.all_vertices[4]


    sp2 = MyProject.radix_heap_solver(graph, start)

   println("radix: ", sp2)
end

main()