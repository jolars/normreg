using DataFrames
using DataFramesMeta
using JSON
using LaTeXStrings
using NormReg
using Plots
using ProjectRoot
using StatsBase
using StatsPlots

set_plot_defaults();

json_data = JSON.parsefile(@projectroot("results", "interactions.json"));
df = DataFrame(json_data);

df_subset = subset(
    df,
    :center_before => c -> c .== true,
    :delta => d -> d .== 1,
    :norm_strategy => n -> n .∈ Ref([1, 2]),
);

df_grouped = @chain df_subset begin
    select([:betas, :it, :norm_strategy, :q, :beta])
    groupby([:norm_strategy], sort = true)
end;

n_rows = length(unique(df_subset.norm_strategy))
n_cols = length(unique(df_subset.beta))
n_groups = 3

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" "Interaction"]

plots = []

for (i, df_group) in enumerate(df_grouped)
    df_subgrouped = groupby(df_group, [:beta], sort = false)

    for (j, df_subgroup) in enumerate(df_subgrouped)
        df_subgroup_subset = select(df_subgroup, [:betas, :it, :q])
        n_q = length(unique(df_subgroup.q))
        n_it = length(unique(df_subgroup.it))
        df_wide = reduce(hcat, df_subgroup_subset.betas)
        df_wide_cut = reshape(df_wide, (3, n_it, n_q))
        df_final = permutedims(df_wide_cut, [2, 3, 1])

        ylabel =
            j == 1 ? L"\hat{\beta}_j\\ \text{Strategy %$(df_subgroup.norm_strategy[1])}" : ""

        xlabel = j == 3 && i == n_rows ? L"q" : ""

        beta = join(df_subgroup.beta[1], "\\;")

        title = i == 1 ? L"$\beta^*=[%$(beta)]^\intercal$" : ""

        xformatter = i == n_rows ? :auto : _ -> ""

        yformatter = j == 1 ? :auto : _ -> ""

        y = dropdims(mean(df_final, dims = 1), dims = 1)

        y_err = dropdims(std(df_final, dims = 1), dims = 1)

        q = unique(df_subgroup.q)

        pl = plot(
            q,
            y,
            ribbon = (y_err, y_err),
            labels = labels,
            legendposition = j == n_cols && i == 1 ? :outerright : :none,
            title = title,
            xformatter = xformatter,
            xticks = [0.2, 0.5, 0.8],
            xlabel = xlabel,
            yformatter = yformatter,
            ylabel = ylabel,
            ylims = (-0.1, 1.1),
        )

        push!(plots, pl)
    end
end

layout = (n_rows, n_cols)

labels = [L"\operatorname{Bernoulli}(q)" L"\operatorname{Normal}(0,0.5)" "Interaction"]

plots = plot(plots..., layout = layout, size = (FULL_WIDTH, 260))

file_path = @projectroot("plots", "interactions-classbalance.pdf")
savefig(plots, file_path)
