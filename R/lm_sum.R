#' This function displays all the essential statistics for a standard or robust linear model in a concise, well-organized dataframe
#'
#' @return Either a table in your console or a R plot object depending on parameters.
#'
#' @param model Linear model of type "lm" or "lm_robust"
#'
#' @param plot Default FALSE. FALSE : output is a dataframe displayed in console ; TRUE = output is a Rplot object.
#'
#' @param type Default "full. "full" : displays statistics for each of the model's predictors and for the full model ; "pred" : displays the predictors statistics only ; "mod" : displays the full model statistics only.
#'
#' @export
lm_sum = function(model, plot = F, type = "full") {
  require(rsq, include.only="rsq.partial")
  require(broom, include.only=c("tidy", "glance"))
  require(knitr, include.only = c("kable", "kables"))
  require(gt, include.only = c("gt", "fmt_number"))
  require(patchwork, include.only = c("wrap_table", "plot_layout"))
  if (class(model) == "lm") {
    sum = summary(model)
    rsq = rsq.partial(model)
    tmp1 = data.frame(sum$coefficients) |> round(digits = 3)
    tmp1$df = sum$fstatistic[3]
    tmp1$star = ifelse(
      tmp1$Pr...t.. >= .05, "NS", ifelse(
        tmp1$Pr...t.. < .05 & tmp1$Pr...t.. >= .01, "*", ifelse(
          tmp1$Pr...t.. < .01 & tmp1$Pr...t.. >= .001, "**", "***"
        )
      )
    )
    tmp1 = cbind(rownames(tmp1), tmp1, round(c(NA, rsq$partial.rsq), digits = 3), round(confint(model), digits = 3))
    colnames(tmp1) = c("predictors", "estimates", "std. error", "t-value", "p-value", "df", "sign", "rsq", "2.5 %", "97.5 %")
    tmp1 = subset(tmp1, select = c("predictors", "estimates", "std. error", "t-value", "df", "p-value", "sign", "rsq", "2.5 %", "97.5 %"))
    rownames(tmp1) = 1:length(tmp1$predictors)
    tmp2 = data.frame(`F-statistic` = sum$fstatistic[1], `num df` = sum$fstatistic[2], `denom df` = sum$fstatistic[3], `p-value` = glance(model)$p.value, `multiple rsq` = sum$r.squared, `adjusted rsq` = sum$adj.r.squared)
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
      tmp1 = tmp1 |> gt() |> fmt_number(decimals = 3) |> wrap_table(space = "free_x")
      tmp2 = tmp2 |> gt() |> fmt_number(decimals = 3) |> wrap_table(space = "free_x")
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
    tmp1 = subset(tmp1, select = -outcome)
    tmp1$rsq = tmp1$statistic^2 / (tmp1$statistic^2 + model$df.residual)
    tmp1$star = ifelse(
      tmp1$p.value >= .05, "NS", ifelse(
        tmp1$p.value < .05 & tmp1$p.value >= .01, "*", ifelse(
          tmp1$p.value < .01 & tmp1$p.value >= .001, "**", "***"
        )
      )
    )
    colnames(tmp1) = c("predictors", "estimates", "std. error", "t-value", "p-value", "2.5 %", "97.5 %", "df", "rsq", "sign")
    tmp1 = subset(tmp1, select = c("predictors", "estimates", "std. error", "t-value", "df", "p-value", "sign", "rsq", "2.5 %", "97.5 %"))
    tmp2 = data.frame(`F-statistic` = model$fstatistic[1], `num df` = model$fstatistic[2], `denom df` = model$fstatistic[3], `p-value` = glance(model)$p.value, `multiple rsq` = model$r.squared, `adjusted rsq` = model$adj.r.squared)
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
      tmp1 = tmp1 |> gt() |> fmt_number(decimals = 3) |> wrap_table(space = "free_x")
      tmp2 = tmp2 |> gt() |> fmt_number(decimals = 3) |> wrap_table(space = "free_x")
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
