
#' @importFrom openssl sha256
hash_id <- function(f){
  if(is.null(f)) return(NULL)
  paste0("hash://sha256/", openssl::sha256(file(f, raw = TRUE)))
}

multihash_file <- function(files){
  ids <- vapply(files, hash_id, character(1L), USE.NAMES = FALSE)
  multihash_ids(ids)
}

multihash_ids <- function(ids){
  paste0("hash://sha256/", paste0(openssl::sha256(paste(ids, collapse="\n"))))
}

is_uri <- function(x){
  if(is.null(x)) return(FALSE)  
  if(file.exists(x)) return(FALSE)
  if(grepl("^\\w+:.*", x)) return(TRUE)
  
}


compact <- function (l){
  out <- Filter(Negate(is.null), l)
  keep <- vapply(out, length, integer(1L)) > 0
  if(sum(keep) == 0) return(NULL)
  out[keep]
}

#' @importFrom mime guess_type
compressed_extension <- function(file){
  ext <- function(x) gsub(".*[.](\\w+)$", "\\1", basename(x))
  ex <- ext(file)
  compressFormat = switch(ex, 
                          "gz" = "gzip",
                          "bz2" = "bz2",
                          NULL)
  if(!is.null(compressFormat)){
    format <- mime::guess_type(gsub(compressFormat, "", file))
  } else{
    format <- mime::guess_type(file)
  }
  
  list(format = format, compressFormat = compressFormat)
}

#' @importFrom jsonlite fromJSON toJSON
merge_json <- function(x,y){
  m <- c(jsonlite::fromJSON(x, simplifyVector = FALSE), 
         jsonlite::fromJSON(y, simplifyVector = FALSE))
  jsonlite::toJSON(m, auto_unbox = TRUE, pretty = TRUE)
}


rdf_table <- function(doc){
  jsonld <- jsonld::jsonld_normalize(doc)
  read.table(text = jsonld, sep = " ", comment.char = "", quote = '"',
             col.names = c("subject", "predicate", "object", "graph"))

}
