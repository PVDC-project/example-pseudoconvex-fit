function p = fit_cubic(X,Y)
% fit a cubic function according to Section II.A in https://ieeexplore.ieee.org/abstract/document/8302960
disp('Cubic fit setup...')
sdpvar a b c d
e = (a*X.^3 + b*X.^2 + c*X + d) - Y;
objective = sum(e.*e);
constraints = [a >= 0, b <= 0, c >= 0, d >= 0, b^2 <= 3*a*c];
diagnostics = optimize(constraints,objective,sdpsettings('verbose',0));
if diagnostics.problem; error('solver issue'); end
disp('Cubic fit done.')
p = [value(a), value(b), value(c), value(d)];
end