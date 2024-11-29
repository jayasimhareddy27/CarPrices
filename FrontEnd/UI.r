HomeAccordian<- fluidPage(
  accordion(  
    accordion_panel( 
      title ="Set Year range to observer Cars production across year", 
      icon = bsicons::bs_icon("menu-app"),
      Accordian_Home_Anayltics1UI()
    ),
    accordion_panel( 
      title = "Select a year to observer how many Cars are manufacture in a year by each brand", 
      icon = bsicons::bs_icon("menu-app"),
      Accordian_Home_Anayltics2UI()
    ),
    accordion_panel( 
      title = "Group by brand", 
      icon = bsicons::bs_icon("menu-app"),
      Accordian_Home_Anayltics3UI()
    )
#    ,
#    accordion_panel( 
#      title = "Dynamic Graph", 
#      icon = bsicons::bs_icon("menu-app"),
#      Accordian_Home_Anayltics4UI()
#    )
  ))
Predictor<- fluidPage(
  card(
    card_title(p("Select the car attributes(brand,model,milage...) to predict the car price")),
  ),
  Simple_LMUI()
)

EDA<- fluidPage(
  accordion(  
    accordion_panel( 
      title ="Understand how to reduce the car price by understand its feature relations to prices", 
      EDAUI()
    ),
    accordion_panel( 
      title ="Heatmap for correlations", 
      HeatMapperUI() 
    ),
    
  )
)

ui <-  fluidPage(
  page_navbar(
    id = "main_navbar",
    title = "Know Car Prices!",
    bg = "#841617",
    inverse = TRUE,
    nav_panel(title = "Anayltics",HomeAccordian),
    nav_panel(title = "Get the price",Predictor),
    nav_panel(title = "About Us", AboutusUI()),
    nav_panel(title = "How to decrease price!", EDA),
    
    nav_spacer()
  )
)
