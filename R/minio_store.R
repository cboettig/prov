
#' @export
minio_store <-  function(files, 
                         server,
                         dir = Sys.getenv("MINIO_HOME")){
  
  store <- file.path(dir, "content-store")
  
  contentid::store(files, dir = store)
  contentid::retrieve(paths, dir = store)
  
  ## This content-store made public via a MINIO server, so we can 
  ## map paths into URLs and register them. 
  urls <- file.path(server, gsub(paste0("^", dir), "", paths))
  contentid::register(urls, "https://hash-archive.org")
  
}