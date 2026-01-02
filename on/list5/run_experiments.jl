# Zofia Tarchalska

include("file_manager.jl")

using .FileManager
using .blocksys
using  Plots, Statistics

paths = [[16, ".\\Dane16_1_1\\A.txt", ".\\Dane16_1_1\\b.txt"],
        [10000, ".\\Dane10000_1_1\\A.txt", ".\\Dane10000_1_1\\b.txt"],
        [50000, ".\\Dane50000_1_1\\A.txt", ".\\Dane50000_1_1\\b.txt"],
        [100000, ".\\Dane100000_1_1\\A.txt", ".\\Dane100000_1_1\\b.txt"],
        [500000, ".\\Dane500000_1_1\\A.txt", ".\\Dane500000_1_1\\b.txt"],
        [750000, ".\\Dane750000_1_1\\A.txt", ".\\Dane750000_1_1\\b.txt"],
        [1000000, ".\\Dane1000000_1_1\\A.txt", ".\\Dane1000000_1_1\\b.txt"]
        ]

sizes = Int[]
t_gauss = Float64[]; t_gauss_main = Float64[]; t_lu = Float64[]; t_lu_main = Float64[]
m_gauss = Int[]; m_gauss_main = Int[]; m_lu = Int[]; m_lu_main = Int[]

try
    A0 = read_A(paths[1][2])
    b0 = read_b(paths[1][3])

    gauss_elimination(deepcopy(A0), deepcopy(b0))
    gauss_elimination_with_main_element(deepcopy(A0), deepcopy(b0))
    solve_by_lu!(deepcopy(A0), deepcopy(b0))
    solve_by_lu_with_main_element!(deepcopy(A0), deepcopy(b0))
catch e
    @warn "Warmup failed: $e"
end



for arr in paths
    
    size = arr[1]
    A = read_A(arr[2])
    b = read_b(arr[3])

    GC.gc()
    
    res1 = @timed gauss_elimination(deepcopy(A), deepcopy(b))
    res2 = @timed gauss_elimination_with_main_element(deepcopy(A), deepcopy(b))
    res3 = @timed solve_by_lu!(deepcopy(A), deepcopy(b))
    res4 = @timed solve_by_lu_with_main_element!(deepcopy(A), deepcopy(b))

    # z tego co zwraca @timed potrzebny jest tylko time i bytes
    _, time1, bytes1, _, _ = res1
    _, time2, bytes2, _, _ = res2
    _, time3, bytes3, _, _ = res3
    _, time4, bytes4, _, _ = res4

    open(".\\results\\results.txt", "a") do io 
        println(io, size)
        println(io, time1, bytes1)
        println(io, time2, bytes2)
        println(io, time3, bytes3)
        println(io, time4, bytes4)
    end
    println("Zapisano dla: ", size)

  
    push!(sizes, size)
    push!(t_gauss, time1)
    push!(m_gauss, bytes1)
    push!(t_gauss_main, time2)
    push!(m_gauss_main, bytes2)
    push!(t_lu, time3)
    push!(m_lu, bytes3)
    push!(t_lu_main, time4)
    push!(m_lu_main, bytes4)
    
end


plt_time = plot(sizes, t_gauss, label="Gauss", marker=:o)
plot!(sizes, t_gauss_pivot, label="Gauss z wyborem", marker=:diamond)
plot!(sizes, t_lu, label="LU", marker=:star5)
plot!(sizes, t_lu_pivot, label="LU z wyborem", marker=:square)

xlabel!("Rozmiar macierzy (n)")
ylabel!("Czas wykonania (s)")
title!("Czas wykonania algorytmów")

xscale!(:log10)   
yscale!(:log10)

legend(:topleft)

plt_mem = plot(sizes, m_gauss, label="Gauss", marker=:o)
plot!(sizes, m_gauss_pivot, label="Gauss z wyborem", marker=:diamond)
plot!(sizes, m_lu, label="LU", marker=:star5)
plot!(sizes, m_lu_pivot, label="LU z wyborem", marker=:square)

xlabel!("Rozmiar macierzy (n)")
ylabel!("Alokacje pamięci (B)")
title!("Alokacje pamięci (mediana @timed bytes)")

xscale!(:log10)
yscale!(:log10)

legend(:topleft)


display(plt_time)
display(plt_mem)
