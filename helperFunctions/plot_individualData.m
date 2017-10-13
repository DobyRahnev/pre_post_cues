function plot_individualData(set1, set2, limits, titleLabel)

figure
plot(set1, set2, 'o')
hold on
plot(limits, limits, 'k')

title(titleLabel,'FontSize',30)
xlabel('pre-cue effect', 'FontSize',30);
ylabel('post-cue effect','FontSize',30);
xlim(limits);
ylim(limits);
