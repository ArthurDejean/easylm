#' This function checks the assumptions for a linear model: normality, homoscedasticity, and independence of the residuals. In addition, this function performs a comprehensive analysis of outliers.
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
  rownames(checks) = c("Normalité de distribution","Homogénéité des variances","Indépendance")
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
  checks |> kable(align="l", caption="VÉRIFICATION DES CONDITIONS D'APPLICATION POUR LE MODÈLE LINÉAIRE") |> print()
  par(mfrow=c(2,2))
  plot(model)
  par(mfrow=c(1,1))
  cat("\n------------------------------------\nRECHERCHE D'OUTLIERS\n\nTest de Bonferroni pour les outliers\n")
  print(outlierTest(model))
  cat("\n")
  outliers = cbind(hatvalues(model),rstudent(model),cooks.distance(model)) |> as.data.frame()
  outliers$ID = model |> hatvalues() |> names() |> as.numeric()
  colnames(outliers) = c("levier","RSS","cooksD","ID")
  tmp1 = outliers[order(-outliers$levier),] |> subset(select=c(ID,levier))
  tmp2 = outliers[order(-outliers$RSS),] |> subset(select=c(ID,RSS))
  tmp3 = outliers[order(outliers$RSS),] |> subset(select=c(ID,RSS))
  tmp4 = outliers[order(-outliers$cooksD),] |> subset(select=c(ID,cooksD))
  outliers = cbind(tmp1,tmp2,tmp3,tmp4) ; rm(tmp1,tmp2,tmp3,tmp4)
  outliers[1:10,] |> kable(align="rlrlrlrl", caption="LEVIERS, RSS & D DE COOKS LES PLUS ELEVES") |> print()
  cat("Levier moyen =",mean(hatvalues(model)),"\n")
  cat("critère sur le levier : si un levier est plus élevé que 2 fois le levier moyen, alors c'est outlier.\n")
  cat("Critère sur le RSS : si un |RSS| est supérieur à 3, alors c'est un outlier.\n")
  cat("critère sur le D de Cook : si un D est supérieur à 1 et/ou se distingue des autres, alors c'est un outlier.\n")
  cat("\n------------------------------------\n\n")
}
