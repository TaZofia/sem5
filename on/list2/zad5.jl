# Zofia Tarchalska


function recurency(type)
    p = type(0.01)
    r = type(3.0)
    println("Iter | p")
    for i in 1:40
        p = p + r * p * (1 - p)
        println(rpad(string(i), 5), "| ", p)
    end
    return p
end

function modified_recurency(type)
    p = type(0.01)
    r = type(3.0)
    println("Iter | p (modified)")
    for i in 1:10
        p = p + r * p * (1 - p)
        println(rpad(string(i), 5), "| ", p)
    end

    p = floor(p * type(1000)) / type(1000)
    println("cut  | ", p)

    for i in 11:40
        p = p + r * p * (1 - p)
        println(rpad(string(i), 5), "| ", p)
    end
    return p
end

println("Float32")
recurency(Float32)
modified_recurency(Float32)

println("Float64")
recurency(Float64)
modified_recurency(Float64)







