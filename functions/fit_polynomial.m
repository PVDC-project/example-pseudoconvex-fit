function p_opt = fit_polynomial(X,Y,n)
% fit a pseudoconvex polynomial of order n
% implementation is based on https://yalmip.github.io/example/polynomialdesign/

% create the polynomial and higher derivatives
x = sdpvar(1);
[p,a] = polynomial(x,n);  % p = a' * v; v = [1,x,x^2,...,x^n]
dp = jacobian(p,x);

% objective (least-squares)
objective = 0;
for k = 1:length(X)
    e = replace(p,x,X(k)) - Y(k);
    objective = objective + e'*e;
end

% use sum-of-squares reformulation to ensure positivity of the gradient
% on the interval x >= 0
m = 3;  % order of the multiplier s(x) in p(x) = s(x)*g(x)
[s,c] = polynomial(x,m);
g = x;
constraints = [sos(s), sos(dp-s*g)];
options = [];
decision_vars = [a;c];
[sol,~,~,res] = solvesos(constraints, objective, options, decision_vars);
assert(~sol.problem, 'solver error')
assert(~any(clean(res,1e-6)), 'residual too large')

p_opt = fliplr(value(a'));  % YALMIP vs. MATLAB convention
end
