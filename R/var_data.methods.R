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

# Prepare for LSTM model
prepare_lstm.var_data <- function(var_data) {
  # Unpack:
  list2env(var_data, envir = environment())
  # Remove constant if necessary:
  if (ncol(X)!=ncol(y)) {
    X <- X[,-1]
  }
  # Reshape:
  X <- array_reshape(X, c(nrow(X),lags,ncol(X)))
  y <- array_reshape(y, c(nrow(y),lags,ncol(y)))
  # Output:
  var_data_lstm <- list(
    X = X,
    y = y,
    var_data = var_data
  )
  class(var_data_lstm) <- "var_data_lstm"
  return(var_data_lstm)
}

prepare_lstm <- function(var_data) {
  UseMethod("prepare_lstm", var_data)
}