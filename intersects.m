function [intersections] = intersects(nseg,rutact,rutas)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    intersections = 0;
    for ir=1:length(rutas)
        if(rutas(ir).camino(2) ~= nseg)
            intersections = intersections + length(intersect(rutact,rutas(ir).camino(2:end-1)));
        end
    end
end

