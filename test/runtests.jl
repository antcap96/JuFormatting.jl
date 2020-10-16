using JuFormatting
using PyCall
using Test

function test(str, args)
    result = (format(str, args...) == PyObject(str).format(args...))
    if !result
        println("julia>  format(\"$str\", $args...): \"", format(str, args...), "\"")
        println("python> \"$str\".format(*$args)   : \"", PyObject(str).format(args...), "\"")
        println()
    end
    return result
end

@testset "JuFormatting.jl" begin
    # Write your tests here.
    @test test("{:3} {:.5g}", Any[1, .34])
    @test test("{:.3G} {:F} {:4.1E} {:.100g} {:5f} {:6.3e} {:%} {}", rand(8))
    
    # edge cases
    #   fails because julia formats Inf and NaN different from python
    #   @test test("{:f} {:g} {:e} {} {:f} {:g} {:e} {}", [Inf, Inf, Inf, Inf, NaN, NaN, NaN, NaN])
    @test test("{:F} {:G} {:E} {:F} {:G} {:E}", [Inf, -Inf, Inf, NaN, -NaN, NaN])
    @test test("{:f} {:g} {:e} {}", zeros(4))

    # integer representations
    @test test("{:#X} {:#x} {:#o} {:#b} {:#d}", rand(1:100, 5))
    @test test("{:X} {:x} {:o} {:b} {:d}", rand(1:100, 5))

    # rounding
    @test test("{:.1f}", 0.99)
    @test test("{:.1g}", 0.99)
    @test test("{:.1e}", 0.99)
    @test test("{:.1}" , 0.99)

    # aling and fill and escape braces
    @test test("{:a<10x}", rand(1:500))
    @test test("{: ^10} }}{{", -rand(1:500))
    @test test("{: >+10} }}", rand(1:500))
    @test test("{: ^ 10} {{", rand(1:500))
    @test test("{:+015x}", rand(1:500))

    # @f_str tests
    @test f"{0.:}" == "0.0"
    @test f"{0.:.0}" == "0.0"
    @test f"{0.:.0g}" == "0"

    # Inf and NaN
    @test format("{}", Inf) == "Inf"
    @test format("{}", NaN) == "NaN"

    # a lot of big floats
    #   fails because julia uses exponent earlier than python
    #   @test test("{} "^10, exp10.(rand(10)*10))
    @test test("{:e} "^10, exp10.(rand(10)*10))
    @test test("{:f} "^10, exp10.(rand(10)*10))
    @test test("{:g} "^10, exp10.(rand(10)*10))


end
