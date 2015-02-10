function [ ball_history ] = update_ball_tracking( current_conn_comps, current_frame, time, ball_history )

    MIN_TIME = 25;
    
    % Distance function parameters
    A = 1;  % Area
    X = 1;  % Centroid X
    Y = 1;  % Centroid Y
    T = 1;  % Time
    H = 1;  % Avg. hue
    S = 1;  % Avg. saturation
    VX = 1;  % X-velocity
    VY = 1;  % Y-velocity
    VM = 1;  % Velocity magnitude
    DIST_THRESH = 250;  % ! Will need some optimization !
    
    num_conn_comps = size(current_conn_comps, 1);  % should be no more than 8 (or 10)
    
    are_there_conn_comps = size(current_conn_comps, 2);  % not really sure what's up with this... 
    if ~are_there_conn_comps
        return
    end
    
    current_frame_hsv = rgb2hsv(current_frame);
    hues = current_frame_hsv(:, :, 1);
    sats = current_frame_hsv(:, :, 2);
    
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
        for t = MIN_TIME : (time - 1)  % is -1 needed here? (error without)
            n_objects = size(ball_history{t});
            for obj_i = 1 : n_objects
                obj = ball_history{t}{obj_i};
                
                % Get proposed ball vector properties
                temp_cc_vx = (cc_x - obj.x) / (time - t);
                temp_cc_vy = (cc_y - obj.y) / (time - t);
                temp_cc_vm = sqrt(temp_cc_vx^2 + temp_cc_vy^2);
                
                % Comparison
                distance = sqrt(...
                    A * (cc_a - obj.a) ^ 2 + ...
                    X * (cc_x - obj.x) ^ 2 + ...
                    Y * (cc_y - obj.y) ^ 2 + ...
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
                end
                
            end
        end
        
        if strcmp(best_match_id, 'NONE')
            best_match_id = strcat(num2str(time), '-', num2str(cc_i));
            best_match_id  % for debugging
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
            'vm', cc_vm ...
        );
    end


end

