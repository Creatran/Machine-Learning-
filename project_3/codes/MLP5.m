load digits.mat
[n,d] = size(X);
nLabels = max(y);
yExpanded = linearInd2Binary(y,nLabels);
t = size(Xvalid,1);
t2 = size(Xtest,1);

% Standardize columns and add bias
[X,mu,sigma] = standardizeCols(X);
X = [ones(n,1) X];
d = d + 1;

% Make sure to apply the same transformation to the validation/test data
Xvalid = standardizeCols(Xvalid,mu,sigma);
Xvalid = [ones(t,1) Xvalid];
Xtest = standardizeCols(Xtest,mu,sigma);
Xtest = [ones(t2,1) Xtest];

% Choose network structure
nHidden = [100];

% Count number of parameters and initialize weights 'w'
nParams = d*nHidden(1);
for h = 2:length(nHidden)
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end)*nLabels;
maxIter = 100000;
w = randn(nParams,1);

% Train with stochastic gradient
%%%%%%%%%%%
stepSize = 1e-3;
funObj = @(w,i)MLP_softmax(w,X(i,:),yExpanded(i,:),nHidden,nLabels);

tic;
for iter = 1:maxIter    
    if mod(iter-1,round(maxIter/20)) == 0
        yhat = Predict5(w,Xvalid,nHidden,nLabels);
        a2 = sum(yhat~=yvalid)/t;
        fprintf('Training iteration = %d, validation error = %f\n',iter-1, a2);        
    end
    
    i = ceil(rand*n);
    [e2, g] = funObj(w,i);
    
    w = w - stepSize*g;
end
toc;

% Evaluate test error
yhat = Predict5(w, Xtest, nHidden, nLabels);
fprintf('Test error with final model = %f\n',sum(yhat~=ytest)/t2);
