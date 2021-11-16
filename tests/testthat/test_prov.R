testthat::context("prov fn")


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
             append= FALSE)
  
  expect_true(file.exists(provdb))
  
})


test_that("one data file only", {
  
  ## Use temp files for illustration only
  provdb <- tempfile(fileext = ".json")
  input_data <- tempfile(fileext = ".csv")

  ## A minimal workflow:
  write.csv(mtcars, input_data)

  write_prov(input_data, provdb = provdb, append= FALSE)
  expect_true(file.exists(provdb))
  
  # writeLines(readLines(provdb))
  
})


test_that("two data files only", {
  
  ## Use temp files for illustration only
  provdb <- tempfile(fileext = ".json")
  output_data <- tempfile(fileext = ".csv")
  output_data2 <- tempfile(fileext = ".csv")
  
  ## A minimal workflow:
  write.csv(mtcars, output_data)
  write.csv(iris, output_data2)
  
  write_prov(data_out =  c(output_data, output_data2), 
             provdb = provdb, append= FALSE)
  expect_true(file.exists(provdb))
  
  writeLines(readLines(provdb))
  
})



test_that("multiple output files", {
  
  ## Use temp files for illustration only
  provdb <- tempfile(fileext = ".json")
  input_data <- tempfile(fileext = ".csv")
  output1 <- tempfile(fileext = ".csv")
  output2 <- tempfile(fileext = ".csv")
  code <- tempfile(fileext = ".R")
  
  ## A minimal workflow:
  write.csv(mtcars, input_data)
  out <- lm(mpg ~ disp, data = mtcars)
  write.csv(out$coefficients, output1)
  write.csv(out$residuals, output2)
  
  # really this would already exist...
  writeLines("out <- lm(mpg ~ disp, data = mtcars)", code)
  
  ## And here we go:
  write_prov(input_data, code, c(output1, output2), provdb = provdb,
             append= FALSE)
  
  expect_true(file.exists(provdb))
  
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
             append= FALSE, schema = "http://schema.org")
  
  expect_true(file.exists(provdb))
  
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
             append= FALSE)
  
  expect_true(file.exists(provdb))
  
})