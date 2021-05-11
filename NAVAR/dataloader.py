import torch
import numpy as np

class DataLoader(object):

    def __init__(self, data, maxlags, normalize=True,  val_proportion=0.1, split_timeseries=False, lstm=False):
        self.all_Xs, self.all_Ys = self.prepare_data(data, maxlags, normalize, split_timeseries)
        self.train_Xs, self.train_Ys, self.val_Xs, self.val_Ys = self.split_train_val(val_proportion)

    def prepare_data(self, data, maxlags, normalize, split_timeseries=False):
        """
        Prepares multivariate time series data such that it can be used by a NAVAR model

        Args:
            data: ndarray
                T (time points) x N (variables) input data
            maxlags: int
                Maximum number of time lags
            normalize: bool
                Indicates whether we should should normalize every variable
            split_timeseries: int
                If the original time series consists of multiple shorter time series, this argument should indicate the
                original time series length. Otherwise should be zero.
            lstm: bool
                Indicates whether we should prepare the data for a LSTM model (or MLP).
        Returns:
            X: Tensor (T - maxlags - 1) x maxlags x N
                Input for the NAVAR model
            Y: Tensor (T - maxlags - 1) x N
                Target variables for the NAVAR model
        """
        # T is the total number of time steps, N is the number of variables
        T, N = data.shape
        data = torch.from_numpy(data)

        # normalize every variable to have 0 mean and standard deviation 1
        if normalize:
            data = data / torch.std(data, dim=0)
            data = data - data.mean(dim=0)
        
        # initialize our input and target variables
        X = torch.zeros((int(T/maxlags), maxlags, N))
        
        # X and Y consist of timeseries of length K
        for i in range(int(T/maxlags) -1):
            X[i, :, :] = data[i*maxlags:(i+1)*maxlags, :]
        X = X.permute(0, 2, 1)
        X.view(-1, N, maxlags)
        Y = X[:, :, 1:]
        X = X[:, :, :-1]
            
            
        return X, Y

    def split_train_val(self, val_proportion):
        """
        Splits the data in a training and validation set. The validation set is the final 'val_proportion' of the
        data.
        Args:
            val_proportion: float
                Proportion of the data set that should be used for validation
        Returns:
            List of Tensors:
                [training_Xs, training_Ys, validation_Xs, validation_Ys]

        """
        number_of_val_indices = np.int(np.floor(val_proportion * self.all_Ys.shape[0]))
        train_indices = np.arange(self.all_Ys.shape[0] - number_of_val_indices)
        val_indices = np.arange(self.all_Ys.shape[0] - number_of_val_indices, self.all_Ys.shape[0])
        if val_proportion == 0:
            return self.all_Xs, self.all_Ys, None, None
        else:
            return self.all_Xs[train_indices], self.all_Ys[train_indices], \
                   self.all_Xs[val_indices], self.all_Ys[val_indices]
