### print integers
# Some credit to Formatting.jl (https://github.com/JuliaIO/Formatting.jl)

struct _Dec end
struct _Oct end
struct _Hex end
struct _HEX end
struct _Bin end

_mul(x::Integer, ::_Dec) = x * 10
_mul(x::Integer, ::_Bin) = x << 1
_mul(x::Integer, ::_Oct) = x << 3
_mul(x::Integer, ::Union{_Hex, _HEX}) = x << 4

_div(x::Integer, ::_Dec) = div(x, 10)
_div(x::Integer, ::_Bin) = x >> 1
_div(x::Integer, ::_Oct) = x >> 3
_div(x::Integer, ::Union{_Hex, _HEX}) = x >> 4

_ipre(op) = ""
_ipre(::_Hex) = "0x"
_ipre(::_HEX) = "0X"
_ipre(::_Oct) = "0o"
_ipre(::_Bin) = "0b"

_digitchar(x::Integer, ::_Bin) = Char(x == 0 ? '0' : '1')
_digitchar(x::Integer, ::_Dec) = Char('0' + x)
_digitchar(x::Integer, ::_Oct) = Char('0' + x)
_digitchar(x::Integer, ::_Hex) = Char(x < 10 ? '0' + x : 'a' + (x - 10))
_digitchar(x::Integer, ::_HEX) = Char(x < 10 ? '0' + x : 'A' + (x - 10))


function format_integer(val, op, hash::Bool)
    # prefix
    result = ""
    if hash
        result = _ipre(op)
    end

    # find largest power that fits in `val`, subtract it from `val`
    # and repeat the process until `val` is 0

    lowerbound = _div(val, op)
    b = one(val)
    while b <= lowerbound
        b = _mul(b, op)
    end
    remainder = val
    while b > 0
        (quotient, remainder) = divrem(remainder, b)
        result *= _digitchar(quotient, op)
        b = _div(b, op)
    end
    return result
end