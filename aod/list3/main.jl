include("my_project.jl")
using .MyProject

function read_sources(filename)
    sources = Int[]
    for line in eachline(filename)
        if line[1] == 's'
            splitted_line = split(line)
            src = parse(Int, splitted_line[2])
            push!(sources, src)
        end
    end
    return sources
end

function read_pair(filename)
    pairs = Tuple{Int,Int}[]
    for line in eachline(filename)
        if line[1] == 'q'
            splitted_line = split(line)
            from = parse(Int, splitted_line[2])
            to = parse(Int, splitted_line[3])
            push!(pairs, (from, to))
        end
    end
    return pairs
end


function create_result_file_sources(data_filename, source_filename, algorithm_name, min_cost, max_cost, avg_time, number_of_vertices, number_of_edges, result_filename)
    folder = ".\\results\\sources"
    path = joinpath(folder, result_filename)
    
    open(path, "w") do io
        write(io, "p res sp ss $(algorithm_name)\n")
        write(io, "f $(data_filename) $(source_filename)\n")
        write(io, "g $(number_of_vertices) $(number_of_edges) $(min_cost) $(max_cost)\n")
        write(io, "t $(avg_time)")
    end
    
end

function create_result_file_pairs(data_filename, pair_file, algorithm_name, min_cost, max_cost, number_of_vertices, number_of_edges, costs, result_filename)
    folder = ".\\results\\pairs"

    path = joinpath(folder, result_filename)
    
    open(path, "w") do io
        number_of_pairs = length(costs)
        write(io, "p res sp p2p $(number_of_pairs) $(algorithm_name)\n")
        write(io, "f $(data_filename) $(pair_file)\n")
        write(io, "g $(number_of_vertices) $(number_of_edges) $(min_cost) $(max_cost)\n")
        for ((from, to), cost) in costs
            write(io, "d $from $to $cost\n") 
        end
    end
    
end

function main()
    if length(ARGS) != 7
        println("[ERROR] Proper use: \n<algorithm_name> -d <file_with_data> -<ss/p2p> <file_with_src> -<oss/op2p> <file_with_results>")        
        exit(1)
    end

    file_with_data = ""
    flag1 = ARGS[2]
    flag2 = ARGS[4]
    flag3 = ARGS[6]
    graph = nothing
    number_of_vertices = 0
    number_of_edges = 0
    max_edge_cost = 0
    min_edge_cost = 0

    if flag1 == "-d"
        file_with_data = ARGS[3]
        graph, number_of_vertices, number_of_edges, max_edge_cost, min_edge_cost = read_graph_from_file(file_with_data)
    else
        println("[ERROR] Wrong first flag.")
        exit(1)
    end


    file_src_or_pair = ARGS[5]
    algorithm_name = ARGS[1]

    if flag2 == "-ss"
        if !endswith(file_src_or_pair, ".ss")
            println("[ERROR] Wrong file format. Should be <filename>.ss")
        end

        sources = read_sources(file_src_or_pair)
        if algorithm_name == "dijkstra"
            all_time = 0
            for src in sources
                start_node = graph.all_vertices[src]        # src to Integer a potrzebuję obiektu Node
                time = dijkstra_for_sources(graph, start_node)
                all_time += time
            end
            avg_time = all_time/length(sources)

        elseif algorithm_name == "dial"
            all_time = 0
            for src in sources
                start_node = graph.all_vertices[src]        # src to Integer a potrzebuję obiektu Node
                time = dial_for_sources(graph, start_node, max_edge_cost)
                all_time += time
            end
            avg_time = all_time/length(sources)

        elseif algorithm_name == "radixheap"
            all_time = 0
            for src in sources
                start_node = graph.all_vertices[src]        # src to Integer a potrzebuję obiektu Node
                time = radix_heap_solver(graph, start_node)
                all_time += time
            end
            avg_time = all_time/length(sources)
        else
            println("[ERROR] Wrong algorithm. Should be: dijkstra, dial or radixheap.")
            exit(1)
        end

        result_filename = ARGS[7]

        if endswith(result_filename, ".ss.res") && flag3 == "-oss"
            create_result_file_sources(file_with_data, file_src_or_pair, algorithm_name, min_edge_cost, max_edge_cost, avg_time, number_of_vertices, number_of_edges, result_filename)
        else
            println("[ERROR] Wrong format of file with results or wrong flag. Should be: -oss <filename>.ss.res")
            exit(1)
        end


    elseif flag2 == "-p2p"

        if !endswith(file_src_or_pair, ".p2p")
            println("[ERROR] Wrong file format. Should be <filename>.p2p")
        end

        pairs = read_pair(file_src_or_pair)
        
        if algorithm_name == "dijkstra"
            costs = Vector{Tuple{Tuple{Int,Int}, Int}}()
            for (start, finish) in pairs
                start_node = graph.all_vertices[start]        # start to Integer a potrzebuję obiektu Node
                finish_node = graph.all_vertices[finish]
                shortes_path_cost = dijkstra_for_pairs(graph, start_node, finish_node)
                push!(costs, ((start, finish), shortes_path_cost))
            end

        elseif algorithm_name == "dial"
            costs = Vector{Tuple{Tuple{Int,Int}, Int}}()
            for (start, finish) in pairs
                start_node = graph.all_vertices[start]        # start to Integer a potrzebuję obiektu Node
                finish_node = graph.all_vertices[finish]
                shortes_path_cost = dial_for_pairs(graph, start_node, finish_node, max_edge_cost)
                push!(costs, ((start, finish), shortes_path_cost))
            end

        elseif algorithm_name == "radixheap"
            costs = Vector{Tuple{Tuple{Int,Int}, Int}}()
            for (start, finish) in pairs
                start_node = graph.all_vertices[start]        # start to Integer a potrzebuję obiektu Node
                finish_node = graph.all_vertices[finish]
                shortes_path_cost = radix_heap_solver(graph, start_node, target=finish_node)
                push!(costs, ((start, finish), shortes_path_cost))
            end

        else
            println("[ERROR] Wrong algorithm. Should be: dijkstra, dial or radixheap.")
            exit(1)
        end

        output_filename = ARGS[7]

        if endswith(output_filename, ".p2p.res") && flag3 == "-op2p"
            create_result_file_pairs(file_with_data, file_src_or_pair, algorithm_name, min_edge_cost, max_edge_cost, number_of_vertices, number_of_edges, costs, output_filename)
        else
            println("[ERROR] Wrong format of file with results or wrong flag. Should be: -op2p <filename>.p2p.res")
            exit(1)
        end
    else
        println("[ERROR] Wrong second flag.")
        exit(1)
    end
end
main()