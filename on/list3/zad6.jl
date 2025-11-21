# Zofia Tarchalska

include("roots.jl")
using .roots

delta = epsilon = 10^-5

f1(x) = exp(1 -x) - 1
pf1(x) = -1 *exp(1-x)
f2(x) = x * exp(-x)
pf2(x) = exp(-x) * (1 - x)

intervals = [(0.0, 2.0), (0.0, 3.0), (0.0, 10.5)]

results = [mbisekcji(f1, a, b, delta, epsilon) for (a, b) in intervals]

println("----------Funkcja f1----------")

for (i, (a, b)) in enumerate(intervals)
    println("Przedział [$a, $b]")
    println("x = ", results[i][1])
    println("f1(x) = ", results[i][2])
    println(rpad("Liczba iteracji ", 20), results[i][3])
    println(rpad("Kod błędu ", 20), results[i][4])
    println() 
end

intervals2 = [0.0, 1.0, -2.0, 1000000]

results2 = [mstycznych(f1, pf1, x, delta, epsilon, 50) for x in intervals2]

for (i, x) in enumerate(intervals2)
    println("Przybliżenie x = $x")
    println("x = ", results2[i][1])
    println("f1(x) = ", results2[i][2])
    println(rpad("Liczba iteracji ", 20), results2[i][3])
    println(rpad("Kod błędu ", 20), results2[i][4])
    println() 
end


results3 = [msiecznych(f1, x1, x2, delta, epsilon, 50) for (x1, x2) in intervals]

for (i, (x1, x2)) in enumerate(intervals)
    println("Przybliżenia x1 = $x1, x2 = $x2")
    println("x = ", results3[i][1])
    println("f1(x) = ", results3[i][2])
    println(rpad("Liczba iteracji ", 20), results3[i][3])
    println(rpad("Kod błędu ", 20), results3[i][4])
    println() 
end

println("----------Funkcja f2----------")

intervals4 = [(-1.0, 1.0), (-1.0, 2.0), (-1.0, 9.5)]

results4 = [mbisekcji(f2, a, b, delta, epsilon) for (a, b) in intervals4]

for (i, (a, b)) in enumerate(intervals4)
    println("Przedział [$a, $b]")
    println("x = ", results4[i][1])
    println("f2(x) = ", results4[i][2])
    println(rpad("Liczba iteracji ", 20), results4[i][3])
    println(rpad("Kod błędu ", 20), results4[i][4])
    println() 
end

intervals5 = [-1.0, 0.0, 3.0, 1000000]

results5 = [mstycznych(f2, pf2, x, delta, epsilon, 50) for x in intervals5]

for (i, x) in enumerate(intervals5)
    println("Przybliżenie x = $x")
    println("x = ", results5[i][1])
    println("f2(x) = ", results5[i][2])
    println(rpad("Liczba iteracji ", 20), results5[i][3])
    println(rpad("Kod błędu ", 20), results5[i][4])
    println() 
end


results6 = [msiecznych(f2, x1, x2, delta, epsilon, 50) for (x1, x2) in intervals4]

for (i, (x1, x2)) in enumerate(intervals4)
    println("Przybliżenia x1 = $x1, x2 = $x2")
    println("x = ", results6[i][1])
    println("f2(x) = ", results6[i][2])
    println(rpad("Liczba iteracji ", 20), results6[i][3])
    println(rpad("Kod błędu ", 20), results6[i][4])
    println() 
end









