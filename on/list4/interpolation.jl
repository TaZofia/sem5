# Zofia Tarchalska

module Interpolation
export ilorazyRoznicowe, warNewton, naturalna, rysujNnfx
using Plots

"""
Oblicza ilorazy różnicowe dla zadanych węzłów interpolacji.
x : wektor węzłów interpolacji
f : wektor wartości funkcji w punktach z x 
"""
function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})

    x_len = length(x)
    fx = zeros(Float64, x_len)
    for i in 1:x_len
        fx[i] = f[i]
    end
    for j in 2:x_len
        for i in x_len:-1:j
            fx[i] = (fx[i] - fx[i-1])/(x[i]-x[i-j+1])
        end
    end
    return fx
end

"""
Oblicza wartość wielomianu interpolacyjnego w postaci Newtona w punkcie t.
x : wektor węzłów interpolacji.
fx : wektor ilorazów różnicowych (wynik funkcji `ilorazyRoznicowe`).
t : punkt, w którym obliczamy wartość wielomianu.
"""
function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(x) - 1

    w = fx[n + 1]
    for i in n:-1:1
        w = w * (t - x[i])  + fx[i]  
    end
    return w
end


"""
Przekształca wielomian interpolacyjny z postaci Newtona do postaci naturalnej
(czyli klasycznej sumy współczynników przy kolejnych potęgach x).
x : wektor węzłów interpolacji.
fx : wektor ilorazów różnicowych.
"""
function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    n = length(x)
    a = zeros(n)
    a[n] = fx[n]
    for i in (n-1):-1:1
        a[i] = fx[i] - x[i] * a[i+1]
        for j in (i+1):(n-1)
            a[j] += -x[i] * a[j+1]
        end
    end
    return a
end

"""
Rysuje wykres funkcji `f` oraz jej wielomianu interpolacyjnego Newtona
dla zadanych węzłów (równoodległych lub Czebyszewa).

f : funkcja, którą interpolujemy.
a, b : początek i koniec przedziału interpolacji.
n : stopień wielomianu (liczba węzłów = n+1).
wezly : sposób wyboru węzłów (`:rownoodlegle` lub `:czebyszew`).

"""

function rysujNnfx(f,a::Float64,b::Float64,n::Int,  wezly::Symbol = :rownoodlegle)

    x = zeros(n+1)
    y = zeros(n+1)
    h = (b-a)/n

    if wezly == :czebyszew
        for k in 0:n
            x[k+1] = (a+b)/2 + (b-a)/2*cos((2*k+1)*pi/(2*n+2))
            y[k+1] = f(x[k+1])
        end 
    elseif wezly == :rownoodlegle
        for k in 0:n
            x[k+1] = a + k*h
            y[k+1] = f(x[k+1])
        end
    else
        println("[ERROR] wrong wezly")
        return
    end


    c = ilorazyRoznicowe(x, y)

    points = 50 * (n+1)         # siatka punktów (50 razy gęściej niż liczba węzłów)
    dx = (b-a)/(points-1)
    xs = zeros(points)          # punkty w przedziale [a, b]
    poly = zeros(points)        # wartości przyjmowane przez wielomian w tych punktach
    func = zeros(points)        # wartości przyjmowane przez funckję w tych punktach
    xs[1] = a
    poly[1] = func[1] = y[1]

    for i in 2:points
        xs[i] = xs[i-1] + dx
        poly[i] = warNewton(x, c, xs[i])
        func[i] = f(xs[i])
    end
    p = plot(xs, [poly func], label=["wielomian" "funkcja"], title="n = $n")
    return p
end


end