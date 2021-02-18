package_vector <- c(
	"bayesplot",
	"haven",
	"ggstance",
	"tidybayes",
	"shinystan",
	"fixest",
	"lfe",
	"sandwich",
	"AER",
	"vroom",
	"rstanarm",
	"MASS",
	"brms")
install.packages(package_vector)
devtools::install_github("rmcelreath/rethinking@2.13")
