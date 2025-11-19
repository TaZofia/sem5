# Zofia Tarchalska

include("roots.jl")
using .roots
using Test

@testset "roots tests" begin
    
    epsilon = delta = 10^-6

    @testset "mbisekcji tests" begin

        @testset "find root f(x) = x - 2" begin
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
        
        @testset "same sign at the beginning, end" begin
            f(x) = x^2 + 2.0  # zawsze dodatnia
            r, v, it, err = mbisekcji(f, -1.0, 1.0, delta, epsilon)
            @test err != 0
            @test r === Nothing
            @test v === Nothing
            @test it == 0
        end
    
        @testset "infinite values" begin
            f(x) = 1.0 / x   # funckja homograficzna
            r, v, it, err = mbisekcji(f, 0.0, 2.0, delta, epsilon)
            @test err != 0
            @test r === Nothing
            @test v === Nothing
            @test it == 0
        end
    
        @testset "find root f(x) = 0.1x^2 - 0.4" begin
            f(x) = 0.1*x^2 - 0.4
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
    end

    @testset "mstycznych tests" begin
        @testset "find root f(x) = x - 2" begin
            f(x) = x - 2.0
            pf(x) = 1.0
            real_root = 2.0
            r, v, it, err = mstycznych(f, pf, 2.5, delta, epsilon, 50)
            @test err == 0
            @test isfinite(r)
            @test isfinite(v)
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta
            @test it >= 0
        end

        @testset "find root f(x) = x^2 - 4" begin
            f(x) = x^2.0 - 4.0
            pf(x) = 2.0*x
            real_root = 2.0
            r, v, it, err = mstycznych(f, pf, 2.5, delta, epsilon, 50)
            @test err == 0
            @test isfinite(r)
            @test isfinite(v)
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta
            @test it >= 0
        end

        @testset "first x0 good enough" begin
            f(x) = x^2.0 - 4.0
            pf(x) = 2*x
            x0 = 2.0 + 1e-8
            real_root = 2.0
            r, v, it, err = mstycznych(f, pf, x0, delta, epsilon, 10)
            @test err == 0
            @test it == 0
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta 
        end

        @testset "derivative close to 0.0" begin
            f(x) = x^2 - 1
            pf(x) = 0   # oszustwo, ale sprawdzamy czy wyłapie błąd
            x0 = 0.0
            r, v, it, err = mstycznych(f, pf, x0, delta, epsilon, 50)
            @test err == 2
            @test isfinite(r)
            @test isfinite(v)
        end

        @testset "reach maxit" begin
            f(x) = x^3 + x
            pf(x) = 3*x^2 + 1
            real_root = 0.0
            r, v, it, err = mstycznych(f, pf, 0.5, delta, epsilon, 2)   # mało iteracji
            @test err == 1
            @test it == 2
        end
    end

    @testset "msiecznych tests" begin
        @testset "find root f(x) = x - 2" begin
            f(x) = x - 2.0
            real_root = 2.0
            r, v, it, err = msiecznych(f, 1.0, 3.0, delta, epsilon, 50)
            @test err == 0
            @test isfinite(r)
            @test isfinite(v)
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta
            @test it >= 0
        end
    
        @testset "find root f(x) = x^2 - 4" begin
            f(x) = x^2 - 4.0
            real_root = 2.0
            r, v, it, err = msiecznych(f, 1.0, 3.0, delta, epsilon, 50)
            @test err == 0
            @test isfinite(r)
            @test isfinite(v)
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta
            @test it >= 0
        end
    
        @testset "first x0 good enough" begin
            f(x) = x^2 - 4.0
            x0 = 2.0 + 1e-8
            x1 = 3.0
            real_root = 2.0
            r, v, it, err = msiecznych(f, x0, x1, delta, epsilon, 10)
            @test err == 0
            @test it == 0
            @test abs(v) <= epsilon
            @test abs(real_root - r) <= delta
        end
    
        @testset "non-finite values at endpoints" begin
            f(x) = 1.0 / x  # funkcja homograficzna
            r, v, it, err = msiecznych(f, 0.0, 1.0, delta, epsilon, 50)
            @test err == 1
            @test r === Nothing
            @test v === Nothing
            @test it == 0
        end
    
        @testset "reach maxit" begin
            f(x) = x^3 + x
            r, v, it, err = msiecznych(f, 0.5, 1.0, delta, epsilon, 2)
            @test err == 1
            @test it == 2
        end
    end
end