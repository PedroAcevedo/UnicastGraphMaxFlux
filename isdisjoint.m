function [answer] = isdisjoint(elem,set, rutas)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    answer = 1;
    for i=1:length(set)
        if ~isempty(intersect(rutas(elem).camino(2:end-1),rutas(set(i)).camino(2:end-1)))
            answer = 0;
            return;
        end
    end
end

