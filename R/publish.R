

#' @importFrom contentid store register retrieve content_id
#' @importFrom uuid UUIDgenerate
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
  



## Identifiers are useless without some provenance metadata.
## This let's us know what we are looking for.


