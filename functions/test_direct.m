function test_data = test_direct(test_data)
cost_type = test_data.fit_id;  % 0 - kernel, 1 - cubic, 2 - polynomial
cost = @(torques) motor_loss_approx(torques,cost_type,test_data);

X = test_data.X;
min_torque_demand = 4*X(1);
max_torque_demand = 4*X(end)/2;
number_of_points = 100;
torque_demand_array = linspace(min_torque_demand,max_torque_demand,number_of_points);

torques_opt_log = nan(4,length(torque_demand_array));
objective_log = nan(1,length(torque_demand_array));
k = 1;
for torque_demand = torque_demand_array
    torques1 = torque_demand/4 * ones(4,1);
    cost1 = cost(torques1);
    torques2 = torque_demand/2 * [1;1;0;0];
    cost2 = cost(torques2);
    if cost2 < cost1
        torques_opt_log(:,k) = torques2;
        objective_log(k) = cost2;
    else
        torques_opt_log(:,k) = torques1;
        objective_log(k) = cost1;
    end
    k = k + 1;
end

test_data.torque_demand_array = torque_demand_array;
test_data.torques_opt_log = torques_opt_log;
test_data.objective_log = objective_log;
end
