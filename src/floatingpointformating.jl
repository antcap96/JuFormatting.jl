function sci(val, precision, capitals::Bool)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    if val == 0
        return sci_zero(precision, capitals)
    end

    exp, digits = getndigits(val, precision+1)

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

function sci_zero(precision, capitals::Bool)
    return floatingpoint_zero(precision) * (capitals ? "E" : "e") * "+00"
end


function floatingpoint(val, precision::Integer, capitals::Bool)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    if val == 0
        return floatingpoint_zero(precision)
    end

    (exp, sdigits) = getnfractionaldigits(val, precision)

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

function floatingpoint_zero(precision)
    if precision == 0
        return "0"
    else
        return "0." * '0'^precision
    end
end

function generalformat(val, precision::Integer, capitals::Bool, min_digits::Bool=false)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    if val == 0
        if min_digits
            return "0.0"
        else
            return "0"
        end
    end

    precision = max(precision, 1) #in generalformatting, precision is ≥ 1

    exp , _ = getndigits(val, precision)

    exponent = ""
    if exp >= precision - (min_digits ? 1 : 0) || exp <= -5
        fractional_digits = precision-1

        number = sci(val, fractional_digits, capitals)
        i = findfirst(capitals ? 'E' : 'e', number)
        number, exponent = number[1:i-1], number[i:end]
    else
        fractional_digits = max(precision-exp-1, min_digits ? 1 : 0)

        number = floatingpoint(val, fractional_digits, capitals)
    end

    if fractional_digits > 0
        number = rstrip(number, ['0'])
    end

    if number[end] == '.'
        if min_digits
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

"""
get the first `n` digits in base 10 representation of `val` rounded to `n`
digits precision and calculate largest power of 10 that is less or equal to the
rounded number
"""
function getndigits(val, n)
    @assert(n>0)

    r = Rational{BigInt}(val)
    power = convert(Int, floor(log2(r.den)))
    digits = r.num*big(5)^power

    len_digits = length(string(digits))

    #round and add 0 to fill the precision
    digits = div(digits, big(10)^max(len_digits - n, 0), RoundNearest)
    sdigits = string(digits)

    exp = convert(Int, floor(log10(val)))
    if length(sdigits) == n+1 #rounding caused the number to grow
        return (exp+1, sdigits[1:end-1])
    else
        return (exp, sdigits * '0'^(n - length(sdigits)))
    end
end

"""
get the first digits in base 10 representation of rounded `val` such that the
fractional part has `n` digits and calculate largest power of 10 that is less
or equal to the rounded number
"""
function getnfractionaldigits(val, n)
    r = Rational{BigInt}(val)

    exp = convert(Int, floor(log10(val)))
    power = convert(Int, floor(log2(r.den)))

    digits = r.num*big(5)^power

    len_digits = length(string(digits))
    ndigits_to_remove = len_digits - (n + exp + 1)

    #round and add 0 to fill the precision
    digits = div(digits, big(10)^max(ndigits_to_remove, 0), RoundNearest)

    if digits == 0
        return (-(n + 1), "")
    end

    sdigits = string(digits)

    if length(sdigits) == len_digits - ndigits_to_remove + 1
        # rounding caused an extra digit so we need to show one extra digit
        (exp + 1, sdigits * '0'^(n + exp + 2 - length(sdigits)))
    else
        (exp    , sdigits * '0'^(n + exp + 1 - length(sdigits)))
    end
end