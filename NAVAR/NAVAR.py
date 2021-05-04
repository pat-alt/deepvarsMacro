import torch.nn as nn
import torch

class NAVAR(nn.Module):
    def __init__(self, num_nodes, num_hidden, maxlags, hidden_layers=1, dropout=0):
        """
        Neural Additive Vector AutoRegression (NAVAR) model
        Args:
            num_nodes: int
                The number of time series (N)
            num_hidden: int
                Number of hidden units per layer
            maxlags: int
                Maximum number of time lags considered (K)
            hidden_layers: int
                Number of hidden layers
            dropout:
                Dropout probability of units in hidden layers
        """
        super(NAVAR, self).__init__()

        self.num_nodes = num_nodes
        self.num_hidden = num_hidden
        self.first_hidden_layer = nn.Conv1d(num_nodes, num_hidden * num_nodes, kernel_size=maxlags,
                                                  groups=num_nodes)
        self.dropout = nn.Dropout(p=dropout)
        self.hidden_layer_list = nn.ModuleList()
        self.dropout_list = nn.ModuleList()
        for k in range(hidden_layers - 1):
            self.hidden_layer_list.append(
                nn.Conv1d(num_nodes, num_hidden * num_nodes, kernel_size=num_hidden, groups=num_nodes))
            self.dropout_list.append(nn.Dropout(p=dropout))
        self.contributions = nn.Conv1d(num_nodes, num_nodes * num_nodes, kernel_size=num_hidden, groups=num_nodes)
        self.biases = nn.Parameter(torch.ones(1, num_nodes) * 0.0001)

    def forward(self, x):
        hidden = self.first_hidden_layer(x).clamp(min=0).view([-1, self.num_nodes, self.num_hidden])
        hidden = self.dropout(hidden)
        for i in range(len(self.hidden_layer_list)):
            hidden = self.hidden_layer_list[i](hidden).clamp(min=0).view([-1, self.num_nodes, self.num_hidden])
            hidden = self.dropout_list[i](hidden)

        contributions = self.contributions(hidden)
        contributions = contributions.view([-1, self.num_nodes, self.num_nodes, 1])
        predictions = torch.sum(contributions, dim=1).squeeze() #+ self.biases
        contributions = contributions.view([-1, self.num_nodes*self.num_nodes, 1]).squeeze()
        return predictions, contributions

class NAVARLSTM(nn.Module):
    def __init__(self, num_nodes, num_hidden, maxlags, hidden_layers=1, dropout=0):
        """
        Neural Additive Vector AutoRegression (NAVAR) model
        Args:
            num_nodes: int
                The number of time series (N)
            num_hidden: int
                Number of hidden units per layer
            maxlags: int
                Maximum number of time lags considered (K)
            hidden_layers: int
                Number of hidden layers
            dropout:
                Dropout probability of units in hidden layers
        """
        super(NAVARLSTM, self).__init__()

        self.num_nodes = num_nodes # output nodes (N variables)
        self.num_hidden = num_hidden # number of neurons (think with)

        self.lstm_list = nn.ModuleList()
        self.fc_list = nn.ModuleList()
        # For all of our N variables:
        for node in range(self.num_nodes):
            # He uses: input dimension = 1, num_hidden = 10 (random?), hidden states/layers = 1 (random?)
            self.lstm_list.append(nn.LSTM(1, num_hidden, hidden_layers, dropout=dropout, batch_first=True))
            # ... should return something of shape (1 x 10) - think dimension 10 (num_hidden)
            # This is then fed to dense layer ...
            self.fc_list.append(nn.Linear(num_hidden, num_nodes))
            # which outputs something of dimension (num_nodes). 

        self.biases = nn.Parameter(torch.ones(1, num_nodes) * 0.0001)

    def forward(self, x):
        batch_size, number_of_nodes, time_series_length = x.shape
        contributions = torch.zeros((batch_size, self.num_nodes*self.num_nodes, time_series_length)).cuda()
       
        # we split the input into the components
        x = x.split(1, dim=1)

        # then we apply the LSTM layers and calculate the contributions
        for node in range(self.num_nodes):
            model_input = torch.transpose(x[node], 1, 2)
            lstm = self.lstm_list[node] # instantiate
            fc = self.fc_list[node] # instantiate
            lstm_output, _ = lstm(model_input) # output of dimension num_hidden (10)
            # ... then feed to dense/Linear layer (take input of dim 10 -> num_nodes)
            contributions[:, node*self.num_nodes:(node+1)*self.num_nodes, :] = fc(lstm_output).transpose(1,2)

        contributions = contributions.view([batch_size, self.num_nodes, self.num_nodes, time_series_length])
        predictions = torch.sum(contributions, dim=1) + self.biases.transpose(0,1)
        contributions = contributions.view([-1, self.num_nodes*self.num_nodes, 1]).squeeze()
        return predictions, contributions
        

