# Zofia Tarchalska

include("roots.jl")
using .roots

f(x) = 3*x - exp(x)
delta = 10^-4
epsilon = 10^-4

results1 = mbisekcji(f, 0.0, 1.0, delta, epsilon)

results2 = mbisekcji(f, 1.0, 3.0, delta, epsilon)

println("Przedział [0, 1]")
println(rpad("Punkt wspólny x ", 20), results1[1])
println(rpad("3x - e^x ", 20), results1[2])
println(rpad("Liczba iteracji ", 20), results1[3])
println(rpad("Kod błędu ", 20), results1[4])

println("Przedział [1, 3]")
println(rpad("Punkt wspólny x ", 20), results2[1])
println(rpad("3x - e^x ", 20), results2[2])
println(rpad("Liczba iteracji ", 20), results2[3])
println(rpad("Kod błędu ", 20), results2[4])