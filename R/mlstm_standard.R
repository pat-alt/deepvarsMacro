mlstm_standard <- function(data, lags=1, horizon=1) {
  # Set up: ----
  var_names <- colnames(data)[colnames(data)!="date"] # variable names excluding date
  if ("date" %in% names(data)) {
    if (data[,class(date)[1]]!="Date") {
      warning("Date indexing is only implemented for date of class Date. Using simple integer index instead.")
      data[,date:=1:.N]
    }
  }
  data <- data.table::as.data.table(data) # turn into data.table
  data_out <- copy(data) # save a copy of all data
  data <- data[,.SD,.SDcols=var_names] # keep only model variables
  N <- nrow(data)-lags
  K <- ncol(data)
  
  # Standardize: ----
  scaler <- list(
    means = data[,lapply(.SD, mean),.SDcols=var_names],
    sd = data[,lapply(.SD, sd),.SDcols=var_names]
  )
  data[,(var_names):=lapply(.SD, function(i) {(i-mean(i))/sd(i)}),.SDcols=var_names]
  
  # Reshape: ----
  X <- array(data = as.matrix(na.omit(data[,shift(.SD, lags)])), dim = c(N, lags, ncol(data)))
  y <- array(data = as.matrix(data[-(1:lags),]), dim = c(N, horizon, ncol(data)))
  
  # Output:
  mlstm_data <- list(
    X=X,
    y=y,
    lags=lags,
    K=K,
    var_names=var_names,
    scaler=scaler,
    data=data_out
  )
  class(mlstm_data) <- "mlstm_data"
  
  return(mlstm_data)
}