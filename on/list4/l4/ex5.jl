# Zofia Tarchalska
include( "interpolation.jl")

using .Interpolation
using Plots

function ex5()
    wezly = :rownoodlegle

    n_values = [5, 10, 15]
    f1(x) = exp(x)
    f2(x) = x^2*sin(x)

    for n in n_values
        result1 = rysujNnfx(f1, 0.0, 1.0, n, wezly)
        result2 = rysujNnfx(f2, -1.0, 1.0, n, wezly)

        savefig(result1, "ex5_results\\ex5_a_rownoodlegle_n$n.png")
        savefig(result2, "ex5_results\\ex5_b_rownoodlegle_n$n.png")      
    end 
end

ex5()