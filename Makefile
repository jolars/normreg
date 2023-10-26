JULIA := julia

DATA_DIR := data
PAPER_PLOTS_DIR := paper/plots
PLOTS_DIR := plots
SCRIPTS_DIR := scripts
SCRIPTS_EXP_DIR := $(SCRIPTS_DIR)/experiments
SCRIPTS_PLOTS_DIR := $(SCRIPTS_DIR)/plots

EXP_SCRIPTS := $(wildcard $(SCRIPTS_EXP_DIR)/*.jl)

DATA_DIRS := $(patsubst $(SCRIPTS_EXP_DIR)/%.jl, $(DATA_DIR)/%, $(EXP_SCRIPTS))

PLOT_SCRIPTS := $(wildcard $(SCRIPTS_PLOTS_DIR)/*.jl)

PLOT_NAMES := lasso_ridge_twodim realdata_paths

PDF_FILES := $(patsubst %,plots/%.pdf,$(PLOT_NAMES))
SVG_FILES := $(patsubst %,plots/%.svg,$(PLOT_NAMES))

all: $(addprefix $(PAPER_PLOTS_DIR)/,$(notdir $(PDF_FILES))) $(DATA_DIRS)

$(PLOTS_DIR)/%.pdf: $(SCRIPTS_PLOTS_DIR)/%.jl
	@mkdir -p $(@D)
	$(JULIA) $<

# $(DATA_DIR)/dummy_plot.jld2: $(SCRIPTS_EXPERIMENTS_DIR)/dummy_variables.jl $(DATA_DIR)/dummy_variables
# 	$(JULIA) $<
#
# $(DATA_DIR)/dummy-plot.jld2: $(SCRIPTS_EXPERIMENTS_DIR)/dummy-variables.jl
# 	$(JULIA) $<

# $(DUMMY_VARIABLES): $(SCRIPTS_EXPERIMENTS_DIR)/dummy-variables.jl
# 	$(JULIA) $<

$(PAPER_PLOTS_DIR)/%.pdf: $(PLOTS_DIR)/%.pdf
	@mkdir -p $(@D)
	@rsync -u $< $@

.PHONY: clean
clean:
	@rm -rf $(PLOTS_DIR)/* $(PAPER_PLOTS_DIR)/* $(DATA_DIR)/*
