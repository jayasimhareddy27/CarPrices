Accordian_Home_Anayltics1UI <- function(){
  fluidPage(
    card(
      sliderInput("CardDistribution_Yearly_IN","",min = 1974,max = 2024,value = c(1974, 2024)) ,
      card(plotOutput(outputId = "CardDistribution_Yearly", brush = "plot_brush"))
    )
  )
} 
  


Accordian_Home_Anayltics1Server <- function(input){
  DataDistribution_Dates <- reactive({
    cbind(input$CardDistribution_Yearly_IN[1],input$CardDistribution_Yearly_IN[2])
  })
  renderPlot({
    start_year <- DataDistribution_Dates()[1]
    end_year <- DataDistribution_Dates()[2]
    CarDistribution_BY_yearUser <- CarDistribution_BY_year %>% 
                                    mutate(model_year = as.numeric(as.character(model_year))) %>%
                                    filter(model_year>start_year,model_year<end_year)
    ggplot(data = CarDistribution_BY_yearUser) + geom_line(aes(x = model_year, y = Count)) +
      labs(x="Year",y="# Sold",title = paste("Cards sold in year: ",typeof(DataDistribution_Dates()[1]),"-",DataDistribution_Dates()[2]))
  }) 
}