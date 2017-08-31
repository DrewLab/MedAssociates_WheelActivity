function []=plotActogram(wheel_data_struct, figurenum)
%plots an actogram
% wheel_data_struct - has substructs: 
% revolution_count - a n_days  X 1440 (minute) matrix, with the 'day'
% starting at noon, with the number of wheel revolutions in the  .
% count_times - timing of the bins with the
% figurenum -  figure number to plot the actogram in
% pjd 5/2017
zero_time=wheel_data_struct.count_time(1,:);%first time recording point
zero_time(4:end)=0;
start_time=round(etime(wheel_data_struct.count_time(1,:),zero_time));
start_time_index=round(start_time/60);%convert to minutes from start time
minutes_til_noon=12*60;
minutes_per_day=24*60;

max_revolutions=200;
n_days=size(wheel_data_struct.revolution_count,2);



figure(figurenum)
hold off
bottom_of_plot=.05;
top_of_plot=.95;
plot_increment=(top_of_plot-bottom_of_plot)/(n_days-2);
[x,y]=min(abs(wheel_data_struct.count_time-datenum(wheel_data_struct.treatment_time,'dd-mm-yyyy HH:MM:ss')));
[~,treatment_index_day]=min(x);
treatment_index_minute=y(treatment_index_day);

for k=2:n_days-1 %don't plot the first day
    the_ax(k)=subplot('Position',[.1 (top_of_plot-(k-1)*plot_increment) .8 plot_increment]);
    hold off
    bax=bar([1:minutes_per_day]/60,wheel_data_struct.revolution_count(:,k),'k');
    axis([0 24 0 max_revolutions ])
    xticks(0:6:24)
    text(1,50,wheel_data_struct.day_string{k})
    hold on

    plot([7 7],[0 max_revolutions] ,'r')
    plot([19 19],[0 max_revolutions], 'r')
    if k==2
        plot([start_time_index-minutes_til_noon start_time_index-minutes_til_noon]/60, [0 100],'b')%denote the start of recorting
    end
    
    if k==treatment_index_day
        try
            plot([treatment_index_minute treatment_index_minute]/60, [0 max_revolutions] ,'m', 'LineWidth',3)
        catch
        end
        
    end
    
    if k==n_days-1
        axis on
        ylabel('activity counts')
        xlabel('Time')
        xticklabels({'12:00', '18:00', '24:00', '06:00'})
    elseif k==2
        title(['mouseID:' wheel_data_struct.mouseID ', Treatment:' wheel_data_struct.treatment])
        axis off
    else
        axis off
    end
    linkaxes(the_ax,'x')
end