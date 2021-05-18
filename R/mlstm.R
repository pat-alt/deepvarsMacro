# Main class: ----

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

# Methods: ----

## Fit the model: ----
fit.mlstm <- function(mlstm,X_train=NULL,y_train=NULL,X_test=NULL,y_test=NULL,...) {
  
  K <- dim(mlstm$var_data_lstm$y)[3]
  train_test_data_supplied <- !is.null(X_train) & !is.null(y_train) & !is.null(X_test) & !is.null(y_test)
  
  # Fit:
  if (!train_test_data_supplied) {
    # If no training and test data supplied, run on whole data set:
    X_train <- mlstm$var_data_lstm$X
    y_train <- mlstm$var_data_lstm$y
    fitted_models <- lapply(
      1:K,
      function(k) {
        history <- mlstm$model_list[[k]] %>% 
          keras::fit(
            x = X_train, y = y_train[,,k],
            ...
          )
        list(
          model = mlstm$model_list[[k]],
          history = history
        )
      }
    )
  } else {
    # Else fit with supplied train and test data:
    fitted_models <- lapply(
      1:K,
      function(k) {
        history <- mlstm$model_list[[k]] %>% 
          keras::fit(
            x = X_train, y = y_train[,,k],
            validation_data = list(X_test, y_test[,,k]),
            ...
          )
        list(
          model = mlstm$model_list[[k]],
          history = history
        )
      }
    )
  }
  
  # Output:
  mlstm$model_list <- lapply(fitted_models, function(fitted_model) fitted_model[["model"]]) # update model list
  mlstm[["model_histories"]] <- lapply(fitted_models, function(fitted_model) fitted_model[["history"]]) # extract history
  mlstm$X_train <- X_train
  mlstm$y_train <- y_train
  mlstm$X_test <- X_test
  mlstm$y_test <- y_test
  
  return(mlstm)
}

fit <- function(mlstm,X_train=NULL,y_train=NULL,X_test=NULL,y_test=NULL,...) {
  UseMethod("fit", mlstm)
}

## Predictions: ----
predict.mlstm <- function(mlstm, X=NULL) {
  
  # Check if model has been fitted:
  if (is.null(mlstm$model_histories)) {
    stop("Model has not been fitted yet.")
  }
  
  # If no X supplied, run on training data:
  if (is.null(X)) {
    X <- mlstm$X_train
  }
  
  # Compute predictions:
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
  
  # Return predictions:
  mlstm_predictions <- list(
    predictions = predictions,
    X = X,
    mlstm = mlstm
  ) 
  class(mlstm_predictions) <- "mlstm_predictions"
  return(mlstm_predictions)
}

predict <- function(mlstm, X=NULL) {
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

## Mean squared error (MSE): ----
mse.mlstm <- function(X,y,mlstm) {
  
  # Check if model has been fitted:
  if (is.null(mlstm$model_histories)) {
    stop("Model has not been fitted yet.")
  }
  
  # Predictions:
  pred <- predict(X, mlstm)
  y_hat <- pred$predictions
  y_hat[,type:="y_hat"]
  
  # Observed values:
  if (length(dim(y))==3) {
    y <- array_reshape(y, dim=c(dim(y)[1],dim(y)[3]))
  }
  y_true <- invert_scaling(y, var_data)
  y_true[,type:="y_true"]
  y_true <- melt(y_true, id.vars = "type")
  
  # Compute MSE:
  mse <- rbind(y_hat, y_true)
  mse[,id:=1:(.N),by=.(variable, type)]
  mse <- dcast(mse, variable + id ~ type, value.var="value")
  mse <- mse[,.(mse=mean((y_hat-y_true)^2)),by=variable]
  
  return(mse)
}

mse <- function(X,y, mlstm) {
  UseMethod("mse", mlstm)
}

## Root mean squared error (RMSE): ----
rmse.mlstm <- function(X,y,mlstm) {
  
  # Check if model has been fitted:
  if (is.null(mlstm$model_histories)) {
    stop("Model has not been fitted yet.")
  }
  
  # RMSE:
  mse <- mse(X, y, mlstm)
  rmse <- mse[,.(rmse=sqrt(mse)),by=variable]
  
  return(rmse)
}

rmse <- function(X,y, mlstm) {
  UseMethod("rmse", mlstm)
}

## Forecasting: ----
forecast.mlstm <- function(mlstm_, n.ahead=1) {
  # dcast(pred$predictions, 0 ~ variable, value.var = "value")[,.SD,.SDcols=mlstm$var_data_lstm$var_data$var_names]
}