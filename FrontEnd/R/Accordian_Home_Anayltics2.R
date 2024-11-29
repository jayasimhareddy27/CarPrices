Accordian_Home_Anayltics2UI <-function(){
  fluidPage(
    card(
      selectInput("CarBrands_year_IN","",choices = Brands_years,selected = 1993 ) ,
      card(plotOutput(outputId = "CarBrands_year", brush = "plot_brush"))
    )
  )
} 


Accordian_Home_Anayltics2Server <- function(input,CarBrands_year){
  renderPlot({
    BrandYear_yr <- input$CarBrands_year_IN
    CarBrands_year <- CarBrands_year %>% filter(model_year==BrandYear_yr,Count>1)
    ggplot(data = CarBrands_year) + geom_bar(stat = "identity",aes(x = brand, y = Count)) +
      labs(x="Models",y="# Manufactured",title = paste(BrandYear_yr))+
      theme(axis.text.x= element_text(size=10,angle = 90),axis.text.y= element_text(size=10,angle = 90))
  }) 
}
