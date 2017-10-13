function [d_prime, c, beta] = data_analysis_acc(stimulus, accuracy)

% A simple function that computes SDT parameters
% stimulus should be a vector of 2 values (lower one is noise, higher one is stimulus)
% accuracy should be a vector of 0's and 1's

% Determine hit and FA rate
hit_rate = sum(stimulus(accuracy==1)==max(stimulus)) / sum(stimulus==max(stimulus));
fa_rate = sum(stimulus(accuracy==0)==min(stimulus)) / sum(stimulus==min(stimulus));

% Correct for values of 0 or 1
if hit_rate == 0
    hit_rate = .5/sum(stimulus==max(stimulus));
elseif hit_rate == 1
    hit_rate = 1 - .5/sum(stimulus==max(stimulus));
end
if fa_rate == 0
    fa_rate = .5/sum(stimulus==min(stimulus));
elseif fa_rate == 1
    fa_rate = 1 - .5/sum(stimulus==min(stimulus));
end

% Compute d' and criterion c
d_prime = norminv(hit_rate) - norminv(fa_rate);
c = -.5*(norminv(hit_rate) + norminv(fa_rate));
beta = exp(d_prime * c);