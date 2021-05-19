# Methods: ----

## Fit the model: ----
fit.mlstm <- function(mlstm,X_train=NULL,y_train=NULL,X_test=NULL,y_test=NULL,...) {
  
  K <- mlstm$model_data$K
  train_test_data_supplied <- !is.null(X_train) & !is.null(y_train) & !is.null(X_test) & !is.null(y_test)
  
  # Fit:
  if (!train_test_data_supplied) {
    # If no training and test data supplied, run on whole data set:
    X_train <- mlstm$model_data$X
    y_train <- mlstm$model_data$y
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
  
  # Set up:
  model_data <- mlstm$model_data
  
  # Compute predictions:
  predictions <- rbindlist(
    lapply(
      1:length(mlstm$model_list),
      function(k) {
        mod <- mlstm$model_list[[k]]
        y_hat <- mod %>%
          stats::predict(X)
        y_hat <- invert_scaling(y_hat, model_data, k=k)
        var <- names(y_hat)
        y_hat[,variable:=var]
        setnames(y_hat, var, "value")
        return(y_hat)
      }
    )
  )
  
  # Return predictions:
  predictions <- list(
    predictions = predictions,
    X = X,
    model = mlstm
  ) 
  class(predictions) <- "predictions"
  return(predictions)
}

predict <- function(mlstm, X=NULL) {
  UseMethod("predict", mlstm)
}

## Mean squared error (MSE): ----
mse.mlstm <- function(mlstm,X=NULL,y=NULL) {
  
  # Check if model has been fitted:
  if (is.null(mlstm$model_histories)) {
    stop("Model has not been fitted yet.")
  }
  
  # Has X, y been supplied?
  if (is.null(X) & is.null(y)) {
    X <- mlstm$X_train
    y <- mlstm$y_train
  } 
  
  # Set up:
  model_data <- mlstm$model_data
  
  # Predictions:
  pred <- predict(mlstm, X=X)
  y_hat <- pred$predictions
  y_hat[,type:="y_hat"]
  
  # Observed values:
  if (length(dim(y))==3) {
    y <- array_reshape(y, dim=c(dim(y)[1],dim(y)[3]))
  }
  y_true <- invert_scaling(y, model_data)
  y_true[,type:="y_true"]
  y_true <- melt(y_true, id.vars = "type")
  
  # Compute MSE:
  mse <- rbind(y_hat, y_true)
  mse[,id:=1:(.N),by=.(variable, type)]
  mse <- dcast(mse, variable + id ~ type, value.var="value")
  mse <- mse[,.(mse=mean((y_hat-y_true)^2)),by=variable]
  
  return(mse)
}

mse <- function(mlstm,X=NULL,y=NULL) {
  UseMethod("mse", mlstm)
}

## Root mean squared error (RMSE): ----
rmse.mlstm <- function(mlstm,X=NULL,y=NULL) {
  
  # Check if model has been fitted:
  if (is.null(mlstm$model_histories)) {
    stop("Model has not been fitted yet.")
  }
  
  # Has X, y been supplied?
  if (is.null(X) & is.null(y)) {
    X <- mlstm$X_train
    y <- mlstm$y_train
  } 
  
  # RMSE:
  mse <- mse(X, y, mlstm)
  rmse <- mse[,.(rmse=sqrt(mse)),by=variable]
  
  return(rmse)
}

rmse <- function(mlstm,X=NULL,y=NULL) {
  UseMethod("rmse", mlstm)
}

## Forecasting: ----
forecast.mlstm <- function(mlstm, n.ahead=1) {
  
  # Set up:
  var_names <- mlstm$model_data$var_names
  lags <- mlstm$model_data$lags
  sample <- copy(mlstm$model_data$data)
  if (!"date" %in% names(sample)) {
    sample[,date:=1:.N]
  }
  fcst <- data.table()
  data <- rbind(sample, fcst)
  counter <- 1
  increment_date <- ifelse(sample[,class(date)=="Date"], round(sample[,mean(diff(date))]), 1)
  
  # Forecast recursively:
  while(counter <= n.ahead) {
    X <- prepare_predictors(data[,.SD,.SDcols=var_names],lags)
    X <- array_reshape(X, dim = c(1,1,ncol(X)))
    y_hat <- predict(mlstm, X)
    
    # Update
    fcst_t <- dcast(y_hat$predictions, .~variable)[,-1]
    fcst_t[,date:=data[.N,date+increment_date]]
    fcst <- rbind(fcst, fcst_t)
    data <- rbind(data, fcst_t)
    counter <- counter + 1
  }
  setcolorder(fcst, "date")
  
  # Return:
  fcst <- list(
    fcst = fcst,
    model_data = mlstm$model_data
  )
  class(fcst) <- "forecast"
  
  return(fcst)
  
}

forecast <- function(mlstm, n.ahead=1) {
  UseMethod("forecast", mlstm)
}
