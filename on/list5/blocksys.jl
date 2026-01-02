# Zofia Tarchalska
include("matrix.jl")

module blocksys

export generate_right_hand_side, gauss_elimination, gauss_elimination_with_main_element, generate_lu!, generate_lu_with_main_element!, solve_by_lu!, solve_by_lu_with_main_element!, solve_with_lu!, solve_with_lu_with_main_element!
using Main.Matrix

"""
Funkcja wyznaczająca wektor prawych stron dla podanej macierzy A przy założeniu, że wektor rozwiązań x
składa się z samych jedynek.
A - macierz taka jak na liście
"""
function generate_right_hand_side(A::BlockMatrix)
    n = A.size[1]
    Rhs = zeros(Float64, n)
    for i in 1:n

        start = convert(Int, max(i - (2 + A.block_size), 1))
        finish = convert(Int, min(i + A.block_size, n))

        for j in start:finish
            Rhs[i] += A[i, j]
        end
    end
    return Rhs
end


"""
Funkcja, która rozwiązuje układ równań metodą eliminacji Gaussa bez wyboru elementu głównego
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n

"""
function gauss_elimination(A::BlockMatrix, b::Vector{Float64})
    println("in")
    n = A.size[1]
    for k in 1 : n-1
        if k%1000 == 0
            println("wiersz: ", k)
        end
        for i in k+1 : min(n, k + A.block_size + 1)
          
            if A[k, k] == 0
                error("Zero value on the diagonal of A at index ($k, $k)")
                return
            end

            m = A[i, k] / A[k, k]
            A[i, k] = 0.0

            for j in k+1 : min(n, k + A.block_size + 1)
                A[i, j] -= m * A[k, j]
            end

            b[i] -= m * b[k]
            
        end
    end

    # wyznaczanie wektora x
    x = zeros(n)
    x[n] = b[n] / A[n, n]
    for i in n-1 : -1 : 1
        x[i] = b[i]
        for j in i+1 : min(n, i + 2 + A.block_size )
            x[i] -= A[i, j] * x[j]
        end
        x[i] /= A[i, i]
    end
    return x
end



"""
Funkcja, która rozwiązuje układ równań metodą eliminacji Gaussa z częściowym wyborem elementu głównego.
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n
"""

function gauss_elimination_with_main_element(A::BlockMatrix, b::Vector{Float64})
    n = A.size[1]
    p = collect(1:n)      # wektor permutacji, początkowo nic nie jest zmienione, więc numer wiersza odpowiada indeksowi
   
    for k in 1 : n-1
        bound = min(n, k + A.block_size + 1)

        pivot = k;      # pivot będzie wskazywać indeks największego elementu w kolumnie
        for r in k:bound
            if abs(A[p[r], k]) > abs(A[p[pivot], k])
                pivot = r
            end
        end

        p[k], p[pivot] = p[pivot], p[k]

  

        # eliminacja 
        for i in k+1 : bound
            z = A[p[i], k] / A[p[k], k]
            A[p[i], k] = 0.0

            for j in k+1 : min(n, k + 2 * A.block_size)
                A[p[i], j] -= z * A[p[k], j]
            end
            b[p[i]] -= z * b[p[k]]
        end
    end

    x = zeros(n)

    x[n] = b[p[n]] / A[p[n], n]
    for i in n-1 : -1 : 1
        x[i] = b[p[i]]
        for j in i+1 : min(n, i + 2 * A.block_size)
            x[i] -= A[p[i], j] * x[j]
        end
        x[i] /= A[p[i], i]
    end
    return x
end

"""
Funkcja wyznaczająca rozkład LU dla podanej macierzy współczynników. Bez wyboru elementu głównego.
A - macierz współczynników będąca postaci opisanej na liście (ulega zmianom)
"""
function generate_lu!(A::BlockMatrix)    
    n = A.size

    for k in 1 : n-1
        for i in k+1 : min(n, k + A.block_size + 1)
          
            if A[k, k] == 0
                error("Zero value on the diagonal of A at index ($k, $k)")
                return
            end
            l = A[i, k] / A[k, k]
            A[i, k] = l                 # dolnotórjkątne zapisywanie współczynników l

            for j in k+1 : min(n, k + A.block_size + 1)
                A[i, j] -= l * A[k, j]  # aktualizowanie górnotrójkątnej części macierzy
            end 
        
        end
    end
end

"""
Funkcja rozwiązująca układ równań dla podanego wektora prawych stron i rozkładu LU macierzy współczynników.

LU - macierz kwadratowa, w której pod przekątną zapisane są elementy macierzy dolnotrójkątnej L, a nad przekątną elementy macierzy górnotrójkątnej U
b - wektor prawych stron długości n (ulega zmianom)
"""
function solve_with_lu!(LU::BlockMatrix, b::Vector{Float64})
    n = LU.size

    # Ly = b
    # nadpisujemy wektor b i zapisujemy w nim rozwiązanie czyli wektor y 
    for k in 1 : n - 1
        for i in k + 1 : min(n, k + LU.block_size + 1)
            b[i] -= LU[i, k] * b[k]         # L[i, k] - kolejne elementy od przekątnej w dół kolumny
        end
    end

    # Ux = y
    # teraz b przechowuje nasz y
    # nasz x to y przez U
    x = zeros(Float64, n)
    for i in n : -1 : 1
        x[i] = b[i]
        for j in i+1 : min(n, i + LU.block_size)
            x[i] -= LU[i, j] * x[j]
        end
        x[i] /= LU[i, i]
    end
    return x
end


"""
Funkcja rozwiązująca układ równań postaci opisanej na liście z wykorzystaniem rozkładu LU.
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n 
"""
function solve_by_lu!(A, b)
    generate_lu!(A)
    return solve_with_lu!(A, b)
end



"""
Funkcja wyznaczająca rozkład LU z wykorzystaniem częściowego wyboru dla podanej macierzy współczynników. Z częściowym wyborem elementu głównego.

A - macierz taka jak na liście o wymiarach nxn (ulega zmianom)
p - wektor permutacji
"""
function generate_lu_with_main_element!(A::BlockMatrix)
    n = A.size
    p = [1:n;]
    for k in 1 : n-1
        bound = min(n, k + A.block_size + 1)
        
        j = k;     
        for r in k:bound
            if abs(A[p[r], k]) > abs(A[p[j], k])
                j = r
            end
        end

        p[k], p[j] = p[j], p[k]
        for i in k+1 : bound
            z = A[p[i], k] / A[p[k], k]
            A[p[i], k] = z
            for j in k+1 : min(n, k + 2 * A.block_size)
                A[p[i], j] -= z * A[p[k], j]
            end
        end
    end
    return p
end


"""
Funkcja rozwiązująca układ równań dla podanego wektora prawych stron i rozkładu LU macierzy współczynników wiersza
z wektorem permutacji uzyskanym podczas generowania rozkładu z częściowym wyborem.
LU - macierz kwadratowa, w której pod przekątną zapisane są elementy macierzy dolnotrójkątnej L, a nad przekątną elementy macierzy górnotrójkątnej U

p - wektor permutacji długości n
b - wektor prawych stron długości n  (ulega zmianom)
"""
function solve_with_lu_with_main_element!(LU::BlockMatrix, p::Vector{Int}, b::Vector{Float64})
    n = LU.size

    # Ly = b
    for k in 1:n-1
        for i in k+1:min(n, 2 * LU.block_size + k)
            b[p[i]] -= LU[p[i], k] * b[p[k]]
        end
    end    

    # Ux = y
    x = zeros(Float64, n)
    x[n] = b[p[n]] / LU[p[n], n]
    for i in n-1 : -1 : 1
        x[i] = b[p[i]]
        for j in i+1 : min(n, i + 2 * LU.block_size)
            x[i] -= LU[p[i], j] * x[j]
        end
        x[i] /= LU[p[i], i]
    end
    return x
end


"""
Funkcja rozwiązująca układ równań postaci opisanej na liście z wykorzystaniem rozkładu LU i częściowym wyborem.
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n
"""
function solve_by_lu_with_main_element!(A, b)
    P = generate_lu_with_main_element!(A)
    return solve_with_lu_with_main_element!(A, P, b)
end


end

