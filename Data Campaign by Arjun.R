#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


library(shiny)
library(shinyWidgets)
library(dplyr)
library(ggplot2)
library(readr)
library(randomForest)
library(lubridate)
library(readxl)


dataset <- readxl::read_excel("C:/Users/dixit/Downloads/dummy_npi_data.xlsx", sheet = "Dataset")


colnames(dataset) <- make.names(colnames(dataset))  


if("Login.Time" %in% colnames(dataset)) {
  dataset <- dataset %>% mutate(Login_Time = as.POSIXct(Login.Time, format="%H:%M:%S"),
                                Login_Hour = hour(Login_Time))
} else {
  stop("Error: Login Time column not found in dataset")
}


required_columns <- c("Speciality", "Region", "Count.of.Survey.Attempts")
optional_columns <- c("Usage.Time..mins.")
existing_columns <- colnames(dataset)

missing_required <- setdiff(required_columns, existing_columns)
if (length(missing_required) > 0) {
  stop(paste("Error: Missing required columns:", paste(missing_required, collapse=", ")))
}


formula_terms <- intersect(c("Login_Hour", required_columns, optional_columns), existing_columns)
formula <- reformulate(formula_terms[-1], response = "Login_Hour")


ui <- fluidPage(
  tags$head(
    tags$style(HTML(
      "body {
         background-color: #f4f4f4;
         display: flex;
         justify-content: center;
         align-items: center;
         height: 100vh;
         margin: 0;
       }
       .container {
         text-align: center;
         width: 600px;
       }
       .title-panel {
         font-size: 32px;
         font-weight: bold;
         margin-bottom: 20px;
       }
       .panel {
         border: 2px solid #007BFF;
         border-radius: 10px;
         padding: 20px;
         background-color: white;
         text-align: center;
       }
       .btn:hover {
         background-color: #0056b3;
         color: white;
       }
       .chat-button {
         position: fixed;
         bottom: 20px;
         right: 20px;
         background-color: #007BFF;
         color: white;
         border: none;
         padding: 15px;
         border-radius: 50%;
         cursor: pointer;
       }
       .chat-panel {
         display: none;
         position: fixed;
         bottom: 80px;
         right: 20px;
         width: 300px;
         border: 2px solid #28a745;
         border-radius: 10px;
         background-color: #f8f9fa;
         padding: 15px;
       }"
    ))
  ),
  div(class = "container",
      div(class = "title-panel", "Doctor Survey Campaign"),
      div(class = "panel",
          dateInput("survey_date", "Select Date:"),
          airDatepickerInput("survey_time", "Select Time:", timepicker = TRUE, onlyTime = TRUE),
          actionButton("predict_btn", "Get Best NPIs", class = "btn btn-primary"),
          downloadButton("download_csv", "Download CSV", class = "btn btn-success"),
          uiOutput("prediction_results")
      ),
      actionButton("chat_toggle", "💬", class = "chat-button"),
      div(id = "chat_panel", class = "chat-panel",
          h4("Chat with Doctor"),
          textInput("patient_email", "Patient Email"),
          textInput("doctor_email", "Doctor Email"),
          textInput("patient_region", "Patient Region"),
          textAreaInput("patient_situation", "Current Situation"),
          actionButton("send_message", "Send Message", class = "btn btn-info")
      )
  ),
  uiOutput("npi_details")
)


server <- function(input, output, session) {
 
  
  
  
  train_model <- reactive({
    model <- randomForest(formula, data = dataset)
    return(model)
  })
  
  predict_doctors <- eventReactive(input$predict_btn, {
    user_hour <- hour(input$survey_time)
    user_minute <- minute(input$survey_time)
    user_datetime <- as.POSIXct(paste(input$survey_date, sprintf("%02d:%02d:00", user_hour, user_minute)), format="%Y-%m-%d %H:%M:%S")
    model <- train_model()
    dataset$predicted <- predict(model, dataset)
    best_doctors <- dataset %>% filter(abs(predicted - hour(user_datetime)) <= 1) %>% select(NPI)
    return(best_doctors)
  })
  

  output$prediction_results <- renderUI({
    best_doctors <- predict_doctors()
    if (nrow(best_doctors) > 0) {
      links <- lapply(best_doctors$NPI, function(npi) {
        actionLink(inputId = paste0("npi_", npi), label = npi)
      })
      do.call(tagList, links)
    }
  })
  
  
  observe({
    lapply(predict_doctors()$NPI, function(npi) {
      observeEvent(input[[paste0("npi_", npi)]], {
        output$npi_details <- renderUI({
          div(
            h3("NPI Details"),
            p(paste("Selected NPI:", npi))
          )
        })
      })
    })
  })
  

  output$download_csv <- downloadHandler(
    filename = function() { "best_doctors.csv" },
    content = function(file) {
      write_csv(predict_doctors(), file)
    }
  )
 
  
  observeEvent(input$chat_toggle, {
    toggle("chat_panel")
  })
  

  observeEvent(input$send_message, {
    showModal(modalDialog(
      title = "Message Sent",
      "Your message has been sent to the doctor!",
      easyClose = TRUE
    ))
  })
}



shinyApp(ui = ui, server = server)