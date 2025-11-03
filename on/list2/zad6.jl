# Zofia Tarchalska
using Plots

function recurency(c, x)
    println("Iter | x")
    for i in 1:40
        x = x^2 + c
        println(rpad(string(i), 5), "| ", x)
    end
    return x
end

c1 = -2.0
x_arr1 = [1.0, 2.0, 1.99999999999999]

c2 = -1.0
x_arr2 = [1, -1, 0.75, 0.25]


println("c = ", c1)
for x in x_arr1
    println("x = ", x)
    recurency(c1, x)    
end

println("c = ", c2)
for x in x_arr2
    println("x = ", x)
    recurency(c2, x)    
end