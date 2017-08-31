function [wheel_data_struct]=extractMouse_xlsx(mouse_id,treatment,treatment_time)
% this function is designed to work with the exported output  of the mouse activity wheels 
% from Med-Associates (Burlington VT). 

% This function reads through all the .xlsx files in a directory, and
% extract the activity pattern of a single mouse.  Data must be exported with a
% one-minute bin size.  The exported .xls file must be saved as a .xlsx file.
%
% INPUTS
% mouse_id - a string, must match the string with spaces removed in row 11
%of the exported excel worksheet
% treatment - a string specifying the treatment
% treatment_time - a string of the form 'dd-mm-yyyy HH:mm:SS' specifying a
% single treatment
% OUTPUTS
% wheel_data_struct - a structure with substructs:
% revolution_count - a n_days  X 1440 (minute) matrix, with the 'day'
% starting at noon, with the number of wheel revolutions in the  .
% count_times - timing of the bins with the
% pjd 5/2017

run_files=dir('*.xlsx');%files need to be in .xlsx format
n_files=length(run_files); %calculate how many files to load and porcess
binsize=1;% in minutes
n_bins_per_day=24*(60/binsize);
minutes_til_noon=12*60;

% data from each file
wheel_times_vec=cell(n_files,1);
mouseID_array=cell(n_files,1);
revolution_count_vec=cell(n_files,1);
%start and end times for the file
start_time=cell(n_files,1);
end_time=cell(n_files,1);

for the_file=1:n_files
    [wheel_times_vec{the_file},mouseID_array{the_file},revolution_count_vec{the_file},start_time{the_file},end_time{the_file}]...
        =read_wheel_xlsx(run_files(the_file).name);
end

for m=1:length(mouseID_array)
    for n=1:length(mouseID_array{the_file})
        mouseID_array{m}{n}=erase(mouseID_array{m}{n},' ');%get rid of spaces in the mouse IDs
    end
end


start_times_num=zeros(n_files,1);
for k=1:n_files
    start_times_num(k)=datenum(start_time{k});
    wheel_times_vec{the_file}(1,:)=wheel_times_vec{the_file}(1,:)+1900;
end

[~,the_file_order]=sort(start_times_num);
total_recording_sec=etime(end_time{the_file_order(end)},start_time{the_file_order(1)});% get the total duration of the recording
n_inclusive_days=ceil(total_recording_sec/(24*60*60))+2;
wheel_data_matrix=NaN*zeros(24*60,n_inclusive_days);%day starts at noon,
zero_time=start_time{the_file_order(1)};
zero_time(4:end)=0;
chosen_mouse=find(strcmp(mouse_id,mouseID_array{1}));

for the_mouse=chosen_mouse
    wheel_data_struct=make_wheel_data_struct(mouseID_array{1}{the_mouse});%generate data_structure for the mouse
    wheel_data_struct.treatment=treatment;
    wheel_data_struct.treatment_time=treatment_time;
    wheel_data_struct.revolution_count=wheel_data_matrix;
    wheel_data_struct.count_time=wheel_data_matrix;
    
    for the_file=1:n_files
        
        file_start_time_index=round(etime(start_time{the_file_order(the_file)}, zero_time)/60);
        
        file_flag=0;
        [ind1,ind2]=ind2sub([ n_bins_per_day n_inclusive_days],file_start_time_index+minutes_til_noon+(0:(length(revolution_count_vec{the_file})-1)));
        for k=1:length(revolution_count_vec{the_file})
            try
                wheel_data_struct.revolution_count(ind1(k),ind2(k))=revolution_count_vec{the_file}(k,the_mouse);
                wheel_data_struct.count_time(ind1(k),ind2(k))=datenum(wheel_times_vec{the_file}(k,:));
            catch %some dates in the xlsx files appear corrupted (returning a  [1x6 vector] instead of a [1x1]), this try-catch loop avoids them
                file_flag=1
                wheel_data_struct.mouseID
            end
        end
        
        wheel_data_struct.file_names{the_file}=run_files(the_file).name;
        wheel_data_struct.the_file_order=the_file_order;
        
    end
    
    
    
    %% assign relevant structure
    wheel_data_struct.count_time(1,1);
    for k=1:n_inclusive_days
        try
            wheel_data_struct.day_string{k}=datestr(min(wheel_data_struct.count_time(:,k)),1);
        catch
            wheel_data_struct.day_string{k}='NaN';
        end
    end
    
    
    [x,y]=min(abs(wheel_data_struct.count_time-datenum(wheel_data_struct.treatment_time,'dd-mm-yyyy HH:MM:ss')));
    [~,wheel_data_struct.treatment_index_day]=min(x);
    wheel_data_struct.treatment_index_minute=y(wheel_data_struct.treatment_index_day);
    
    
    
    
    
    
    
end


end



function wheel_data_struct=make_wheel_data_struct(name_of_mouse)
% this function makes a wheel data structure
wheel_data_struct=struct('mouseID',[]);
wheel_data_struct.mouseID=name_of_mouse;%name of mouse
wheel_data_struct.n_days=0;
wheel_data_struct.start_date_vector=now;%first day
wheel_data_struct.manipulation_date_vector=now;
wheel_data_struct.manipulation='';
end


function [wheel_times_vec,mouseID_array,revolution_count_vec,start_time,end_time]=read_wheel_xlsx(filename)
% assumes a 1 minute bin size

% wheel_times_vec - datetime vector of the wheel count time points
% revolution_count_vec - matrix of wheel revolutions counts
% start_time - time of export start
% end_time - end of export time

data_start_row=12;
wheel_id_row=11;
% get wheel time points
[raw_num,raw_txt,raw_data]=xlsread(filename,1);
size(raw_num)
start_time=datevec(raw_data{3,2});
start_time(:,1)=start_time(:,1)+1900; %these date offsetes work with a Mac
end_time=datevec(raw_data{4,2});
end_time(:,1)=end_time(:,1)+1900;

nrows=size(raw_num,1);
ncolumns=size(raw_num,2);
nmice=ncolumns-1;
% get time points
wheel_times_num=raw_num(12:end,1);
wheel_times_vec=datevec(datenum(wheel_times_num+693960));% corrects for excel-matlab calander differences on a Mac

mouseID_array=raw_txt(wheel_id_row,2:ncolumns);
revolution_count_vec=raw_num(12:end,2:ncolumns);

end
