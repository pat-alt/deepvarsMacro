mlstm <- function(model, var_data_lstm) {
  K <- dim(var_data_lstm$y)[3]
  model_list <- lapply(1:K, function(k) model)
  mlstm <- list(
    model_list = model_list,
    var_data_lstm = var_data_lstm
  )
  class(mlstm) <- "mlstm"
  return(mlstm)
}

# Methods:
fit.mlstm <- function(X_train,y_train,X_test,y_test,mlstm,...) {
  K <- dim(mlstm$var_data_lstm$y)[3]
  mlstm$model_list <- lapply(
    1:K,
    function(k) {
      mlstm$model_list[[k]] %>% 
        keras::fit(
          x = X_train, y = y_train[,,k],
          validation_data = list(X_test, y_test[,,k]),
          ...
        )
      mlstm$model_list[[k]]
    }
  )
  return(mlstm)
}

fit <- function(X_train,y_train,X_test,y_test,mlstm,...) {
  UseMethod("fit", mlstm)
}

predict.mlstm <- function(X, mlstm) {
  predictions <- rbindlist(
    lapply(
      1:length(mlstm$model_list),
      function(k) {
        mod <- mlstm$model_list[[k]]
        y_hat <- mod %>%
          stats::predict(X)
        y_hat <- invert_scaling(y_hat, var_data, k=k)
        var <- names(y_hat)
        y_hat[,variable:=var]
        setnames(y_hat, var, "value")
        return(y_hat)
      }
    )
  )
  return(predictions)
}

predict <- function(X, mlstm) {
  UseMethod("predict", mlstm)
}
