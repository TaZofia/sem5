using LinearAlgebra

function hilb(n::Int)
    # Function generates the Hilbert matrix  A of size n,
    #  A (i, j) = 1 / (i + j - 1)
    # Inputs:   
    #	n: size of matrix A, n>=1
    #
    #
    # Usage: hilb(10)
    #
    # Pawel Zielinski
    if n < 1
        error("size n should be >= 1")
    end
    return [1 / (i + j - 1) for i in 1:n, j in 1:n]
end

function matcond(n::Int, c::Float64)
    # Function generates a random square matrix A of size n with
    # a given condition number c.
    # Inputs:
    #	n: size of matrix A, n>1
    #	c: condition of matrix A, c>= 1.0
    #
    # Usage: matcond(10, 100.0)
    #
    # Pawel Zielinski
    if n < 2
        error("size n should be > 1")
    end
    if c< 1.0
        error("condition number  c of a matrix  should be >= 1.0")
    end
    (U,S,V)=svd(rand(n,n))
    return U*diagm(0 =>[LinRange(1.0,c,n);])*V'
end

function solve(A, n)
    x = ones(n)       # vector with ones - exact result
    b = A * x


    x_gauss = A \ b

    x_inv = inv(A) * b

    relative_error_gauss = norm(x_gauss - x) / norm(x)
    relative_error_inv = norm(x_inv - x) / norm(x)

    println(rpad(n,4), rpad(cond(A),25), rpad(rank(A),8), 
        rpad(relative_error_gauss,25), rpad(relative_error_inv,25))
end

println("Macierz Hilberta\n")
println(rpad("n", 4),
        rpad("cond(A)", 25), 
        rpad("rank(A)", 8), 
        rpad("error Gauss", 25), 
        rpad("error inv", 25))

for n in 1:50
    solve(hilb(n), n)
end

println("\nMacierz losowa\n")
println(rpad("n", 4), 
        rpad("c", 25), 
        rpad("rank(A)", 8), 
        rpad("error Gauss", 25), 
        rpad("error inv", 25))

for n in [5,10,20]
    for c in [0,1,3,7,12,16]
        solve(matcond(n, 10.0^c), n)
    end
end