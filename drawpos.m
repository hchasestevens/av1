load balls_loc.mat

num_balls = size(new_balls,2);
present = zeros(1, num_balls);
limits  = zeros(1, num_balls);
nextid  = ones(1, num_balls);
ball_name = {'white 1', 'white 2', 'pink 1', 'pink 2', 'orange 1', 'orange 2', 'orange 3', 'orange 4', 'orange 5', 'orange 6'};
file_name='./set1/';
file_format='.jpg';

for i = 1:num_balls
	limits(i) = numel(new_balls(i).row_of_centers);
end

background = imread('bgframe.jpg');

%tracked_balls = {};
%tracked_balls{87-25} = {}; % 1 set for each frame

total_detections = zeros(1, 4);

for i = 25:87
	filename = [file_name sprintf('%08d', i) file_format];
	current_frame=imread(filename);
	clc
    substracted_frame = background_sub(current_frame, background);
    
    imshow(current_frame);
    hold on
       
    props = extractForegroundObjects(separate_balls(substracted_frame, current_frame), current_frame);
    drawCentres(props);
    detections = evaluate(i, props);
    total_detections = total_detections + detections;
    
    %tracked_balls = update_ball_tracking(props, current_frame, i, tracked_balls);
    
	for j = 1:num_balls
		limits(j) = numel(new_balls(j).row_of_centers);
		if nextid(j) <= limits(j)
			if new_balls(j).frame_numbers(nextid(j)) == i
				text(new_balls(j).row_of_centers(nextid(j)), new_balls(j).col_of_centers(nextid(j)), ball_name{j}, 'Clipping', 'on', 'Color', 'cyan');
				plot(new_balls(j).row_of_centers(nextid(j)), new_balls(j).col_of_centers(nextid(j)), 'g+');
				nextid(j) = nextid(j) + 1;
			end
        end
    end
	pause(0.5)
end

total_detections(1:3)
total_detections(4)/total_detections(1)

