module Newton
export ilorazyRoznicowe, warNewton, naturalna

function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})

    x_len = length(x)
    fx = zeros(Float64, x_len)
    for i in 1:x_len
        fx[i] = f[i]
    end
    for j in 2:x_len
        for i in n:-1:j
            fx[i] = (fx[i] - fx[i-1])/(x[i]-x[i-j+1])
        end
    end
    return fx
    
end

function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(x) - 1

    w = fx[n + 1]
    for i in n:-1:1
        w = w * (t - x[i])  + fx[i]  
    end
    return w
end

function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    n = length(x) - 1
    a = zeros(Float64, n + 1)

    a[n + 1] = fx[n + 1]
    for k in n:-1:1 
        for j in k:-1:1
            a[j] = a[j] - x[k] * a[j + 1]         
        end 
        a[k] = a[k] + fx[k]        
    end
end


end