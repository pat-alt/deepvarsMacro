# Train test split:
train_test_split <- function(var_data,ratio_train=0.8,n_train=NULL) {
  # Unpack:
  list2env(var_data, envir = environment())
  # Splitting:
  if (is.null(n_train)) {
    n_train <- floor(ratio_train * nrow(X))
  }
  X_train <- X[1:n_train,]
  y_train <- y[1:n_train,]
  X_test <- X[(n_train+1):nrow(X),]
  y_test <- y[(n_train+1):nrow(y),]
  return(
    list(
      X_train=X_train,
      y_train=y_train,
      X_test=X_test,
      y_test=y_test
    )
  )
}

train_test_split <- function(var_data,ratio_train=0.8,n_train=NULL) {
  UseMethod("train_test_split", var_data)
}

# Invert scaling
invert_scaling.var_data <- function(y, var_data, k=NULL) {
  if (!is.null(var_data$scaler)) {
    y <- data.table(y)
    if (!is.null(k)) {
      var_names <- var_data$var_names[k]
    } else {
      var_names <- var_data$var_names
    }
    colnames(y) <- var_names
    y[
      ,
      (var_names):=lapply(
        var_names, 
        function(var) {
          get(var) * var_data$scaler$sd[1,get(var)] + var_data$scaler$means[1,get(var)]
        }
      )
    ]
  } else {
    message("Data was never scaled.")
  }
  return(y)
}

invert_scaling <- function(y, var_data, k=NULL) {
  UseMethod("invert_scaling", var_data)
}

# Prepare for LSTM model
prepare_lstm.var_data <- function(var_data) {
  # Unpack:
  list2env(var_data, envir = environment())
  # Remove constant if necessary:
  if (ncol(X)!=ncol(y)) {
    X <- X[,-1]
  }
  # Reshape:
  X <- array_reshape(X, c(nrow(X),1,ncol(X)))
  y <- array_reshape(y, c(nrow(y),1,ncol(y)))
  
  # Output:
  mlstm_data <- list(
    X=X,
    y=y,
    lags=lags,
    K=K,
    var_names=var_names,
    scaler=scaler,
    data=data
  )
  class(mlstm_data) <- "mlstm_data"
  return(mlstm_data)
}

prepare_lstm <- function(var_data) {
  UseMethod("prepare_lstm", var_data)
}