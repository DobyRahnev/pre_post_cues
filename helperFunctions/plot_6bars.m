function plot_6bars(data_orig, y_label)

number_subjects = size(data_orig,1);
locations = [1,2,4,5,7,8];
data(:,1) = data_orig(:,1,1);
data(:,2) = data_orig(:,2,1);
data(:,3) = data_orig(:,1,2);
data(:,4) = data_orig(:,2,2);
data(:,5) = data_orig(:,1,3);
data(:,6) = data_orig(:,2,3);
figure
ax = axes;
bar(locations(1), mean(data(:,1)), 'w');
hold
bar(locations(2), mean(data(:,2)), 'r');

bar(locations(3), mean(data(:,3)), 'w');
bar(locations(4), mean(data(:,4)), 'r');

bar(locations(5), mean(data(:,5)), 'w');
bar(locations(6), mean(data(:,6)), 'r');

%Plot confidence intervals
shift=0;
for i=1:size(data,2)  
    plot([locations(i),locations(i)], [mean(data(:,i))-std(data(:,i))/sqrt(number_subjects), ...
        mean(data(:,i))+std(data(:,i))/sqrt(number_subjects)], 'k', 'LineWidth',2);
    plot([locations(i)-.05,locations(i)+.05], [mean(data(:,i))-std(data(:,i))/sqrt(number_subjects), ...
        mean(data(:,i))-std(data(:,i))/sqrt(number_subjects)], 'k', 'LineWidth',2);
    plot([locations(i)-.05,locations(i)+.05], [mean(data(:,i))+std(data(:,i))/sqrt(number_subjects), ...
        mean(data(:,i))+std(data(:,i))/sqrt(number_subjects)], 'k', 'LineWidth',2);
end

%title('effect of TMS','FontSize',30)
ylabel(y_label,'FontSize',30);
xlim([.5, locations(end)+.5]);
set(ax,'XTick',[1.5, 4.5, 7.5]);
set(gca,'XTickLabel',{'Left cue', 'Right cue', 'Neutral cue'})
xlabel('Cue type', 'FontSize', 30);
legend('Pre cue', 'Post cue')