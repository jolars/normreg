using Plots
using LaTeXStrings
using NormReg
using ProjectRoot

set_plot_defaults();

function soft_threshold(x, threshold)
  return sign.(x) .* max.(abs.(x) .- threshold, 0)
end

x = range(-2, stop = 2, length = 100)
y = soft_threshold(x, 1)

hline([0], color = "grey", linestyle = :dash, linewidth = 0.5)
plot!(x, y, color = "black", legend = false, size = (180, 150))
xlabel!(L"z")
ylabel!(L"S_\lambda(z)")

savefig(@projectroot("talks", "uppsala", "figures", "soft-thresholding.pdf"))
