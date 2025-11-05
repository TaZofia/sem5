# Zofia Tarchalska

using JuMP, GLPK, JSON

# read json file
data = JSON.parsefile("data_ex1.json")

suppliers = data["suppliers"]
airports = data["airports"]

supply_limit = data["supply"]
demand = data["demand"]

costs = Dict{Tuple{String, String}, Int}()
# (f, l) - pair where f is a one of suppliers and l is one of airports
for (key, value) in pairs(data["costs"])
    f, l = split(key, "-")
    costs[(f, l)] = value
end

model = Model(GLPK.Optimizer)           # solver
@variable(model, x[suppliers, airports] >= 0)   # matrix where each element x[s, a] means how much fuel supplier sends to airport

for s in suppliers
    delivery = []
    for a in airports
        if haskey(costs, (s, a))
            push!(delivery, x[s, a])
        end
    end

    delivery_sum = sum(delivery)

    @constraint(model, delivery_sum <= supply_limit[s])     # supplier can't deliver more than its limit
end

for a in airports
    delivery = []
    for s in suppliers
        if haskey(costs, (s, a))
            push!(delivery, x[s, a])
        end
    end

    delivery_sum = sum(delivery)
    @constraint(model, delivery_sum == demand[a])        # airport must get as much fuel as it needs
end

@objective(model, Min, sum(costs[(s, a)] * x[s, a] for (s, a) in keys(costs)))

optimize!(model)


println("Min cost: ", objective_value(model))
for s in suppliers
    total_sent = 0.0
    println("\nCompany $s, limit = ", supply_limit[s])
    for a in airports
        if haskey(costs, (s, a))
            amount = value(x[s, a])
            println("Supplier $s → Airport $a: ", amount)
            total_sent += amount
        end
    end
    println("\n$s delivered $total_sent in total.")
end

  