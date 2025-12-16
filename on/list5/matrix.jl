# Zofia Tarchalska
module Matrix
export BlockMatrix, get_blockmatrix, get_bottom_row, get_top_row, get_first_column, get_last_column, get_nonzero_columns, get_nonzero_rows

using SparseArrays

"""
Struktura odzwierciedlająca macierz zadaną na liście
"""
mutable struct BlockMatrix
    matrix::SparseMatrixCSC{Float64, Int}
    size::Int               # rozmiar macierzy A
    block_size::Int         # rozmiar macierzy Ak, Bk, Ck
    blocks_no::Int
    operation_count::Int
end


function Base.getindex(M::BlockMatrix, i::Int, j::Int)
    M.operation_count += 1
    return M.matrix[i, j]
end


function Base.setindex!(M::BlockMatrix, value::Float64, i::Int, j::Int)
    M.matrix[i, j] = value
end


"""
Funkcja, która zwraca inseks pierwszej niezerowej kolumny

M - macierz
row - wiersz 
"""
function get_first_column(M::BlockMatrix, row::Int)
    return max(1, row - ((row - 1) % M.block_size) - 1)
end


"""
Funkcja zwracająca dla danego wiersza macierzy zakres kolumn, w których występują niezerowe wartości.

M - macierz
row - wiersz 
"""
function get_nonzero_columns(M::BlockMatrix, row::Int)
    return get_first_column(M, row) : get_last_column(M, row)
end


"""
Funkcja, która zwraca indeks ostatniej kolumy z niezerową wartością

M - macierz
row - wiersz macierzy
"""
function get_last_column(M::BlockMatrix, row::Int)
    return min(M.size, M.block_size + row)
end



function multiply_matrix_by_vector(M::BlockMatrix, V::Vector{Float64})
    if length(V) != M.size
        error("Wrong size of vector")
    end
    R = zeros(Float64, M.size)
    for i in 1:M.size
        for j in get_columns(M, i)
            R[i] += V[j] * M[i, j]          # klasyczne mnożenie macierzy przez wektor
        end
    end
    return R
end


"""
Funkcja tworząca macierz postaci zadanej na liście wypełnioną podanymi wartościami.

size - szerokość/wysokość macierzy
block_size - szerokość/wysokość bloku (musi być dzielnikiem size)
Vs - wektor trójek (i, j, v), gdzie i, j to indeksy a v to wartość
"""
function get_blockmatrix(size::Int, block_size::Int, Vs::Vector{Tuple{Int, Int, Float64}})
    M = get_blockmatrix(size, block_size)
    for (i, j, v) in Vs
        M[i, j] = v
    end
    return M
end


"""
Funkcja tworząca pustą macierz postaci zadanej na liście.
size - szerokość/wysokość macierzy
block_size - szerokość/wysokość bloku (musi być dzielnikiem size)
"""
function get_blockmatrix(size::Int, block_size::Int)
    block_no = Int(size / block_size)
    A = spzeros(size, size)
    return BlockMatrix(A, size, block_size, block_no, 0)
end



"""
Funkcja zwracająca dla danej kolumny macierzy indeks pierwszego od od góry wiersza z niezerową wartością.
M - macierz
col - kolumna macierzy

"""
function get_top_row(M::BlockMatrix, col::Int)
    return max(1, col - M.block_size)
end


"""
Funkcja zwracająca dla danej kolumny macierzy indeks pierwszego od od dołu wiersza z niezerową wartością.
M - macierz
column - kolumna macierzy
"""
function get_bottom_row(M::BlockMatrix, col::Int)
    return min(M.size, col + M.block_size - (col % M.block_size))
end


"""
Funkcja zwracająca dla danej kolumny macierzy zakres wierszy, w których występują niezerowe wartości.
M - macierz
colv- kolumna macierzy

"""
function get_nonzero_rows(M::BlockMatrix, col::Int)
    return get_top_row(M, col) : get_bottom_row(M, col)
end
end

