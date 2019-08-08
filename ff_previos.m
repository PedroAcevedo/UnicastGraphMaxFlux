function previos=ff_previos(prev,n)
for kp = 1:n
    fprintf('%d) ',kp);
    for ip =1:length(prev(kp).p)
        fprintf('%d ',prev(kp).p(ip));
    end
    fprintf('\n');
end