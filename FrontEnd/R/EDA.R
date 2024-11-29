EDAUI <- function() {
  fluidPage(
    titlePanel("Interactive Plots"),
    sidebarLayout(
      sidebarPanel(
        selectInput("x_var", "X Variable:", choices = ModelPurposeDataColnames),
        uiOutput("filter_ui"),  # Dynamically generated UI for factor filtering
      ),
      mainPanel(
        plotOutput("plot")
      )
    )
  )
}

EDAServer <- function(input, output, session) {
  # Dynamically generate checkboxes if the x variable is a factor
  output$filter_ui <- renderUI({
    x_var <- input$x_var
    
    if (!is.null(x_var) && is.factor(ModelPurposeData[[x_var]])) {
      # Get all levels and select only the first two by default
      levels_x <- levels(ModelPurposeData[[x_var]])
      selected_levels <- head(levels_x, 2)  # Select first two levels by default
      checkboxGroupInput("factor_levels", 
                         "Select Levels to Display:", 
                         choices = levels_x, 
                         selected = selected_levels)
    }
  })

  output$plot <- renderPlot({
    x_var <- input$x_var
    
    # Validate if x_var is selected
    validate(
      need(x_var %in% colnames(ModelPurposeData), "Invalid X Variable selected")
    )
    
    x_is_factor <- is.factor(ModelPurposeData[[x_var]])
    x_is_numeric <- is.numeric(ModelPurposeData[[x_var]])
    
    if (x_is_factor) {
      # Filter the data based on selected factor levels
      selected_levels <- input$factor_levels
      validate(
        need(!is.null(selected_levels), "No levels selected. Please select at least one level.")
      )
      filtered_data <- ModelPurposeData %>%
        filter(!!sym(x_var) %in% selected_levels) %>%
        mutate(log_price = log(price + 1))  # Log-transform price to avoid log(0)
      
      # Create a boxplot with log-transformed prices
      plot <- filtered_data %>%
        ggplot(aes_string(x = x_var, y = "log_price")) +
        geom_boxplot(fill = "lightblue", alpha = 0.7, outlier.color = "red") +
        labs(title = paste("Boxplot of Log-Transformed Price by", x_var), 
             x = x_var, 
             y = "Log(Price)") +
        theme_minimal()
      
    } else if (x_is_numeric) {
      # x is numeric: Create a scatter plot
      filtered_data <- ModelPurposeData %>%
        mutate(log_price = log(price + 1))  # Log-transform price dynamically
      
      plot <- filtered_data %>%
        ggplot(aes_string(x = x_var, y = "log_price")) +
        geom_point(alpha = 0.6, color = "blue") +
        geom_smooth(method = "lm", se = FALSE, color = "red") +
        labs(title = paste("Scatter Plot of Log-Transformed Price vs", x_var), 
             x = x_var, 
             y = "Log(Price)") +
        theme_minimal()
      
    } else {
      # Default case: Empty plot with a warning
      plot <- ggplot() +
        labs(title = "Invalid X Variable Type", x = x_var, y = "Log(Price)") +
        theme_minimal()
    }
    
    # Return the dynamically created plot
    return(plot)
  })
}
