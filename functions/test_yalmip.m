function test_data = test_yalmip(test_data)
cost_type = test_data.fit_id;  % 0 - kernel, 1 - cubic, 2 - polynomial
cost = @(torques) motor_loss_approx(torques,cost_type,test_data);

X = test_data.X;
min_torque_demand = 4*X(1);
max_torque_demand = 4*X(end)/2;
number_of_points = 100;
torque_demand_array = linspace(min_torque_demand,max_torque_demand,number_of_points);

% optimization problem formulation
disp('Formulating the optimization problem...')
torques = sdpvar(4,1);
total_torque = sdpvar(1);
objective = 0;
for motor_idx = 1:4
    objective = objective + cost(torques);
end
constraints = [];
constraints = [constraints, torques >= 0];
constraints = [constraints, sum(torques) == total_torque];
constraints = [constraints, torques(1) == torques(2), torques(3) == torques(4)];
yalmip_settings = sdpsettings('verbose',0);
yalmip_settings.usex0 = 1;
yalmip_settings.fmincon.ScaleProblem = true;

% optimization-based test
torques_opt_log = nan(4,length(torque_demand_array));
objective_log = nan(1,length(torque_demand_array));
k = 1;
print_interval = length(torque_demand_array)/10;
disp('Starting the test...')
for torque_demand = torque_demand_array
    % random init is necessary
    rand_torque = torque_demand / 4 + X(end)/10*(-1 + 2*rand(4,1));
    assign(torques, rand_torque)

    diagnostics = optimize([constraints, sum(torques)==torque_demand], objective, yalmip_settings);
    exitflag = diagnostics.problem;

    if exitflag; disp(diagnostics.infostr); warning('Solver error, continuing anyway...'); end
    torques_opt_log(:,k) = sort(value(torques), 'descend');  % to force the front motors
    objective_log(k) = value(objective);
    k = k + 1;

    if ~mod(k,print_interval); disp([num2str(k/print_interval*10),'% done.'])
end

test_data.torque_demand_array = torque_demand_array;
test_data.torques_opt_log = torques_opt_log;
test_data.objective_log = objective_log;
end
