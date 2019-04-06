library(methods)
library(glmnet)

predict.babyweight <- function(babyweight,newdata=list()) {
    # center and scale data
    newdata[,1:5] <- sapply(newdata[,1:5], as.numeric)
    newdata <- predict(babyweight$preproc, newdata)

    # set factor data types
    newdata[, c("is_male", "child_race")] <- sapply(newdata[, c("is_male", "child_race")] , as.factor)

    # inverse of log transform
    exp(predict(babyweight$model, newdata))
}

new_babyweight <- function(modelfile, preprocfile) {
    model <- readRDS(modelfile)
    preproc <- readRDS(preprocfile)
    structure(list(model=model,preproc=preproc), class = "babyweight")
}

initialise_seldon <- function(params) {
    new_babyweight("model.rds", "preproc.rds")
}
