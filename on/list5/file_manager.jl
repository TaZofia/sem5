# Zofia Tarchalska 
include("blocksys.jl")

module FileManager
using SparseArrays
using Main.Matrix

export read_A, read_b, write_x, read_a_test, read_matrix

function read_A(filename)

    open(filename, "r") do io
        first_line = split(readline(io))
        matrix_size = parse(Int, first_line[1])
        block_size = parse(Int, first_line[2])
        println("block_size: ",  block_size)
        block_no = 0

        if matrix_size % block_size == 0
            block_no = div(matrix_size, block_size)
        else 
            println("[ERROR] Block size should divide matrix size.")
            exit(1)
        end

        rows = Int[]
        columns = Int[]
        values = Float64[]

        for line in eachline(io)
            params = split(line)
            if length(params) < 3
                continue
            end
            r = parse(Int, params[1])
            c = parse(Int, params[2])
            v = parse(Float64, params[3])

            push!(rows, r)
            push!(columns, c)
            push!(values, v)
        end
        A = sparse(rows, columns, values, matrix_size, matrix_size)
        
        return BlockMatrix(A, matrix_size, block_size, block_no)
    end
end


function read_a_test(filename)

    open(filename, "r") do io
        first_line = split(readline(io))
        
        n = 16
        A = zeros(n, n)

        for line in eachline(io)
            params = split(line)
            if length(params) < 3
                continue
            end
            r = parse(Int, params[1])
            c = parse(Int, params[2])
            v = parse(Float64, params[3])

            A[r, c] = v
        end
        return A
    end

end


function read_matrix(filename::String)
    open(filename) do f
        params = split(readline(f))
        size = parse(Int, params[1])
        block_size = parse(Int, params[2])
        A = get_blockmatrix(size, block_size)
        while !eof(f)
            line = split(readline(f))
            i = parse(Int, line[1])
            j = parse(Int, line[2])
            v = parse(Float64, line[3])
            A[i, j] = v
        end
        return A
    end
end

function read_matrix_as_sparse(filename::String)
    open(filename) do f
        params = split(readline(f))
        size = parse(Int, params[1])
        block_size = parse(Int, params[2])
        A = spzeros(size, size)
        while !eof(f)
            line = split(readline(f))
            i = parse(Int, line[1])
            j = parse(Int, line[2])
            A[i,j] = parse(Float64, line[3])
        end
        return A
    end
end


function read_b(filename)
    open(filename, "r") do io
        first_line = split(readline(io))
        b_size = parse(Int, first_line[1])

        b = zeros(b_size)

        counter = 0
        for line in eachline(io)
            counter += 1
            params = split(line) 
            val = parse(Float64, params[1])   
            b[counter] = val     
        end
        return b
    end
end


function write_x(filename::String, x::Vector{Float64}, target_x::Union{Nothing, Vector{Float64}})
    open(filename, "w") do f
        if target_x !== nothing
            error = norm(x-target_x) / norm(target_x)
            write(f, "$error\n")
        end
        for x_val in x
            write(f, "$x_val\n")
        end
    end
end

end

    
