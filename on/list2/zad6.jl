# Zofia Tarchalska
using Plots

function recurency(c, x)
    x_vals = Float64[]
    println("Iter | x")
    for i in 1:40
        push!(x_vals, x)
        x = x^2 + c
        println(rpad(string(i), 5), "| ", x)
    end
    return x_vals
end

# plot with x value in wach iteration - not important
function plot_sequence(x_vals, c, x0)
    n_vals = 0:length(x_vals)-1
    plot(n_vals, x_vals, seriestype=:scatter, markersize=3,
        title="Case: c=$c, x0=$x0", xlabel="n", ylabel="xₙ")
end

# more important plot
function cobweb_plot(x_vals, c, x0; xrange=(-3, 3), yrange=(-3, 3))
    f(x) = x^2 + c
    xs = range(xrange[1], xrange[2], length=400)

    p = plot(xs, f.(xs), legend=false)
    plot!(p, xs, xs, linestyle=:dash)

    x = x0
    for y in x_vals
        y = f(x)
        plot!(p, [x, x], [x, y], color=:black)   # vertical to f(x)
        plot!(p, [x, y], [y, y], color=:black)   # horizontal to diagonal
        x = y
    end

    xlims!(p, xrange)
    ylims!(p, yrange)
    title!(p, "Cobweb: c=$c, x0=$x0")
    xlabel!(p, "x")
    ylabel!(p, "y")
    return p
end

c1 = -2.0
x_arr1 = [1.0, 2.0, 1.99999999999999]

c2 = -1.0
x_arr2 = [1, -1, 0.75, 0.25]

global case_num = 1

println("c = ", c1)
for x in x_arr1
    println("x = ", x)
    all_values = recurency(c1, x) 
    p = plot_sequence(all_values, c1, x)
    savefig(p, "plot$(case_num).png")

    pc = cobweb_plot(all_values, c1, x)
    savefig(pc, "plot$(case_num)_cobweb.png")

    global case_num += 1
end

println("c = ", c2)
for x in x_arr2
    println("x = ", x)
    all_values2 = recurency(c2, x)
    p2 = plot_sequence(all_values2, c2, x)
    savefig(p2, "plot$(case_num).png")

    pc2 = cobweb_plot(all_values2, c2, x)
    savefig(pc2, "plot$(case_num)_cobweb.png")

    global case_num += 1
end



