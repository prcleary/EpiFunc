#' Set values to NA
#'
#' @import tidyverse
#' @author Daniel Gardiner (daniel.gardiner@phe.gov.uk)
#'
#' @param data a data.frame
#' @param values.to.set.to.na a character vector specifying values to set to NA
#'
#' @return a dataframe with specified values set to NA
#'
#' @export
#'
#' @description This function takes a data.frame and sets specified values to NA
#'
#' @examples
#' # set dummy data
#'
#' set.seed(4)
#'
#' data = data.frame(dates = sample(seq(as.Date('2014-01-01'), as.Date('2016-04-01'), by="day"), 20, replace = TRUE),
#'                   sex = factor(c("Male", "Female", "Female", NA)),
#'                   conf = factor(sample(c("Confirmed", "Probable", "Possible"), 20, replace = TRUE)),
#'                   status = sample(c("Student", "Staff", NA), 20, replace = TRUE),
#'                   age = sample(c(1:20, NA), 20, replace = TRUE),
#'                   stringsAsFactors = FALSE)
#'
#' # apply function
#'
#' set_to_na(data, c("Male", "Student"))
set_to_na = function(data, values.to.set.to.na){
  data %>%
    lapply(function(x)
      replace(x, tolower(x) %in% tolower(values.to.set.to.na), NA)) %>%
    as_tibble()
}




