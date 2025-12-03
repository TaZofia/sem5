include("interpolation")

using .Interpolation
using Test

@testset "testy wszystkich 4 funkcji" begin
    @testset "testy ilorazyRoznicowe" begin
        @testset "funckja kwadratowa" begin
            # weźmy funkcję x^2
            x = [-1.0, 0.0, 1.0, 2.0]
            y = [1.0, 0.0, 1.0, 4.0]
            fx = ilorazyRoznicowe(x, y)
            @test fx = [1.0, -1.0, 1.0, 0.0]
        end
        @testset "funkcja liniowa" begin
            # 2x + 1
            x = [0.0, 1.0, 2.0]
            y = [1.0, 3.0, 5.0]
            fx = ilorazyRoznicowe(x, y)
            @test fx = [1.0, 2.0, 0.0]
        end
    end
end
