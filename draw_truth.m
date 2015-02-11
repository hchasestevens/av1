load balls_loc.mat
background = imread('bgframe.jpg');
imshow(background)
hold on

COLORS = {'red', 'green', 'blue', 'yellow', 'cyan', 'black', 'white', 'magenta'};

num_balls = size(new_balls,2);

for i = 1:num_balls
    color_i = randi(max(size(COLORS)));
    cc_color = COLORS{color_i};
    previous = new_balls(i).frame_numbers(1);
    for j = 2:size(new_balls(i).frame_numbers, 1)
        if previous + 1 == new_balls(i).frame_numbers(j)
            draw_line(new_balls(i).row_of_centers(j), new_balls(i).col_of_centers(j), new_balls(i).row_of_centers(j-1), new_balls(i).col_of_centers(j-1), cc_color)
        end
        previous = new_balls(i).frame_numbers(j);
    end
end