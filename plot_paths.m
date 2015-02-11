function [] = plot_paths( tracked_balls, time )

    % Adapted from personal code from a previous IVR assignment

    INITIAL_TIME = 25;

    for t = time : -1 : INITIAL_TIME + 1
        num_objects = max(size(tracked_balls{t}));

        for obj_i = 1 : num_objects
            obj = tracked_balls{t}{obj_i};
            
            cur_object_count = max(size(tracked_balls{time}));
            for obj_j = 1 : cur_object_count
                cur_obj = tracked_balls{time}{obj_j};

                if strcmp(obj.id, cur_obj.id)
                    draw_line(obj.x, obj.y, obj.prev_x, obj.prev_y, obj.color); 
                    break
                end
            end
        end
    end
end
