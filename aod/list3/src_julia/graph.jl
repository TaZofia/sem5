module Graphs

export Node, Graph
    
mutable struct Node
    value::Int
    parent::Union{Nothing, Node}  
    dist::Int
    adj_list::Vector{Tuple{Node, Int}}
end

mutable struct Graph
    all_vertices::Vector{Node}
end

end