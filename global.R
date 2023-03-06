#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load the data we will be working from in the application.
suppressPackageStartupMessages({
  lscc <- readRDS(here::here("data/lscc.rds"))
  panels <- readRDS(here::here("data/panels.rds"))

  library(shiny)
  library(magrittr)

})

clinical_panel <- function(file = "lscc.rds") {
  lscc
}

panel_summary <- function(panels) {
  purrr::map(panels, \(x){
    tibble::tibble(
      "Name"=x$name,
      "Category"=x$category,
      "Markers"= stringi::stri_flatten(x$markers, collapse=", "),
      "Score" = x$scorefn
    )
  }) |>
    purrr::list_rbind()
}

#' Title
#'
#' @param .x
#'
#' @return
#' @export
#'
#' @examples
overview_stats <- function(.x) {
  tibble::tribble(
    ~Description, ~Value,
    "Samples", ncol(.x),
    "Assays", nrow(.x),
    "Panels", length(panels)
  )
}
