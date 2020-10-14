#TODO: rational
function sci(val, precision, capitals::Bool)
    if isinf(val) || isnan(val)
        format_inf_nan(val, capitals)
    end

    # Calculate the exponent
    exp = Int(floor(log10(val)))

    # Normalize the value
    val *= exp10(-exp)

    # If the value is exactly an integer, then we don't want to
    # print *any* decimal digits, regardless of precision
    if val == floor(val)
        #val = Int(val)
    else
        # Otherwise, round it based on precision
        val = round(val, digits=precision)
        # The rounding operation might have increased the
        # number to where it is no longer normalized, if so
        # then adjust the exponent.
        if val >= 10.0
            exp += 1
            val = val * 0.1
        end
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
    return string(val) * letter * esign * exp
end

function floatingpoint(val, precision::Integer, capitals::Bool)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    r = Rational{BigInt}(val)

    exp = convert(Int, floor(log10(val)))
    power = convert(Int, floor(log2(r.den)))

    digits = r.num*big(5)^power

    len_digits = length(string(digits))
    #round
    digits = div(digits, big(10)^max(len_digits-exp-precision-1, 0), RoundNearest)
    sdigits = string(digits)
    sdigits *= '0'^max(0, precision + exp + 1 - length(sdigits))

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

#TODO: rational
function generalformat(val, precision::Integer, capitals::Bool, mindigits::Bool=false)
    if isinf(val) || isnan(val)
        return format_inf_nan(val, capitals)
    end

    exp = Int(floor(log10(val)))
    if exp >= precision - (mindigits ? 1 : 0) || exp <= -5
        return sci(val, precision-1, capitals)
    end

    fractional_digits = precision-exp-1
    if mindigits
        fractional_digits = max(fractional_digits, 1)
    end

    number = floatingpoint(val, fractional_digits, capitals)

    if fractional_digits > 0
        number = rstrip(number, ['0'])
    end

    if number[end] == '.'
        if mindigits
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