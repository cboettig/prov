testthat::context("http://schema.org")

test_that("prov in-code-out", {
  
  ## Use temp files for illustration only
  provdb <- tempfile(fileext = ".json")
  input_data <- tempfile(fileext = ".csv")
  output_data <- tempfile(fileext = ".csv")
  code <- tempfile(fileext = ".R")
  
  ## A minimal workflow:
  write.csv(mtcars, input_data)
  out <- lm(mpg ~ disp, data = mtcars)
  write.csv(out$coefficients, output_data)
  
  # really this would already exist...
  writeLines("out <- lm(mpg ~ disp, data = mtcars)", code)
  
  ## And here we go:
  write_prov(input_data, code, output_data, provdb = provdb,
             append= FALSE, schema = "http://schema.org")
  
  expect_true(file.exists(provdb))
  
})