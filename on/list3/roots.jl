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
            return (Nothing, Nothing, it, 1)
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
    
    x1 = x0 - 1
    f0 = f(x0)
    i = maxit

    while i > 0 && abs(x1 - x0) > delta && abs(f0) > epsilon
        f1 = pf(x0)

        if abs(f1) < epsilon        # pochodna bliska 0
            return (Nothing, Nothing, maxit - i, 2)
        end
        
        x1 = x0
        x0 = x0 - f0 / f1
        f0 = f(x0)

        i -= 1

        if i == 0
            return  (Nothing, Nothing, maxit - i, 1)          
        end
    end

    return (x0, f0, maxit - i, 0)

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
    i = maxit
    while i > 0 && abs(x0 -x1) > delta

        """
        złe punkty startowe
        if abs(f0 - f1) < epsilon
            return (Nothing, Nothing, maxit - i, )            
        end
        """

        r = x0 - f0 * (x0 - x1) / (f0- f1)
        v = f(r)

        if abs(v) < epsilon
            return (r, v, maxit - i, 0)
        end
        x1 = x0
        f1 = f0
        x0 = r
        f0 = v

        i-=1

        if i == 0
           return (Nothing, Nothing, maxit - i, 1)            
        end
    end
end

end