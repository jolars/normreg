using Plots
using LaTeXStrings
using Distributions
using NormReg
using ProjectRoot

set_plot_defaults();

lambda = 1
mu = 1.2
sigma = 1

xlims = (-4, 4)
ylims = (0, 0.45)

X = Normal(mu, sigma)

x = range(mu - sigma * 4, stop = mu + sigma * 4, length = 100);
y = pdf.(X, x);

lo = findall(x .<= -lambda)
hi = findall(x .>= lambda)

x_lo = range(mu - sigma * 4, stop = -lambda, length = 100)
y_lo = pdf.(X, x_lo)

x_hi = range(lambda, stop = mu + sigma * 4, length = 100)
y_hi = pdf.(X, x_hi)

p1 = plot(
  x_lo,
  y_lo,
  fillrange = [zeros(100) y_lo],
  c = :orange,
  fillalpha = 0.2,
  xlims = xlims,
  ylims = ylims,
  xlabel = L"Z",
)
plot!(p1, x_hi, y_hi, fillrange = [zeros(100) y_hi], c = :orange, fillalpha = 0.2)
plot!(p1, x, y, c = :black)
vline!(p1, [-lambda, lambda], c = :black, ls = :dot)
annotate!(lambda - 0.1, 0, text(L"\lambda", :black, :bottom, :right, 10))
annotate!(-lambda + 0.1, 0, text(L"-\lambda", :black, :bottom, :left, 10))

x_st = soft_threshold.(x, lambda)

p2 = plot(
  x_st,
  y,
  fillrange = [zeros(length(x_st)) y],
  c = :orange,
  fillalpha = 0.2,
  linealpha = 1,
  lc = :black,
  xlims = xlims,
  ylims = ylims,
)

f_zero = cdf(X, lambda) - cdf(X, -lambda)

plot!(
  p2,
  [0],
  [f_zero],
  seriestype = [:sticks, :scatter],
  c = :black,
  xlabel = L"\operatorname{S}_\lambda(Z)",
  ls = :dot,
)

plot_talk = plot(p1, p2, layout = (2, 1), size = (190, 240), link = :x)

savefig(plot_talk, @projectroot("talks", "uppsala", "figures", "z_normal.pdf"))
