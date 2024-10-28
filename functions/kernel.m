function [k,j] = kernel(x1, x2)
    % kernel function definition (squared-exponential)
    v = 1;      % output variance (parameter)
    l = 0.01;   % length scale (parameter)
    
    k = v^2 * exp(-1/(2*l^2) * (x1-x2)'*(x1-x2));
    j = (k / (l^2)) * (x2 - x1);  % derivative w.r.t x1 (analytic)
end