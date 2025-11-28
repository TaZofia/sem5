module Dijkstra
using ..Graphs
using DataStructures
export dijkstra

function initialize_single_source(graph, start)
    for vertex in graph.all_vertices
        vertex.dist = Inf
        vertex.parent = nothing        
    end
    start.dist = 0
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

end