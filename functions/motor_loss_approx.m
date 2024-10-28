function cost = motor_loss_approx(torques,cost_type,test_data)
cost = 0;
switch cost_type
    case 0  % kernel regression
        a = test_data.a;
        a0 = test_data.a0;
        X = test_data.X;
        cost = 0;
        for k = 1:4
            motor_cost = kernel_vector(torques(k),X) * a + a0;
            cost = cost + motor_cost;
        end
    case {1,2}  % cubic or polynomial fit
        p = test_data.p;
        for motor_idx = 1:4
            torque = torques(motor_idx);
            if isnumeric(torque)
                motor_cost = polyval(p,torque);
            else  % sdpvar
                v = monolist(torque,length(p)-1);  % monomials of order n
                motor_cost = fliplr(p) * v;
            end
            cost = cost + motor_cost;
        end
end