prepare_data <- function(data, lags=1, constant=TRUE, standardize=FALSE) {
  # Preprocessing ----
  var_names <- colnames(data)
  N <- nrow(data)-lags
  K <- ncol(data)
  var_names <- colnames(data)
  data <- data.table::as.data.table(data)
  # Standardize:
  if (standardize) {
    scaler <- list(
      means = data[,lapply(.SD, mean)],
      sd = data[,lapply(.SD, sd)]
    )
    data[,(var_names):=lapply(.SD, function(i) {(i-mean(i))/sd(i)}),.SDcols=var_names]
  } else {
    scale <- NULL
  }
  # Data and lags:
  new_names <- c(sapply(1:lags, function(p) sprintf("%s_l%i", var_names, p)))
  data[
    ,
    (new_names) := sapply(
      1:lags, 
      function(lag) {
        data.table::shift(.SD, lag)
      }
    )
  ]
  # Dependent variable:
  y = as.matrix(data[(lags+1):.N,1:K])
  # Explanatory variables:
  if (constant==T) {
    const = 1
    X = cbind("constant"=1,as.matrix(data[(lags+1):.N,(K+1):ncol(data)]))
  } else {
    const = 0
    X = as.matrix(data[(lags+1):.N,(K+1):ncol(data)])
  }
  
  # Output:
  var_data <- list(
    X=X,
    y=y,
    lags=lags,
    K=K,
    var_names=var_names,
    scaler=scaler
  )
  class(var_data) <- "var_data"
  
  return(var_data)
}