library(foreach)
library(data.table)
library(doParallel)
library(parallel)

rolling_window_fe <- function(dt, w_size=150, n_ahead=12, num_epochs=500, t="") {
  
  # Number of windows and window size
  n_windows = nrow(dt) - w_size - n_ahead
  var_cols <- colnames(dt)[2:ncol(dt)]
  
  # Cluster:
  no_cores <- detectCores() - 2
  cl <- makeCluster(round(no_cores), type="FORK")
  registerDoParallel(cl)
  
  # Rolling Window Loop:
  fcst <- foreach(i = 1:n_windows, .verbose=TRUE, .combine = rbind, .packages = c("torch", "deepvars"), .errorhandling = 'remove') %dopar% {
    
    message(sprintf("Window %i out of %i", i, n_windows))
    print(i)
    
    # SETUP
    dt_in <- dt[i:(w_size + i - 1)]
    train_val <- train_val_test_split(dt_in)
    train_ds_dvar <- train_val$train # training data for Deep VAR
    valid_ds_dvar <- train_val$val # validation data for Deep VAR
    train_ds <- rbind(train_ds_dvar, valid_ds_dvar) # training data for all other models
    test_ds <- train_val$test
    dt_out <- data.table(test_ds)[1:n_ahead][,id:=1:.N]
    dt_out_l <- melt(dt_out, id.vars = "id", value.name = "y")
    setkey(dt_out_l, id, variable)
    
    # RUNNING MODELS
    # Choosing lags:
    max_lags <- 12
    lags <- lag_order(train_ds, max_lag = max_lags)$p
    
    # VAR fitting:
    var_model <- vareg(train_ds, lags = lags)
    
    # Deep VAR fitting:
    n_ahead_train <- ifelse(t=="recursive",1,n_ahead)
    deepvar_model <- deepvareg(
      train_ds = train_ds_dvar, 
      valid_ds = valid_ds_dvar,
      lags = lags, 
      n_ahead = n_ahead_train,
      num_epochs = num_epochs
    )
    # Threshold VAR
    tv_model <- tsDyn::TVAR(train_ds, include = "const", lag=lags, nthresh=2, trim=0.1)
    
    # FORECASTS
    # VAR:
    fcst_var <- data.table(predict(var_model, n.ahead = n_ahead)$prediction)[,id:=1:.N]
    fcst_var <- melt(fcst_var, id.vars = "id", value.name = "y_hat")[,model:="var"]
    setkey(fcst_var, id, variable)
    # Deep VAR:
    fcst_dvar <- data.table(predict(deepvar_model, n.ahead = n_ahead)$prediction)[,id:=1:.N]
    fcst_dvar <- melt(fcst_dvar, id.vars = "id", value.name = "y_hat")[,model:="dvar"]
    setkey(fcst_dvar, id, variable)
    # Random Walk:
    fcst_rw <- rbind(tail(train_ds,1),dt_out[1:(nrow(dt_out))-1],fill=TRUE)[,id:=1:.N]
    fcst_rw <- melt(fcst_rw, id.vars="id", value.name = "y_hat")[,model:="rw"]
    setkey(fcst_rw, id, variable)
    # Threshold VAR
    fcst_tv <- data.table(predict(tv_model, n.ahead = n_ahead))[,id:=1:.N]
    fcst_tv <- melt(fcst_tv, id.vars="id", value.name = "y_hat")[,model:="tv"]
    setkey(fcst_tv, id, variable)
    
    fcst <- rbind(fcst_var, fcst_dvar, fcst_rw, fcst_tv)
    fcst <- dt_out_l[fcst]
    fcst[,sqerror:=(y-y_hat)^2]
    fcst[,window:=i]
    
    return(fcst)
    
  }
  
  return(fcst)
  
}
