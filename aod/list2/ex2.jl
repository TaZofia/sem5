# Zofia Tarchalska

using JuMP, GLPK, JSON


data = JSON.parsefile("data_ex2.json")

products = data["products"]
machines = data["machines"]
working_hours = data["working_hours"]
products_prices = data["products_prices"]
working_cost = data["working_cost"]
products_cost = data["products_cost"]
machine_time_minutes = data["machine_time_minutes"]
max_demand = data["max_demand"]


model = Model(GLPK.Optimizer) 
@variable(model, x[products] >= 0)

# machine's working time constarint
for m in machines
    sum = 0.0
    for p in products
        minutes = machine_time_minutes[p][m]
        sum += (minutes * x[p])       
    end
    @constraint(model, sum <= working_hours[m]*60)
end

# demand constarint
for p in products
    @constraint(model, x[p] <= max_demand[p])
end

@objective(model, Max, sum(
    (products_prices[p] - products_cost[p] - sum(working_cost[m] * (machine_time_minutes[p][m] / 60.0) for m in machines)) * x[p]
    for p in products
))
optimize!(model)

# Wyniki
println("\nOptimal production strategy:")
for p in products
    println("Product $p: ", value(x[p]), " kg")
end

println("\nMax profit: ", objective_value(model), " zł")