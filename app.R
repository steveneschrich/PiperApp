#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load the data we will be working from in the application.
lscc <- readRDS(here::here("data/lscc.rds"))

clinical_panel <- function(file = "lscc.rds") {
  lscc
}


library(shiny)
library(magrittr)

# Define UI for application that draws a histogram
ui <- fluidPage(
  #theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
  # App title ----
  titlePanel("PIPER" ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(
      shiny::imageOutput("hdr_image", width="1%", height="1px", inline=TRUE),
      shiny::selectInput("patient", "Patient:",
                         Biobase::sampleNames(clinical_panel())
      ),

      shiny::selectInput(
        "panel", "Clinical Panel:",
        unique(Biobase::fData(clinical_panel())$Subcategory)
      )
    ),
    # Input: Select the random distribution type ----
    #   radioButtons("dist", "Distribution type:",
    #                c("Normal" = "norm",
    #                  "Uniform" = "unif",
    #                  "Log-normal" = "lnorm",
    #                  "Exponential" = "exp")),
    #
    #   # br() element to introduce extra vertical spacing ----
    #   br(),
    #
    #   # Input: Slider for the number of observations to generate ----
    #   sliderInput("n",
    #               "Number of observations:",
    #               value = 500,
    #               min = 1,
    #               max = 1000)
    #
    # ),

    # Main panel for displaying outputs ----
    mainPanel(
      #theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  shiny::tabPanel("Overview",
                                  shiny::verticalLayout(
                                    shiny::tableOutput("overviewTable"), shiny::plotOutput("subwayMap"))
                  ),
                  shiny::tabPanel("Panel Measurements",reactable::reactableOutput("summaryTable")),
                  shiny::tabPanel("Spider", shiny::plotOutput("spiderPlot")),
                  shiny::tabPanel("Donut", shiny::plotOutput("donutPlot")),
                  shiny::tabPanel("Lollipop", shiny::plotOutput("lollipop")),
                  shiny::tabPanel("Rug Plot", shiny::plotOutput("rugplot", inline=FALSE)),
                  shiny::tabPanel("Heatmap", shiny::plotOutput("heatmap"))
      )

    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$spiderPlot <- shiny::renderPlot({
    piper::plot_spider(clinical_panel(), pnum=input$patient, panel=input$panel)
  })
  output$donutPlot <- shiny::renderPlot({
    piper::plot_donut(clinical_panel(), pnum=input$patient, panel=input$panel)

  })
  output$hdr_image <- shiny::renderImage({
    list(src=here::here("img/PIPER_IMG.png"),width="50px",height="50px",alt="PIPER logo")
  },
  deleteFile=FALSE
  )

  output$summaryTable <- reactable::renderReactable({
    reactable::reactable(table_panel_statistics(clinical_panel(), pnum=input$patient, panel=input$panel))
  })
  output$summary<-shiny::renderText("Summary here")
  output$overviewTable <- shiny::renderTable({
    overview_stats(clinical_panel())
  })
  output$heatmap <- shiny::renderPlot({
    piper::plot_heatmap(clinical_panel(), pnum=input$patient, panel=input$panel)
  })
  output$lollipop <- shiny::renderPlot({
    piper::plot_lollipop(clinical_panel(), pnum=input$patient, panel=input$panel)
  })
  output$rugplot <- shiny::renderPlot({
    piper::plot_rug(clinical_panel(), pnum=input$patient, panel=input$panel)
  })
  output$subwayMap <- shiny::renderPlot({
    piper::plot_subway(clinical_panel(), pnum=input$patient)
  })
}

#' Title
#'
#' @param .x
#' @param pnum
#' @param panel
#'
#' @return
#' @export
#'
#' @examples
table_panel_statistics <- function(.x, pnum=1, panel="Tissue QC") {


  if ( is.character(pnum))
    pnum <- which(Biobase::sampleNames(.x) %in% pnum)

  piper::get_sample(.x, pnum) %>%
    dplyr::left_join(piper::calculate_panel_statistics(.x), by="Protein_Peptide") %>%
    dplyr::mutate(Quantile = purrr::map2_dbl(.data$ECDF, .data$Patient, ~100 * .x(.y))) %>%
    dplyr::arrange(.data$Subcategory, .data$Protein_Peptide) %>%
    dplyr::select(.data$Protein_Peptide, .data$Patient,
                  .data$Subcategory, .data$Quantile,
                  .data$MinExpression, .data$MeanExpression,
                  .data$MaxExpression)

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
    "Samples", unname(ncol(.x)),
    "Assays", unname(nrow(.x)),
    "Assay Categories", length(unique(Biobase::fData(.x)$Category))
  )
}


# Run the application
shinyApp(ui = ui, server = server)
