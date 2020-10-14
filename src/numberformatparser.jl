@enum Align begin
    A_left
    A_right
    A_center
    A_equal
end

const alignmap = Dict("<" => A_left,
                      ">" => A_right,
                      "^" => A_center,
                      "=" => A_equal,
                      "" => A_right)

@enum Sign begin
    S_plus
    S_minus
    S_space
end

const signmap = Dict("+" => S_plus,
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

const typemap = Dict("b" => T_b,
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
    precision::Int
    type::FormatType
end

"""
fmt(fmtstr, x)

return `x` formated according to `fmtstr`

This function is called by format and can be overloaded to add suport for diferent types
"""
function fmt end

fmt(fmtstr::AbstractString, x::Union{Integer, AbstractFloat}) = spec_format(parse_format(fmtstr, x), x)
fmt(fmtstr::AbstractString, x) = string(x)

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
    #TODO: type check depend on type
    if(!occursin(m.captures[9], "bcdoxXneEfFgGn%"))
        error("unkown type: \"$(m.captures[9])\"")
    end

    if(length(m.match) != length(fmtstr))
        error("\"$(fmtstr[(length(m.match)+1):end])\" is not understood at idx $(length(m.match) + 1)")
    end

    # Get parameters
    fill = ' ' #default value
    align = A_right #default value
    if m.captures[6] == "0" #changes default
        fill = '0'
        align = A_equal
    end
    if !(m.captures[1] === nothing)
        fill = length(m.captures[2]) > 0 ? m.captures[2][1] : ' '
        align = alignmap[m.captures[3]]
    end
    sign = signmap[m.captures[4]]
    hash = (m.captures[5] == "#")
    if m.captures[7] == ""
        width = -1
    else
        width = parse(Int, m.captures[7])
    end
    if m.captures[8] === nothing
        precision = -1
    else
        precision = parse(Int, m.captures[8][2:end])
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
        precision,
        type
    )
end

function spec_format(fmt::FormatSpecNumber, x::Number)
    sign, number = separate_sign(x)

    sign = format_sign(sign, fmt.sign)

    number = format_number(number, fmt.precision, fmt.type, fmt.hash)

    combine(sign, number, fmt.fill, fmt.width, fmt.align)
end

function separate_sign(x)
    signbit(x) ?
        ("-", -x) :
        ("+",  x)
end

function format_sign(sign, signfmt)
    if sign == "-"
        return sign
    else
        if signfmt == S_minus
            return ""
        elseif signfmt == S_plus
            return "+"
        elseif signfmt == S_space
            return " "
        end
    end
end

function format_number(number, precision, type, hash::Bool)
    # floating point representations
    if type == T_e
        return sci(number, precision, false)
    elseif type == T_E
        return sci(number, precision, true)
    elseif type == T_f
        return floatingpoint(number, precision, false)
    elseif type == T_F
        return floatingpoint(number, precision, true)
    elseif type == T_percent
        return floatingpoint(number*100, precision, false) * "%"
    elseif type == T_g
        return generalformat(number, precision, false)
    elseif type == T_G
        return generalformat(number, precision, true)
    elseif type == T_float
        return generalformat(number, precision, false, true)
    end
    # integer representations
    #TODO: precision check
    if type == T_b
        return format_integer(number, _Bin(), hash)
    elseif type == T_o
        return format_integer(number, _Oct(), hash)
    elseif type == T_d
        return format_integer(number, _Dec(), hash)
    elseif type == T_x
        return format_integer(number, _Hex(), hash)
    elseif type == T_X
        return format_integer(number, _HEX(), hash)
    elseif type == T_c
        return format_char(number)
    end
    string(number)
end

"""
combine(sign, number, fill, width, align)

creates a string with `sign` and `number` of size `width` (or more if number
is too big) using `fill` as padding according to `signtype` and `align`
"""
function combine(sign::AbstractString,
                 number::AbstractString,
                 fill::Char,
                 width::Integer,
                 align::Align)
    number_len = length(number)
    fill_len = max(0, width-number_len-length(sign))

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
