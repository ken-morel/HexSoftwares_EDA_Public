using CSV
using DataFrames
using Makie
using GLMakie

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
    plotprices(df) |> display
    return
end

function plotprices(df::DataFrame)
    f = Figure()
    ax = Axis(f[1, 1])
    pricecounts = countmap(df.price)
    prices, counts = zip(pricecounts...)
    maxprice = max(prices)
    maxcounts = max(counts)
    Label(f[1, 1], "House price per number of rents", fontsize = 30)

    slide = Slider(f[1, 2], range = 1:0.2:100, horizontal = false)


    plots = scatter!(
        ax,
        pricescounts .|> reverse;
        alpha = 0.2,
        color = :blue,
        markersize = 2,
        label = "Room",
    )
    hlines!(ax, [averageroomprice(df)]; label = "Average room price", linewidth = 2, color = :red)

    return f
end
