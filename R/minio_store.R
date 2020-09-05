## 

#' @importFrom contentid store register retrieve content_id
minio_store <-  function(files, 
                         server,
                         dir = Sys.getenv("MINIO_HOME"),
                         registries = "https://hash-archive.org"){
  
  store <- file.path(dir, "content-store")
  
  ## Better workflow would use MINIO REST API to publish files,
  ## And then register that public URL
  
  ids <- contentid::store(files, dir = store)
  paths <- contentid::retrieve(paths, dir = store)
  
  ## This content-store made public via a MINIO server, so we can 
  ## map paths into URLs and register them. 
  urls <- file.path(server, gsub(paste0("^", dir), "", paths))
  contentid::register(urls, registries)
  
}


publish <- function(data_in = NULL,
                    code = NULL,
                    data_out = NULL,
                    meta = NULL, 
                    provdb="prov.json",
                    dir = Sys.getenv("MINIO_HOME"),
                    server =  "https://data.ecoforecast.org"){
  minio_store(c(data_in,code, data_out, meta), dir, server)
  write_prov(data_in, code, data_out, meta, provdb)
  
}