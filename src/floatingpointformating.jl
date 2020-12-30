
function generalformat(val, precision::Integer, capitals::Bool, force_separator::Bool=false)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    if val == 0
        if force_separator
            return "0.0"
        else
            return "0"
        end
    end

    precision = max(precision, 1) #in generalformatting, precision is ≥ 1

    uintexponent = capitals ? 'E' : 'e'

    number = Ryu.writeexp(val, precision-1, false, false, false, UInt8(uintexponent))

    fractional_digits = precision-1

    exp = parse(Int, split(number, uintexponent)[2])

    exponent = ""
    if exp >= precision - (force_separator ? 1 : 0) || exp <= -5
        i = findfirst(uintexponent, number)
        number, exponent = number[1:i-1], number[i:end]
    else
        fractional_digits = max(precision-exp-1, force_separator ? 1 : 0)

        number = (capitals ? uppercase : identity)(Ryu.writefixed(val, fractional_digits))
    end

    if fractional_digits > 0
        number = rstrip(number, ['0'])
    end

    if number[end] == '.'
        if force_separator
            number *= '0'
        else
            number =  number[1:end-1]
        end
    end

    number * exponent
end

function format_inf_nan(val, capitals)
    ans = string(val) #NOTE: diferent from python where inf and nan are lowercase
    if capitals
        return uppercase(ans)
    else
        return ans
    end
end
