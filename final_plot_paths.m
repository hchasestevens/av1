function [] = final_plot_paths( tracked_balls )

    % Adapted from personal code from a previous IVR assignment

    INITIAL_TIME = 25;
    FINAL_TIME = 87;

    for t = FINAL_TIME : -1 : INITIAL_TIME + 1
        num_objects = max(size(tracked_balls{t}));

        for obj_i = 1 : num_objects
            obj = tracked_balls{t}{obj_i};
            draw_line(obj.x, obj.y, obj.prev_x, obj.prev_y, obj.color); 
        end
    end
end
