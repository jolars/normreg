JULIA := julia

SCRIPTS_PLOTS_DIR := scripts/plots
SCRIPTS_EXPERIMENTS_DIR := scripts/experiments
PLOTS_DIR := plots
PAPER_PLOTS_DIR := paper/plots
DATA_DIR := data

PLOT_SCRIPTS := $(wildcard $(SCRIPTS_PLOTS_DIR)/*.jl)
EXPERIMENT_SCRIPTS := $(wildcard $(SCRIPTS_EXPERIMENTS_DIR)/*.jl)

DUMMY_VARIABLES := $(wildcard $(DATA_DIR)/dummy-variables/*.jld2)

PDF_FILES := $(patsubst $(SCRIPTS_PLOTS_DIR)/%.jl, $(PLOTS_DIR)/%.pdf, $(PLOT_SCRIPTS))
PNG_FILES := $(patsubst $(SCRIPTS_PLOTS_DIR)/%.jl, $(PLOTS_DIR)/%.png, $(PLOT_SCRIPTS))

all: $(PDF_FILES) $(PNG_FILES) $(addprefix $(PAPER_PLOTS_DIR)/,$(notdir $(PDF_FILES)))

$(PLOTS_DIR)/dummy-plot.pdf $(PLOTS_DIR)/dummy-plot.png: $(SCRIPTS_PLOTS_DIR)/dummy-plot.jl $(DUMMY_VARIABLES)
	$(JULIA) $<

$(DATA_DIR)/dummy-plot.jld2: $(SCRIPTS_EXPERIMENTS_DIR)/dummy-variables.jl
	$(JULIA) $<

$(DUMMY_VARIABLES): $(SCRIPTS_EXPERIMENTS_DIR)/dummy-variables.jl
	$(JULIA) $<

$(PAPER_PLOTS_DIR)/%.pdf: $(PLOTS_DIR)/%.pdf
	@mkdir -p $(@D)
	@rsync -u $< $@

.PHONY: clean
clean:
	@rm -rf $(PLOTS_DIR)/* $(PAPER_PLOTS_DIR)/* $(DATA_DIR)/*
