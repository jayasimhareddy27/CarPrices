HeatMapperUI <- function() {
  fluidPage(
    titlePanel("Heatmap for Correlations"),
    sidebarLayout(
      sidebarPanel(
        checkboxGroupInput(
          "selected_features",
          "Select Features to Include:",
          choices = colnames(numeric_data),  # Provide numeric columns directly
          selected = colnames(numeric_data)  # Select all numeric features by default
        )
      ),
      mainPanel(
        plotOutput("heatmap_plot")
      )
    )
  )
}

HeatMapperServer <-function(input, output) {
  output$heatmap_plot <- renderPlot({
    # Ensure there are selected features
    validate(
      need(length(input$selected_features) > 1, "Please select at least two numeric features")
    )
    
    # Subset the selected numeric features
    selected_data <- numeric_data[, input$selected_features, drop = FALSE]
    
    # Compute the correlation matrix
    correlation_matrix <- cor(selected_data, use = "complete.obs")
    
    # Convert correlation matrix to long format for ggplot
    heatmap_data <- as.data.frame(as.table(correlation_matrix))
    colnames(heatmap_data) <- c("Feature1", "Feature2", "Correlation")
    
    # Create the heatmap
    ggplot(heatmap_data, aes(x = Feature1, y = Feature2, fill = Correlation)) +
      geom_tile(color = "white") +
      scale_fill_gradient2(
        low = "blue",
        mid = "white",
        high = "red",
        midpoint = 0,
        name = "Correlation"
      ) +
      geom_text(aes(label = round(Correlation, 2)), color = "black", size = 4) +  # Add values inside cells
      labs(
        title = "Correlation Heatmap",
        x = "Features",
        y = "Features"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid = element_blank()
      )
  })
}