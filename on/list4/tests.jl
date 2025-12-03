include("interpolation.jl")

using .Interpolation
using Test

@testset "testy wszystkich 4 funkcji" begin
    @testset "testy ilorazyRoznicowe" begin
        @testset "funckja kwadratowa" begin
            # weźmy funkcję x^2
            x = [-1.0, 0.0, 1.0, 2.0]
            y = [1.0, 0.0, 1.0, 4.0]
            fx = ilorazyRoznicowe(x, y)
            @test fx == [1.0, -1.0, 1.0, 0.0]
        end
        @testset "funkcja liniowa" begin
            # 2x + 1
            x = [0.0, 1.0, 2.0]
            y = [1.0, 3.0, 5.0]
            fx = ilorazyRoznicowe(x, y)
            @test fx == [1.0, 2.0, 0.0]
        end
    end
    @testset "testy warNewton" begin
        @testset "funkcja liniowa" begin
            # 2x + 1
            x = [0.0, 1.0, 2.0]
            y = [1.0, 3.0, 5.0]
            fx = ilorazyRoznicowe(x, y)
            val1 = warNewton(x, fx, 0.0)
            val2 = warNewton(x, fx, 1.5)
            @test val1 == 1.0
            @test val2 == 4.0
        end
        @testset "funkcja kwadratowa" begin
            # x^2
            x = [-1.0, 0.0, 1.0, 2.0]
            y = [1.0, 0.0, 1.0, 4.0]
            fx = ilorazyRoznicowe(x, y)
            val1 = warNewton(x , fx, -2.0)
            val2 = warNewton(x, fx, 1.5)
            val3 = warNewton(x, fx, 3.0)
            @test val1 == 4.0
            @test val2 == 2.25
            @test val3 == 9.0
        end
    end
    @testset "testy naturalna" begin
        @testset "naturalna - funkcja liniowa" begin
            # f(x) = 2x + 1
            x = [0.0, 1.0, 2.0]
            y = [1.0, 3.0, 5.0]
            fx = ilorazyRoznicowe(x, y)
            a = naturalna(x, fx)
            @test a ≈ [1.0, 2.0, 0.0]
        end
        
        @testset "naturalna - funkcja kwadratowa" begin
            # f(x) = x^2
            x = [-1.0, 0.0, 1.0, 2.0]
            y = [1.0, 0.0, 1.0, 4.0]
            fx = ilorazyRoznicowe(x, y)
            a = naturalna(x, fx)
            @test a ≈ [0.0, 0.0, 1.0, 0.0]
        end
        
        @testset "naturalna - funkcja stała" begin
            # f(x) = 5
            x = [0.0, 1.0, 2.0]
            y = [5.0, 5.0, 5.0]
            fx = ilorazyRoznicowe(x, y)
            a = naturalna(x, fx)
            @test a ≈ [5.0, 0.0, 0.0]
        end
    end
    @testset "testy rysujNnfx" begin
        @testset "funkcja liniowa, węzły równoodległe" begin
            f(x) = 2x + 1
            a, b, n = 0.0, 2.0, 2
            # wywołanie funkcji (zwraca wykres, ale nas interesują dane wewnętrzne)
            p = rysujNnfx(f, a, b, n, :rownoodlegle)
    
            # sprawdzamy interpolację w węzłach
            x = [0.0, 1.0, 2.0]
            y = [f(xi) for xi in x]
            fx = ilorazyRoznicowe(x, y)
            for (xi, yi) in zip(x, y)
                @test warNewton(x, fx, xi) ≈ yi atol=1e-12 rtol=1e-12
            end
        end
    
        @testset "funkcja kwadratowa, węzły Czebyszewa" begin
            f(x) = x^2
            a, b, n = -1.0, 1.0, 3
            p = rysujNnfx(f, a, b, n, :czebyszew)
    
            # wyznaczamy węzły Czebyszewa ręcznie
            x = [(a+b)/2 + (b-a)/2 * cos((2k+1)*pi/(2*(n+1))) for k in 0:n]
            y = [f(xi) for xi in x]
            fx = ilorazyRoznicowe(x, y)
    
            # sprawdzamy interpolację w węzłach
            for (xi, yi) in zip(x, y)
                @test warNewton(x, fx, xi) ≈ yi atol=1e-12 rtol=1e-12
            end
        end
    end
end
