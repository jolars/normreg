using FilePathsBase

# Return the root of the project
function project_root(current_dir = @__DIR__)
  while current_dir != "/"
    if isdir(joinpath(current_dir, ".git")) ||
       isfile(joinpath(current_dir, "Project.toml"))
      return current_dir
    end
    current_dir = dirname(current_dir)
  end
  error("Project root not found")
end

# Construct paths relative to the project root
here(args...) = joinpath(project_root(), args...)
