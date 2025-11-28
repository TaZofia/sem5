module Graphs

export Node, Graph
    
mutable struct Node
    value::Int
    parent::Union{Nothing, Node}  
    dist::Float64 
    adj_list::Vector{Tuple{Node, Float64}}
end

mutable struct Graph
    all_vertices::Vector{Node}
end

end