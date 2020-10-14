# JuFormatting

[![Build Status](https://travis-ci.com/antcap96/JuFormatting.jl.svg?branch=master)](https://travis-ci.com/antcap96/JuFormatting.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/antcap96/JuFormatting.jl?svg=true)](https://ci.appveyor.com/project/antcap96/JuFormatting-jl)
[![Coverage](https://codecov.io/gh/antcap96/JuFormatting.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/antcap96/JuFormatting.jl)
[![Coverage](https://coveralls.io/repos/github/antcap96/JuFormatting.jl/badge.svg?branch=master)](https://coveralls.io/github/antcap96/JuFormatting.jl?branch=master)


The JuFormatting package provides the usefull formatting syntax from python in both a function form and a f-string using the @f_str macro.

## Example

```julia
    julia> format("{:#b}", 3)
    "0b11"

    julia> f"{31.32:10.3g}"
    "      31.3"
```

## Diferences from python / todos

* the "n" and "," formating type is not implemented for Integers nor floats.

* Inf and NaN are formated diferently from python to match julia default conversion to string of these values.

* getattr and getindex are not yet supported in the format syntax

* replacement fields in format specifiers are not yet supported