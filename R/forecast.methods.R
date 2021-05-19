plot.forecast <- function(forecast, history=NULL) {
  
  K <- forecast$model_data$K
  sample <- forecast$model_data$data[,type:="Actual"]
  if (!"date" %in% names(sample)) {
    sample[,date:=1:.N]
  }
  fcst <- forecast$fcst[,type:="Forecast"]
  dt_plot <- rbind(sample,fcst)
  dt_plot <- melt(dt_plot, id.vars = c("date","type"))
  if (!is.null(history)) {
    dt_plot <- dt_plot[date >= sample[,max(date)]-history]
  }
  
  
  p <- ggplot2::ggplot(data=dt_plot) +
    ggplot2::geom_line(ggplot2::aes(x=date, y=value, linetype=type)) +
    facet_wrap(.~variable, nrow = K) +
    scale_linetype_discrete(name="Type:") +
    labs(
      x="Date",
      y="Value"
    )
  p
  
  return(p)
}
