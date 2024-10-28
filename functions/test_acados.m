function test_data = test_acados(test_data)
cost_type = test_data.fit_id;  % 0 - kernel, 1 - cubic, 2 - polynomial
cost = @(torques) motor_loss_approx(torques,cost_type,test_data);

X = test_data.X;
min_torque_demand = 4*X(1);
max_torque_demand = 4*X(end)/2;
number_of_points = 100;
torque_demand_array = linspace(min_torque_demand,max_torque_demand,number_of_points);

% optimization problem formulation
disp('Formulating the optimization problem...')
torques = casadi.SX.sym('torques',4);
total_torque = casadi.SX.sym('total_torque',1);
f = cost(torques);
g = vertcat( ...
    sum(torques) - total_torque,... % == 0
    torques,...                     % \in [0,1]
    torques(1) - torques(2),...     % == 0
    torques(3) - torques(4)...      % == 0
    );
glb = zeros(7,1);
gub = [0; ones(4,1); 0; 0];

% create the solver
solver_data = struct('x',torques,'p',total_torque,'f',f,'g',g,'glb',glb,'gub',gub);
ocp_solver = create_acados_nlp_solver(solver_data);

% solve the NLP for different torque demands
% optimization-based test
torques_opt_log = nan(4,number_of_points);
objective_log = nan(1,number_of_points);
status_log = nan(1,number_of_points);
k = 1;
disp('Starting the test...')
for torque_demand = torque_demand_array
    rand_torque = torque_demand/4 + torque_demand/8*rand(4,1);  % heuristic
    ocp_solver.set('init_x', repmat(rand_torque,1,2));
    ocp_solver.set('p', torque_demand);

    ocp_solver.solve();

    % check status
    status = ocp_solver.get('status');
    if status ~= 0
        warning(['solver failed with status ',num2str(status)]);
    end

    torques_opt = ocp_solver.get('x',1);
    torques_opt_log(:,k) = sort(torques_opt, 'descend');  % to force the front motors
    objective_log(k) = ocp_solver.get_cost();
    status_log(k) = status;
    k = k + 1;
    if ~mod(k/number_of_points*100,25)
        disp([num2str(k/number_of_points*100),'% done.'])
    end
end

test_data.torque_demand_array = torque_demand_array;
test_data.torques_opt_log = torques_opt_log;
test_data.objective_log = objective_log;
test_data.status_log = status_log;

% cleanup
acados_tmp_file = dir('*.json');
if ~isempty(acados_tmp_file)
    delete(acados_tmp_file.name)
end
% rmdir build s
% rmdir c_generated_code s
end
