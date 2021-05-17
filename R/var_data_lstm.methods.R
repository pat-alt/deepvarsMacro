# Train test split:
train_test_split.var_data_lstm <- function(
  var_data_lstm,
  ratio_train=0.8,
  n_train=NULL
) {
  # Unpack:
  list2env(var_data_lstm, envir = environment())
  # Splitting:
  if (is.null(n_train)) {
    n_train <- floor(ratio_train * nrow(X))
  }
  N_X <- dim(X)[1]
  K_X <- dim(X)[3]
  N_y <- dim(y)[1]
  K_y <- dim(y)[3]
  X_train <- array_reshape(X[1:n_train,,], dim=c(n_train,1,K_X))
  y_train <- array_reshape(y[1:n_train,,], dim=c(n_train,1,K_y))
  X_test <- array_reshape(X[(n_train+1):nrow(X),,], dim=c(N_X-n_train,1,K_X))
  y_test <- array_reshape(y[(n_train+1):nrow(X),,], dim=c(N_y-n_train,1,K_y))
  return(
    list(
      X_train=X_train,
      y_train=y_train,
      X_test=X_test,
      y_test=y_test
    )
  )
}

train_test_split <- function(
  var_data_lstm,
  ratio_train=0.8,
  n_train=NULL
) {
  UseMethod("train_test_split", var_data_lstm)
}