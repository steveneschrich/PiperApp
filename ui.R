# Define the help text for panels here (eventually another file).
welcomeHelpPanel <- wellPanel(
  HTML(
    "<TITLE>PIPER</TITLE>
<p>Welcome to PIPER! This tool is envisioned to assist in translational
research studies involving targeted proteomics. A variety of visualizations
are available for interpreting proteomics measurements in the context of
a patient cohort. The tool can be used to better understand the distribution
of measurements and can assist in determining appropriate thresholds for
phenotype evaluation.
</p>
<p>
This tool is currently loaded with a cohort of 108 Lung Cancer Squamous Cell
Carcinoma patient tumors assayed with a proteomics panel measuring 92 different
peptides. These assays are grouped into meaningful panels, corresponding to
clinical and/or biological phenotypes.
</p>
"
  )
)

overviewTabsetPanel <- shiny::tabPanel(
  "Overview",
  # Two rows: text description and subway map.
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "The subway map is an overview of the assay panels available. Each tram line
is associated with a specific target audience. The circles represent different
panels with the interior of the circle colored according to the level of activity
of the panel (compared to the reference population). Blue is lower activity,
red is higher.
"
      )
    )
  )),
  fluidRow(shiny::plotOutput("subwayMap"))
)


panelDetailTabsetPanel <- shiny::tabPanel(
  "Panel Details",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
A protein panel consists of a series of assays that represent the specific biological or clinical phenotype in question.
Each panel is associated with a category. Throughout the application, a summary score can be derived from the panel. This is
detailed in the final column of the table.
"
      )
    )
  )),
  fluidRow(reactable::reactableOutput("panelTable"))
)


panelMeasurementTabsetPanel <-  shiny::tabPanel(
  "Assay Measurements",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
Each assay (peptide) is quantified in amol/ug, which is then log2 transformed for display purposes. This table includes these
measurements. Note that a peptide may belong to several panels (which are listed below). In addition to the expression of the
peptide within each sample, the percentile of the measurement (compared to the reference population) is included. Additional
columns provide the minimum/maximum/mean/median of the reference population for measurement context.
"
      )
    )
  )),
  fluidRow(reactable::reactableOutput("summaryTable"))
)

radarPlotTabsetPanel <- shiny::tabPanel(
  "Radar",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
A radar, or spider, plot visualizes the panel markers as points in a circular graph. This is most useful for identifying specific
markers that have high expression. Note that the levels visualized in this plot are percentages of the maximum expression of the
reference cohort (for the assay).
"
      )
    )
  )),
  fluidRow(plotly::plotlyOutput("radarPlot"))
)


donutPlotTabsetPanel <- shiny::tabPanel(
  "Donut",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
A donut plot shows the relative proportion of signal attributed to each marker within the panel. Markers may be missing within a
given sample and are not included in the proportions.
"
      )
    )
  )),
  fluidRow(shiny::plotOutput("donutPlot"))
)


lollipopPlotTabsetPanel <- shiny::tabPanel(
  "Lollipop",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
A lollipop plot provides a visualization of panel measurements within the context of the entire reference population. The
population is represented by a horizontal bar. The sample measurement is indicated by a small donut. The color of the
donut and the number in the donut indicates the percentile of the measurement in the reference population.
"
      )
    )
  )),
  fluidRow(shiny::plotOutput("lollipop"))
)

rugPlotTabsetPanel <- shiny::tabPanel(
  "Rug Plot",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
A rug plot provides visual gauges of the assay level compared to the reference population. Vertical black bars indicate reference
values and the red triangles indicate the position of the sample measurement compared to the reference measurements.
"
      )
    )
  )),
  fluidRow(shiny::plotOutput("rugplot", inline=FALSE))
)


heatmapTabsetPanel <- shiny::tabPanel(
  "Heatmap",
  fluidRow(column(
    width = 5,
    wellPanel(
      HTML(
        "
A heatmap is a common tool in translational research. Each measurement is indicated by a single box in the graph. A row represents all
sample measurements for a given assay. A column represents a single sample from the population. The target sample is indicated on the
right side of the heatmap for reference. In the Lung Squamous cohort, both the biological subtype and tumor laterality data are indicated.
"
      )
    )
  )),
  fluidRow(shiny::plotOutput("heatmap"))
)



# Define UI for application
ui <- fluidPage(
  #theme = bslib::bs_theme(version = 5, bootswatch = "minty"),

  # App title
  fluidRow(
    column(width = 1, titlePanel("PIPER")),
    column(width = 2, helpText("Physician-Interpretible Phenotypic Evaluation in R"))
  ),
  # Header (image, welcome text)
  fluidRow(
    column(width=1,shiny::imageOutput("hdr_image", width="1%", height="1px", inline=TRUE)),
    column(width = 8, welcomeHelpPanel)
  ),

  hr(),

  # Sidebar layout with input and output definitions ----
  fluidRow(
    column(width=2, shiny::tableOutput("overviewTable")),
    column(width=4,
           shiny::selectInput("patient", "Patient:",
                              colnames(clinical_panel())
           ),
           helpText("Select patient to view assay results.")
    ),

    column(width=4,
           shiny::selectInput(
             "panel", "Clinical Panel:",
             names(panels)
           ),
           helpText("Select assay panel to view.")
    )
  ),
  fluidRow(
    column(width=12,
           # Main panel for displaying outputs ----

           #theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
           # Output: Tabset w/ plot, summary, and table ----
           tabsetPanel(type = "tabs",
                       overviewTabsetPanel,
                       panelDetailTabsetPanel,
                       panelMeasurementTabsetPanel,
                       radarPlotTabsetPanel,
                       donutPlotTabsetPanel,
                       lollipopPlotTabsetPanel,
                       rugPlotTabsetPanel,
                       heatmapTabsetPanel
           )

    )
  )
)
