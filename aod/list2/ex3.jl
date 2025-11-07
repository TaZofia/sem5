# Zofia Tarchalska

using JuMP, GLPK, JSON

data = JSON.parsefile("data_ex3.json")

periods = data["periods"]
max_number_of_units = data["max_number_of_units"]
unit_production_cost = data["unit_production_cost"]
additional_production = data["additional_production"]
demand = data["demand"]
storage = data["storage"]


model = Model(GLPK.Optimizer) 
@variable(model, x_normal[periods] >= 0)
@variable(model, x_extra[periods] >= 0)
@variable(model, x_stored[periods] >= 0)

@constraint(model, [p in periods], x_normal[p] <= max_number_of_units[p])

for (i, p) in enumerate(periods)
    if i == 1
        @constraint(model, x_normal[p] + x_extra[p] + storage["initial_stock"] == demand[p] + x_stored[p])
    else
        prev = periods[i-1]
        @constraint(model, x_normal[p] + x_extra[p] + x_stored[prev] == demand[p] + x_stored[p])
    end
end

@constraint(model, [p in periods], x_extra[p] <= additional_production[p]["limit"])
@constraint(model, [p in periods], x_stored[p] <= storage["max_capacity"])

@objective(model, Min, sum(x_normal[p]*unit_production_cost[p] + x_extra[p]*additional_production[p]["cost"] + x_stored[p]*storage["unit_cost"] for p in periods))


optimize!(model)

println("Production plan: ")
for p in periods
    println("\nPeriod $p: ")
    println("normal production = ", value(x_normal[p]))
    println("additional_production = ", value(x_extra[p]))
    println("stored= ", value(x_stored[p]))
end

println("\nMin cost: ", objective_value(model))
