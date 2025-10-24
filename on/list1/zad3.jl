# Zofia Tarchalska

function check_start(start, delta)
    real = start
    for i in 1:100
        start += delta
        real = nextfloat(real)
        if start != real
            return false
        end
    end
    return true
end

function check_end(finish, delta)
    real = finish
    for i in 1:100
        finish -= delta
        real = prevfloat(real)
        if finish != real
            return false
        end
    end
    return true
end

delta = 2.0^-52

if(check_start(1.0, delta) && check_end(2.0, delta))
    println("Liczby w przedziale [1, 2] są równomiernie rozmieszczone")
else
    println(":( Liczby w przedziale [1, 2] nie są równomiernie rozmieszczone")
end





function count_delta(num)
    exp = parse(Int, bitstring(num)[2:12], base=2)  # odczyt cechy z zapisu dwójkowego - wykładnik w zapisie IEEE
    exp2 = exp - 1023 - 52
    delta = 2.0^exp2
    return delta, exp2
end

delta1, exp1 = count_delta(0.5)


if(check_start(0.5, delta1) && check_end(1.0, delta1))
    println("Liczby w przedziale [1/2, 1] są równomiernie rozmieszczone") 
    println("delta = ", delta1, " = 2^", exp1)
else
    println(":( Liczby w przedziale [1, 2] nie są równomiernie rozmieszczone")
end

delta2, exp2 = count_delta(2.0)

if(check_start(2.0, delta2) && check_end(4.0, delta2))
    println("Liczby w przedziale [2, 4] są równomiernie rozmieszczone") 
    println("delta = ", delta2, " = 2^", exp2)
else
    println(":( Liczby w przedziale [2, 4] nie są równomiernie rozmieszczone")
end

