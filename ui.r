#install.packages("shiny")
# setwd("C:/Data/Coursera/9 DevelopingDataProducts/Week3/Looney/")
require(shiny)

shinyUI(
 
  fluidPage(
    # Application title
    titlePanel( img(src="Logo.png", height = 100, width = 500)),
    headerPanel(
      h3('An App for Predicting Moon Phases Throughout the Year(s)'),
      br()
    ),
  
    sidebarLayout(
      sidebarPanel(
        numericInput("yearentered", "Enter Year (1950-2099)", as.integer(as.integer(format(Sys.Date(), "%Y"))), min = 1950, max = 2099)
      ),
      #actionButton("goButton", "Execute"),
      
      #submitButton('ApplyChanges'),
      column(sliderInput("monthentered", 
                  "Select Month of Year (Jan = 1, Dec = 12):", 
                  min = 1,
                  max = 12, 
                  value = as.integer(as.integer(format(Sys.Date(), "%m")))),width=8)
    ),
      mainPanel(width = 12,
    h4('Calculated for year:'),
    verbatimTextOutput("yearentered"),
    column(8,h4('Full Moon at Brightest')),
    column(5, tableOutput("view")),
    column(7,plotOutput("moonPhased"))
  )
))



