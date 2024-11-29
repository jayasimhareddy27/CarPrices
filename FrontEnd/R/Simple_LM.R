
Simple_LMUI <- function(){
  fluidPage(
    card(
      fluidRow(
        column(4, selectInput("Car_brand", "Brand", choices = Unique_Brands$brand, selected = Unique_Brands[[1]])),
        column(4, selectInput("Car_model", "Model", choices = NULL)),  # Updated dynamically
        column(4, selectInput("Car_model_year", "Model Year", choices = NULL))
      ),
      fluidRow(
        column(4, selectInput("Car_fuel_type", "Fuel Type", choices = NULL)),
        column(4, selectInput("Car_transmission", "Transmission", choices = Unique_transmission, selected = Unique_transmission[[1]])),
        column(4, selectInput("Car_accident", "Accident History", choices = Unique_accident, selected = Unique_accident[[1]])),
      ),
      fluidRow(
        column(4, selectInput("Car_engine_configuration", "Engine Configuration", choices = Unique_engine_configuration,selected = Unique_engine_configuration[[1]])),
        column(4, selectInput("Car_engine_technology", "Engine Technology", choices = Unique_engine_technology,selected = Unique_engine_technology[[1]])),
        column(4, selectInput("Car_engine_special", "Engine Special Features", choices = Unique_engine_special,selected = Unique_engine_special[[1]]))
      ),
      fluidRow(
        column(4, textInput("Car_milage", "Milage", value = "1000", width = NULL, placeholder = NULL)),
        column(4, textInput("Car_engine_horsepower", "Engine Horsepower", value = "330", width = NULL, placeholder = NULL)),
        column(4, actionButton("Simple_LM_eval", "Get The price")),
      )
    ),
    card(
      fluidRow(
        column(12, tableOutput("ResultsTable")) 
      )
    )
  )
}


Simple_LMServer <- function(input, output, session) {
  user_data <- reactiveValues(predictions = data.frame())
  
  # Update car model based on selected brand
  observeEvent(input$Car_brand, {
    selected_brand <- input$Car_brand
    filtered_models <- ProcessedData %>%
      filter(brand == selected_brand) %>%
      select(model) %>%
      unique() %>%
      pull(model)
    
    updateSelectInput(session, "Car_model", choices = filtered_models, selected = filtered_models[1])
  })
  
  # Update other inputs (year, fuel type, etc.) based on selected model
  observeEvent(input$Car_model, {
    selected_model <- input$Car_model
    
    # Update model year
    filtered_years <- ProcessedData %>%
      filter(model == selected_model, brand == input$Car_brand) %>%
      select(model_year) %>%
      unique() %>%
      pull(model_year)
    
    updateSelectInput(session, "Car_model_year", choices = filtered_years, selected = filtered_years[1])
  })

  # Update engine and other details based on selected model year, brand, and model
  observeEvent(input$Car_model_year, {
    selected_model <- input$Car_model
    selected_year <- input$Car_model_year
    selected_brand <- input$Car_brand
    
    # Update engine fuel type
    filtered_engine_fuel_type <- ProcessedData %>%
      filter(model == selected_model, model_year == selected_year, brand == selected_brand) %>%
      select(fuel_type) %>%
      unique() %>%
      pull(fuel_type)
    
    updateSelectInput(session, "Car_fuel_type", choices = filtered_engine_fuel_type, selected = filtered_engine_fuel_type[1])

  })
  
  
  
  observeEvent(input$Simple_LM_eval, {
    shinyjs::show("loading")
    Sys.sleep(2)  # Simulate delay for processing
    
    # Create a new data frame with the selected inputs
    brand <- factor(input$Car_brand, levels = levels(ModelPurposeData$brand))
    
    ModelYear <- as.numeric(input$Car_model_year)
    Milage <-  as.numeric(input$Car_milage)
    EngineHorsepower  <-  as.numeric(input$Car_engine_horsepower)
    
    FuelType  <-  factor(input$Car_fuel_type, levels = levels(ModelPurposeData$FuelType))
    Transmission  <-  factor(input$Car_transmission, levels = levels(ModelPurposeData$Transmission))
    Accident  <-  factor(input$Car_accident, levels = levels(ModelPurposeData$Accident))

    EngineTechnology  <-  factor(input$Car_engine_technology, levels = levels(ModelPurposeData$EngineTechnology))
    EngineSpecial <-  factor(input$Car_engine_special, levels = levels(ModelPurposeData$EngineSpecial))
    EngineConfiguration <-  factor(input$Car_engine_configuration, levels = levels(ModelPurposeData$EngineConfiguration))
    
    newdata <- data.frame(
      brand,
      ModelYear,Milage,EngineHorsepower,
      FuelType,Transmission,Accident,
      EngineConfiguration,EngineSpecial,EngineTechnology
    )
    
    source_python("Models/XGB/loadXGBoost_predict.py")
    source_python("Models/LM/loadlmpredict.py")

    newdata$'Precise price' <- predict_car_prices_XGB(newdata)
    newdata$'General price' <- predict_car_prices_LM(newdata)
    user_data$predictions <- rbind(user_data$predictions, newdata)


    output$ResultsTable <- renderUI({
      tableOutput("predictions_table")  
    })
    output$predictions_table <- renderTable({
      user_data$predictions
    })
    
  })
  
  
  

}
