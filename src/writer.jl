"Write [`Record`](@ref)s to `IO` as string."
function Base.write(io::IO, records::Vector{Record}) #Note: catching non-isbits arrays and we assume the indexes have been bumpped and the open ends are correct.
    for record in records
        Base.write(io, record, '\n')
    end
    return position(io)
end

"Write [`Record`](@ref) to `IO` as string."
function Base.write(io::IO, record::Record)
    # delim = '\t'
    delim = ' '
    strings = convert(Vector{String}, record)

    Base.join(io, strings, delim)

    return position(io)
end
