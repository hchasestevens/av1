function [ ball_history ] = update_ball_tracking( current_conn_comps, current_frame, time, ball_history )

    MIN_TIME = 25;
    FRAME_X = size(current_frame, 1);
    FRAME_Y = size(current_frame, 1);
    
    % Distance function parameters - have tried to normalize these to ~1 
    A = 1 / (FRAME_X * FRAME_Y);  % Area
    X = 1 / FRAME_X;  % Centroid X
    Y = 1 / FRAME_Y;  % Centroid Y
    T = 1;  % Time
    H = 1;  % Avg. hue
    S = 1;  % Avg. saturation
    VX = 1 / FRAME_X;  % X-velocity
    VY = 1 / FRAME_Y;  % Y-velocity
    VM = 1 / sqrt(FRAME_X * FRAME_Y);  % Velocity magnitude
    DIST_THRESH = 30;  % ! Will need some optimization !
    TIME_THRESH = 1;  % Only look N frames max back in time
    
    num_conn_comps = size(current_conn_comps, 1);  % should be no more than 8 (or 10)
    
    are_there_conn_comps = size(current_conn_comps, 2);  % not really sure what's up with this... 
    if ~are_there_conn_comps
        return
    end
    
    current_frame_hsv = rgb2hsv(current_frame);
    hues = current_frame_hsv(:, :, 1);
    sats = current_frame_hsv(:, :, 2);
    
    matched_obj_ids = {};
    n_matched_objs = 0;
    
    for cc_i = 1 : num_conn_comps
        cc = current_conn_comps(cc_i);
        cc_a = cc.Area;
        cc_x = cc.Centroid(1);
        cc_y = cc.Centroid(2);
        cc_t = time;
        
        n_pixels = size(cc.PixelList, 1);
        
        cc_hues = zeros(n_pixels);
        cc_sats = zeros(n_pixels);
        for p_i = 1 : n_pixels
            y = cc.PixelList(p_i, 1);
            x = cc.PixelList(p_i, 2);
            cc_hues(p_i) = hues(x, y);
            cc_sats(p_i) = sats(x, y);
        end
        cc_h = sum(sum(cc_hues)) / size(cc_hues, 1);  % sum of sums? why?
        cc_s = sum(sum(cc_sats)) / size(cc_sats, 1);
                
        best_match_id = 'NONE';
        best_match_score = -1;
        cc_vx = 0;
        cc_vy = 0;
        cc_vm = 0;
        cc_prev_x = 0;
        cc_prev_y = 0;
        for t = max(MIN_TIME, (time - TIME_THRESH)) : (time - 1)  % is -1 needed here? (error without)
            n_objects = size(ball_history{t});
            for obj_i = 1 : n_objects
                obj = ball_history{t}{obj_i};
                
                % Enforce 1-to-1 mappings ... "first come, first served"
                already_matched = 0;
                for i = 1 : n_matched_objs
                    if strcmp(obj.id, matched_obj_ids{i})
                        already_matched = 1;
                    end
                end
                if already_matched
                    continue
                end
                
                % Get proposed ball vector properties
                temp_cc_vx = (cc_x - obj.x) / (time - t);
                temp_cc_vy = (cc_y - obj.y) / (time - t);
                temp_cc_vm = sqrt(temp_cc_vx^2 + temp_cc_vy^2);
                
                % Comparison
                distance = sqrt(...
                    A * (cc_a - obj.a) ^ 2 + ...
                    X * (cc_x - (obj.x + obj.vx)) ^ 2 + ...
                    Y * (cc_y - (obj.y + obj.vy)) ^ 2 + ...
                    T * (cc_t - obj.t) ^ 2 + ...
                    H * (cc_h - obj.h) ^ 2 + ...
                    S * (cc_s - obj.s) ^ 2 + ...
                    VX * (temp_cc_vx - obj.vx) ^ 2 + ...
                    VY * (temp_cc_vy - obj.vy) ^ 2 + ...
                    VM * (temp_cc_vm - obj.vm) ^ 2 ...
                );
            
                if distance > DIST_THRESH
                    continue
                end    
                
                if (distance < best_match_score) || strcmp(best_match_id, 'NONE')
                    best_match_id = obj.id;
                    best_match_score = distance;
                    cc_vx = temp_cc_vx;
                    cc_vy = temp_cc_vy;
                    cc_vm = temp_cc_vm;
                    cc_prev_x = obj.x;
                    cc_prev_y = obj.y;
                end
                
            end
        end
        
        if strcmp(best_match_id, 'NONE')
            best_match_id = strcat(num2str(time), '-', num2str(cc_i));
            cc_prev_x = cc_x;
            cc_prev_y = cc_y;
            best_match_id  % for debugging
        else
            % Record object ID as matched, so no other CCs can claim it:
            n_matched_objs = n_matched_objs + 1;
            matched_obj_ids{n_matched_objs} = best_match_id;
            
            % Commented out for now... with big enough emphasis on T comp.
            % or limit how far back in time matching can occur, hopefully
            % this will not be needed
            %for t = MIN_TIME : (time - 1)
            %    n_objects = size(ball_history{t});
            %    for obj_i = 1 : n_objects
            %        obj = ball_history{t}{obj_i};
            %        if strcmp(obj.id, best_match_id)
            %            % Get most recent location of object
            %            cc_prev_x = obj.x;
            %            cc_prev_y = obj.y;
            %        end
            %    end
            %end
        end
        
        ball_history{time}{cc_i} = struct( ...
            'id', best_match_id, ...
            'a', cc_a, ...
            'x', cc_x, ...
            'y', cc_y, ...
            't', cc_t, ...
            'h', cc_h, ...
            's', cc_s, ...
            'vx', cc_vx, ...
            'vy', cc_vy, ...
            'vm', cc_vm, ...
            'prev_x', cc_prev_x, ...
            'prev_y', cc_prev_y ...
        );
    end


end

