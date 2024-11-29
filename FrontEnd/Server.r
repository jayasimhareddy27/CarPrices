

server <- function(input, output,session) {
  
  output$CardDistribution_Yearly <- Accordian_Home_Anayltics1Server(input) 
  output$CarBrands_year <- Accordian_Home_Anayltics2Server(input,CarBrands_year)
  output$Allploter <- Accordian_Home_Anayltics3Server(input)
  Simple_LMServer(input,output,session)
  EDAServer(input, output)
  HeatMapperServer(input, output)
}
 