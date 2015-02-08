function [ props ] = extractForegroundObjects(foreground)
    MIN_AREA = 0;
    
    % Find all the balls and their properties present in the frame
    props = regionprops(foreground, 'centroid', 'area', 'EquivDiameter');
    
    % Remove small objects (noise)
    rm = [];
    for i = 1 : length(props)
       if props(i).Area < MIN_AREA
          rm = [rm i];
       end
    end
    props(rm) = [];

end

