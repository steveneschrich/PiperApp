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
panels <- readRDS(here::here("data/panels.rds"))

clinical_panel <- function(file = "lscc.rds") {
  lscc
}


library(shiny)
library(magrittr)

# Define UI for application that draws a histogram
ui <- fluidPage(
  #theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
  # App title ----
  fluidRow(

    # Sidebar panel for inputs ----
    column(width=1,
           shiny::imageOutput("hdr_image", width="1%", height="1px", inline=TRUE),

    ),
    column(width=2,titlePanel("PIPER" ))
  ),

  # Sidebar layout with input and output definitions ----
  fluidRow(

    column(width=6,
           shiny::selectInput("patient", "Patient:",
                              colnames(clinical_panel())
           )
    ),
    column(width=6,
      shiny::selectInput(
        "panel", "Clinical Panel:",
        names(panels)
      )
    )
  ),
  fluidRow(
    column(width=12,
      # Main panel for displaying outputs ----

      #theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  shiny::tabPanel("Overview",
                                  shiny::verticalLayout(
                                    shiny::tableOutput("overviewTable"), shiny::plotOutput("subwayMap"))
                  ),
                  shiny::tabPanel("Panel Measurements",reactable::reactableOutput("summaryTable")),
                  shiny::tabPanel("Radar", plotly::plotlyOutput("radarPlot")),
                  shiny::tabPanel("Donut", shiny::plotOutput("donutPlot")),
                  shiny::tabPanel("Lollipop", shiny::plotOutput("lollipop")),
                  shiny::tabPanel("Rug Plot", shiny::plotOutput("rugplot", inline=FALSE)),
                  shiny::tabPanel(
                    "Heatmap",
                    shiny::plotOutput("heatmap")
                  )
      )

    )
  )
)


# Define server logic required to draw a histogram
server <- function(input, output,session) {

  output$radarPlot <- plotly::renderPlotly({
    piper::plot_radar(
      clinical_panel()[,input$patient],
      clinical_panel(),
      panel=panels[[input$panel]]
    )
  })
  output$donutPlot <- shiny::renderPlot({
    piper::plot_donut(
      clinical_panel()[,input$patient],
      clinical_panel(),
      panel=panels[[input$panel]]
    )
  })
  output$hdr_image <- shiny::renderImage({
    list(src=here::here("img/PIPER_IMG.png"),width="50px",height="50px",alt="PIPER logo")
  },
  deleteFile=FALSE
  )

  output$summaryTable <- reactable::renderReactable({
    reactable::reactable(table_panel_statistics(clinical_panel(), pnum=input$patient))
  })
  output$summary<-shiny::renderText("Summary here")
  output$overviewTable <- shiny::renderTable({
    overview_stats(clinical_panel())
  })
  output$heatmap <- shiny::renderPlot({

    ht1 <- piper::plot_heatmap(
      sample = clinical_panel()[,input$patient],
      reference = clinical_panel(),
      panel = panels[[input$panel]]
    )
   ht1

  })
  output$lollipop <- shiny::renderPlot({
    piper::plot_lollipop(
      sample = clinical_panel()[,input$patient],
      reference=clinical_panel(),
      panel=panels[[input$panel]])
  })
  output$rugplot <- shiny::renderPlot({
    piper::plot_rug(
      sample = clinical_panel()[,input$patient],
      reference = clinical_panel(),
      panel=panels[[input$panel]]
    )
  })
  output$subwayMap <- shiny::renderPlot({
    piper::plot_subway(clinical_panel()[,input$patient],
                       clinical_panel(),
                       panels)
  })
}

#' Title
#'
#' @param .x
#' @param pnum
#'
#' @return
#' @export
#'
#' @examples
table_panel_statistics <- function(.x, pnum=1) {


  if ( is.character(pnum))
    pnum <- which(colnames(.x) %in% pnum)

  piper::summary_statistics_table(.x[,pnum], .x, panels)
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


# Run the application
shinyApp(ui = ui, server = server)
