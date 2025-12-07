include("my_project.jl")
using .MyProject

function main()
    filename = ".\\USA-road-d.NY.gr"
    filename2 = ".\\my_graph2.gr"
    graph, vertices, edges, min_weight, max_weight = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]

    shortest_paths = MyProject.dijkstra_for_sources(graph, start)

    for v in shortest_paths.all_vertices
        println("shortest path from ", start.value,
                " to ", v.value,
                " = ", v.dist)
    end

    graph, vertices, edges, min_weight, max_weight = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]

    println("dial")
    sp = MyProject.dial_for_sources(graph, start, 6)

    for v in sp.all_vertices
        println("shortest path from ", start.value,
                " to ", v.value,
                " = ", v.dist)
    end

    graph, vertices, edges, min_weight, max_weight = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]



    println("radix heap")
    sp2 = MyProject.radix_heap_solver(graph, start)

    for v in sp2.all_vertices
        println("shortest path from ", start.value,
                " to ", v.value,
                " = ", v.dist)
    end

end

main()