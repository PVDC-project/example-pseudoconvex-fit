function [] = plot_total_loss(test_data)
X = test_data.X;
X_scale = test_data.X_scale;
Y_scale = test_data.Y_scale;

[a,b] = meshgrid(X,X);
cost_type = test_data.fit_id == 2;  % polynomial, otherwise kernel
cost = @(x,y) 0.5 * motor_loss_approx([x;x;y;y],cost_type,test_data);  % plot for 2 motors only
Z = arrayfun(cost,a,b);

figure
surf(a*X_scale,b*X_scale,Z*Y_scale)
xlabel('$T_1$ [Nm]')
ylabel('$T_2$ [Nm]')
zlabel('Losses [W]')
title('Combined losses with 2 motors')
end