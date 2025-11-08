# Zofia Tarchalska

using JuMP, GLPK, JSON

function my_solver(nodes, edges, start_node, end_node, time_limit)
    number_of_edges = length(edges)

    model = Model(GLPK.Optimizer)
    @variable(model, x[1:number_of_edges], Bin)   # x(e) - binary. 1 means we take this edge

    @constraint(model, sum(edges[e][4] * x[e] for e in 1:number_of_edges) <= time_limit)

    for node in nodes
        incoming = [e for e in 1:number_of_edges if edges[e][2] == node]
        outgoing = [e for e in 1:number_of_edges if edges[e][1] == node]

        if node == start_node
            @constraint(model, sum(x[e] for e in incoming) - sum(x[e] for e in outgoing) == -1)
        elseif node == end_node
            @constraint(model, sum(x[e] for e in incoming) - sum(x[e] for e in outgoing) == 1)
        else
            @constraint(model, sum(x[e] for e in incoming) - sum(x[e] for e in outgoing) == 0)
        end
    end

    @objective(model, Min, sum(edges[e][3] * x[e] for e in 1:number_of_edges))

    optimize!(model)
    return model, x
end

function print_result(model, x, edges)
    if termination_status(model) == MOI.OPTIMAL
        println("Optimal path found:")
        println("Total cost: ", objective_value(model))
        println("Total time: ", sum(edges[e][4] * value(x[e]) for e in 1:length(edges)))
        println("Edges in the path:")
        for e in 1:length(edges)
            if value(x[e]) == 1.0
                println("$(edges[e][1]) → $(edges[e][2]) (cost: $(edges[e][3]), time: $(edges[e][4]))")
            end
        end
    else
        println("No solution found within the time constraint.")
    end
end

function result()

    data = JSON.parsefile("data_ex4.json")

    nodes = data["nodes"]
    start_node = data["start"]
    end_node = data["end"]
    time_limit = data["time_limit"]
    edges = data["edges"]
    my_edges = data["my_edges"]

    model, x = my_solver(nodes, edges, start_node, end_node, time_limit)
    my_model, my_x = my_solver(nodes, my_edges, start_node, end_node, time_limit)
    
    println("Model from exercise")
    print_result(model, x, edges)
    println("My model")
    print_result(my_model, my_x, my_edges)
end

result()