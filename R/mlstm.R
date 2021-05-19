# Main class: ----
mlstm <- function(mlstm_data, n_units=50) {
  K <- mlstm_data$K
  dim_input <- dim(mlstm_data$X)[2:3]
  model_list <- lapply(
    1:K, 
    function(k) {
      model <- keras_model_sequential() %>% 
        layer_lstm(units = n_units, input_shape = dim_input) %>% 
        layer_dense(units = 1)
      model %>% 
        compile(
          loss = "mae",
          optimizer = "adam"
        )
      return(model)
    }
  )
  
  mlstm <- list(
    model_list = model_list,
    model_data = mlstm_data
  )
  class(mlstm) <- "mlstm"
  return(mlstm)
}

