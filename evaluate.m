function [detections] = evaluate(frame_id, props)
    load balls_loc.mat
    num_balls = size(new_balls,2);
    centers = cat(1, props.Centroid);
    
    correct_detections = 0;
    not_detected = 0;
    total_distance = 0;
    for i = 1:num_balls
        pos_index = find(new_balls(i).frame_numbers == frame_id);
        if isempty(pos_index)
            continue;
        end
        found_match = 0;
        for j = 1 : size(centers, 1)
            distance = norm(centers(j, :) - [new_balls(i).row_of_centers(pos_index) new_balls(i).col_of_centers(pos_index)]);
            if distance <= 10
                total_distance = total_distance + distance;
                correct_detections = correct_detections + 1;
                found_match = 1;
                break;
            end
        end
        if ~found_match
            not_detected = not_detected + 1;
        end
    end
 
    incorrect_detections = size(centers, 1) - correct_detections;
    detections = [correct_detections incorrect_detections not_detected total_distance]
end

