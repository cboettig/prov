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
  
  
  p <- prov(input_data, code, output_data)
  
  ## And here we go:
  write_prov(input_data, code, output_data, provdb = provdb,
             append= FALSE, schema = "http://schema.org")
  
  expect_true(file.exists(provdb))
  
  ## And here we go:
  write_prov(code = code,
             data_out = c(input_data, output_data),
             title = "Example Dataset",
             description = "really this is just for illustrative purposes",
             creator = list(givenName = "John", 
                            familyName = "Public", 
                            email="john@public.com"),
             provdb = provdb,
             append= FALSE, 
             schema = "http://schema.org")
  
  
  
})

test_that("Dataset", {
  
  ## Use temp files for illustration only
  provdb <- tempfile(fileext = ".json")
  input_data <- tempfile(fileext = ".csv")

  ## A minimal workflow:
  write.csv(mtcars, input_data)

  ## And here we go:
  write_prov(input_data, 
             title = "Example Dataset",
             description = "really this is just for illustrative purposes",
             creator = list(givenName = "John", 
                            familyName = "Public", 
                            email="john@public.com"),
             provdb = provdb,
             append= FALSE, 
             schema = "http://schema.org")
  
  expect_true(file.exists(provdb))
  
})