module Dijkstra
using ..Graphs
using DataStructures
export dijkstra, dijkstra_for_pairs, dijkstra_for_sources, dial_for_sources, dial_for_pairs, radix_heap_solver

function initialize_single_source(graph, start)
    for vertex in graph.all_vertices
        vertex.dist = typemax(Int)
        vertex.parent = nothing        
    end
    start.dist = Int(0)
end

function relax(u, v, w)
    if v.dist > u.dist + w
        v.dist = u.dist + w
        v.parent = u    
    end
end


function dijkstra(graph, start)

    initialize_single_source(graph, start)
    vertices_with_final_sp = Vector{Graphs.Node}()

    Q = PriorityQueue{Graphs.Node, Float64}()
    for v in graph.all_vertices
        enqueue!(Q, v, v.dist)        
    end

    while !isempty(Q)
        min_vertex = dequeue!(Q)
        push!(vertices_with_final_sp, min_vertex)
        for (vertex, weight) in min_vertex.adj_list 
            relax(min_vertex, vertex, weight) 
            if haskey(Q, vertex)
                Q[vertex] = vertex.dist
            end             
        end
    end
    return vertices_with_final_sp
end



function dijkstra_for_sources(graph, start)

    start_time = time_ns()

    initialize_single_source(graph, start)

    Q = PriorityQueue{Graphs.Node, Float64}()
    for v in graph.all_vertices
        enqueue!(Q, v, v.dist)        
    end

    while !isempty(Q)
        min_vertex = dequeue!(Q)
        for (vertex, weight) in min_vertex.adj_list 
            relax(min_vertex, vertex, weight) 
            if haskey(Q, vertex)
                Q[vertex] = vertex.dist
            end             
        end
    end

    end_time = time_ns()
    elapsed_time = (end_time - start_time)

    return elapsed_time
end


function dijkstra_for_pairs(graph, start, finish)

    initialize_single_source(graph, start)
    cost = 0

    Q = PriorityQueue{Graphs.Node, Float64}()
    for v in graph.all_vertices
        enqueue!(Q, v, v.dist)        
    end

    while !isempty(Q)
        min_vertex = dequeue!(Q)

        if finish == min_vertex
            cost = min_vertex.dist
            return cost            
        end

        for (vertex, weight) in min_vertex.adj_list 
            relax(min_vertex, vertex, weight) 
            if haskey(Q, vertex)
                Q[vertex] = vertex.dist
            end             
        end
    end
end

function dial_for_sources(graph, start, biggest_weight)
    start_time = time_ns()
    n = length(graph.all_vertices)
    max_distance = biggest_weight*n

    initialize_single_source(graph, start)

    buckets = [Node[] for _ in 1:(max_distance+1)]

    # start in bucket 0 (index = dist+1)
    push!(buckets[1], start)

    current = 0
    while current <= max_distance
        bucket = buckets[current+1]
        
        while !isempty(bucket)
            u = pop!(bucket)

            for (v, w) in u.adj_list
                

                alt = u.dist + w
                if alt < v.dist
                    old = v.dist
                    v.dist = alt
                    v.parent = u

                    # remove from old bucket if not INF
                    if old != typemax(Int)
                        old_idx = old + 1
                        b = buckets[old_idx]
                        pos = findfirst(==(v), b)
                        if pos !== nothing
                            deleteat!(b, pos)
                        end
                    end

                    push!(buckets[alt+1], v)
                end
            end
        end

        current += 1
    end
    end_time = time_ns()
    elapsed_time = (end_time - start_time)

    return elapsed_time
end

# needs testing 
function dial_for_pairs(graph, start, finish, biggest_weight)
    n = length(graph.all_vertices)
    max_distance = biggest_weight*n

    initialize_single_source(graph, start)

    buckets = [Node[] for _ in 1:(max_distance+1)]

    # start in bucket 0 (index = dist+1)
    push!(buckets[1], start)

    current = 0
    while current <= max_distance
        bucket = buckets[current+1]
        
        while !isempty(bucket)
            u = pop!(bucket)

            if u == finish
                return u.dist
            end

            for (v, w) in u.adj_list
                

                alt = u.dist + w
                if alt < v.dist
                    old = v.dist
                    v.dist = alt
                    v.parent = u

                    # remove from old bucket if not INF
                    if old != typemax(Int)
                        old_idx = old + 1
                        b = buckets[old_idx]
                        pos = findfirst(==(v), b)
                        if pos !== nothing
                            deleteat!(b, pos)
                        end
                    end

                    push!(buckets[alt+1], v)
                end
            end
        end

        current += 1
    end
end

mutable struct Item
    key::Int
    u::Graphs.Node
end

function radix_heap_solver(graph::Graphs.Graph, source::Graphs.Node; target::Union{Nothing, Graphs.Node}=nothing)
    start_time = time_ns()
    # inicjalizacja dystansów
    for v in graph.all_vertices
        v.dist = typemax(Int)
        v.parent = nothing
    end
    source.dist = 0

 

    # pomocnicza funkcja
    get_bucket_index(last::Int, key::Int) = begin
        diff = UInt64(last ⊻ key)
        diff == 0 ? 0 : 64 - leading_zeros(diff)
    end

    buckets = [Item[] for _ in 1:65]   # kubełki 0..64
    last_dist::Int = 0
    size_count::Int = 0

    push!(buckets[1], Item(0, source))
    size_count += 1

    while size_count > 0
        bucket_idx = 1
        while bucket_idx <= length(buckets) && isempty(buckets[bucket_idx])
            bucket_idx += 1
        end
        if bucket_idx > length(buckets)
            break
        end

        if bucket_idx > 1
            # 1) min over stored keys
            min_key = typemax(Int)
            for it in buckets[bucket_idx]
                if it.key < min_key
                    min_key = it.key
                end
            end
            last_dist = min_key

            # 2) wyciągamy kubełek
            move = copy(buckets[bucket_idx])
            empty!(buckets[bucket_idx])
            size_count -= length(move)

            # 3) re-bucketujemy ważne wpisy
            for it in move
                u = it.u
                k = it.key
                if k != u.dist
                    continue
                end
                new_idx = get_bucket_index(last_dist, k) + 1
                push!(buckets[new_idx], it)
                size_count += 1
            end
            continue
        end

        # bucket 0
        while !isempty(buckets[1])
            it = pop!(buckets[1])
            size_count -= 1

            u = it.u
            k = it.key
            if k != u.dist
                continue
            end

            if target !== nothing && u == target
                cost = u.dist
                return cost
            end

            for (v, w) in u.adj_list
                nd = u.dist + w
                if nd < v.dist
                    v.dist = nd
                    v.parent = u
                    idx = get_bucket_index(last_dist, nd) + 1
                    push!(buckets[idx], Item(nd, v))
                    size_count += 1
                end
            end
        end
    end
    end_time = time_ns()
    elapsed_time = (end_time - start_time)

    return elapsed_time
end


end
