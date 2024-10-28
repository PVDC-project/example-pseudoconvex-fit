function [k_vect,k_grad] = kernel_vector(x,X)
    N = size(X,2);
    k_vect = nan(1,N);
    k_grad = nan(1,N);
    if ~isa(x,'sdpvar')  % preallocation doesn't work with sdpvars
        k_vect = nan(1,N);
        k_grad = nan(1,N);
    end             
    if isa(x,'sym')  % if x is symbolic (MATLAB toolbox)
        k_vect = sym(k_vect);
        k_grad = sym(k_grad);
    end    
    if isa(x,'casadi.MX')  % cast for CasADi
        k_vect = casadi.MX(k_vect);
        k_grad = casadi.MX(k_vect);
    end
    
    for idx = 1:N
        [k,j] = kernel(x,X(:,idx));
        k_vect(idx) = k;
        k_grad(idx) = j;
    end
end
