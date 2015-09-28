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
  
  phases<-function(x,y){
    yr <- x    #"year selected -- replace this with the form value"
    mth <-y 
    mth <- as.integer(format(Sys.Date(), "%m"))  # default is current month
    mindt <-as.Date(paste(yr,mth,'1', sep = "-")) # first day of selected month
    yrsel <-as.Date(paste(yr,'1-1', sep = "-"))  # first day of selected year
    
    #create variable for first day of following month
    #if month selected = 12, add one to year and use month 1
    if(mth == 12){
      yr = yr + 1
    }
    
    if(mth == 12){
      mth = 1
    } else {
      mth = mth + 1
    }
    
    #calculated next month from date selected
    maxdt <- as.Date(paste(yr,mth,'1', sep = "-"))
    
    # create a data frame of entire year
    dated<-seq(yrsel, by = "day", length.out = 366)  #max days in year
    
    # create a data frame of days for the month
    #dated<-seq(dtsel, by = "day", length.out = 31)  #max days in months
    c<- as.data.frame(dated)
    c<- subset(c,c$dated <= as.Date(paste(yr,'12-31', sep = "-")))  #remove any dates not in same month
    
    
    # add 2 columns calculated by the functions in the lunar package
    # Phase is the segment of the moon's cycle and illum is the proportion of the moon illuminated (for graph)
    c$Phase<-lunar.phase(c$dated,shift=0,name=8)
    c$illum<-lunar.illumination(c$dated, shift = 0)
    c$month<-month(c$dated)
    
    # two subsets required -- full moon phases for year and all dates for month
    allyr <-subset(c,c$Phase == 'Full')
    allmth <-subset(c,c$dated >= mindt & c$dated < maxdt)
    
    # get full moon min and max dates for each month
    yrFull<-aggregate(dated ~ month, data = allyr,min)
    yrFull<-cbind(yrFull,aggregate(dated ~ month, data = allyr,max))
    names(yrFull) <- c("month","Start","month2","End")
    
    #subset month dates into phases
    fullmoon <-subset(allmth,allmth$Phase == 'Full')
    newmoon <-subset(allmth,allmth$Phase == 'New' )
    q1halfmoon <- subset(allmth,allmth$Phase == 'First quarter' )
    q2halfmoon <- subset(allmth,allmth$Phase == 'Last quarter')
    
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
    x<-yrFull[,1:2]
    x$end<-yrFull[,4]
    x
    
  }
  
  
  output$yearentered <- renderText({
    input$yearentered})
  output$monthentered <- renderText({input$monthentered})
  output$view <- renderTable({phases(input$yearentered,input$monthentered)})
  output$moonPhased <- renderPlot({
    plot(phases().allmth$dated, allmth$illum, type='p', pch=20, xlab="Date", ylab="Proportion of Moon Illuminated")
    
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
  })

})
