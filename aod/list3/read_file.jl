module Read
using ..Graphs
export read_graph_from_file

function read_graph_from_file(filename)

    graph = Graphs.Graph([])
    number_of_vertices = 0
    number_of_edges = 0
    biggest_weight = 0
    smallest_weight = 0

    for line in eachline(filename)

        problem = ""

        if line[1] == 'p'
            splitted_line = split(line)
            problem = splitted_line[2]
            number_of_vertices = parse(Int, splitted_line[3])
            number_of_edges = parse(Int, splitted_line[4])

            for i in 1:number_of_vertices
                n = Graphs.Node(i, nothing, typemax(Int), [])         
                push!(graph.all_vertices, n)
            end
        end

        
        
        from_vertex = 0
        to_vertex = 0
        weight = 0
        biggest_weight = weight
        smallest_weight = weight

        if line[1] == 'a'  
            splitted_line = split(line)
            from_vertex = parse(Int, splitted_line[2])
            to_vertex = parse(Int, splitted_line[3])
            weight = parse(Int, splitted_line[4]) 

            if weight > biggest_weight
                biggest_weight = weight
            end
            if weight < smallest_weight
                smallest_weight = weight
            end

            push!(graph.all_vertices[from_vertex].adj_list, (graph.all_vertices[to_vertex], weight))
        end
    end
    return graph, number_of_vertices, number_of_edges, biggest_weight, smallest_weight
end

end
