# Load libraries 
.libPaths(Sys.getenv("LIBS"))
library(caret)
library(argparse)

# Configure command line arguments
parser <- ArgumentParser()
parser$add_argument("--gcs_train_data", default="")
parser$add_argument("--gcs_export_dir", default="")
args <- parser$parse_args()

# Get training data
system(paste0("gsutil cp ", args$gcs_train_data, " /tmp/train_data.csv"))
df <- read.csv("/tmp/train_data.csv")

# Use caret to impute missing values
df[,1:6] <- sapply(df[,1:6], as.numeric)
preproc <- preProcess(df[,-1], method = c("scale","center","medianImpute"))
df[,-1] <- predict(preproc, df[,-1])

# Specify factor data types
df[, c("is_male", "child_race")] <- sapply(df[, c("is_male", "child_race")] , as.factor)
summary(df)

# Partition data into test and train dataframes
trainIndex <- createDataPartition(df$is_male, p = .8, list = FALSE)
train_df <- df[trainIndex, ] 
test_df <- df[-trainIndex, ]

# Hyperparameter search an training control parameters
tunegrid <- expand.grid( lambda = c(.001, .01, .1),
                         alpha = c(.001, .01, .1) )

trcontrol = trainControl( method = "cv", number = 5, verboseIter = TRUE)

# Training with caret, log transformation of response
(model <- train(log(y) ~ ., data = train_df, method = "glmnet", trControl = trcontrol, tuneGrid = tunegrid))
summary(model$finalModel)

# Export models to Google Cloud Storage
saveRDS(preproc, '/tmp/preproc.rds')
saveRDS(model, '/tmp/model.rds')
system(paste0("gsutil cp /tmp/model.rds ", args$gcs_export_dir, "/model.rds"))
system(paste0("gsutil cp /tmp/preproc.rds ", args$gcs_export_dir, "/preproc.rds"))