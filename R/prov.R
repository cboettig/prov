


#' Write a provenance trace into JSON-LD
#'
#' @param data_in path or URI for input data
#' @param code path or URI for code
#' @param data_out path or URI to output data
#' @param meta path or URI to metadata describing the workflow
#' @param creator URI, list node, or text for creator
#' @param title Dataset title, character string
#' @param description Dataset description, character string
#' @param issued publication date, as Date or character object
#' @param license URL to a copyright license
#' @param provdb path to output JSON file, default "prov.json"
#' @param append Should we append to existing json or overwrite it?
#' @param schema Use schema.org or DCAT2 schema? See details.
#' @param ... additional named elements passed to Dataset
#' @details 
#' 
#' If creator, title, and description are all empty, will serialize
#' only a graph of distribution (data download) elements, not a 
#' Dataset. 
#' 
#' Additional elements passed through `...` must be explicitly namespaced,
#' e.g. `dcat:version`, when using DCAT2 schema. When using schema.org,
#' elements must be in schema.org namespace.  p  
#' 
#' Provenance can be expressed in (purely) schema.org or as DCAT2 
#' (includes terms from DCTERMS, PROV, DCAT2, CITO ontologies). 
#' The latter is more expressive in terms of provenance.
#' Also note DCAT but not schema can explicitly encode compression and
#' metadata file relationships.
#' @export
#'
#' @examples
#'  
#' ## Use temp files for illustration only
#' provdb <- tempfile(fileext = ".json")
#' input_data <- tempfile(fileext = ".csv")
#' output_data <- tempfile(fileext = ".csv")
#' code <- tempfile(fileext = ".R")
#' 
#' ## A minimal workflow: 
#' write.csv(mtcars, input_data)
#' out <- lm(mpg ~ disp, data = mtcars)
#' write.csv(out$coefficients, output_data)
#' 
#' # really this would already exist...
#' writeLines("out <- lm(mpg ~ disp, data = mtcars)", code)
#' 
#' ## And here we go: 
#' write_prov(input_data, code, output_data, provdb = provdb,  
#'            append= FALSE)
#'  
#' ## Include a title to group these into a Dataset:
#' write_prov(input_data, code, output_data, provdb = provdb,
#'            title = "example dataset with provenance",  append= FALSE)
#'            
write_prov <-  function(
  data_in = NULL,
  code = NULL, 
  data_out = NULL,
  meta = NULL,
  creator = NULL,
  title = NULL,
  description = NULL,
  issued = as.character(Sys.Date()),
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
  provdb = "prov.json",
  append = TRUE,
  schema = c("http://www.w3.org/ns/dcat", "http://schema.org"),
  ...
){
  
  prov_obj <- 
  prov(data_in = data_in, 
       code = code, 
       data_out = data_out,
       meta = meta,
       creator = creator,
       title = title,
       description = description,
       issued = issued,
       license = license,
       schema = schema, 
       ...)
  
  write_jsonld(prov_obj, provdb, append, schema = schema)
  
}

#' generate provenance information
#' 
#' @inheritParams write_prov
#' @export
prov <-  function(
  data_in = NULL,
  code = NULL, 
  data_out = NULL,
  meta = NULL,
  creator = NULL,
  title = NULL,
  description = NULL,
  issued = as.character(Sys.Date()),
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
  schema = c("http://www.w3.org/ns/dcat", "http://schema.org"),
  ...
  ){
  
  schema <- match.arg(schema)
  files <- 
    switch(schema, 
           "http://www.w3.org/ns/dcat" = 
             dcat_provenance(data_in = data_in, 
                               code = code, 
                               data_out = data_out, 
                               meta = meta),
           "http://schema.org" = 
             schema_provenance(data_in = data_in, 
                               code = code, 
                               data_out = data_out)
    )
  
  
  ## If we have none of these fields, don't package as a dataset
  if(all(is.null(c(creator, title, description))))
    return(list("@graph" = files))
  
  actions <- list()
  if(grepl("schema.org", schema)){
   ## If we're writing a dataset, action type should not be included
   ## in the distribution element! 
   type <- lookup(files, "type")
   actions <- files[type == "Action"]
   files <- files[type != "Action"]
  }
  
  out <- switch(schema, 
         "http://www.w3.org/ns/dcat" = 
           dcat_dataset(distribution = files,
                        creator = creator,
                        title = title,
                        description = description,
                        issued = issued,
                        license = license,
                        ...),
         "http://schema.org" = 
           schema_dataset(distribution = files,
               creator = creator,
               title = title,
               description = description,
               issued = issued,
               license = license,
               ...)
  )
  if(length(actions) > 0){
    return(list(
      "@graph" = list(out, actions)
          ))
  }
  out
              
}
