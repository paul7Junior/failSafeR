#########################
library(semantic.dashboard)
#########################
ui <- dashboardPage(
  dashboardHeader(disable = TRUE),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    # HTML("<script src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML' async></script>"),

    # tags$script(src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML')

    fluidRow(
      HTML('<div class="ui three item menu">
  <a class="active item">Editorials</a>
           <a class="item">Reviews</a>
           <a class="item">Upcoming Events</a>
           </div>'),
      div(class = 'ui centered grid', column(5, HTML('
<div style="border:0" class="ui segments">
                              <div style="padding-bottom:0" class="ui basic center aligned segment">
                              <p style="font-size:50px">FailSafeR</p>
                              </div>
                              <div style="padding-top:0" class="ui basic center aligned segment">
                              <p style="font-size:20px;color:#555555">A Failure Theory.</p>
                              </div>
                              </div>
                              ')),
               column(10, HTML('<div class="ui search">
  <input style="border:0;caret-color: #fbbd08;font-size:50px" class="prompt" type="text" placeholder="">
                               <div class="results"></div>
                               </div>'))),
      # div(class = 'ui grid',
          # includeMarkdown('items/Untitled.Rmd')
          uiOutput('markdown')
          # )
    )
  )
)

server <- function(input, output) {

  output$markdown <- renderUI({
    withMathJax(includeHTML('items/Untitled.html'))
    # HTML(markdown::markdownToHTML(knit('items/Untitled.Rmd', quiet = TRUE)))
  })

  set.seed(122)
  histdata <- rnorm(500)
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)
