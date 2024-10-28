function [X,Y,X_scale,Y_scale] = load_data(data_id)
switch data_id
    case 0
        load data/plot-data.csv plot_data
        X = plot_data(:,1)';
        Y = plot_data(:,2)';
        % scale data for the small cars
        X = X / 15000;
        Y = Y / 7;
        % consider only positive torques
        Y = Y(X >= 0);
        X = X(X >= 0);
        % eliminate any duplicate entries in X
        [X,idx] = unique(X);
        Y = Y(idx);
        % sort the values
        [X,idx] = sort(X);
        Y = Y(idx);
    otherwise
        error('Data ID unknown.')
end

% normalize the data
X_scale = max(abs(X));
Y_scale = max(abs(Y));
X = X ./ X_scale;
Y = Y ./ Y_scale;

assert(length(X)==length(Y),'data size error')
end