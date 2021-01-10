using Pkg

Pkg.activate(joinpath(dirname(@__FILE__), ".."))

using JuFormatting
using PyCall
using BenchmarkTools
using Random
using JLD

# Define a parent BenchmarkGroup to contain our suite
suite = BenchmarkGroup()

precision_fmt = Dict{String, String}()

for t in ["f", "g", "e", ""]
    precision_fmt[t] = string(["{:.$i$t}" for i in 1:100]...)
end

suite["fixed precision"] = BenchmarkGroup(["float", "number"])
suite["exp"] = BenchmarkGroup(["float", "number"])
suite["general"] = BenchmarkGroup(["float", "number"])
suite["default"] = BenchmarkGroup(["float", "number"])

suite["fixed precision"]["fmt"]       = @benchmarkable PyObject($(rand())).__format__("f")
suite["fixed precision"]["one"]       = @benchmarkable PyObject("{:f}").format($(rand()))
suite["fixed precision"]["small"]     = @benchmarkable PyObject("{:f} {:f}").format($(rand()), $(rand()))
suite["fixed precision"]["long"]      = @benchmarkable PyObject("{:f}"^100).format($([rand() for i in 1:100])...)
suite["fixed precision"]["precision"] = @benchmarkable PyObject(precision_fmt["f"]).format($([rand() for i in 1:100])...)

suite["exp"]["fmt"]       = @benchmarkable PyObject($(rand())).__format__("e")
suite["exp"]["one"]       = @benchmarkable PyObject("{:e}").format($(rand()))
suite["exp"]["small"]     = @benchmarkable PyObject("{:e} {:e}").format($(rand()), $(rand()))
suite["exp"]["long"]      = @benchmarkable PyObject("{:e}"^100).format($([rand() for i in 1:100])...)
suite["exp"]["precision"] = @benchmarkable PyObject(precision_fmt["e"]).format($([rand() for i in 1:100])...)

suite["general"]["fmt"]       = @benchmarkable PyObject($(rand())).__format__("g")
suite["general"]["one"]       = @benchmarkable PyObject("{:g}").format($(rand()))
suite["general"]["small"]     = @benchmarkable PyObject("{:g} {:g}").format($(rand()), $(rand()))
suite["general"]["long"]      = @benchmarkable PyObject("{:g}"^100).format($([rand() for i in 1:100])...)
suite["general"]["precision"] = @benchmarkable PyObject(precision_fmt["g"]).format($([rand() for i in 1:100])...)

suite["default"]["fmt"]       = @benchmarkable PyObject($(rand())).__format__("")
suite["default"]["one"]       = @benchmarkable PyObject("{:}").format($(rand()))
suite["default"]["small"]     = @benchmarkable PyObject("{:} {:}").format($(rand()), $(rand()))
suite["default"]["long"]      = @benchmarkable PyObject("{:}"^100).format($([rand() for i in 1:100])...)
suite["default"]["precision"] = @benchmarkable PyObject(precision_fmt[""]).format($([rand() for i in 1:100])...)

# If a cache of tuned parameters already exists, use it, otherwise, tune and cache
# the benchmark parameters. Reusing cached parameters is faster and more reliable
# than re-tuning `suite` every time the file is included.
paramspath = joinpath(dirname(@__FILE__), "params_python.json")

if isfile(paramspath)
    loadparams!(suite, BenchmarkTools.load(paramspath)[1], :evals);
else
    tune!(suite)
    BenchmarkTools.save(paramspath, params(suite));
end

results = run(suite, verbose = true)

save(joinpath(dirname(@__FILE__), "result_python.jld"), "results_py", results)
println(results)