
# Run the application
#runApp(".")
#shinyApp(ui = ui, server = server)

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
    reactable::reactable(
      piper::summary_statistics_table(
        clinical_panel()[,input$patient],
        clinical_panel(),
        panels
      ),
      defaultColDef = reactable::colDef(format = reactable::colFormat(digits=3))
    )
  })

  output$panelTable <- reactable::renderReactable({
    reactable::reactable(panel_summary(panels))
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



