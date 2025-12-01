include("my_project.jl")
using .MyProject

function main()
    filename = ".\\USA-road-d.NY.gr"
    filename2 = ".\\my_graph.gr"
    graph = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]

    shortest_paths = MyProject.dijkstra(graph, start)

    for v in shortest_paths
        println("shortest path from ", start.value,
                " to ", v.value,
                " = ", v.dist)
    end

    graph = MyProject.read_graph_from_file(filename2)
    start = graph.all_vertices[1]

    println("dial")
    sp = MyProject.dial_for_sources(graph, start, 6)

    for v in sp.all_vertices
        println("shortest path from ", start.value,
                " to ", v.value,
                " = ", v.dist)
    end

    graph = MyProject.read_graph_from_file(filename2)
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