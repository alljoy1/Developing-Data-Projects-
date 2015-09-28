#install.packages("shiny")
# setwd("C:/Data/Coursera/9 DevelopingDataProducts/Week3/Looney/")
require(shiny)

shinyUI(
 
  fluidPage(
    # Application title
    titlePanel( img(src="logo.png", height = 150, width = 600)),
    headerPanel(
      h3('An App for Predicting Moon Phases Throughout the Year(s)'),
      br()
    ),
  
    sidebarLayout(
      sidebarPanel(
        numericInput("yearentered", "Enter Year (1950-2099)", as.integer(format(Sys.Date(), "%Y")), min = 1950, max = 2099)
      ),
      actionButton("goButton", "Execute"),
      
      #submitButton('Apply Changes'),
      mainPanel(
          sliderInput("monthentered", 
                      "Select Month of Year (Jan = 1, Dec = 12):", 
                      min = 1,
                      max = 12, 
                      value = as.integer(format(Sys.Date(), "%m")), width = 600)
          ),
      
      plotOutput("moonPhased")
      
      #tableOutput("view")
  )
))



