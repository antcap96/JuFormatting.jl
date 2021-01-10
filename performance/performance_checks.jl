using Pkg

Pkg.activate(joinpath(dirname(@__FILE__), ".."))

using JuFormatting
using BenchmarkTools
using Random
using JLD

result_baseline = load(joinpath(dirname(@__FILE__), "result_baseline.jld"))["results_baseline"]
result_py = load(joinpath(dirname(@__FILE__), "result_python.jld"))["results_py"]
results_joinall = load(joinpath(dirname(@__FILE__), "result_joinall.jld"))["results_joinall"]
results_nokwards = load(joinpath(dirname(@__FILE__), "result_nokwards.jld"))["results_nokwards"]

j = judge(median(results_nokwards), median(results_joinall))

display(j)
