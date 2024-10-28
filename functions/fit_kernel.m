function [a_opt,a0_opt] = fit_kernel(X,Y)
% based on section II in https://ieeexplore.ieee.org/document/9699361
% (with some modifications)

% get dimensions
N = size(X,2);

% (symbolic) jacobian function for eq. (3b)
% x_sym = sym('x',[size(X,1),1],'real');
% [~, k_grad] = kernel_vector(x_sym,X);
% k_grad = jacobian(k_sym,x_sym)';

% optimization using YALMIP
disp('Setting up the kernel regression...')
s = 0.15;   % regularization parameter "sigma" in eq. (3a)
% xopt = 0;   % problem-dependent optimum, parameter x* in eq. (3b)

% y = k(x,X) * a + a0; optimize for a and a0
a0 = sdpvar;
a = sdpvar(N,1);

% least-squares cost
x = kernel_matrix(X);  
x = x .* (x > 1e-6);  % remove small values (Gaussian kernel is unbounded)

e = (s^2*eye(N) + x) * a + ...
    ones(N,1) * a0 - Y';
objective = e'*e;

% pseudoconvexity constraints (between two adjacent points)
constraints = [];
upsample_factor = 3;  % interpolate data for a finer gridding
N2 = N * upsample_factor - (upsample_factor-1);
X2 = interp1(X,1:1/upsample_factor:numel(X));
for k = 2:N2
    x = X2(:,k);
    x_prev = X2(:,k-1);
    % numerical derivative
    k_grad_numeric = 1/(x-x_prev) * (kernel_vector(x,X) - kernel_vector(x_prev,X));
    % k_grad_numeric = double(subs(k_grad,x_sym,x));  % symbolic derivative
    v1 = k_grad_numeric * a;
    v2 = x - x_prev;
    constraints = [constraints, v1' * v2 >= 0];
end

yalmip_settings = sdpsettings('verbose',2);
yalmip_settings.gurobi.NumericFocus = 1;  % improve accuracy
yalmip_settings.gurobi.TuneTimeLimit = 0;
yalmip_settings.solver = 'mosek';  % better performance than gurobi

disp('Solving the regression...')
diagnostics = optimize(constraints,objective,yalmip_settings);
if ~diagnostics.problem
    disp('Kernel regression succesful.')
else
    error('Solver error.')
end

a_opt = value(a);
a0_opt = value(a0);
end