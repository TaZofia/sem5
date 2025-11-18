module roots

export mbisekcji, mstycznych, msiecznych

"""
Dane:
f - funkcja f(x) zadana jako anonimowa funkcja (ang. anonymous function),
a,b - końce przedziału początkowego,
delta - dokładność w argumentach. Maksymalna dopuszczalna odległość między prawdziwym pierwiastkiem a przybliżeniem
epsilon - dokładność w wartościach funkcji. Wartość, dla której nasza funkcja jest już wystarczająco bliska 0

Wyniki:
(r,v,it,err) - czwórka, gdzie
r - przybliżenie pierwiastka równania f(x) = 0,
v - wartość f(r),
it - liczba wykonanych iteracji,
err - sygnalizacja błędu
    0 - brak błędu
    1 - funkcja nie zmienia znaku w przedziale [a,b]
"""

function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)

    fa = f(a)
    fb = f(b)

    if !(isfinite(fa) && isfinite(fb))
        return (Nothing, Nothing, 0, 1)
    end
    if fa * fb <= 0
        return (Nothing, Nothing, 0, 1)
    end

    it = 0

    while true
        it+=1

        center = (b - a) / 2
        r = center + a
        v = f(r)

        if center <= delta || abs(r) <= epsilon
            return (r, v, it, 0)
        end

        if v*fa < 0
            b = r
            fb = f(b)
        elseif v*fb < 0
            a = r
            fa = f(a)
        else
            return (r, v, it, 1)
        end

    end
    
end

"""
Dane:
f, pf - funkcją f(x) oraz pochodną f
x0 - przybliżenie początkowe,
delta,epsilon - dokładności obliczeń,
maxit - maksymalna dopuszczalna liczba iteracji,
Wyniki:
(r,v,it,err) - czwórka, gdzie
r - przybliżenie pierwiastka równania f(x) = 0,
v - wartość f(r),
it - liczba wykonanych iteracji,
err - sygnalizacja błędu
    0 - metoda zbieżna
    1 - nie osiągnięto wymaganej dokładności w maxit iteracji,
    2 - pochodna bliska zeru
"""

function mstycznych(f,pf,x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
  
    v = f(x0)
    i = 1

    if abs(v) < epsilon
        return x0, v, 0, 0
    end

    while i <= maxit 
        df = pf(x0)

        if abs(f1) < epsilon        # pochodna bliska 0
            return (x0, v, i, 2)
        end
    
        x1 = x0 - v/df
        v = f(x1)


        if abs(x1 - x0) < delta || abs(v) < epsilon
            return x1, v, i, 0
        end
        x0 = x1
        i += 1
    end

    return (x0, v, i, 1)

end




"""
Dane:
f - funkcja f(x) zadana jako anonimowa funkcja,
x0,x1 - przybliżenia początkowe,
delta,epsilon - dokładności obliczeń, tak samo jak poprzednio
maxit - maksymalna dopuszczalna liczba iteracji,

Wyniki:
(r,v,it,err) - czwórka, gdzie
r - przybliżenie pierwiastka równania f(x) = 0,
v - wartość f(r),
it - liczba wykonanych iteracji,
err - sygnalizacja błędu
    0 - metoda zbieżna
    1 - nie osiągnięto wymaganej dokładności w maxit iteracji
"""
function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64,
    maxit::Int)

    f0 = f(x0)
    f1 = f(x1)
    i = 1

    if !isfinite(f0) || !isfinite(f1)
        return (Nothing, Nothing, 0, 1)
    end

    if abs(f0) <= epsilon
        return (x0, f0, 0, 0)
    end
    if abs(f1) <= epsilon
        return (x1, f1, 0, 0)
    end

    while i <= maxit

        if abs(f0) < abs(f1)    # zabezpieczenie się przed za małym mianownikiem        
            x0, x1 = x1, x0
            f0, f1 = f1, f0
        end

        r = x0 - f0 * (x0 - x1) / (f0 - f1)
        v = f(r)

        if abs(v) < epsilon     # nasze znalezione przybliżenie
            return (r, v, i, 0)
        end
        x1 = x0
        f1 = f0
        x0 = r
        f0 = v

        i+=1

    end
    return (r, v, i, 1)   
end

end