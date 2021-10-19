
#' @importFrom openssl sha256
hash_id <- function(f){
  if(all(is.null(f))) return(NULL)
  vapply(f, 
         function(f)
           paste0("hash://sha256/", openssl::sha256(file(f, raw = TRUE))),
         character(1L))
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
  
  compressFormat <- rep(NA_character_, length(file))
  compressed <- grepl("(\\.gz$)|(\\.bz2$)|(\\.xz)", file)
  compressed_ext <- tools::file_ext(file[compressed])
  compressFormat[compressed] <- gsub("gz", "gzip", compressed_ext)
  
  file[compressed] <- tools::file_path_sans_ext(file[compressed])
  format <- mime::guess_type(file)

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
  utils::read.table(text = jsonld, sep = " ", comment.char = "", quote = '"',
             col.names = c("subject", "predicate", "object", "graph"))

}
