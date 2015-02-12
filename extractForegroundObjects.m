function [ top_props ] = extractForegroundObjects(foreground, current_frame)
    MIN_AREA = 50;
    MIN_LUMINOSITY = 40;
    NUMBER_OF_BALLS = 10;
    
    current_frame_greyscale = rgb2gray(current_frame);
    
    % Find all the balls and their properties present in the frame
    props = regionprops(foreground, 'centroid', 'area', 'EquivDiameter', 'pixelList');
    
    % Remove small or dark objects (noise)
    rm = [];
    for i = 1 : length(props)
       % small
       if props(i).Area < MIN_AREA
          rm = [rm i];
          continue
       end
       
       % dark
       n_pixels = size(props(i).PixelList, 1);
       pixel_bw = zeros(n_pixels, 1);
       
       for p_i = 1 : n_pixels
           x = props(i).PixelList(p_i, 1);
           y = props(i).PixelList(p_i, 2);
           pixel_bw(p_i) = current_frame_greyscale(y, x);
       end
       
       if mean(pixel_bw) < MIN_LUMINOSITY
           rm = [rm i];
       end
       
    end
    
    props(rm) = [];
    
    % Find only 8-10 largest
    number_to_add = min(size(props, 1), NUMBER_OF_BALLS); 
    areas = cat(1, props.Area);
    if isempty(areas)
        top_props = props;
    else
        sorted_areas = sort(areas, 'descend');
        minimum_area = sorted_areas(number_to_add);
    
        top_props = props(1:number_to_add);
        k = 1;
        for i = 1 : size(props, 1)
            if props(i).Area >= minimum_area && k <= number_to_add
                top_props(k) = props(i);
                k = k + 1;
            end
        end
    end
end

