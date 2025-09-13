include("./data.jl")

function (@main)(::Vector{String})
    @info "Loading data ..."
    @time data = loaddata()
    @info "Cleaning dataset ..."
    @time cleandata!(data)
    return 0
end
