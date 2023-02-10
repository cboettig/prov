library(aws.s3)
library(openssl)

hash_to_path <- function(hash){
  vapply(hash, 
         function(hash) {
           hash <- gsub("^hash://sha256/", "", hash)
           sub1 <- substr(hash, 1, 2)
           sub2 <- substr(hash, 3, 4)
           file.path(sub1,sub2,hash)
         },
  character(1L),
  USE.NAMES = FALSE)
}


content_path <- function(path){
  vapply(path, 
         function(f){
           hash <- openssl::sha256(file(f, raw = TRUE))
           hash_to_path(hash)
         },
         character(1L), 
         USE.NAMES = FALSE)
}


s3_store <-  function(files, 
                      objects = content_path(files),
                      bucket = "content-store",
                      ...){
  
  lapply(seq_along(files), function(i) 
    aws.s3::put_object(files[[i]], objects[[i]], bucket, ...)
  )
  
  invisible(objects)
}

s3_retrieve <- function(ids, dir = ".", bucket = "content-store", ...){
  paths <- hash_to_path(ids)
  lapply(seq_along(paths), function(path){
    aws.s3::save_object(object = path, 
                        file = file.path(dir, path),  
                        bucket = bucket, 
                        ...)
  })
  
  invisible(file.path(dir, paths))
}


## Access public content
s3_public_url <- function(path, 
                   bucket,
                   region = Sys.getenv("AWS_DEFAULT_REGION"), 
                   baseurl = Sys.getenv("AWS_S3_ENDPOINT")){
  paste0(paste0("https://", region, ".", baseurl, "/", bucket, "/"), path)
}

