prepare_data <- function(data, lags=1, constant=TRUE) {
  # Preprocessing ----
  var_names <- colnames(data)
  N <- nrow(data)-lags
  K <- ncol(data)
  var_names <- colnames(data)
  data <- data.table::as.data.table(data)
  data_out <- data.table::copy(data)
  # Data and lags:
  new_names <- c(sapply(1:lags, function(p) sprintf("%s_l%i", var_names, p)))
  data_out[
    ,
    (new_names) := sapply(
      1:lags, 
      function(lag) {
        data.table::shift(.SD, lag)
      }
    )
  ]
  # Dependent variable:
  y = as.matrix(data_out[(lags+1):.N,1:K])
  # Explanatory variables:
  if (constant==T) {
    const = 1
    X = cbind("constant"=1,as.matrix(data_out[(lags+1):.N,(K+1):ncol(data_out)]))
  } else {
    const = 0
    X = as.matrix(data_out[(lags+1):.N,(K+1):ncol(data_out)])
  }
  
  # Output:
  var_data <- list(
    X=X,
    y=y,
    lags=lags,
    K=K
  )
  class(var_data) <- "var_data"
  
  return(var_data)
}