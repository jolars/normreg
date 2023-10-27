JULIA := julia

DATA_DIR := data
PAPER_PLOTS_DIR := paper/plots
PLOTS_DIR := plots
SCRIPTS_DIR := scripts
SCRIPTS_EXP_DIR := $(SCRIPTS_DIR)/experiments
SCRIPTS_PLOTS_DIR := $(SCRIPTS_DIR)/plots

PLOT_SCRIPTS := $(wildcard $(SCRIPTS_PLOTS_DIR)/*.jl)
PDF_FILES := $(patsubst $(SCRIPTS_PLOTS_DIR)/%.jl, $(PLOTS_DIR)/%.pdf, $(PLOT_SCRIPTS))

all: $(addprefix $(PAPER_PLOTS_DIR)/,$(notdir $(PDF_FILES))) $(PDF_FILES)

$(PLOTS_DIR)/%.pdf: $(DATA_DIR)/% $(SCRIPTS_PLOTS_DIR)/%.jl
	@mkdir -p $(@D)
	$(eval STEM=$(patsubst $(PLOTS_DIR)/%.pdf,%,$@))
	$(JULIA) $(SCRIPTS_PLOTS_DIR)/$(STEM).jl

$(DATA_DIR)/%: $(SCRIPTS_EXP_DIR)/%.jl
	$(JULIA) $<

$(PAPER_PLOTS_DIR)/%.pdf: $(PLOTS_DIR)/%.pdf
	@mkdir -p $(@D)
	@rsync -u $< $@

.PHONY: clean
clean:
	@rm -rf $(PLOTS_DIR)/* $(PAPER_PLOTS_DIR)/* $(DATA_DIR)/*
