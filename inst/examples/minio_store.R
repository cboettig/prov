library(aws.s3)
library(contentid)
library(openssl)

content_path <- function(path){
  
  vapply(path, 
         function(f){
           hash <- openssl::sha256(file(f, raw = TRUE))
           sub1 <- substr(hash, 1, 2)
           sub2 <- substr(hash, 3, 4)
           file.path(sub1,sub2,hash)
         },
         character(1L), 
         USE.NAMES = FALSE)
}

s3_url <- function(path, 
                   bucket,
                   region = Sys.getenv("AWS_DEFAULT_REGION"), 
                   endpoint = Sys.getenv("AWS_S3_ENDPOINT")){
  paste0(paste0("https://", region, ".", endpoint, "/", bucket, "/"), path)
}



minio_store <-  function(files, 
                         objects = content_path(files),
                         bucket = "content-store",
                         registries = "https://hash-archive.org"){
  
  lapply(seq_along(files), function(i) 
    aws.s3::put_object(files[[i]], objects[[i]], bucket)
  )
  
  urls <- s3_url(objects, bucket = bucket)
  contentid::register(urls, registries)
  
}

