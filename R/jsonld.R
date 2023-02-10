
context_file <- function(schema = c("http://schema.org", "http://www.w3.org/ns/dcat")){
  
  schema <- match.arg(schema)
  
  #paste0("https://raw.githubusercontent.com/",
  #       "cboettig/prov/master/inst/context/dcat_context.json")
  
  switch(schema, 
         "http://www.w3.org/ns/dcat" = system.file("context", 
                                                   "dcat_context.json",
                                                   package="prov", 
                                                   mustWork = TRUE),
         "http://schema.org" = system.file("context", 
                                           "schema_context.json",
                                           package="prov", 
                                           mustWork = TRUE)
          )
}


context <- function(schema){
  read_json(context_file(schema))
}

write_jsonld <- function(obj,
                         file = "prov.json",
                         append = TRUE,
                         schema = c("http://schema.org", "http://www.w3.org/ns/dcat"))
){
  schema <- match.arg(schema)
  context <- context(schema)
  out <- c(context, obj)
  
  if(fs::file_exists(file) && append){
    tmp <- tempfile(fileext=".json")
    jsonlite::write_json(out, tmp, auto_unbox=TRUE, pretty = TRUE)
    out <- append_ld(c(tmp, file))
    writeLines(out, file)
  } else {
    jsonlite::write_json(out, file, auto_unbox=TRUE, pretty = TRUE)
  }
  
}


## Append triples, like so:
# triple <- list(list("@id" = "hash://sha256/93e741a4ff044319b3288d71c71d4e95a76039bc3656e252621d3ad49ccc8200",
#                    "http://www.w3.org/ns/prov#wasRevisionOf" = "hash://sha256/xxxxx"))
# append_ld(triple, "prov.json")



append_ld <- function(x) {
  rdf <- lapply(x, jsonld::jsonld_to_rdf)
  rdf <- do.call(paste, rdf)
  jsonld::jsonld_from_rdf(rdf)
}


