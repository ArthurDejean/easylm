#' Cette fonction affiche toutes les statistiques essentielles d'un modèle linéaire classique ou robuste dans un dataframe concis et ordonné
#'
#' @param model modèle "lm" ou "lm_robust"
#'
#' @param plot Par défaut F. F : La sortie est un objet R de type dataframe ; T = la sortie est un plot.
#'
#' @param type Par défaut "full". "full" : affiche en sortie les staistiques pour chacun des prédicteurs du modèle et celles du modèle entier ; "pred" : n'affiche que les statistiques des prédicteurs ; "mod" : n'affiche que les statistiques du modèle entier.
#'
#' @export
lm_sum = function(model, plot = F, type = "full") {
  require(rsq, include.only="rsq.partial")
  require(broom, include.only="tidy")
  require(knitr, include.only = c("kable", "kables"))
  require(gt, include.only = "gt")
  require(patchwork, include.only = c("wrap_table", "plot_layout"))
  if (class(model) == "lm") {
    sum = summary(model)
    rsq = rsq.partial(model)
    tmp1 = data.frame(sum$coefficients) |> round(digits = 3)
    tmp1$star = ifelse(
      tmp1$Pr...t.. >= .05, "NS", ifelse(
        tmp1$Pr...t.. < .05 & tmp1$Pr...t.. >= .01, "*", ifelse(
          tmp1$Pr...t.. < .01 & tmp1$Pr...t.. >= .001, "**", "***"
        )
      )
    )
    tmp1 = cbind(rownames(tmp1), tmp1, round(c(NA, rsq$partial.rsq), digits = 3), round(confint(model), digits = 3))
    colnames(tmp1) = c("predictors", "estimates", "std. error", "t-value", "p-value", "sign", "rsq", "2.5 %", "97.5 %")
    rownames(tmp1) = 1:length(tmp1$predictors)
    tmp2 = data.frame(
      names = c("F-statistic", "num df", "denom df", "multiple rsq", "adjusted rsq"),
      values = round(c(sum$fstatistic, sum$r.squared, sum$adj.r.squared), digits = 3)
    )
    if (plot == F) {
      if (type == "full") {
        print(kable(tmp1, digits = 3, caption = "Each predictor statistics"))
        print(kable(tmp2, digits = 3, caption = "Entire model statistics"))
      }
      if (type == "pred") {
        print(kable(tmp1, digits = 3, caption = "Each predictor statistics"))
      }
      if (type == "mod") {
        print(kable(tmp2, digits = 3, caption = "Entire model statistics"))
      }
    }
    if (plot == T) {
      tmp1 = tmp1 |> gt() |> wrap_table()
      tmp2 = tmp2 |> gt() |> wrap_table()
      if (type == "full") {
        return(tmp1 + tmp2 + plot_layout(nrow = 2))
      }
      if (type == "pred") {
        return(tmp1)
      }
      if (type == "mod") {
        return(tmp2)
      }
    }
  }
  if (class(model) == "lm_robust") {
    tmp1 = broom::tidy(model)
    tmp1 = subset(tmp1, select = -c(df, outcome))
    tmp1$rsq = tmp1$statistic^2 / (tmp1$statistic^2 + model$df.residual)
    tmp1$star = ifelse(
      tmp1$p.value >= .05, "NS", ifelse(
        tmp1$p.value < .05 & tmp1$p.value >= .01, "*", ifelse(
          tmp1$p.value < .01 & tmp1$p.value >= .001, "**", "***"
        )
      )
    )
    colnames(tmp1) = c("predictors", "estimates", "std. error", "t-value", "p-value", "2.5 %", "97.5 %", "rsq", "sign")
    tmp1 = subset(tmp1, select = c("predictors", "estimates", "std. error", "t-value", "p-value", "sign", "rsq", "2.5 %", "97.5 %"))
    tmp2 = data.frame(
      names = c("F-statistic", "num df", "denom df", "multiple rsq", "adjusted rsq"),
      values = round(c(model$fstatistic, model$r.squared, model$adj.r.squared), digits = 3)
    )
    if (plot == F) {
      if (type == "full") {
        print(kable(tmp1, digits = 3, caption = "Each predictor statistics"))
        print(kable(tmp2, digits = 3, caption = "Entire model statistics"))
      }
      if (type == "pred") {
        print(kable(tmp1, digits = 3, caption = "Each predictor statistics"))
      }
      if (type == "mod") {
        print(kable(tmp2, digits = 3, caption = "Entire model statistics"))
      }
    }
    if (plot == T) {
      tmp1 = tmp1 |> gt() |> wrap_table()
      tmp2 = tmp2 |> gt() |> wrap_table()
      if (type == "full") {
        return(tmp1 + tmp2 + plot_layout(nrow = 2))
      }
      if (type == "pred") {
        return(tmp1)
      }
      if (type == "mod") {
        return(tmp2)
      }
    }
  }
}
