function test_data = test_casadi(test_data)
cost_type = test_data.fit_id;  % 0 - kernel, 1 - cubic, 2 - polynomial
cost = @(torques) motor_loss_approx(torques,cost_type,test_data);

X = test_data.X;
min_torque_demand = 4*X(1);
max_torque_demand = 4*X(end)/2;
number_of_points = 100;
torque_demand_array = linspace(min_torque_demand,max_torque_demand,number_of_points);

% optimization problem formulation
disp('Formulating the optimization problem...')
opti = casadi.Opti();
torques = opti.variable(4,1);
total_torque = opti.parameter();

opti.minimize( cost(torques) );
opti.subject_to( sum(torques) == total_torque );
opti.subject_to( torques >= 0 )
opti.subject_to( torques(1) == torques(2));
opti.subject_to( torques(3) == torques(4));

p_opts = struct('print_time',0,'record_time',1);
s_opts = struct('print_level',0,'max_iter',100);
opti.solver('fatrop',p_opts,s_opts);

% optimization-based test
torques_opt_log = nan(4,length(torque_demand_array));
objective_log = nan(1,length(torque_demand_array));
k = 1;
disp('Starting the test...')
for torque_demand = torque_demand_array
    rand_torque = X(end)/2 + X(end)/10*rand(4,1);  % heuristic
    opti.set_initial(torques, rand_torque);
    
    opti.set_value(total_torque, torque_demand);
    sol = opti.solve();
    
    exitflag = sol.stats.success ~= 1;
    
    if exitflag; warning('Solver error, continuing anyway...'); end
    
    torques_opt_log(:,k) = sort(sol.value(torques), 'descend');  % to force the front motors
    try
        objective_log(k) = sol.stats.iterations.obj(end);
    catch
        objective_log(k) = cost(torques_opt_log(:,k));
    end
    k = k + 1;
    if ~mod(k/number_of_points*100,25)
        disp([num2str(k/number_of_points*100),'% done.'])
    end
end

test_data.torque_demand_array = torque_demand_array;
test_data.torques_opt_log = torques_opt_log;
test_data.objective_log = objective_log;

% cleanup
casadi_tmp_file = dir('*.casadi');
if ~isempty(casadi_tmp_file)
    delete(casadi_tmp_file.name)
end
end
