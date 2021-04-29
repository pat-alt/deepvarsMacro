#' navar_lstm_init
#'
#' @param num_nodes The number of time series (N)
#' @param num_hidden Number of hidden units per layer
#' @param hidden_layers Number of hidden layers
#' @param dropout Dropout probability of units in hidden layers
#' @param bias_scale Scaling factor for bias
#'
#' @return
#' @export
#'
#' @examples
navar_lstm_init <- function(num_nodes, num_hidden, hidden_layers, dropout, bias_scale=0.0001) {
  self$num_nodes <- num_nodes
  self$num_hidden <- num_hidden
  self$lstm_list <- nn_module_list(
    lapply(
      1:num_nodes,
      function(i) {
        nn_lstm(
          input_size = 1, 
          hidden_size = num_hidden, 
          num_layers = hidden_layers,
          dropout = dropout,
          batch_first = TRUE
        )
      }
    )
  )
  self$fc_list <- nn_module_list(
    lapply(
      1:num_nodes,
      function(i) {
        nn_linear(in_features = num_hidden, out_features = num_nodes)
      }
    )
  )
  self$biases <- nn_parameter(torch_ones(1, num_nodes) * bias_scale)
}

navar_lstm_forward <- function(x) {
  batch_size <- x$size()[1]
  number_of_nodes <- x$size()[2]
  time_series_length <- x$size()[3]
  contribution <- torch_zeros(batch_size, number_of_nodes, time_series_length)
  
  # we split the input into the components
  x <- torch_split(x, split_size = 1, dim = 1)
  
  # then we apply the LSTM layers and calculate the contributions
  for (node in 1:self$num_nodes) {
    model_input <- torch_transpose(x[node,], 1, 2)
    lstm <- self$lstm_list[[node]]
    fc <- self$fc_list[[node]]
    list_output <- lstm(model_input)
    contributions[,(node*self$num_nodes):((node+1)*self$num_nodes),] <- torch_transpose(fc(lstm_output))
  }
  
  contributions <- torch_reshape(contributions, list(batch_size, self$num_nodes, self$num_nodes, time_series_length))
  predictions <- torch_sum(contributions, dim=1) + torch_transpose(self$biases, 0, 1)
  contributions <- torch_squeeze(torch_reshape(contributions, list(-1, self$num_nodes*self$num_hidden, 1)))
  
  return(
    list(
      predictions = predictions,
      contributions = contributions
    )
  )
}

# Module
navar_lstm <- nn_module(
  classname = "NAVARLSTM",
  initialize = navar_lstm_init,
  forward = navar_lstm_forward
)