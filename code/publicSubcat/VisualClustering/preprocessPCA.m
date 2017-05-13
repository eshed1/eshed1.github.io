function X = preprocessPCA(X,initial_dims,varargin);
%initial_dims is the tearget dimension for dimensionality reduction. 
%alternatively, can set energyt which is common in practice (95% or 98% or another energy amount).
energyt = -1;
if(~isempty(varargin));
    energyt = varargin{1};
end

if size(X, 2) < size(X, 1)
    C = X' * X;
else
    C = (1 / size(X, 1)) * (X * X');
end
[M, lambda] = eig(C);
[lambda, ind] = sort(diag(lambda), 'descend');
if(energyt>0)
    %%
    currE=-1; isel = 1;
    while(currE<energyt)
        isel=isel+1;
        currE = sum(lambda(1:isel))/sum(lambda);
    end
    %%
    M = M(:,ind(1:isel));
    lambda = lambda(1:isel);
else
    M = M(:,ind(1:initial_dims));
    lambda = lambda(1:initial_dims);
end
if ~(size(X, 2) < size(X, 1))
    M = bsxfun(@times, X' * M, (1 ./ sqrt(size(X, 1) .* lambda))');
end
X = bsxfun(@minus, X, mean(X, 1)) * M;
%     clear M lambda ind
end