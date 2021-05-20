library(keras)
prepare_mlstm_data <- function(data, lags=1, horizon=1, type="var") {
  
  if (type=="var") {
    var_data <- prepare_var_data(data, lags = lags, standardize = TRUE)
    mlstm_data <- prepare_lstm(var_data)
  } else if (type=="standard") {
    mlstm_data <- mlstm_standard(data, lags=lags, horizon=1)
  }
  
  return(mlstm_data)
  
}