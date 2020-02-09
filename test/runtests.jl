using Bedgraph
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

import Bedgraph.Record


module Bag
using Bedgraph
import Bedgraph.Record

const chroms = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
const firsts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const lasts = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]


const browser1 = "browser position chr19:49302001-49304701"
const browser2 = "browser hide all"
const browser3 = "browser pack refGene encodeRegions"
const browser4 = "browser full altGraph"

const comment1 = "#	300 base wide bar graph, autoScale is on by default == graphing"
const comment2 = "#	limits will dynamically change to always show full range of data"
const comment3 = "#	in viewing window, priority = 20 positions this as the second graph"
const comment4 = "#	Note, zero-relative, half-open coordinate system in use for bedGraph format"

# space separated lines.
const line1 = "chr19 49302000 49302300 -1.0"
const line2 = "chr19 49302300 49302600 -0.75"
const line3 = "chr19 49302600 49302900 -0.50"
const line4 = "chr19 49302900 49303200 -0.25"
const line5 = "chr19 49303200 49303500 0.0"
const line6 = "chr19 49303500 49303800 0.25"
const line7 = "chr19 49303800 49304100 0.50"
const line8 = "chr19 49304100 49304400 0.75"
const line9 = "chr19 49304400 49304700 1.00"

const line_other_space = "2R 8225773 8226043 -0.426032509896305"
const line_other = "2R	8225773	8226043	-0.426032509896305"

const line_other_chrom = "1 3006665 3006673 2"

# Varaiations of line 1.
const line1_2 = "chr19   49302000    49302300    -1.0" # tab separated.
const line1_3 = "chr19  49302000     49302300        -1.0" # mix of tabs and spaces.
const line1_4 = " chr19 49302000 49302300 -1.0" # space at start.
const line1_5 = "    chr19 49302000 49302300 -1.0" # tab at start.
const line1_6 = "chr19 49302000 49302300 -1.0 " # space at end.
const line1_7 = "chr19 49302000 49302300 -1.0    " # tab at end.

const cells1 = ["chr19", "49302000", "49302300", "-1.0"]

const record1 = Record("chr19", 49302000, 49302300, -1.0)

const parameter_line_min = "track type=bedGraph"
const parameter_line = "track type=bedGraph name=\"BedGraph Format\" description=\"BedGraph format\" visibility=full color=200, 100, 0 altColor=0, 100, 200 priority=20"
const parameter_line_4 = "track type=bedGraph name=track_label description=center_label"
const parameter_line_long = "track type=bedGraph name=track_label description=center_label visibility=display_mode color=r, g, b altColor=r, g, b priority=priority autoScale=on|off alwaysZero=on|off gridDefault=on|off maxHeightPixels=max:default:min graphType=bar|points viewLimits=lower:upper yLineMark=real-value yLineOnOff=on|off windowingFunction=maximum|mean|minimum smoothingWindow=off|2-16"

const file = joinpath(@__DIR__, "data.bedgraph")
const file_headerless = joinpath(@__DIR__, "data-headerless.bedgraph")

const header = [browser1, browser2, browser3, browser4, comment1, comment2, comment3, comment4, parameter_line]
const records = [record1, Record(line2), Record(line3), Record(line4), Record(line5), Record(line6), Record(line7), Record(line8), Record(line9)]

end # module bag

@testset "Bedgraph" begin

@testset "Record Constructor" begin
	@test_nowarn Record("chr1", 1.0, 1.0, 1.1)
	@test Record("chr1", 1.0, 1.0, 1.0) == Record("chr1", 1, 1, 1.0)
	@test Record("chr1", "1.0", "1", "1.1") == Record("chr1", 1, 1, 1.1)
end

@testset "I/O" begin

	@test isfile(Bag.file)
	@test isfile(Bag.file_headerless)

	# Seek test.
	open(Bag.file, "r") do io
	    seek(io, Record)
	    @test position(io) == 536
	    @test readline(io) == Bag.line1
	end

	# Check things for headerless Bag.files.
	open(Bag.file_headerless, "r") do io

		# Check that the first record of a headerless bedGraph file can be sought.
	    seek(io, Record)
	    @test position(io) == 0
	    @test readline(io) == Bag.line1 # IO position is at the start of line 2.

		# Check behaviour of consecutive calls to seek(io, Record).
		seek(io, Record)
		seek(io, Record)
		@test readline(io) == Bag.line2

	end

	open(Bag.file) do io
		seek(io, Record)
		@test read!(io, Vector{Bedgraph.Record}(undef, length(Bag.records))) ==  Bag.records
	end

	@test_nowarn Bedgraph.BedgraphHeader()
	@test_nowarn Bedgraph.BedgraphHeader{Vector{String}}()

	@test read(Bag.file, Vector{Bedgraph.Record}) ==  Bag.records
	@test read(Bag.file, Bedgraph.BedgraphHeader{Vector{String}}).data == Bag.header


	open(Bag.file, "r") do io # Note: reading records first to check seek.
	    @test read(io, Vector{Record}) == Bag.records
		@test read(io, Bedgraph.BedgraphHeader).data == Bag.header
		@test read(io, Bedgraph.BedgraphHeader{Vector{String}}).data == Bag.header
	end

	open(Bag.file_headerless, "r") do io # Note: reading records first to check seek.
		@test read(io, Vector{Record}) == Bag.records
		@test read(io, Bedgraph.BedgraphHeader).data == []
	    @test read(io, Bedgraph.BedgraphHeader{Vector{String}}).data == []
	end

	@test Bag.records == open(Bag.file, "r") do io
		records = Vector{Record}()

		while !eof(seek(io, Bedgraph.Record))
	        record = read(io, Bedgraph.Record) #Note: no protection.
	        push!(records, record)
	    end

	    return records
	end

	@test Bag.records == open(Bag.file, "r") do io
	    seek(io, Bedgraph.Record)
	    return read(io, Vector{Bedgraph.Record})
	end

	@test_nowarn mktemp() do path, io
		header = Bedgraph.generate_basic_header(Bag.records)
	    write(io, header, Bag.records)

		seekstart(io)
		@test Bag.records == read(io, Vector{Record})
	end


	@test Record{Int} <: Record

	@test_nowarn mktemp() do path, io
	    write(io, Bag.records[[1,5,9]])

		seekstart(io)
		@test Bag.records[[1,5,9]] == read(io, Vector{Record{Int}})
	end

	@test_nowarn mktemp() do path, io
		header = Bedgraph.generate_basic_header(Bag.records)
	    write(io, header, Bag.records)

		seekstart(io)
		@test Bag.records == read(io, Vector{Record{Float64}})
	end

	# Not able to capture write(::IO, ::AbstractVector).
	# @test_nowarn mktemp() do path, io
	# 	# test AbstractVector
	# 	records = view(Bag.records, 2:4)
	# 	header = Bedgraph.generateBasicHeader(records)
	#     write(io, header, records)
	#
	# 	seekstart(io)
	# 	@test records == read(io, Vector{Record})
	# end

	@test_nowarn mktemp() do path, io
		header = Bedgraph.generate_basic_header("chr19", Bag.records[1].first, Bag.records[end].last, bump_forward=false)
		write(io, header, Bag.records)

		seekstart(io)
		@test Bag.records == read(io, Vector{Record})
	end

	@test_nowarn mktempdir() do path
		outputfile = joinpath(path, "test.bedgraph")
		header = Bedgraph.generate_basic_header(Bag.records)
		write(outputfile, header, Bag.records)

		@test Bag.records == read(outputfile, Vector{Record})
	end

end #testset I/O


@testset "Matching" begin

	@test Bedgraph.is_comment(Bag.comment1)
	@test Bedgraph.is_browser(Bag.browser3)

	@test Bedgraph.is_like_record("1 2 3 4") == true
	@test Bedgraph.is_like_record(Bag.parameter_line) == false
	@test Bedgraph.is_like_record(Bag.parameter_line_4) == false
	@test Bedgraph.is_like_record(Bag.parameter_line_min) == false
	@test Bedgraph.is_like_record(Bag.parameter_line_long) == false
	@test Bedgraph.is_like_record(Bag.line1) == true
	@test Bedgraph.is_like_record(Bag.line1_2) == true
	@test Bedgraph.is_like_record(Bag.line1_3) == true
	@test Bedgraph.is_like_record(Bag.line1_4) == true
	@test Bedgraph.is_like_record(Bag.line1_5) == true
	@test Bedgraph.is_like_record(Bag.line1_6) == true
	@test Bedgraph.is_like_record(Bag.line1_7) == true


	@test Bedgraph.is_like_record(Bag.line_other_space) == true
	@test Bedgraph.is_like_record(Bag.line_other) == true
	@test Bedgraph.is_like_record(Bag.line_other_chrom) == true

end #testset Matching


@testset "Line Splitting" begin

	@test Bedgraph._split_line(Bag.line1)[1:4] == Bag.cells1
	@test Bedgraph._split_line(Bag.line1_2)[1:4] == Bag.cells1
	@test Bedgraph._split_line(Bag.line1_3)[1:4] == Bag.cells1
	@test Bedgraph._split_line(Bag.line1_4)[1:4] == Bag.cells1
	@test Bedgraph._split_line(Bag.line1_5)[1:4] == Bag.cells1
	@test Bedgraph._split_line(Bag.line1_6)[1:4] == Bag.cells1
	@test Bedgraph._split_line(Bag.line1_7)[1:4] == Bag.cells1

end #testset Parsing


@testset "Sorting" begin

	# Testing isless function.
	@test isless(Record(Bag.line1), Record(Bag.line2)) == true
	@test isless(Record(Bag.line2), Record(Bag.line1)) == false

	unordered = Bag.records[[9,4,5,6,8,7,1,3,2]]

	@test Bag.records != unordered
	@test Bag.records == sort(unordered)

	# Testing sort by concept.
	@test Bag.records == sort(unordered, by=x->[x.chrom, x.first, x.last])

end #testset Sorting


@testset "Conversion" begin

	@test Bag.record1 == convert(Record, Bag.line1)
	@test Bag.record1 == Record(Bag.line1)
	@test Bag.record1 == convert(Record, string(Bag.line1, " ", "extra_cell"))
	@test Bag.record1 == Record(string(Bag.line1, " ", "extra_cell"))

end #testset Conversion

@testset "Internal Helpers" begin

	@test Bedgraph._range(Bag.record1) == Bag.record1.first : Bag.record1.last - 1
	@test Bedgraph._range(Bag.record1, right_open=false) == (Bag.record1.first + 1 ) : Bag.record1.last

	@test Bedgraph._range(Bag.records) == Bag.record1.first : Record(Bag.line9).last - 1
	@test Bedgraph._range(Bag.records, right_open=false) == Bag.record1.first + 1 : Record(Bag.line9).last


	bumped_records = Bedgraph._bump_forward(Bag.records)
	@test bumped_records[1].first == (Bag.records[1].first + 1)
	@test bumped_records[1].last == (Bag.records[1].last + 1)

	bumped_records = Bedgraph._bump_back(Bag.records)
	@test bumped_records[1].first == (Bag.records[1].first - 1)
	@test bumped_records[1].last == (Bag.records[1].last - 1)

end #testset Internal Helpers

@testset "Deprecated" begin
	@test (@test_deprecated convert(Vector{Record}, Bag.chroms, Bag.firsts, Bag.lasts, Bag.values)) == Bag.records
end

end # total testset
