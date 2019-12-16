"Check whether string is in the four column BED format."
function is_like_record(line::AbstractString)
    return occursin(r"^\s*\S*(?=[A-Za-z0-9])\S*\s+(\d+)\s+(\d+)\s+(\S*\d)\s*$", line) # Note: is like a record.
end
is_like_record(io::IO) = is_like_record(String(take!(io)))

"Check whether string has broswer information."
function is_browser(line::AbstractString)
    return occursin(r"^browser", lowercase(line))
end

"Check whether string is a comment."
function is_comment(line::AbstractString)
    return occursin(r"^\s*(?:#|$)", line)
end

function seek_next_record(io::IO)

    pos = position(io)

    while !eof(io)
        pos = position(io)
        line = readline(io)

        if is_like_record(line)
            break
        end

    end

    return seek(io, pos)
end

"Seek position of next [`Record`](@ref)."
function Base.seek(io::IO, ::Type{<:Record})
    return seek_next_record(io)
end

# Note: all options are placed in a single line separated by spaces.
function read_parameters(io::IO)
    seekstart(io)

    pos = position(io)

    while !eof(io) && !is_like_record(line) # Note: regex is used to limit the search by exiting the loop when a line matches the bedGraph record format.
        line = readline(io)

        if contains(line, "type=bedGraph") # Note: the track type is REQUIRED, and must be bedGraph.
            return line
        end

    end
end

function read_record(io::IO) :: Union{Nothing, Record}

    line = IOBuffer(readline(io))

    if is_like_record(line)
        return read(line, Record)
    end

    return nothing
end

"Read string into type's constructor."
function Base.read(io::IO, obj::Type{<:Record})
    line = readline(io)
    return convert(obj, line)
end

function read_records(io::IO, sink, el::Type=Record)
    seekstart(io)

    while !eof(seek(io, Record))#TODO: consider using el in seek.
        record = read(io, el)
        push!(sink, record) #Note: converts Record to sink's eltype.
    end

    return sink

end

read_records(io::IO, sink::Type=Vector{Record}, el::Type=Record) = read_records(io::IO, sink(), el)

function Base.read(io::IO, ::Type{V}) where {R<:Record, V<:AbstractVector{R}}
    return read_records(io, V, R)
end
