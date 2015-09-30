#
packages<-function(x){
  x<-as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

packages(lunar)
packages(lubridate)
packages(shiny)
require(lubridate)
require(lunar)
require(shiny)



# Define server logic required to summarize and view the selected
# dataset
shinyServer(function(input, output) {
 
  # this function uses the lunar package to calculate phases for the entire year selected 
  phases<-function(yr){
   
    # create a data frame of entire year
    yrsel <- as.Date(paste(yr,'01-01', sep = "-"))
    dated<-seq(yrsel, by = "day", length.out = 366)  #max days in year

    c<- as.data.frame(dated)
    c<- subset(c,c$dated <= as.Date(paste(yr,'12-31', sep = "-")))  #remove any dates not in same month
    
    # add 2 columns calculated by the functions in the lunar package
    # Phase is the segment of the moon's cycle and illum is the proportion of the moon illuminated (for graph)
    c$Phase<-lunar.phase(c$dated,shift=0,name=8)
    c$illum<-lunar.illumination(c$dated, shift = 0)
    c$month<-month(c$dated)

    return(c)
  }
 
  #this function creates data table for 1st full moon of all months in the year
  yearphases<-function(allyr){
    yrFull<-aggregate(dated ~ month + Phase, data = allyr,min)
    yrFull<-cbind(yrFull,aggregate(dated ~ month + Phase, data = allyr,max))
    yrFull<-subset(yrFull,yrFull$Phase == 'Full')
    yrFull[,1]<-as.integer(yrFull[,1])
    x<-yrFull[,1:2]
    x$Start<-as.character(yrFull[,3])
    x$end<-as.character(yrFull[,6])
    #names(yrFull) <- c("Month","Phase","Start","End")
    return(as.data.frame(x))
  }
  
  #this function sets up plot for input month
  monthphases<-function(allmth, mthentr){
    #subset month dates into phases
    fullmoon <-subset(allmth,allmth$Phase == 'Full' & allmth$month == as.integer(mthentr))
    newmoon <-subset(allmth,allmth$Phase == 'New' & allmth$month == as.integer(mthentr) )
    q1halfmoon <- subset(allmth,allmth$Phase == 'First quarter' & allmth$month == as.integer(mthentr))
    q2halfmoon <- subset(allmth,allmth$Phase == 'Last quarter' & allmth$month == as.integer(mthentr))
    
    fullstart <- as.Date(fullmoon$dated[1:1],'%y-%m-%d')
    
    #splits data frame for 2nd full moon
    if(NROW(fullmoon) >= 5) {
      bluemoon <-subset(fullmoon,fullmoon$dated >= fullstart + 5)
      fullmoon <-subset(fullmoon,fullmoon$dated < fullstart + 5)
    } else {
      bluemoon <-data.frame(fullmoon[0,0])
    }
    
    if (NROW(bluemoon) > 0) {
      bluestart<- as.Date(bluemoon$dated[1:1],'%y-%m-%d')
      blueend <- as.Date(bluemoon$dated[NROW(bluemoon)],'%y-%m-%d')
    }
    fullend <- as.Date(fullmoon$dated[NROW(fullmoon)],'%y-%m-%d')
    
    newstart <- as.Date(newmoon$dated[1:1],'%y-%m-%d')
    newmoon <-subset(newmoon,newmoon$dated < newstart + 5)  #remove any 2nd new moon
    newend <- as.Date(newmoon$dated[NROW(newmoon)],'%y-%m-%d')
    
    q1start <- as.Date(q1halfmoon$dated[1:1],'%y-%m-%d')
    q1halfmoon <-subset(q1halfmoon,q1halfmoon$dated < q1start + 5)  #remove any 2nd Q1
    q1end <- as.Date(q1halfmoon$dated[NROW(q1halfmoon)],'%y-%m-%d')
    
    q2start <- as.Date(q2halfmoon$dated[1:1],'%y-%m-%d')
    q2halfmoon <-subset(q2halfmoon,q2halfmoon$dated < q2start + 5)  #remove any 2nd Q2
    q2end <- as.Date(q2halfmoon$dated[NROW(q2halfmoon)],'%y-%m-%d')

    lunarplot<-plot(allmth$dated, allmth$illum, type='p', pch=20, xlab="Date", ylab="Proportion of Moon Illuminated")
    
    abline(v=fullstart,col = "red")
    mtext("Full", at=fullstart, side=3)
    abline(v=fullend,col = "red")
    
    abline(v=newstart,col = "green")
    mtext("New", at=newstart, side=3)
    abline(v=newend,col = "green")
    
    abline(v=q1start,col = "purple")
    mtext("Q1 Half", at=q1start, side=3)
    abline(v=q1end, col = "purple")
    
    abline(v=q2start, col = "purple")
    mtext("Q2 Half", at=q2start, side=3)
    abline(v=q2end, col = "purple")
    
    if (NROW(bluemoon) > 0) {
      abline(v=bluestart, col = "red")
      mtext("Full", at=bluestart, side=3)
      abline(v=blueend, col = "red")
    }    
    
    return(lunarplot)
  }

  
  # two subsets required -- full moon phases for year and all dates for month
  #yrentered<-reactive({as.integer(input$yearentered)})
  complyr<-reactive({phases(as.integer(input$yearentered))})
  

  output$yearentered <- renderText(input$yearentered)
  output$monthentered <- renderText(input$monthentered)
  output$view <- renderTable({yearphases(complyr())})
  output$moonPhased <- renderPlot({ monthphases(subset(complyr(),complyr()$month ==input$monthentered ), input$monthentered)})

})


