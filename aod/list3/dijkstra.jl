
include("graph.jl")

module Dijkstra
using ..Graphs: Graph, Node
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
    vertices_with_final_sp = Nothing

    Q = PriorityQueue{Graphs.Node, Int}()

    while !isempty(Q)
        min_vertex = !dequeue(Q)
        vertices_with_final_sp.add(min_vertex)
        for (vertex, weight) in min_vertex.adj_list 
            relax(min_vertex, vertex, weight)              
        end
    end
    return vertices_with_final_sp
end

end