% Pseudoconvex approximation of motor losses
clear all; clc;close all;
addpath('functions')

%% data preparation
% 0 - data from Fig. 4 in https://ieeexplore.ieee.org/abstract/document/7430272 (105 km/h, scaled to small cars)
data_id = 0;
[X,Y,X_scale,Y_scale] = load_data(data_id);  % normalized to [0,1]

%% motor loss approximation
% 0 - kernel regression
% 1 - cubic fit (explicit pseudoconvex constraints)
% 2 - polynomial fit of order n (pseudoconvexity through sum-of-squares)
fit_id = 2;

fig = figure;  % display fit
switch fit_id
    case 0  % kernel regression
        [a,a0] = fit_kernel(X,Y);
        y = arrayfun(@(x) kernel_vector(x,X) * a + a0, X);
        title_str = 'Kernel regression';
        p = fit_cubic(X,Y);  % for comparison
    case 1  % cubic fit
        p = fit_cubic(X,Y);
        y = polyval(p,X);
        title_str = 'Cubic approximation';
    case 2  % polynomial fit
        n = 5;
        p = fit_polynomial(X,Y,n);
        y = polyval(p,X);
        title_str = ['Polynomial approximation of order ',num2str(n)];
end
plot_fit(X,Y,y,X_scale,Y_scale,fig)
title(title_str)

%% test the fit for torque distribution
% 0 - direct test (FWD vs. AWD) with kernel regression
% 1 - direct test (FWD vs. AWD) with the cubic fit
% 2 - direct test (FWD vs. AWD) with a polynomial fit of order n
% 3 - optimization-based test using YALMIP
% 4 - optimization-based test using CasADi
% 5 - optimization-based test using acados
test_id = 4;

test_data = struct('test_id',test_id,'fit_id',fit_id,'p',p,...
                   'X',X,'X_scale',X_scale,'Y_scale',Y_scale);
if ~fit_id  % kernel regression is used
    test_data.a = a;
    test_data.a0 = a0;
end

if test_id < 3  % direct optimization
    if (test_id ~= test_data.fit_id)
        warning('matching test_id and fit_id...')
        test_id = test_data.fit_id;
    end
end

switch test_id
    case {0,1,2}
        test_data = test_direct(test_data);
    case 3
        test_data = test_yalmip(test_data);
    case 4
        test_data = test_casadi(test_data);
    case 5
        test_data = test_acados(test_data);
end

plot_test(test_data)

plot_total_loss(test_data)
