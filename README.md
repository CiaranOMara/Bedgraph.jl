# Bedgraph.jl

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.com/CiaranOMara/Bedgraph.jl.svg?branch=master)](https://travis-ci.com/CiaranOMara/Bedgraph.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/u0enn28i4ea1f744/branch/master?svg=true)](https://ci.appveyor.com/project/CiaranOMara/bedgraph-jl/branch/master)
[![Build Status](https://api.cirrus-ci.com/github/CiaranOMara/Bedgraph.jl.svg?branch=master)](https://cirrus-ci.com/github/CiaranOMara/Bedgraph.jl)
[![codecov.io](http://codecov.io/github/CiaranOMara/Bedgraph.jl/coverage.svg?branch=master)](http://codecov.io/github/CiaranOMara/Bedgraph.jl?branch=master)

> This project will try to follow the [semver](http://semver.org) pro forma.

## Description
This package provides read and write support for [Bedgraph files](https://genome.ucsc.edu/goldenPath/help/bedgraph.html), as well as other useful utilities.

> **Note:**  this package does not currently handle bedGraph meta data such as the track definition or browser lines.

## Installation
You can install Bedgraph from the [Julia REPL](https://docs.julialang.org/en/v1/manual/getting-started/).
Press `]` to enter [pkg mode](https://docs.julialang.org/en/v1/stdlib/Pkg/), then enter the following:

```julia
add Bedgraph
```

If you are interested in the cutting edge of the development, please check out the [develop branch](https://github.com/CiaranOMara/Bedgraph.jl/tree/develop) to try new features before release.

## Usage

### Reading and writing bedGraph files
> See source for optional `bump_back`, `bump_forward`, and `right_open` key values. These options are included in the pertinent read/write functions to handle quirks of the zero-based and half-open nature of the bedGraph format.

#### Read header/meta
```julia
using Bedgraph

header = read(file, BedgraphHeader{Vector{String}})
```

#### Read records

Read all records at once.
```julia
using Bedgraph

records = read(file, Vector{Bedgraph.Record})
```

```julia
using Bedgraph

records = open(file, "r") do io
    return read(io, Vector{Bedgraph.Record})
end
```

Alternatively you may want to read and process records individually.
```julia
open(file, "r") do io
    while !eof(seek(io, Bedgraph.Record))
        record = read(io, Bedgraph.Record) #Note: no protection.
        # Process record.
    end
end
```

#### Write a bedGraph file
Bedgraph.jl currently provides two write functions: one for `Bedgraph.BedgraphHeader`, and one for `Bedgraph.Record`, which also accepts `Vector{Bedgraph.Record}`.

```julia
using Bedgraph

const chroms = ["chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19", "chr19"]
const firsts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const lasts = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

records = Bedgraph.Record.(chroms, firsts, lasts, values)

sort!(records)

header = Bedgraph.generate_basic_header(records)

write("data.bedgraph", header, records)
```


```julia
using Bedgraph

records = [Record("chr19", 49302000, 49302300, -1.0), Record("chr19", 49302300, 49302600, -1.75)]
header = Bedgraph.generate_basic_header("chr19", records[1].first, records[end].last, bump_forward=false)

open(output_file, "w") do io
    write(io, header, records)
end

```
### Compression and decompression of data

#### Compress data values
Compress data to chromosome coordinates of the zero-based, half-open format.

```julia
using Bedgraph

chrom "chr1"
n = 49302000:49304700
decompressed_values = [-1.0, -1.0, -1.0, ..., 1.00, 1.00, 1.00]

compressed_records = Bedgraph.compress(chrom, n, decompressed_values)
```

```julia
using Bedgraph

const records = [Record("chr19", 49302000, 49302300, -1.0), Record("chr19", 49302300, 49302600, -1.75)]

compressed_records = Bedgraph.compress("chr19", n, decompressed_value)
```

#### Decompress record data
Decompress chromosome coordinates from the zero-based, half-open format.
> **Note:**  please be aware of the order of returned items.

```julia
using Bedgraph

const firsts = [49302000, 49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400]
const lasts = [49302300, 49302600, 49302900, 49303200, 49303500, 49303800, 49304100, 49304400, 49304700]
const values = [-1.0, -0.75, -0.50, -0.25, 0.0, 0.25, 0.50, 0.75, 1.00]

(n, decompressed_values, decompressed_chroms) = Bedgraph.expand(chroms, firsts, lasts, values)
```

```julia

using Bedgraph

const records = [Record("chr19", 49302000, 49302300, -1.0), Record("chr19", 49302300, 49302600, -1.75)]

n, decompressed_values, decompressed_chroms = Bedgraph.expand(records)
```
