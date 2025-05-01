using Downloads
using OrderedCollections
using Printf
using ProgressBars
using SparseArrays

include("datasets.jl")

get_datasets() = DATASETS

function get_dataset_home()
  if "LIBSVMDATA_HOME" in keys(ENV)
    return ENV["LIBSVMDATA_HOME"]
  else
    return mkpath(joinpath(homedir(), "data/libsvm"))
  end
end

function print_datasets()
  datasets = get_datasets()
  println(repeat("=", 82))
  @printf "%-25s | %-15s | %-10s | %-10s | %-10s\n" "Dataset name" "Type" "Data" "Features" "Classes"
  println(repeat("-", 82))
  for (name, dataset) in datasets
    @printf "%-25s | %-15s | %-10d | %-10d | %-10d\n" name dataset[:type] dataset[:dims][1] dataset[:dims][2] dataset[:ncls]
  end
  println(repeat("=", 82))
end

function load_dataset(
  dataset::String;
  dense::Bool = false,
  replace::Bool = false,
  verbose::Bool = true,
)

  # Test if the dataset is supported
  if !(dataset in keys(DATASETS))
    throw(
      ArgumentError(
        "The dataset '$dataset' is not yet supported. You can list the " *
        "available datasets using the 'print_datasets()' function. " *
        "Please report this error if you want the dataset '$dataset' to " *
        "be supported.",
      ),
    )
  end

  # Extract dataset informations
  file = DATASETS[dataset][:file]
  type = DATASETS[dataset][:type]
  m, n = DATASETS[dataset][:dims]

  # Set useful path variables
  dataset_home = get_dataset_home()
  dataset_path = joinpath(dataset_home, file)
  dataset_url = joinpath(BASE_URL, type, file)

  # Check if the dataset exists and download it otherwise (or if replace=true)
  if !isfile(dataset_path)
    verbose && println("Downloading the dataset $dataset...")
    Downloads.download(dataset_url, dataset_path, verbose = verbose)
  elseif replace
    verbose && println("Replacing the dataset $dataset...")
    Downloads.download(dataset_url, dataset_path, verbose = verbose)
  else
    verbose && println("The data $dataset was already downloaded")
  end

  # Unzip the dataset if needed
  if endswith(dataset_path, ".bz2")
    unzipped_dataset_path = string(join(split(dataset_path, ".")[begin:(end - 1)], "."))
    if !isfile(unzipped_dataset_path)
      verbose && println("Unzipping the dataset...")
      run(`bzip2 -d -k $dataset_path`)
    end
    dataset_path = unzipped_dataset_path
  elseif endswith(dataset_path, ".tar.xz")
    unzipped_dataset_path = string(join(split(dataset_path, ".")[begin:(end - 2)], "."))
    if !isfile(unzipped_dataset_path)
      verbose && println("Unzipping the dataset...")
      run(`xz -d -k $dataset_path`)
    end
    dataset_path = unzipped_dataset_path
  elseif endswith(dataset_path, ".xz")
    unzipped_dataset_path = string(join(split(dataset_path, ".")[begin:(end - 1)], "."))
    if !isfile(unzipped_dataset_path)
      verbose && println("Unzipping the dataset...")
      run(`xz -d -k $dataset_path`)
    end
    dataset_path = unzipped_dataset_path
  end

  # Extract the dataset data
  verbose && println("Loading the dataset...")
  multilabel = (type == "multilabel")

  rows = Int[]
  cols = Int[]
  vals = Float64[]
  y = Vector{multilabel ? Vector{Float64} : Float64}(undef, m)

  idx_start = 1
  open(dataset_path, "r") do file
    lines = readlines(file)
    pgbar = verbose ? ProgressBar(lines) : lines

    for (j, line) in enumerate(pgbar)
      parts = split(line, ' ', limit = 2)

      label = parts[1]
      y[j] = multilabel ? parse.(Float64, split(label, ",")) : parse(Float64, label)

      if length(parts) > 1
        for feature in eachsplit(parts[2], ' ')
          isempty(feature) && continue

          colon_pos = findfirst(':', feature)
          isnothing(colon_pos) && continue

          idx = parse(Int, view(feature, 1:(colon_pos - 1)))
          val = parse(Float64, view(feature, (colon_pos + 1):length(feature)))

          if idx == 0
            idx_start = 0
          end

          if val != 0
            push!(rows, j)
            push!(cols, idx - idx_start + 1)
            push!(vals, val)
          end
        end
      end
    end
  end

  # Create sparse matrix at the end instead of incrementally
  A = sparse(rows, cols, vals, m, n)
  return dense ? Matrix(A) : A, y
end

export get_datasets, print_datasets, load_dataset
