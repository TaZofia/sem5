# Zofia Tarchalska
include("matrix.jl")

module blocksys

export generate_right_hand_side, gauss_elimination, gauss_elimination_with_main_element, generate_lu!, generate_lu_with_main_element!, solve_by_lu!, solve_by_lu_with_main_element!, solve_with_lu!, solve_with_lu_with_main_element!
using Main.Matrix
using SparseArrays
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
    M = A.matrix
    n = A.size[1]
    # Build row-wise maps: Vector of Dict{Int,Float64}
    rows = [Dict{Int,Float64}() for _ in 1:n]
    for col in 1:M.n
        p1 = M.colptr[col]
        p2 = M.colptr[col+1]-1
        for p in p1:p2
            r = M.rowval[p]
            v = M.nzval[p]
            rows[r][col] = v
        end
    end

    # Forward elimination (no pivoting)
    for k in 1:n-1
        if !(haskey(rows[k], k))
            error("Zero pivot at ($k,$k)")
        end
        pivot = rows[k][k]
        # iterate over rows i = k+1 .. min(n, k + A.block_size + 1)
        for i in k+1 : min(n, k + A.block_size + 1)
            aik = get(rows[i], k, 0.0)
            if aik == 0.0
                continue
            end
            m = aik / pivot
            # subtract m * row k from row i for columns j in block window
            # iterate over entries of row k (only nonzeros)
            for (j, akj) in rows[k]
                if j <= k
                    continue
                end
                val = get(rows[i], j, 0.0) - m * akj
                if abs(val) < 1e-15
                    delete!(rows[i], j)
                else
                    rows[i][j] = val
                end
            end
            # set A[i,k] = 0
            delete!(rows[i], k)
            b[i] -= m * b[k]
        end
    end

    # Back substitution
    x = zeros(Float64, n)
    if !haskey(rows[n], n)
        error("Zero diagonal at ($n,$n)")
    end
    x[n] = b[n] / rows[n][n]
    for i in (n-1):-1:1
        s = b[i]
        for (j, aij) in rows[i]
            if j > i
                s -= aij * x[j]
            end
        end
        if !haskey(rows[i], i)
            error("Zero diagonal at ($i,$i)")
        end
        x[i] = s / rows[i][i]
    end
    return x
end



"""
Funkcja, która rozwiązuje układ równań metodą eliminacji Gaussa z częściowym wyborem elementu głównego.
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n
"""

function gauss_elimination_with_main_element(A::BlockMatrix, b::Vector{Float64})
    M = A.matrix
    n = A.size
    rows = [Dict{Int,Float64}() for _ in 1:n]
    for col in 1:M.n
        p1 = M.colptr[col]
        p2 = M.colptr[col+1]-1
        for p in p1:p2
            r = M.rowval[p]
            v = M.nzval[p]
            rows[r][col] = v
        end
    end

    # wektor permutacji: p[idx] = numer oryginalnego wiersza na pozycji idx
    p = collect(1:n)

    # Forward elimination z wyborem elementu głównego w ograniczonym przedziale
    for k in 1:n-1
        bound = min(n, k + A.block_size + 1)

        # wybór pivotu: szukamy r w [k, bound] maksymalizującego |A[p[r], k]|
        pivot = k
        maxval = abs(get(rows[p[k]], k, 0.0))
        for r in k+1:bound
            val = abs(get(rows[p[r]], k, 0.0))
            if val > maxval
                maxval = val
                pivot = r
            end
        end

        # zamiana w permutacji
        if pivot != k
            p[k], p[pivot] = p[pivot], p[k]
        end

        # sprawdzenie pivotu (po zamianie)
        pivot_val = get(rows[p[k]], k, 0.0)
        if pivot_val == 0.0
            error("Zero pivot at ($k,$k) after pivoting")
        end

        # eliminacja w wierszach p[i] dla i = k+1..bound
        for i in k+1:bound
            ai_k = get(rows[p[i]], k, 0.0)
            if ai_k == 0.0
                continue
            end
            z = ai_k / pivot_val

            # odejmij z * (wiersz pivot) od wiersza i, tylko dla kolumn > k
            for (j, akj) in rows[p[k]]
                if j <= k
                    continue
                end
                newval = get(rows[p[i]], j, 0.0) - z * akj
                if abs(newval) < 1e-15
                    # usuń element jeśli bliski zeru
                    if haskey(rows[p[i]], j)
                        delete!(rows[p[i]], j)
                    end
                else
                    rows[p[i]][j] = newval
                end
            end

            # ustaw A[p[i], k] = 0
            if haskey(rows[p[i]], k)
                delete!(rows[p[i]], k)
            end

            # aktualizuj b
            b[p[i]] -= z * b[p[k]]
        end
    end

    # Back substitution z uwzględnieniem permutacji p
    x = zeros(Float64, n)
    if get(rows[p[n]], n, 0.0) == 0.0
        error("Zero diagonal at ($n,$n)")
    end
    x[n] = b[p[n]] / rows[p[n]][n]

    for ii in (n-1):-1:1
        s = b[p[ii]]
        # sumujemy tylko po kolumnach j > ii
        for (j, aij) in rows[p[ii]]
            if j > ii
                s -= aij * x[j]
            end
        end
        if !haskey(rows[p[ii]], ii)
            error("Zero diagonal at ($ii,$ii)")
        end
        x[ii] = s / rows[p[ii]][ii]
    end

    return x
end

"""
Funkcja wyznaczająca rozkład LU dla podanej macierzy współczynników. Bez wyboru elementu głównego.
A - macierz współczynników będąca postaci opisanej na liście (ulega zmianom)
"""

function lu_factorize!(A::BlockMatrix; tol=1e-15)
    M = A.matrix
    n = A.size[1]
    # build row-wise dictionary representation
    rows = [Dict{Int,Float64}() for _ in 1:n]
    for col in 1:M.n
        p1 = M.colptr[col]
        p2 = M.colptr[col+1]-1
        for p in p1:p2
            r = M.rowval[p]
            v = M.nzval[p]
            rows[r][col] = v
        end
    end

    # forward elimination (no pivoting), store multipliers in rows[i][k]
    for k in 1:n-1
        if !haskey(rows[k], k)
            error("Zero pivot at ($k,$k)")
        end
        pivot = rows[k][k]
        for i in k+1 : min(n, k + A.block_size + 1)
            aik = get(rows[i], k, 0.0)
            if aik == 0.0
                continue
            end
            m = aik / pivot
            # store multiplier in L part (below diagonal)
            rows[i][k] = m
            # update row i for columns j > k using current row k (U entries)
            for (j, akj) in rows[k]
                if j <= k
                    continue
                end
                val = get(rows[i], j, 0.0) - m * akj
                if abs(val) < tol
                    delete!(rows[i], j)
                else
                    rows[i][j] = val
                end
            end
            # note: we keep rows[i][k] = m (multiplier) and do not keep original aik
        end
    end

    # rebuild sparse matrix from rows (L multipliers below diagonal, U on/above diagonal)
    I = Int[]; J = Int[]; V = Float64[]
    for i in 1:n
        for (j, v) in rows[i]
            push!(I, i); push!(J, j); push!(V, v)
        end
    end
    A.matrix = sparse(I, J, V, n, n)
    return A
end


"""
Funkcja rozwiązująca układ równań dla podanego wektora prawych stron i rozkładu LU macierzy współczynników.

LU - macierz kwadratowa, w której pod przekątną zapisane są elementy macierzy dolnotrójkątnej L, a nad przekątną elementy macierzy górnotrójkątnej U (bez jedynek na diagonalach)
b - wektor prawych stron długości n (ulega zmianom)
"""
function lu_solve!(A::BlockMatrix, b::Vector{Float64})
    M = A.matrix
    n = A.size[1]
    # build row-wise maps
    rows = [Dict{Int,Float64}() for _ in 1:n]
    for col in 1:M.n
        p1 = M.colptr[col]
        p2 = M.colptr[col+1]-1
        for p in p1:p2
            r = M.rowval[p]
            v = M.nzval[p]
            rows[r][col] = v
        end
    end

    # Forward substitution Ly = b
    y = copy(b)
    for k in 1:n-1
        for i in k+1 : min(n, k + A.block_size + 1)
            lik = get(rows[i], k, 0.0)   # multiplier L[i,k]
            if lik == 0.0
                continue
            end
            y[i] -= lik * y[k]
        end
    end

    # Back substitution Ux = y
    x = zeros(Float64, n)
    if !haskey(rows[n], n)
        error("Zero diagonal at ($n,$n)")
    end
    x[n] = y[n] / rows[n][n]
    for i in (n-1):-1:1
        s = y[i]
        for (j, aij) in rows[i]
            if j > i
                s -= aij * x[j]
            end
        end
        if !haskey(rows[i], i)
            error("Zero diagonal at ($i,$i)")
        end
        x[i] = s / rows[i][i]
    end

    return x
end




"""
Funkcja rozwiązująca układ równań postaci opisanej na liście z wykorzystaniem rozkładu LU.
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n 
"""
function solve_by_lu!(A, b)
    lu_factorize!(A)
    return lu_solve!(A, b)
end



"""
Funkcja wyznaczająca rozkład LU z wykorzystaniem częściowego wyboru dla podanej macierzy współczynników. Z częściowym wyborem elementu głównego.

A - macierz taka jak na liście o wymiarach nxn (ulega zmianom)
p - wektor permutacji
"""

function lu_with_main_element_factorize!(A::BlockMatrix; tol=1e-15)
    M = A.matrix
    n = A.size[1]
    p = collect(1:n)

    # build row-wise dictionary representation (original row indices)
    rows = [Dict{Int,Float64}() for _ in 1:n]
    for col in 1:M.n
        p1 = M.colptr[col]
        p2 = M.colptr[col+1]-1
        for idx in p1:p2
            r = M.rowval[idx]
            v = M.nzval[idx]
            rows[r][col] = v
        end
    end

    # factorization with partial pivoting inside block window
    for k in 1:n-1
        bound = min(n, k + A.block_size + 1)

        # find pivot row index r in k:bound maximizing |A[p[r],k]|
        j = k
        best = abs(get(rows[p[j]], k, 0.0))
        for r in k+1:bound
            val = abs(get(rows[p[r]], k, 0.0))
            if val > best
                best = val
                j = r
            end
        end

        # swap permutation entries
        p[k], p[j] = p[j], p[k]

        # check pivot
        pivot = get(rows[p[k]], k, 0.0)
        if abs(pivot) < tol
            error("Zero pivot (or below tol) at (p[$k],$k)")
        end

        # elimination within block window, store multipliers in rows[p[i]][k]
        for i in k+1:bound
            aik = get(rows[p[i]], k, 0.0)
            if abs(aik) < tol
                # ensure exact zero representation
                delete!(rows[p[i]], k)
                continue
            end
            m = aik / pivot
            rows[p[i]][k] = m
            # update row p[i] for columns j > k using row p[k]
            # iterate over U entries in row p[k]
            for (jcol, akj) in rows[p[k]]
                if jcol <= k
                    continue
                end
                val = get(rows[p[i]], jcol, 0.0) - m * akj
                if abs(val) < tol
                    delete!(rows[p[i]], jcol)
                else
                    rows[p[i]][jcol] = val
                end
            end
        end
    end

    # rebuild sparse matrix from rows (L multipliers below diagonal, U on/above diagonal)
    I = Int[]; J = Int[]; V = Float64[]
    for i in 1:n
        for (j, v) in rows[i]
            push!(I, i); push!(J, j); push!(V, v)
        end
    end
    A.matrix = sparse(I, J, V, n, n)

    return p
end

"""
Funkcja rozwiązująca układ równań dla podanego wektora prawych stron i rozkładu LU macierzy współczynników wiersza
z wektorem permutacji uzyskanym podczas generowania rozkładu z częściowym wyborem.
LU - macierz kwadratowa, w której pod przekątną zapisane są elementy macierzy dolnotrójkątnej L, a nad przekątną elementy macierzy górnotrójkątnej U

p - wektor permutacji długości n
b - wektor prawych stron długości n  (ulega zmianom)
"""
function lu_with_main_element_solve!(LU::BlockMatrix, p::Vector{Int}, b::Vector{Float64})
    M = LU.matrix
    n = LU.size

    # build row-wise maps
    rows = [Dict{Int,Float64}() for _ in 1:n]
    for col in 1:M.n
        p1 = M.colptr[col]
        p2 = M.colptr[col+1]-1
        for idx in p1:p2
            r = M.rowval[idx]
            v = M.nzval[idx]
            rows[r][col] = v
        end
    end

    # Forward substitution Ly = b (z uwzględnieniem permutacji p)
    y = copy(b)
    for k in 1:n-1
        for i in k+1 : min(n, 2 * LU.block_size + k)
            lik = get(rows[p[i]], k, 0.0)   # L[p[i],k]
            if lik == 0.0
                continue
            end
            y[p[i]] -= lik * y[p[k]]
        end
    end

    # Back substitution Ux = y (z uwzględnieniem permutacji p)
    x = zeros(Float64, n)
    if !haskey(rows[p[n]], n)
        error("Zero diagonal at (p[$n],$n)")
    end
    x[n] = y[p[n]] / rows[p[n]][n]
    for i in (n-1):-1:1
        s = y[p[i]]
        for (j, aij) in rows[p[i]]
            if j > i
                s -= aij * x[j]
            end
        end
        if !haskey(rows[p[i]], i)
            error("Zero diagonal at (p[$i],$i)")
        end
        x[i] = s / rows[p[i]][i]
    end

    return x
end



"""
Funkcja rozwiązująca układ równań postaci opisanej na liście z wykorzystaniem rozkładu LU i częściowym wyborem.
A - macierz taka jak na liście o wymiarach nxn
b - wektor prawych stron długości n
"""
function solve_by_lu_with_main_element!(A, b)
    P = lu_with_main_element_factorize!(A)
    return lu_with_main_element_solve!(A, P, b)
end


end

