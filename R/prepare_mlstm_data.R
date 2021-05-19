library(keras)
prepare_mlstm_data <- function(data, lags=1, horizon=1, type="standard") {
  
  if (type=="var") {
    var_data <- prepare_data(data, lags = lags, standardize = TRUE)
    mlstm_data <- prepare_lstm(var_data)
  } else if (type=="standard") {
    mlstm_data <- mlstm_standard(data, lags=1, horizon=1)
  }
  
  return(mlstm_data)
  
}