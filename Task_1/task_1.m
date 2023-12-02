
%Galeon
function path = task_1(map, startPoint, stopPoint)
    map1= map(:,:,1);
    cost = map(:,:,2) .* map(:,:,3);
    start = startPoint;
    stop = stopPoint;
    next_steps = [start];
    dist_to_go = sqrt(sum((start-stop).^2));
    start_next = start;
    while(next_steps(end) ~= stop)
    neigh_costs = cost(start_next(1)-1:start_next(1)+1, start_next(2)-1:start_next(2)+1);
    neigh_dirs = zeros(3);
    for i = -1:1
        for j = -1:1
            neigh_dirs(i+2,j+2) = sqrt(sum((start+[i,j]-stop).^2));
        end
    end
    neigh_dirs(2,2) = Inf;
    neigh_dirs = neigh_dirs + neigh_costs;
    minimum = min(min(neigh_dirs));
    [xmin,ymin] = find(neigh_dirs == minimum);
    next_point = start_next + [xmin, ymin] - [2,2];
    next_steps(end+1, :) = next_point;
    start_next = next_point;
end
path = next_steps;
end