AboutusUI <- function() {
  fluidPage(
    h2("About Us", align = "center"),
    p("Driving into data made fun and insightful!", class = "text-center text-muted"),
    hr(),
    div(
      class = "container",
      h3("Welcome to the World of Data-Driven Cars!"),
      p("Ever wondered how many cars hit the roads each year? Or how your favorite car brand has evolved over time? 
         You're in the right place! Our platform is here to fuel your curiosity and put you in the driver's seat with advanced car pricing and sales analytics."),
      h3("What You Can Do Here", class = "mt-4"),
      tags$ul(
        tags$li("📈 Explore the rise and fall of car sales across decades. Spoiler alert: it’s like a blockbuster movie, full of twists!"),
        tags$li("🚗 Discover which brands ruled the roads each year and see how they stack up."),
        tags$li("💰 Dive into the average car prices by brand. Who’s the luxury king? Who’s the value champion?"),
        tags$li("🔮 Use our prediction tools to get a sneak peek into the possible price of your dream car.")
      ),
      h3("Here’s What the Graphs Tell You", class = "mt-4"),
      tags$ul(
        tags$li(strong("Yearly Car Sales:"), 
                " Think of this as the 'box office' of cars. Track how the industry performed over the years."),
        tags$li(strong("Cars Manufactured by Year:"), 
                " Curious about which brands worked overtime in a given year? This graph spills the beans."),
        tags$li(strong("Average Car Price by Brand:"), 
                " Wondering who’s giving you the most bang for your buck? Or who’s just, well, expensive? This graph has you covered!")
      ),
      h3("Meet the Pit Crew", class = "mt-4"),
      p("We’re a small but mighty team passionate about data, cars, and making your life a little easier (and a lot more fun)."),
      tags$ul(
        tags$li(strong("VANGA JAYASIMHA REDDY: "), "The tech wizard who makes data dance."),
        tags$li(strong("BOMMARLA ATHIRATH: "), "The mastermind behind the wheels of this project.")
      ),
      h3("Our Mission", class = "mt-4"),
      p("At the end of the day, it’s all about helping you make smarter decisions. Whether you’re buying, selling, or just curious, we aim to make car analytics simple, accessible, and (dare we say) enjoyable!")
    ),
    hr(),
    p("Thanks for joining us on this ride. Buckle up, and let’s explore the data highways together!", 
      class = "text-center text-muted mt-3")
  )
}
