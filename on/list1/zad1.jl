
# Zofia Tarchalska

# one() - zwraca jedynkę w danym typie danych

types = [Float16, Float32, Float64]

function macheps(type)
    eps = one(type)     # jedyna w danym typie
    while one(type) + eps / type(2) > one(type)
        eps /= type(2)
    end
    return eps
end

println("------Liczba eps------")

for t in types
    # t to typ danych
    println(t)
    println(rpad("iteracyjnie: ", 15), macheps(t))
    println(rpad("funkcja eps: ", 15), eps(t), '\n')
end



function find_eta(type)
    eta = one(type)
    while type(0.5) * eta > zero(type)
        eta *= type(0.5)
    end
    return eta
end


println("------Liczba eta------")

for t in types
    # t to typ danych
    println(t)
    println(rpad("iteracyjnie: ", 15), find_eta(t))
    println(rpad("funkcja nextfloat: ", 15), nextfloat(t(0.0)), '\n')
end

println("------Wartości precyzji------")

println("Float16: ", Float16(2^-10))
println("Float32: ", Float32(2^-23))
println("Float64: ", Float64(2^-52))

println("------Wartości MIN_sub------")
println("Float16: ", Float16(2^-24))
println("Float32: ", Float32(2^-149))
println("Float64: ", Float64(2^-1074))


println("------Badanie floatmin------")
println("Float16: ", floatmin(Float16))
println("Float32: ", floatmin(Float32))
println("Float64: ", floatmin(Float64))

println("------Badanie MIN_nor------")
println("Float16: ", Float16(2^-14))
println("Float32: ", Float32(2^-126))
println("Float64: ", Float64(2^-1022))



function find_max(type)
    num = prevfloat(type(1.0))
    while !isinf(2*num)
        num *= 2
    end
    return num
end

println("------MAX------")

for t in types
    println(t)
    println(rpad("iteracyjnie: ", 15), find_max(t))
    println(rpad("funkcja floatmax: ", 15), floatmax(t), '\n')
end
