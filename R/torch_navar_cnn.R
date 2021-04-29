#' navar_cnn_init
#'
#' @param num_nodes 
#' @param num_hidden 
#' @param max_lags 
#' @param hidden_layers 
#' @param dropout 
#' @param bias_scale 
#'
#' @import torch
navar_cnn_init <- function(num_nodes, num_hidden, max_lags, hidden_layers=1, dropout=0, bias_scale=0.0001) {
  self$num_nodes <-  num_nodes
  self$num_hidden <- num_hidden
  self$bias_scale <- bias_scale
  # First layer ----
  self$first_hidden_layer <- nn_conv1d(
    in_channels = num_nodes, # ?
    out_channels = num_hidden * num_nodes, # ?
    kernel_size = max_lags, # lag length
    groups = num_nodes # ?
  )
  self$dropout = nn_dropout(p=dropout)
  # Sequential layers ----
  self$conv_list = nn_module_list() # layer list
  self$dropout_list = nn_module_list() # list for dropout indices
  for (i in 2:hidden_layers) {
    self$conv_list[[i]] <- nn_conv1d(
      in_channels = num_nodes, # ?
      out_channels = num_hidden * num_nodes, # ?
      kernel_size = num_hidden, # ?
      groups = num_nodes # ?
    )
  }
  self$dropout_list <- append(self$dropout_list, nn_dropout(p=dropout))
  # Final contributions ----
  self$contributions <- nn_conv1d(
    in_channels = num_nodes, # ?
    out_channels = num_nodes * num_nodes, # ?
    kernel_size = num_hidden, # ?
    groups = num_nodes # ?
  )
  self$biases <- nn_parameter(torch_ones(1, num_nodes) * self$bias_scale)
}

#' navar_cnn_forward
#'
#' @param x 
#'
#' @import torch
navar_cnn_forward <- function(x) {
  hidden <- torch_reshape(torch_clamp(self$first_hidden_layer(x)),list(-1,self$num_nodes,self$num_hidden))
  # hidden = self.first_hidden_layer(x).clamp(min=0).view([-1, self.num_nodes, self.num_hidden])
  hidden <- self$dropout(hidden)
  for (i in 1:length(self$hidden_layer_list)) {
    hidden <- torch_reshape(torch_clamp(self$hidden_layer_list[[i]](x)),list(-1,self$num_nodes,self$num_hidden))
  }
  hidden <- self$dropout_list[[i]](hidden)
  # Compute contributions
  contributions <- self$contributions(hidden)
  contributions <- torch_reshape(contributions, list(-1,self$num_nodes,self$num_hidden))
  predictions <- torch_squeeze(torch_sum(contributions, dim=1)) # + self$biases
  contributions <- torch_squeeze(torch_reshape(contributions, list(-1, self$num_nodes*self$num_hidden, 1)))
  return(
    list(
      predictions = predictions,
      contributions = contributions
    )
  )
}

# Module
navar_cnn <- nn_module(
  classname = "NAVAR",
  initialize = navar_cnn_init,
  forward = navar_cnn_forward
)