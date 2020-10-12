@enum Align begin
    A_left
    A_right
    A_center
    A_equal
end

alignmap = Dict("<" => A_left,
                ">" => A_right,
                "^" => A_center,
                "=" => A_equal,
                "" => A_right)

@enum Sign begin
    S_plus
    S_minus
    S_space
end

signmap = Dict("+" => S_plus,
                "-" => S_minus,
                " " => S_space,
                "" => S_minus)

@enum FormatType begin
    T_b
    T_c
    T_d
    T_o
    T_x
    T_X
    T_n
    T_e
    T_E
    T_f
    T_F
    T_g
    T_G
    T_percent
    T_float
end

typemap = Dict("b" => T_b,
               "c" => T_c,
               "d" => T_d,
               "o" => T_o,
               "x" => T_x,
               "X" => T_X,
               "n" => T_n,
               "e" => T_e,
               "E" => T_E,
               "f" => T_f,
               "F" => T_F,
               "g" => T_g,
               "G" => T_G,
               "%" => T_percent)

struct FormatSpecNumber
    fill::Char
    align::Align
    sign::Sign
    hash::Bool
    width::Int
    type::FormatType
end


"""
    parse_format(fmtstr, x)

    parse the `fmtstr` for the type of `x`
"""
function parse_format end

parse_format(fmtstr::AbstractString, ::Integer) = parse_format_number(fmtstr, T_d)
parse_format(fmtstr::AbstractString, ::AbstractFloat) = parse_format_number(fmtstr, T_float)

function parse_format_number(fmtstr::AbstractString, defaulttype::FormatType)
    rgx = r"((?<fill>.?)(?<align>[<>=^]))?(?<sign>[+\- ]?)(?<hash>#?)(?<zero>0?)(?<width>[0-9]*)(?<precision>\.[0-9]+)?(?<type>.?)"

    m = match(rgx, fmtstr)

    #error handling
    if m === nothing
        error("format \"$fmtstr\" is not understood")
    end

    if(m.offset != 1)
        error("\"$(fmtstr[1:m.offset])\" is not understood in format at index 1")
    end
    
    if(!occursin(m.captures[9], "bcdoxXneEfFgGn%"))
        error("unkown type: \"$(m.captures[9])\"")
    end

    if(length(m.match) != length(fmtstr))
        error("\"$(fmtstr[(length(m.match)+1):end])\" is not understood at idx $(length(m.match) + 1)")
    end

    # Get parameters
    fill = ' ' #default value
    align = A_right #default value
    if m.captures[5] == "0" #changes default
        fill = '0'
        align = A_equal
    end
    if !(m.captures[1] === nothing)
        fill = length(m.captures[2]) > 0 ? m.captures[2][1] : ' '
        align = alignmap[m.captures[3]]
    end
    sign = signmap[m.captures[4]]
    hash = m.captures[6] == "#"
    if m.captures[7] == ""
        width = -1
    else
        width = parse(Int, m.captures[7])
    end
    if m.captures[9] == ""
        type = defaulttype
    else
        type = typemap[m.captures[9]]
    end

    FormatSpecNumber(
        fill,
        align,
        sign,
        hash,
        width,
        type
    )
end

"""
fmt(fmtstr, x)

return `x` formated according to `fmtstr`
"""
function fmt end

fmt(fmtstr::AbstractString, x::Union{Integer, AbstractFloat}) = spec_format(parse_format(fmtstr, x), x)
fmt(fmtstr::AbstractString, x) = string(x)

function spec_format(fmt::FormatSpecNumber, x::Number)
    sign, number = separate_sign(x)
    #TODO:format number acording to type and precision
    combine(sign, string(number), fmt.fill, fmt.width, fmt.sign, fmt.align)
end

function separate_sign(x)
    x < 0 ? 
        ("-", -x) :
        ("+",  x)
end

"""

creates a string with `sign` and `number` of size `width` (or more if number
is too big) using `fill` as padding according to `signtype` and `align`
"""
function combine(sign::AbstractString,
                 number::AbstractString,
                 fill::Char,
                 width::Integer,
                 signtype::Sign,
                 align::Align)
    number_len = length(number)
    fill_len = 0
    if signtype == S_plus || sign == "-"
        fill_len = max(0, width-number_len-1)
    else
        fill_len = max(0, width-number_len)
        sign = ""
    end

    if align == A_center
        l_len = fill_len ÷ 2
        l_fill = fill ^ l_len
        r_fill = fill ^ (fill_len - l_len)

        return l_fill * sign * number * r_fill
    elseif align == A_left
        return sign * number * (fill ^ fill_len)
    elseif align == A_right
        return (fill ^ fill_len) * sign * number
    elseif align == A_equal
        return sign * (fill ^ fill_len) * number
    end
end


function sci(x, precision, letter="e")

    sign, val = separate_sign(x)

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
        val = round(val,precision)
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
    return (sign, string(val) * letter * esign * exp)
end
