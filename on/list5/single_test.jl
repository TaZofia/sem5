# Zofia Tarchalska

include("file_manager.jl")

using .FileManager
using .blocksys
using Statistics

function gauss(A, b)
    n = A.size[1]
    
    for k in 1 : n-1
        for i in k+1 : n
            try
                m = A[i, k] / A[k, k]
                A[i, k] = 0.0

                for j in k+1 : n
                    A[i, j] -= m * A[k, j]
                end

                b[i] -= m * b[k]

            catch err
                error("Zero value on the diagonal of A at index ($k, $k)")

            end            
        end
    end

    # wyznaczanie wektora x
    x = zeros(n)
    x[n] = b[n] / A[n, n]
    for i in n-1 : -1 : 1
        x[i] = b[i]
        for j in i+1 : n
            x[i] -= A[i, j] * x[j]
        end
        x[i] /= A[i, i]
    end
    return x
end


paths = [(".\\Dane16_1_1\\A.txt", ".\\Dane16_1_1\\b.txt"),
        (".\\Dane10000_1_1\\A.txt", ".\\Dane10000_1_1\\b.txt"),
        (".\\Dane50000_1_1\\A.txt", ".\\Dane50000_1_1\\b.txt"),
        (".\\Dane100000_1_1\\A.txt", ".\\Dane100000_1_1\\b.txt"),
        (".\\Dane500000_1_1\\A.txt", ".\\Dane500000_1_1\\b.txt"),
        (".\\Dane750000_1_1\\A.txt", ".\\Dane750000_1_1\\b.txt"),
        (".\\Dane1000000_1_1\\A.txt", ".\\Dane1000000_1_1\\b.txt")
        ]
pair = paths[7]

#A = read_a_test(pair[1])
b = read_b(pair[2])

A2 = read_A(pair[1])
println("po wczytaniu")

#x1 = gauss(deepcopy(A), deepcopy(b))

_, elapsed,_, _, _ = @timed solve_by_lu_with_main_element!(deepcopy(A2), deepcopy(b))

println("czas: ", elapsed)