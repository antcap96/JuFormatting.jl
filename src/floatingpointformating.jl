function sci(val, precision, capitals::Bool)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    # Calculate the exponent
    exp = Int(floor(log10(val)))

    rounded, digits = getndigits(val, precision+1, false)

    if rounded
        exp += 1
    end

    # Convert the exponent to a string using only str().
    # The existing C printf always prints at least 2 digits.
    esign = "+"
    if exp < 0
        exp = -exp
        esign = "-"
    end

    if exp < 10
        exp = "0" * string(exp)
    else
        exp = string(exp)
    end

    # The final result
    letter = capitals ? "E" : "e"

    number =
        if length(digits) == 1
            digits
        else
            digits[1] * "." * digits[2:end]
        end

    return number * letter * esign * exp
end

function floatingpoint(val, precision::Integer, capitals::Bool)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    exp = Int(floor(log10(val)))
    (rounded, sdigits) = getndigits(val, max(0, precision + exp + 1), true)

    if rounded
        exp += 1
    end

    decimalpart =
        if precision <= 0
            ""
        else
            if exp < 0
                "." * '0'^min(-exp-1, precision) * sdigits
            else
                "." * sdigits[(exp+2):end]
            end
        end

    integerpart =
        if exp < 0
            "0"
        else
            sdigits[1:exp+1]
        end

    return integerpart * decimalpart
end

function generalformat(val, precision::Integer, capitals::Bool, min_digits::Bool=false)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    precision = max(precision, 1) #in generalformatting, precision is ≥ 1

    exp = Int(floor(log10(val)))
    rounded , _ = getndigits(val, precision, true)

    if rounded
        exp += 1
    end

    if exp >= precision - (min_digits ? 1 : 0) || exp <= -5
        return sci(val, precision-1, capitals)
    end

    fractional_digits = precision-exp-1
    if min_digits
        fractional_digits = max(fractional_digits, 1)
    end

    number = floatingpoint(val, fractional_digits, capitals)

    if fractional_digits > 0
        number = rstrip(number, ['0'])
    end

    if number[end] == '.'
        if min_digits
            return number * '0'
        else
            return number[1:end-1]
        end
    else
        return number
    end
end

function format_inf_nan(val, capitals)
    ans = string(val) #NOTE: diferent from python where inf and nan are lowercase
    if capitals
        return uppercase(ans)
    else
        return ans
    end
end

"""
return a tuple with if rounding occoured and the first ndigits in the representation of val
"""
function getndigits(val, ndigits, keep_rounded::Bool)
    r = Rational{BigInt}(val)

    if ndigits == 0
        return ""
    end

    exp = convert(Int, floor(log10(val)))
    power = convert(Int, floor(log2(r.den)))

    digits = r.num*big(5)^power

    len_digits = length(string(digits))

    #round and add 0 to fill the precision
    digits = div(digits, big(10)^max(len_digits - ndigits, 0), RoundNearest)
    sdigits = string(digits)

    if length(sdigits) == ndigits+1
        @assert sdigits[end] == '0'
        if keep_rounded
            return (true, sdigits)
        else
            return (true, sdigits[1:end-1])
        end
    else
        return (false, sdigits * '0'^(ndigits - length(sdigits)))
    end
end