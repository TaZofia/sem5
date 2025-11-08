# Zofia Tarchalska

using JuMP, GLPK, JSON



function my_solver(m, n, k, containers)
    model = Model(GLPK.Optimizer) 

    @variable(model, camera[1:n, 1:m] >= 0, Bin)

    # camera can't be where container is
    for (i, j) in containers
        @constraint(model, camera[i, j] == 0)
    end


    for (i, j) in containers
        visible = []

        # up
        for di in 1:k
            if i - di ≥ 1
                push!(visible, camera[i - di, j])
            end
        end

        # down
        for di in 1:k
            if i + di ≤ m
                push!(visible, camera[i + di, j])
            end
        end

        # left
        for dj in 1:k
            if j - dj ≥ 1
                push!(visible, camera[i, j - dj])
            end
        end

        # right
        for dj in 1:k
            if j + dj ≤ n
                push!(visible, camera[i, j + dj])
            end
        end

        # at least one camera has to supervise the container 
        @constraint(model, sum(visible) ≥ 1)

    end

    @objective(model, Min, sum(camera[i, j] for i in 1:m, j in 1:n))
    optimize!(model)

    return model, camera
end

function result()

    data = JSON.parsefile("data_ex6.json")

    m = data["m"]
    n = data["n"]
    containers = data["containers"]
    containers = Set([(c[1], c[2]) for c in data["containers"]])

    k_values = data["k_values"]

    println("X - represents camera")
    println("O - represents container")
    println(". - represents empty cell")

    for k in k_values
        optimized_model, cameras_map = my_solver(m, n, k, containers)

        println("\n\nk = $k")
        println("Min number of cameras: ", objective_value(optimized_model))

        println("\nMap:")
        for i in 1:n
            for j in 1:m
                if (i, j) in containers
                    print(" O ")
                elseif value(cameras_map[i, j]) == 1.0
                    print(" X ")
                else
                    print(" . ")
                end
            end
            println()
        end
    end
end
result()
