# Zofia Tarchalska
import Pkg
Pkg.add("Plots")
using Plots

# f - funckja
function der(f, h, x=1)
    return (f(x+h)-f(x))/h
end


# wzory funkcji w krótszej wersji
f(x) = sin(x) + cos(3x)
df(x) = cos(x) - 3sin(3x)

# wartość pochodnej dla argumentu 1
exact_df = df(1)


println(rpad("n", 10), rpad("f_tilde", 30), rpad("|f_tilde - f'|", 30))
for i in 1:54
    f_tilde = der(f,2.0^-i)
    println(rpad("$i", 10), rpad(f_tilde, 30), rpad(abs(f_tilde - exact_df), 30))
end


xs = 0:54
ys = map(x -> abs(der(f, 2.0^-x) - exact_df), xs)

plot(xs, ys, 
     seriestype = :scatter,
     legend = false,
     yaxis = :log,
     color = :red,
     linewidth = 2)

savefig("wykres.png")
     
println()
println()
println(rpad("n", 5), rpad("1+h", 25), rpad("f(1+h)", 25), rpad("f(1+h)-f(1)", 25))
for i in 1:54
    println(rpad("$i", 5), rpad(1.0+2.0^-i, 25), rpad(f(1.0+2.0^-i), 25), rpad(f(1.0+2.0^-i)-f(1.0), 25))
end

println()
println()
println("f(1.0) = ", f(1.0))