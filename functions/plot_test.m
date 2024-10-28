function [] = plot_test(test_data)
X_scale = test_data.X_scale;
p = test_data.p;

torques_opt_log = test_data.torques_opt_log * X_scale;
objective_log = test_data.objective_log * test_data.Y_scale;
torque_demand_array = test_data.torque_demand_array * X_scale;

figure

yyaxis left
ratio_opt = (torques_opt_log(1,:)+torques_opt_log(2,:)) ./ sum(torques_opt_log);
ratio_opt = round(ratio_opt,2);
stairs(torque_demand_array,100*ratio_opt)
ylabel('Front-to-total torque split [\%]')

if test_data.fit_id == 1  % cubic fit is used
    xline(X_scale * (-4*p(2)/(3*p(1))),'--')  % switching torque
end    

yyaxis right
plot(torque_demand_array,objective_log,'*')
ylabel('Objective')

% mark failed cases
if isfield(test_data,'status_log')
    idx = test_data.status_log > 0;
    hold on
    plot(torque_demand_array(idx),objective_log(idx),'k*')
end

xlabel('Total torque demand [Nm]')

switch test_data.fit_id
    case 0
        fit_str = 'Kernel regression';
    case {1,2}
        fit_str = ['Polynomial of order ',num2str(length(p)-1)];
end

switch test_data.test_id
    case {0,1,2}
        test_str = 'direct test';
    case 3
        test_str = 'YALMIP test';
    case 4
        test_str = 'CasADi test';
    case 5
        test_str = 'acados test';
end

title([fit_str, ' - ', test_str])
