mlstm <- function(var_data_lstm, n_units=50) {
  K <- dim(var_data_lstm$y)[3]
  dim_input <- dim(X_train)[2:3]
  model_list <- lapply(
    1:K, 
    function(k) {
      model <- keras_model_sequential() %>% 
        layer_lstm(units = n_units, input_shape = dim_input) %>% 
        layer_dense(units = 1)
      model %>% 
        compile(
          loss = "mae",
          optimizer = "adam"
        )
      return(model)
    }
  )
  
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
  mlstm_predictions <- list(
    predictions = predictions,
    X = X,
    mlstm = mlstm
  ) 
  class(mlstm_predictions) <- "mlstm_predictions"
  return(mlstm_predictions)
}

predict <- function(X, mlstm) {
  UseMethod("predict", mlstm)
}

plot.mlstm_predictions <- function(mlstm_predictions, y_true=NULL) {
  pred <- mlstm_predictions$predictions
  pred[,type:="Prediction"]
  var_data <- mlstm_predictions$mlstm$var_data_lstm$var_data
  if (!is.null(y_true)) {
    if (length(dim(y_true))==3) {
      y_true <- array_reshape(y_true, dim=c(dim(y_true)[1],dim(y_true)[3]))
    }
    y_true <- invert_scaling(y_true, var_data)
    y_true[,type:="Actual"]
    y_true <- melt(y_true, id.vars = "type")
  }
  dt_plot <- rbind(pred,y_true)
  dt_plot[,date:=1:(.N),by=.(variable, type)]
  p <- ggplot(data=dt_plot, aes(x=date, y=value, colour=type)) +
    geom_line() +
    scale_color_discrete(name="Type:") +
    facet_wrap(
      ~variable, 
      scales="free_y", 
      nrow = dt_l[,length(unique(variable))]
    )
  p
  return(p)
}
