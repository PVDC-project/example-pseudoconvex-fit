function k_matrix = kernel_matrix(X)
    N = size(X,2);
    k_matrix = nan(N);
    for idx = 1:N
        x = X(:,idx);
        k_matrix(idx,:) = kernel_vector(x,X);
    end
end