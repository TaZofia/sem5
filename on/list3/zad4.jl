# Zofia Tarchalska

include("roots.jl")
using .roots

delta = 1/2 * 10^-5
epsilon = 1/2 * 10^-5

f(x) = sin(x) - 0.25*x^2
df(x) = cos(x) - 0.5*x


res1 = mbisekcji(f, 1.5, 2.0, delta, epsilon)
res2 = mstycznych(f, df, 1.5, delta, epsilon, 50)
res3 = msiecznych(f, 1.0, 2.0, delta, epsilon, 50)

resp = [("metoda bisekcji", res1), ("metoda stycznych", res2), ("metoda siecznych", res3)]

for i in resp

    println(i[1])
    results = i[2]

    println("r = ", results[1])
    println("v = ", results[2])
    println("it = ", results[3])
    println("err = ", results[4])

    println()
end
