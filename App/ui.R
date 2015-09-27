require(XML)
require(shiny)

shinyUI(pageWithSidebar(
  headerPanel("Maximum Pain calculator and chart"),
  sidebarPanel(
    textInput("symbol",label = "Stock Symbol" ,value="FB"),
    dateInput("expirationDate", "Expiration Date", value = Sys.Date(), min = Sys.Date(),
              format = "dd M yyyy", startview = "month"), ## No Submit button, use reactive techniques
    width=2),
  mainPanel(
    h2('Usage:'),
    p('First enter the stock symbol (e.g., FB for Facebook, or AAPL for Apple)',
      'and then select the Expiration date for which to calculate the maximum pain.'),
    p('If the selected date is not available you will see an error message listing all the available dates. ',
      'This may happen also when the page is initially loaded if the current date is not an expiration day. ',
      'If you enter a symbol that does not exist or that does not have traded options, you will get an error ',
      'message that does not show any available dates'),
    p('Selected stock symbol',verbatimTextOutput("symbol")),
    p('Selected Expiration', verbatimTextOutput("expirationDate")),
    p('the corresponding Maximum pain value is '),
    verbatimTextOutput("mpval"),
    plotOutput("plot"),
    p("Maximum pain is the closing stock price at expiration where option buyers have the least gains."),
    p("For option underwriters it is the price point where profits are maximized."),
    p('The stock price will trend towards the maximum pain point on expiration day, ',
      'which makes maximum pain a useful indicator'),
    p('Important Note: These calculations depend on Open Interest data which is reported at irregular intervals. ',
      'It is not real-time information.'),
    a("Additional information about Maximum Pain.",     href="http://www.maximum-pain.com", target="_blank")
  )
))