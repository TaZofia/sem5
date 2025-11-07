# Zofia Tarchalska

using JuMP, GLPK, JSON


data = JSON.parsefile("data_ex5.json")

districts = data["districts"]
shifts = data["shifts"]
min_vehicles_per_shift_district = data["min_vehicles_per_shift_district"]
max_vehicles_per_shift_district = data["max_vehicles_per_shift_district"]
min_total_per_shift = data["min_total_per_shift"]
min_total_per_district = data["min_total_per_district"]

model = Model(GLPK.Optimizer) 

@variable(model, x[districts, shifts] >= 0, Int)    # x - how many vehicles are on shift in district

for s in shifts 
    @constraint(model, sum(x[d, s] for d in districts) >= min_total_per_shift[s])
end

for d in districts 
    @constraint(model, sum(x[d, s] for s in shifts) >= min_total_per_district[d])
end

for s in shifts
    for d in districts 
        @constraint(model, x[d, s] <= max_vehicles_per_shift_district[s][d])
        @constraint(model, x[d, s] >= min_vehicles_per_shift_district[s][d])
    end
end


@objective(model, Min, sum(x[d, s] for d in districts for s in shifts))

optimize!(model)

for d in districts
    println("\nDistrict $d")
    for s in shifts
        println("Shift $s: ", value(x[d, s]))        
    end
end


println("\nMin number of vehicles: ", objective_value(model))