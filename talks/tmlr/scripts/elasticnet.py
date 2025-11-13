import importlib
import sys

import matplotlib.pyplot as plt
import numpy as np

# import advstat
from pyprojroot.here import here
from sklearn.linear_model import ElasticNet

plt.rcParams["text.usetex"] = True
plt.rcParams["font.size"] = 8
plt.rcParams["lines.markersize"] = 3
plt.rcParams["text.latex.preamble"] = (
    r"\usepackage[T1]{fontenc}\usepackage{lmodern}\usepackage{mathtools}"
)


def rotate_points(x, y, angle):
    """
    Rotate a set of points counterclockwise by a given angle.
    The angle should be given in radians.
    """
    qx = np.cos(angle) * x - np.sin(angle) * y
    qy = np.sin(angle) * x + np.cos(angle) * y
    return qx, qy


def project_points_onto_line(points, line_start, line_end):
    """
    Project multiple points onto a straight line defined by two points.
    points: numpy array of shape (N, 2) representing the coordinates of the points
    line_start: numpy array representing the coordinates of the start point of the line
    line_end: numpy array representing the coordinates of the end point of the line
    """
    line_direction = line_end - line_start
    line_norm = np.dot(line_direction, line_direction)

    point_vectors = points - line_start
    dot_products = np.dot(point_vectors, line_direction)

    projections = (
        line_start + (dot_products / line_norm)[:, np.newaxis] * line_direction
    )
    return projections


# Define the OLS objective function
def ols_objective(beta, X, y):
    return np.sum(0.5 * (y - np.dot(X, beta)) ** 2)


# Define the l1 norm constraint
def l1_norm(beta):
    return np.sum(np.abs(beta))


def elastic_net(beta, X, y, alpha):
    return (
        ols_objective(beta, X, y)
        + alpha * lambd * np.linalg.norm(beta, 1)
        + (1 - alpha) * lambd * np.linalg.norm(beta, 2)
    )


def plot_penalty(ax, alpha, t0):
    n_points = 51
    cx, cy = 0, 0

    theta_nw = np.linspace(np.pi, np.pi / 2, n_points)
    x_nw = cx + t0 * np.cos(theta_nw)
    y_nw = cy + t0 * np.sin(theta_nw)

    projected_points = project_points_onto_line(
        np.column_stack((x_nw, y_nw)), np.array([-t0, 0]), np.array([0, t0])
    )

    x_nw_proj = projected_points[:, 0]
    y_nw_proj = projected_points[:, 1]

    x_nw = alpha * x_nw_proj + (1 - alpha) * x_nw
    y_nw = alpha * y_nw_proj + (1 - alpha) * y_nw

    x_ne, y_ne = rotate_points(x_nw, y_nw, -np.pi / 2)
    x_se, y_se = rotate_points(x_nw, y_nw, -np.pi)
    x_sw, y_sw = rotate_points(x_nw, y_nw, np.pi / 2)

    x_upper = np.concatenate((x_nw, x_ne))
    x_lower = np.concatenate((x_se, x_sw))
    y_upper = np.concatenate((y_nw, y_ne))
    y_lower = np.flip(np.concatenate((y_se, y_sw)))

    ax.plot(x_upper, y_upper, "k", zorder=3)
    ax.plot(x_lower, y_lower, "k", zorder=3)

    ax.fill_between(x_upper, y_lower, y_upper, color="green", alpha=0.3, zorder=2)


# Generate some random data
np.random.seed(0)
X = np.random.randn(100, 2)
corr = np.array([[1, 0.5], [0.5, 1]])
X = np.dot(np.linalg.cholesky(corr), X.T).T
y = np.dot(X, [2, -1]) + np.random.randn(100)

lambd = 100
w0 = [0.9, 1.4]
n_it = 100

model = ElasticNet(alpha=lambd / 100, l1_ratio=1, fit_intercept=True)
fit = model.fit(X, y)

w_opt = fit.coef_

fig_width = 4
fig_height = 2

t0 = l1_norm(w_opt)
lim = (-1.3, 2.2)

# Generate a grid of beta values
beta_grid = np.linspace(lim[0], lim[1], 400)
B1, B2 = np.meshgrid(beta_grid, beta_grid)
Z = np.array([ols_objective(beta, X, y) for beta in zip(B1.ravel(), B2.ravel())])
Z = Z.reshape(B1.shape)

# Plot the level curves of the OLS objective
fig, ax = plt.subplots(
    1,
    3,
    figsize=(fig_width, fig_height),
    layout="constrained",
    sharex=True,
    sharey=True,
    facecolor="white",
    edgecolor=None,
)

alphas = [0, 0.5, 1]

for i, alpha in enumerate(alphas):
    model = ElasticNet(alpha=lambd / 100, l1_ratio=alpha, fit_intercept=True)
    fit = model.fit(X, y)

    w_opt = fit.coef_

    t0 = alpha * l1_norm(w_opt) + (1 - alpha) * np.linalg.norm(w_opt, 2)

    plot_penalty(ax[i], alpha, t0)

    ax[i].set_xlabel(r"$\beta_1$")

    if i == 0:
        ax[i].set_ylabel(r"$\beta_2$")

    ax[i].set_aspect("equal")

    ax[i].contour(B1, B2, Z, levels=np.logspace(0, 5, 50), colors="grey", zorder=1)

    ax[i].hlines(0, lim[0], lim[1], "grey", ":", zorder=2)
    ax[i].vlines(0, lim[0], lim[1], "grey", ":", zorder=2)

    ax[i].plot(w_opt[0], w_opt[1], "ko")
    ax[i].annotate(
        r"$\hat{\boldsymbol{\beta}}$",
        w_opt,
        w_opt + np.array([0.0, -0.2]),
        horizontalalignment="left",
        verticalalignment="center",
        zorder=10,
    )

    if alpha == 0:
        title = "Ridge"
    elif alpha == 1:
        title = "Lasso"
    else:
        title = "Elastic Net"

    ax[i].set_title(title)

path = here() / "talks" / "uppsala" / "figures" / "elasticnet-balls.pdf"

fig.savefig(
    path,
    bbox_inches="tight",
    pad_inches=0.01,
    transparent=True,
)
