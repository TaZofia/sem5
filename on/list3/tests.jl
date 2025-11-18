include("roots.jl")
using .roots
using Test

@testset "roots tests" begin
    
    epsilon = delta = 10^-6

    @testset "mbisekcji tests" begin

        @testset "znajduje pierwiastek prosty" begin
            f(x) = x - 2.0
            # przedział [1,4] zawiera pierwiastek 2.0
            real_root = 2.0
            r, v, it, err = mbisekcji(f, 1.0, 4.0, delta, epsilon)
            @test err == 0
            @test isfinite(r)
            @test isfinite(v)
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta
            @test it >= 0
        end
        """
        @testset "brak zmiany znaku na końcach -> błąd" begin
            f(x) = x^2 + 1.0  # zawsze dodatnia, brak pierwiastka rzeczywistego
            r, v, it, err = mbisekcji(f, -1.0, 1.0, 1e-8, 1e-12)
            @test err != 0
            @test r === Nothing
            @test v === Nothing
            @test it == 0
        end
    
        @testset "nie skończone wartości -> błąd" begin
            f(x) = 1.0 / x   # singularność w 0, ale końce przedziału zawierają nieskończoność gdy 0 leży na końcu
            r, v, it, err = mbisekcji(f, 0.0, 1.0, 1e-8, 1e-12)
            @test err != 0
            @test r === Nothing
            @test v === Nothing
            @test it == 0
        end
    
        @testset "zakończenie przez delta - szybkie zatrzymanie" begin
            f(x) = x^2 - 4.0
            # ustawiamy bardzo dużą delta, więc warunek center <= delta powinien od razu zatrzymać algorytm
            r, v, it, err = mbisekcji(f, 1.0, 3.0, 10.0, 1e-12)
            @test err == 0
            @test it == 1  # powinna wykonać się jedna iteracja i przerwać
            @test isfinite(r)
            @test isfinite(v)
        end
    
        @testset "zakończenie przez epsilon (wartości funkcji) - behavior test" begin
            # Ten test sprawdza, że zwracana wartość v jest bliska 0 (oczekiwane zachowanie).
            # Jeśli implementacja kończy na podstawie argumentu zamiast wartości funkcji,
            # test wykaże rozbieżność i będzie sygnałem do poprawy implementacji.
            f(x) = sin(x)
            # pierwiastek w 0 leży w [-0.1, 0.1]
            r, v, it, err = mbisekcji(f, -0.1, 0.1, 1e-12, 1e-8)
            @test err == 0
            @test isapprox(v, 0.0; atol=1e-6)
            @test abs(r) <= 0.1
        end
    
        @testset "test parametryczny - kilka przypadków" begin
            cases = [
                (f = x -> x - 1.0, a=0.0, b=2.0, root=1.0),
                (f = x -> x^3 - 8.0, a=1.0, b=3.0, root=2.0),
                (f = x -> exp(x) - 1.0, a=-1.0, b=1.0, root=0.0)
            ]
            for c in cases
                r, v, it, err = mbisekcji(c.f, c.a, c.b, 1e-10, 1e-12)
                @test err == 0
                @test isapprox(v, 0.0; atol=1e-6)
                @test isapprox(r, c.root; atol=1e-5)
            end
        end
        """


        
    end



end