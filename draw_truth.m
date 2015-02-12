load balls_loc.mat
background = imread('bgframe.jpg');
imshow(background)
hold on

COLORS = {'red', 'green', 'blue', 'yellow', 'cyan', 'white', [255/255, 20/255, 147/255], [160/255, 32/255, 240/255], [139/255, 69/255, 19/255], [1, 140/255, 0]};

num_balls = size(new_balls,2);

for i = 1:num_balls
    previous = new_balls(i).frame_numbers(1);
    for j = 2:size(new_balls(i).frame_numbers, 1)
        if previous + 1 == new_balls(i).frame_numbers(j)
            draw_line(new_balls(i).row_of_centers(j), new_balls(i).col_of_centers(j), new_balls(i).row_of_centers(j-1), new_balls(i).col_of_centers(j-1), COLORS{i})
        end
        previous = new_balls(i).frame_numbers(j);
    end
end