# Zofia Tarchalska

using Polynomials



#p = Polynomial([1, -3, 2])  # 1 - 3x + 2x^2
#r = roots(p)

text = read("wielomian.txt", String)

coefficients = parse.(Float64, split(text, ','))
coefficients = reverse(coefficients)


P_polynomial = Polynomial(coefficients)
P_roots = roots(P_polynomial)

p(x) = (x-1)*(x-2)*(x-3)*(x-4)*(x-5)*(x-6)*(x-7)*(x-8)*(x-9)*(x-10)*(x-11)*(x-12)*(x-13)*(x-14)*(x-15)*(x-16)*(x-17)*(x-18)*(x-19)*(x-20)

println(rpad("k", 4),
        " & ", rpad("\$z_k\$", 20), 
        " & ", rpad("\$|P(z_k)|\$", 20), 
        " & ", rpad("\$|p(z_k)|\$", 20), 
        " & ", rpad("\$|z_k - k|\$", 20), 
        " \\\\\\hline")

for k in 1:20
    z_k = P_roots[k]
    println(rpad(k, 4),
        " & ", rpad(z_k, 20),
        " & ", rpad(abs(P_polynomial(z_k)), 20),
        " & ", rpad(abs(p(z_k)), 20),
        " & ", rpad(abs(z_k - k), 20),
        " \\\\\\hline")
end

# Eksperyment ------------------------------------------

text2 = read("wielomian_eksperyment.txt", String)

coefficients2 = parse.(Float64, split(text2, ','))
coefficients2 = reverse(coefficients2)

P_polynomial2 = Polynomial(coefficients2)
P_roots2 = roots(P_polynomial2)

println("\n----------Eksperyment----------\n")
println(rpad("k", 4),
        " & ", rpad("\$z_k\$", 20), 
        " & ", rpad("\$|P(z_k)|\$", 20), 
        " & ", rpad("\$|p(z_k)|\$", 20), 
        " & ", rpad("\$|z_k - k|\$", 20), 
        " \\\\\\hline")

for k in 1:20
    z_k = P_roots2[k]
    println(rpad(k, 4),
        " & ", rpad(z_k, 20),
        " & ", rpad(abs(P_polynomial2(z_k)), 20),
        " & ", rpad(abs(p(z_k)), 20),
        " & ", rpad(abs(z_k - k), 20),
        " \\\\\\hline")
end