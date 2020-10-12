"""
format(str::AbstractString, args...) -> String

format `str` with `args`
"""
function format(str::AbstractString, args...; kwargs...)
    inbetweens = String[]
    formatstrs = String[]
    formatstr = ""
    nextidx = 1
    while formatstr !== nothing
        nextidx, inbetween, formatstr = iterate_braces_pair(str, nextidx)

        push!(inbetweens, inbetween)
        if formatstr !== nothing
            push!(formatstrs, formatstr)
        end
    end

    #TODO: do replacements in fmtstr
    #getattr and getindex

    finalstr = ""

    for (i,formatstr) in enumerate(formatstrs)
        temp = split(formatstr, ":")
        var = temp[1]
        if length(temp) > 1
            fmtstr = temp[2]
        else
            fmtstr = ""
        end
        formated =
            if isempty(var)
                fmt(fmtstr, args[i])
            elseif isdigit(var[1])
                fmt(fmtstr, args[parse(Int,var)])
            else
                fmt(fmtstr, kwargs[Symbol(var)])
            end
        finalstr *= inbetweens[i] * formated
    end
    finalstr * inbetweens[end]
end


"""
iterate_braces_pair(str, start)

return end of analysed string, in-between string and the format string
"""
function iterate_braces_pair(str, start)
    i = start
    while i <= lastindex(str)
        if str[i] == '}'
            if i == lastindex(str)
                error("single '}' is not allowed at idx $i")
            elseif str[i+1] == '}'
                i = nextind(str, i+1)
                continue
            else
                error("single '}' is not allowed at idx $i")
            end
        end

        if str[i] == '{'
            if i == lastindex(str)
                error("single '{' is not allowed at idx $i")
            elseif str[i+1] == '{'
                i = nextind(str, i+1)
                continue
            else
                break
            end
        end

        i = nextind(str, i)
    end

    count = 1
    j = i+1
    while j <= lastindex(str)
        if str[j] == '{'
            count += 1
        elseif str[j] == '}'
            count -= 1
        end
        if count == 0
            break
        end
        j = nextind(str, j)
    end

    found = i <= lastindex(str) && str[i] == '{'

    if count != 0 && found
        error("braces missmatch: \"$(str[i:end])\" at idx $i")
    end
    (
        j+1, 
        replace(replace(str[start:(i-1)], "{{"=>"{"), "}}" => "}"),
        found ? str[i+1:j-1] : nothing
    )
end