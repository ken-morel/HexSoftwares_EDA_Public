using CSV
using DataFrames
using Plots

const DATA_PATH = "./AB_NYC_2019.csv"

function loaddata()
    return CSV.read(DATA_PATH, DataFrame)
end

countmap(vals::AbstractVector{T}) where {T} = Tuple{T, Int64}[
    (a, count(==(a), vals))
        for a in unique(vals)
]

#name,host_name,neighbourhood_group,neighbourhood,room_type,price

function cleandata(df::DataFrame)
    df.reviews_per_month = coalesce.(df.reviews_per_month, 0.0)
    df = filter(df) do row
        row.price > 0
    end
    # select!(df, [:name, :host_name, :neighbourhood, :room_type, :price])
    return unique(df)
end

function (@main)(::Vector{String})
    @info "Loading data ..."
    @time data = loaddata()
    println("Raw data has $(length(data.name)) entries")
    @info "Cleaning dataset ..."
    @time data = cleandata(data)
    println("Cleaned data has $(length(data.name)) entries")
    @info "Finding some stats"
    showstats(data)
    showplots(data)

    @async gui()
    println("Hit enter to exit")
    readline(stdin)

    return 0
end

function averageroomprice(df::DataFrame)::Float32
    return sum(df.price) / length(df.price)
end

function showstats(df::DataFrame)
    len = length(df.name)
    avg_r_price = round(averageroomprice(df); digits = 2)
    println("Average room price is: \$$avg_r_price")
    room_types = unique(df.room_type)
    print("Amongst $len rooms")
    for room_t in room_types
        percent = round(100 * count(==(room_t), df.room_type) / len; digits = 2)
        print(", $percent% were $(room_t)s")
    end
    println()
    return
end

function showplots(df::DataFrame)
    @info "Ploting prices "
    plotprices(df)
    return
end
function plotprices(df::DataFrame)
    # transform each (price, count) to (count, price)
    prices = countmap(df.price) .|> reverse
    plots = scatter(
        prices;
        title = "House price per number of rents",
        xlabel = "Number of rents",
        ylabel = "Rent fee",
        alpha = 0.2,
        markercolor = :blue,
        markersize = 2,
        label = "Room",
    )
    hline!([averageroomprice(df)]; label = "Average room price", linewidth = 2, linecolor = :red)
    return
end
