"""
format(str::AbstractString, args...) -> String

format `str` with `args`
"""
function format(str::AbstractString, args...; kwargs...)
    inbetweens = String[]
    fields = String[]
    field = ""
    nextidx = 1
    while field !== nothing
        nextidx, inbetween, field = iterate_braces_pair(str, nextidx)

        push!(inbetweens, inbetween)
        if field !== nothing
            push!(fields, field)
        end
    end

    #TODO: do replacements in fmtstr
    #getattr and getindex

    finalstr = ""

    for (i, field) in enumerate(fields)
        idx = findfirst(':', field)
        if idx === nothing
            field_name = field
            specifier = ""
        else
            field_name = field[1:(idx-1)]
            specifier = field[(idx+1):end]
        end
        formated =
            if isempty(field_name)
                fmt(specifier, args[i])
            elseif isdigit(field_name[1])
                fmt(specifier, args[parse(Int,field_name)])
            else
                fmt(specifier, kwargs[Symbol(field_name)])
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
                error("single '}' is not allowed at idx $i in string \"$str\"")
            elseif str[i+1] == '}'
                i = nextind(str, i+1)
                continue
            else
                error("single '}' is not allowed at idx $i in string \"$str\"")
            end
        end

        if str[i] == '{'
            if i == lastindex(str)
                error("single '{' is not allowed at idx $i in string \"$str\"")
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