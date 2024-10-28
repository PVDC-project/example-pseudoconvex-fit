function ocp_solver = create_acados_nlp_solver(solver_data)
x = solver_data.x;
p = solver_data.p;
f = solver_data.f;
g = solver_data.g;
glb = solver_data.glb;
gub = solver_data.gub;

% acados model object
model = AcadosModel();
model.name = 'generic_nlp';
model.x = x;
model.p = p;
model.f_expl_expr = casadi.SX.zeros(length(model.x),1);

% acados ocp formulation
ocp = AcadosOcp();
ocp.name = 'nlp_solver';
ocp.model = model;

% (terminal) cost
ocp.cost.cost_type_e = 'EXTERNAL';
ocp.model.cost_expr_ext_cost_e = f;

% (terminal) constraints
ocp.model.con_h_expr_e = g;
ocp.constraints.lh_e = glb;
ocp.constraints.uh_e = gub;

% initial parameter values
ocp.parameter_values = zeros(length(model.p),1);

% set additional fields to prevent errors/warnings
ocp.cost.cost_type_0 = 'EXTERNAL';
ocp.model.cost_expr_ext_cost_0 = 0;
ocp.cost.cost_type = 'EXTERNAL';
ocp.model.cost_expr_ext_cost = 0;

% solver options
ocp.solver_options.tf = 1;
ocp.solver_options.N_horizon = 1;
ocp.solver_options.nlp_solver_type = 'SQP';
ocp.solver_options.integrator_type = 'ERK';
ocp.solver_options.sim_method_num_stages = 1;
ocp.solver_options.sim_method_num_steps = 1;
ocp.solver_options.nlp_solver_max_iter = 500;

% create the solver
ocp_solver = AcadosOcpSolver(ocp);
end
