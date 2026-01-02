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
end


function Base.getindex(M::BlockMatrix, i::Int, j::Int)
    return M.matrix[i, j]
end


function Base.setindex!(M::BlockMatrix, value::Float64, i::Int, j::Int)
    M.matrix[i, j] = value
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

function get_blockmatrix(size::Int, block_size::Int)
    block_no = Int(size / block_size)
    A = spzeros(size, size)
    return BlockMatrix(A, size, block_size, block_no)
end

function get_blockmatrix(size::Int, block_size::Int, Vs::Vector{Tuple{Int, Int, Float64}})
    M = get_blockmatrix(size, block_size)
    for (i, j, v) in Vs
        M[i, j] = v
    end
    return M
end



end