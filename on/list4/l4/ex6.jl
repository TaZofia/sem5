# Zofia Tarchalska
include( "interpolation.jl")

using .Interpolation
using Plots

function ex6()

    symbols = [:czebyszew, :rownoodlegle]
    n_values = [5, 10, 15]

    f1(x) = abs(x)
    f2(x) = 1/(1+x*x)

    for s in symbols
        for n in n_values
            result1 = rysujNnfx(f1, -1.0, 1.0, n, s)
            result2 = rysujNnfx(f2, -5.0, 5.0, n, s)
    
            savefig(result1, "ex6_results\\ex6_a_$(s)_n$(n).png")
            savefig(result2, "ex6_results\\ex6_b_$(s)_n$(n).png")              
        end
    end
end

ex6()