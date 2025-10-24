# Zofia Tarchalska

function find_number()
    my_num = 1.0
    while nextfloat(my_num) * (1.0/nextfloat(my_num)) == 1.0 && my_num < 2.0
        my_num = nextfloat(my_num)
    end
    return my_num
end

println(find_number())