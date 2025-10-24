# Zofia Tarchalska
function forward(type, x, y)
    sum = type(0.0)

    for i in 1:length(x)
        sum += x[i] * y[i]
    end
    return sum
end


function backward(type, x, y)
    sum = type(0.0)

    for i in length(x):-1:1
        sum += x[i] * y[i]
    end
    return sum
end

function biggest_to_smallest(x, y)
    # iloczyny odpowiadających sobie elementów
    p = x .* y

    positive_elements = []
    for value in p
        if value > 0
            push!(positive_elements, value)
        end
    end

    sort!(positive_elements, rev=true)  # malejąco
    sum_pos = sum(positive_elements)

    negative_elements = []
    for value in p
        if value < 0
            push!(negative_elements, value)
        end
    end
    sort!(negative_elements)  

    sum_neg = sum(negative_elements)
    return sum_pos + sum_neg
end

function smallest_to_biggest(x, y)
    p = x .* y

    positive_elements = []
    for value in p
        if value > 0
            push!(positive_elements, value)
        end
    end

    sort!(positive_elements)  
    sum_pos = sum(positive_elements)

    negative_elements = []
    for value in p
        if value < 0
            push!(negative_elements, value)
        end
    end
    sort!(negative_elements, rev=true)  

    sum_neg = sum(negative_elements)
    return sum_pos + sum_neg
end


x = [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957]
y = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]
types = [Float32, Float64]

for t in types
    a = Array{t,1}(x)
    b = Array{t,1}(y)
    println(t)
    println("real: ", "-1.00657107000000e-11")
    println("forward: ", forward(t, a, b))
    println("backward: ", backward(t, a, b))
    println("biggest_to_smallest: ", biggest_to_smallest(a, b))
    println("smallest_to_biggest: ", smallest_to_biggest(a, b), '\n')   
end