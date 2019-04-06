# Set library path and repo
options(repos = "http://cran.us.r-project.org")
.libPaths(Sys.getenv("LIBS"))

# Install required libraries
install.packages("glmnet", quiet=TRUE)
install.packages("caret", quiet=TRUE)
install.packages("argparse", quiet=TRUE)