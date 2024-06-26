print("Reading in data")
project_name <- Sys.getenv('DOMINO_PROJECT_NAME')
path <- paste('/mnt/data/WineQuality-Git/WineQualityData.csv')
#change path for GBP
path <- gsub(" ", "", path, fixed = TRUE)
data <- read.csv(file=path)
head(data)

data$is_red <- as.integer(data$type != 'white')

data <-na.omit(data)
dim(data)[1]-sum(complete.cases(data))

train <-data[sample(nrow(data), round(dim(data)[1]*0.75)),]
# test <- data[(round(dim(data)[1]*0.75)+1):dim(data)[1], 2:dim(data)[2]]
test <- data[(data$id %in% train$id)==FALSE,]
train <- subset(train, select = -c(id) )
test <- subset(test, select = -c(id) )

train_matrix <-  as.matrix(train)
test_matrix <-  as.matrix(test)
label_matrix <- as.matrix(train$quality)
test_lab_matrix <- as.matrix(test$quality)

dim(train)+dim(test)

print("Training Model")

lm_model <- lm(formula = quality ~., data = train)
lm_model


RSQUARE = function(y_actual,y_predict){
  cor(y_actual,y_predict)^2
}

preds_lm <- predict(lm_model, newdata = test)

rsquared_lm <-round(RSQUARE(preds_lm, test$quality),3)
print(rsquared_lm[1])

#mse
mse_lm<- round(mean((test_lab_matrix - preds_lm)^2),3)
print(mse_lm)

diagnostics = list("R2" = rsquared_lm[1], 
                   "MSE"=mse_lm)
library(jsonlite)
fileConn<-file("/mnt/artifacts/dominostats.json")
writeLines(toJSON(diagnostics), fileConn)
close(fileConn)

save(lm_model, file="/mnt/code/models/R_linear_model.Rda")

# install.packages("SHAPforxgboost")
# install.packages("SHAPforxgboost")
# library("SHAPforxgboost")
# shap_values <- shap.values(xgb_model = mod, X_train = dataX)