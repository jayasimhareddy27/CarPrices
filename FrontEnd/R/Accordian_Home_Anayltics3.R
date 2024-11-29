

Accordian_Home_Anayltics3UI <- function(){
  fluidPage(
      checkboxGroupInput(
        "Group_Brand", "Brand",choiceNames =Unique_Brands[[1]],choiceValues =Unique_Brands[[1]], inline = T
      ),
      card(plotOutput(outputId = "Allploter", brush = "plot_brush"))
  )
}
Accordian_Home_Anayltics3Server <- function(input){
  renderPlot({
    DataSet<- ProcessedData %>% filter(brand %in%  input$Group_Brand) %>%  group_by(brand,model_year) %>% summarise(AVG_Price=mean(price)) %>% ungroup()
    DataSet %>% ggplot(aes(x = model_year, y = AVG_Price, color = brand)) + geom_line(aes(group = brand) )
  })
}