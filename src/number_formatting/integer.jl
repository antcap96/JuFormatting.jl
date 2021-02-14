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

_prefix(::_Dec) = Vector{UInt8}("")
_prefix(::_Hex) = Vector{UInt8}("0x")
_prefix(::_HEX) = Vector{UInt8}("0X")
_prefix(::_Oct) = Vector{UInt8}("0o")
_prefix(::_Bin) = Vector{UInt8}("0b")

_digitchar(x::Integer, ::_Bin) = UInt8(x == 0 ? '0' : '1')
_digitchar(x::Integer, ::_Dec) = UInt8('0' + x)
_digitchar(x::Integer, ::_Oct) = UInt8('0' + x)
_digitchar(x::Integer, ::_Hex) = UInt8(x < 10 ? '0' + x : 'a' + (x - 10))
_digitchar(x::Integer, ::_HEX) = UInt8(x < 10 ? '0' + x : 'A' + (x - 10))


function format_integer(val, base, has_prefix::Bool)
    # find largest power that fits in `val`, subtract it from `val`
    # repeat the process until `val` is 0

    lowerbound = _div(val, base)
    power = one(val)
    digits = 1
    while power <= lowerbound
        power = _mul(power, base)
        digits += 1
    end

    prefix = has_prefix ? _prefix(base) : UInt8[]

    result = Vector{UInt8}(undef, digits + length(prefix))
    result[1:length(prefix)] = prefix

    i = 1 + length(prefix)

    remainder = val
    while power > 0
        (quotient, remainder) = divrem(remainder, power)
        result[i] = _digitchar(quotient, base)
        i += 1
        power = _div(power, base)
    end
    return String(result)
end
