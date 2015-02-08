function drawCentres(props)
    centres = cat(1, props.Centroid);
    diameters = cat(1, props.EquivDiameter);
    % Draw centres of the objects
    for i = 1 : size(centres, 1)
        ang = 0:0.01:2*pi; 
        r = diameters(i)/2;
        xp = r*cos(ang);
        yp = r*sin(ang);
        plot(centres(i, 1)+xp, centres(i, 2)+yp, 'LineWidth', 2, 'Color', [1 0 0]); 
    end

