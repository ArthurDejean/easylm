#' This function checks the assumptions for a linear model: normality, homoscedasticity, and independence of the residuals. In addition, this function performs a comprehensive analysis of outliers.
#'
#' @return In the console , the first table displays a summary of common tests for normality of residuals distribution (Jarque-Bera test), for homoscedasticity (Breusch-Pagan test) and for residuals independency (Durbin-Watson test). The second table displays the 10 greatest leverages, studentized residuals and Cook's distances of residuals for outliers searching. The Bonferroni test for outliers based on studentized residuals is provided for additional insight. Besides these console outputs, four plots are simultaneously displayed in the plot viewer pane : a QQ plot for complementary normality assumption check, a Residuals vs Fitted plot and Scale-location plot for complementary homoscedasticity assumption check, and a Residuals vs Leverage plot for highlighting outliers.
#'
#' @param model Linear model. type "lm" only.
#'
#' @export
lm_check = function(model) {
  require(knitr, include.only = "kable")
  require(tseries, include.only = "jarque.bera.test")
  require(lmtest, include.only = "bptest")
  require(car, include.only = c("durbinWatsonTest", "outlierTest"))
  require(stats, include.only = c("hatvalues", "rstudent", "cooks.distance"))
  checks = data.frame(matrix(nrow=3, ncol=1))
  checks$matrix.nrow...3..ncol...1. = c("Jarque-Bera", "Breusch-Pagan", "Durbin-Watson")
  checks$statistic = c(jarque.bera.test(model$res)[1], bptest(model)[1], durbinWatsonTest(model)[2])
  checks$pvalue = c(jarque.bera.test(model$res)[3], bptest(model)[4], durbinWatsonTest(model)[3])
  rownames(checks) = c("Normality","Homoscedasticity","Independency")
  colnames(checks) = c("test","statistic","p-value")
  checks = within(checks, {
    sign = ifelse(
      `p-value`>=0.05,"NS",ifelse(
        `p-value`<0.05 & `p-value`>=0.01,"*", ifelse(
          `p-value`<0.01 & `p-value`>=0.001, "**", "***"
        )
      )
    )
  })
  print(model$call)
  checks |> kable(align="l", caption="TESTS FOR ASSUMPTIONS FOR LINEAR MODELS") |> print()
  par(mfrow=c(2,2))
  plot(model)
  par(mfrow=c(1,1))
  cat("\n------------------------------------\nSEARCH FOR OUTLIERS\n\nBonferroni test for outliers\n")
  print(outlierTest(model))
  cat("\n")
  outliers = cbind(hatvalues(model),rstudent(model),cooks.distance(model)) |> as.data.frame()
  outliers$ID = model |> hatvalues() |> names()
  colnames(outliers) = c("levier","RSS","cooksD","ID")
  tmp1 = outliers[order(-outliers$levier),] |> subset(select=c(ID,levier))
  tmp2 = outliers[order(-outliers$RSS),] |> subset(select=c(ID,RSS))
  tmp3 = outliers[order(outliers$RSS),] |> subset(select=c(ID,RSS))
  tmp4 = outliers[order(-outliers$cooksD),] |> subset(select=c(ID,cooksD))
  outliers = cbind(tmp1,tmp2,tmp3,tmp4) ; rm(tmp1,tmp2,tmp3,tmp4)
  outliers[1:10,] |> kable(align="rlrlrlrl", caption="HIGHEST LEVERAGES, STUDENTIZED RESIDUALS & COOK'S DISTANCES") |> print()
  cat("Mean leverage =",mean(hatvalues(model)),"\n")
  cat("Leverage criterion : If a leverage is more than twice the average leverage ratio, then the associated observation is an outlier.\n")
  cat("Studentized residuals : If the absolute value of a tudentized residual is more than three, then the associated observation is an outlier.\n")
  cat("Cook's distance criterion : if it is more than one, then the associated observation is an outlier.\n")
  cat("\n------------------------------------\n\n")
}

