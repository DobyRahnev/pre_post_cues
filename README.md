Data and code for paper titled "Stimulus expectation alters decision criterion but not sensory signal in perceptual decision making" by Bang & Rahnev.

Both data and code are in MATLAB (tested on version 2016a). Here is a guideline to the folders:

Analyses
- data: contains the raw subject data
- expt_codes: contains the files for recreating the experiment
- simulations: contains the simulations reported in Figure 1
- analysis_behav.m: file for behavioral analyses
- analysis_RC_feature.m: file for feature-based reverse correlation (RC) analyses
- analysis_RC_temp.m: file for temporal reverse correlation (RC) analyses
- model_figure6.m: file with the model

helperFunctions: useful functions that are called by the analysis files above
