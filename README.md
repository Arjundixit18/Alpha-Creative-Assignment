Created a Doctor Survey Campaign Shiny App using R 

# Doctor Survey Campaign (Shiny App)

## Overview
The Doctor Survey Campaign is an interactive Shiny app built using R. This tool helps healthcare professionals and researchers predict the best time to send survey invitations to doctors based on their past login and survey response data.

## Features
- Predict Best NPI (National Provider Identifier): Uses machine learning (Random Forest) to predict the best doctors to contact based on time and historical survey data.
- Interactive UI: Allows users to select a date and time to find the most responsive doctors.
- Downloadable CSV: Users can download a list of best doctors in CSV format.
- Live Chat Panel: Simulated chat interface to communicate with doctors.
- User-friendly Interface: Clean and simple UI with an intuitive layout.

## Technologies Used
- Shiny: For building the interactive web application.
- shinyWidgets: For enhanced UI components.
- dplyr & ggplot2: For data manipulation and visualization.
- readr & readxl: For handling CSV and Excel files.
- randomForest: Machine learning model for prediction.
- lubridate: For handling date and time data.

## How It Works
1. Upload Data: The app loads an Excel dataset containing doctor login times and survey response records.
2. Train Machine Learning Model: A Random Forest model is trained on the dataset.
3. Predict Best Doctors: Users select a date and time, and the model predicts doctors most likely to respond.
4. Display Results: A list of NPIs (doctor identifiers) is shown in a structured format.
5. Download CSV: Users can download the predicted NPIs as a CSV file for further use.
6. Chat Feature: Simulated chat panel allows users to input patient and doctor details for messaging.

## Installation & Setup
### Prerequisites
Ensure you have R and the required packages installed:
```r
install.packages(c("shiny", "shinyWidgets", "dplyr", "ggplot2", "readr", "randomForest", "lubridate", "readxl"))
```

### Running the App
1. Clone this repository or copy the script.
2. Run the script in RStudio or the R console:
   ```r
   shiny::runApp("app.R")
   ```
3. The app will launch in your web browser.

## UI Components
- Date & Time Input: Users select a survey date and time.
- Predict Button: Triggers the prediction of best NPIs.
- Download CSV Button: Exports the predictions as a CSV file.
- Chat Panel: Users can input patient and doctor details to simulate a conversation.



## Next Steps
- Enhance the model with additional features.
- Implement real-time database integration.
- Add authentication for secure access.

## Contributing
Feel free to fork this project and contribute by submitting pull requests.

## License
This project is open-source and available under the MIT License.
