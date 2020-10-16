# JuFormatting.jl

| **Build Status**                          | **Code Coverage**               |
|:-----------------------------------------:|:-------------------------------:|
| [![Build Status][travis-img]][travis-url] | [![][coveral-img]][coveral-url] |
| [![Build Status][appvey-img]][appvey-url] | [![][codecov-img]][codecov-url] |


![logo](logo/logo.svg "JuFormatting.jl")

The JuFormatting package provides the usefull formatting syntax from python in both a function form and a f-string using the @f_str macro. The JuFormatting library is fully written in julia and works for versions greater or equal to julia 1.4.

Installation
------------

In a Julia session, after entering the package manager mode with `]`, run the command

```julia
pkg> update
pkg> add https://github.com/antcap96/JuFormatting.jl
```

Usage
-----

After installing the package, you can start using it

```julia
using JuFormatting
```

The module dives access to two ways of formatting a string, using the `format` function and using the `@f_str` macro allows python's f-string style formatting.

```julia
julia> format("{:#b}", 3)
"0b11"

julia> f"{31.32:10.3g}"
"      31.3"
```

Diferences from python / todos
------------------------------

* the "n" and "," formating type is not implemented for Integers nor floats.

* Inf and NaN are formated diferently from python to match julia default conversion to string of these values.

* getattr and getindex are not yet supported in the format syntax

* replacement fields in format specifiers are not yet supported

* current support for strings does not allow to set width

* julia offers more numeric types than python, currently all abstract floats are handled the same and so do all integers.



[travis-img]: https://travis-ci.com/antcap96/JuFormatting.jl.svg?branch=master
[travis-url]: https://travis-ci.com/antcap96/JuFormatting.jl

[appvey-img]: https://ci.appveyor.com/api/projects/status/github/antcap96/JuFormatting.jl?svg=true
[appvey-url]: https://ci.appveyor.com/project/antcap96/JuFormatting-jl

[coveral-img]: https://coveralls.io/repos/github/antcap96/JuFormatting.jl/badge.svg?branch=master
[coveral-url]: https://coveralls.io/github/antcap96/JuFormatting.jl?branch=master

[codecov-img]: https://codecov.io/gh/antcap96/JuFormatting.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/antcap96/JuFormatting.jl