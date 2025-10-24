# Zofia Tarchalska

function count_macheps(type)

    frac = type(4.0 / 3.0)
    eps = type(3.0) * (frac - one(type)) - one(type)
    return eps

end

types = [Float16, Float32, Float64]

for t in types
    println(t)
    println(rpad("kahan_eps: ", 15), count_macheps(t))
    println(rpad("eps: ", 15), eps(t), '\n')
end