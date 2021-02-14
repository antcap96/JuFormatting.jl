### print integers
# Inspired in Formatting.jl (https://github.com/JuliaIO/Formatting.jl)

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

_prefix(::_Dec) = ""
_prefix(::_Hex) = "0x"
_prefix(::_HEX) = "0X"
_prefix(::_Oct) = "0o"
_prefix(::_Bin) = "0b"

_digitchar(x::Integer, ::_Bin) = Char(x == 0 ? '0' : '1')
_digitchar(x::Integer, ::_Dec) = Char('0' + x)
_digitchar(x::Integer, ::_Oct) = Char('0' + x)
_digitchar(x::Integer, ::_Hex) = Char(x < 10 ? '0' + x : 'a' + (x - 10))
_digitchar(x::Integer, ::_HEX) = Char(x < 10 ? '0' + x : 'A' + (x - 10))


function format_integer(val, base, has_prefix::Bool)
    result = has_prefix ? _prefix(base) : ""

    # find largest power that fits in `val`, subtract it from `val`
    # repeat the process until `val` is 0

    lowerbound = _div(val, base)
    power = one(val)
    while power <= lowerbound
        power = _mul(power, base)
    end
    remainder = val
    while power > 0
        (quotient, remainder) = divrem(remainder, power)
        result *= _digitchar(quotient, base)
        power = _div(power, base)
    end
    return result
end
