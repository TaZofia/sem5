# Zofia Tarchalska

# x - argument
function f(x)
    sqrt(x^2 + 1.0) - 1.0
end

function g(x)
    x^2 / (sqrt(x^2 + 1.0) + 1.0)
end

println(rpad("x", 10), rpad("f(x)", 30), rpad("g(x)", 30))
for i in 1:20
    println(rpad("k = $i", 10), rpad(f(8.0^-i), 30), rpad(g(8.0^-i), 30))
end