module Read
using ..Graphs
export read_graph_from_file

function read_graph_from_file(filename)

    graph = Graphs.Graph([])

    for line in eachline(filename)

        problem = ""
        number_of_vertices = 0
        number_of_edges = 0


        if line[1] == 'p'
            splitted_line = split(line)
            problem = splitted_line[2]
            number_of_vertices = parse(Int, splitted_line[3])
            number_of_edges = parse(Int, splitted_line[4])
        end

        for i in 1:number_of_vertices
            n = Graphs.Node(i, nothing, typemax(Int), [])         
            push!(graph.all_vertices, n)
        end
        
        from_vertex = 0
        to_vertex = 0
        weight = 0

        if line[1] == 'a'  
            splitted_line = split(line)
            from_vertex = parse(Int, splitted_line[2])
            to_vertex = parse(Int, splitted_line[3])
            weight = parse(Int, splitted_line[4]) 
            
            push!(graph.all_vertices[from_vertex].adj_list, (graph.all_vertices[to_vertex], weight))
        end
    end
    return graph
end

end
