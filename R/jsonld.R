
context_file <- function(){
  #paste0("https://raw.githubusercontent.com/",
  #       "cboettig/prov/master/inst/context/dcat_context.json")
  system.file("context", "dcat_context.json",
                       package="prov", mustWork = TRUE)
}

#' @importFrom jsonlite read_json write_json
context <- function(){
  jsonlite::read_json(context_file())
}


write_jsonld <- function(obj,
                         file = "prov.json",
                         append = TRUE,
                         context = context_file() 
){
  
  context <- jsonlite::read_json(context)
  out <- c(context, obj)
  
  if(file.exists(file) && append){
    tmp <- tempfile(fileext=".json")
    jsonlite::write_json(out, tmp, auto_unbox=TRUE, pretty = TRUE)
    out <- merge_jsonld(tmp, file)
    writeLines(out, file)
  } else {
    jsonlite::write_json(out, file, auto_unbox=TRUE, pretty = TRUE)
  }
  
  
}


## Append triples, like so:
# triple <- list(list("@id" = "hash://sha256/93e741a4ff044319b3288d71c71d4e95a76039bc3656e252621d3ad49ccc8200",
#                    "http://www.w3.org/ns/prov#wasRevisionOf" = "hash://sha256/xxxxx"))
# append_ld(triple, "prov.json")



#' @importFrom jsonld jsonld_flatten jsonld_compact
merge_jsonld <- function(x,y, 
  context = context_file()){
  flat_x <- jsonld::jsonld_flatten(x) 
  flat_y <- jsonld::jsonld_flatten(y)
  json <- jsonld::jsonld_flatten(merge_json(flat_x, flat_y))
  jsonld::jsonld_compact(json, context)
}

append_ld <- function(obj, json, 
  context = context_file()){
  flat <- jsonld::jsonld_flatten(json) 
  flat_list <- jsonlite::fromJSON(flat, simplifyVector = FALSE)
  combined <- jsonlite::toJSON(c(flat_list, list(obj)), auto_unbox = TRUE)
  out <- jsonld::jsonld_compact(jsonld::jsonld_flatten(combined), context)
  
  writeLines(out, json)
}

