include("file_manager.jl")
include("matrixgen.jl")

using .matrixgen
using .FileManager
using .blocksys
using Test

blockmat(2000, 10, 10.0, "matrix_A_test.txt")

A = read_A("matrix_A_test.txt")

x = ones(Float64, A.size)       # wektor x wypełniony samymi jedynkami

b = generate_right_hand_side(A) # generujemy odpowiadający macierzy A oraz wektorowi x, wektor b

@testset "Eliminacja Gaussa" begin
    @test isapprox(gauss_elimination(deepcopy(A), deepcopy(b)), x)
end

@testset "Eliminacja Gaussa z częściowym wyborem elementu głównego" begin
    @test isapprox(gauss_elimination_with_main_element(deepcopy(A), deepcopy(b)), x)
end

@testset "Rozwiązanie za pomocą LU" begin
    @test isapprox(solve_by_lu!(deepcopy(A), deepcopy(b)), x)
end

@testset "Rozwiązanie LU z częściowym wyborem elementu głównego" begin
    @test isapprox(solve_by_lu_with_main_element!(deepcopy(A), deepcopy(b)), x)
end



# TO DO sprawdzanie czy samo LU zostało dobrze wyznaczone?