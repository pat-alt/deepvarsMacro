# Train test split:
train_test_split.mlstm_data <- function(mlstm_data,ratio_train=0.8,n_train=NULL) {
  # Unpack:
  list2env(mlstm_data, envir = environment())
  # Splitting:
  if (is.null(n_train)) {
    n_train <- floor(ratio_train * nrow(X))
  }
  X_train <- array(X[1:n_train,,], dim = c(n_train, dim(mlstm_data$X)[2:3]))
  y_train <- array(y[1:n_train,,], dim = c(n_train, dim(mlstm_data$y)[2:3]))
  X_test <- array(X[(n_train+1):nrow(X),,], dim = c(nrow(X)-n_train, dim(mlstm_data$X)[2:3]))
  y_test <- array(X[(n_train+1):nrow(y),,], dim = c(nrow(y)-n_train, dim(mlstm_data$y)[2:3]))
  return(
    list(
      X_train=X_train,
      y_train=y_train,
      X_test=X_test,
      y_test=y_test
    )
  )
}

train_test_split <- function(mlstm_data,ratio_train=0.8,n_train=NULL) {
  UseMethod("train_test_split", mlstm_data)
}


# Invert scaling
invert_scaling.mlstm_data <- function(y, mlstm_data, k=NULL) {
  
  y <- data.table(y)
  if (!is.null(k)) {
    var_names <- mlstm_data$var_names[k]
  } else {
    var_names <- mlstm_data$var_names
  }
  colnames(y) <- var_names
  # Invert scaling:
  y[
    ,
    (var_names):=lapply(
      var_names, 
      function(var) {
        get(var) * mlstm_data$scaler$sd[1,get(var)] + mlstm_data$scaler$means[1,get(var)]
      }
    )
  ]
  
  return(y)
}

invert_scaling <- function(y, mlstm_data, k=NULL) {
  UseMethod("invert_scaling", mlstm_data)
}