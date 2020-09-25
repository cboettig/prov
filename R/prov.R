


#' Write a provenance trace into JSON-LD using DCAT2 & PROV vocabularies  
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
#' 
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
  append = TRUE
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
       license = license)
  
  write_jsonld(prov_obj, provdb, append)
  
}

prov <-  function(
  data_in = NULL,
  code = NULL, 
  data_out = NULL,
  meta = NULL,
  creator = NULL,
  title = NULL,
  description = NULL,
  issued = as.character(Sys.Date()),
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode"
  ){
  
  
  files <- prov_distribution(data_in = data_in, 
                             code = code, 
                             data_out = data_out, 
                             meta = meta)
  
  ## If we have none of these fields, don't package as a dataset
  if(all(is.null(c(creator, title, description))))
    return(list("@graph" = files))
  
  dcat_dataset(distribution = files,
               creator = creator,
               title = title,
               description = description,
               issued = issued,
               license = license)
  
}

#' @importFrom uuid UUIDgenerate
prov_activity <- function(
  id = paste0("urn:uuid:", uuid::UUIDgenerate()),
  description = "Running R script",
  used = NULL, 
  generated = NULL,
  startedAtTime = NULL,
  endedAtTime = NULL
){
  compact(list(
    type = "Activity",
    id = id,
    description = description,
    used = used,
    generated = generated,
    startedAtTime = startedAtTime,
    endedAtTime = endedAtTime
  ))
}

prov_data <- function(file, 
                      id = hash_id(file),
                      description = NULL, 
                      meta_id = NULL,
                      wasGeneratedAtTime = file.mtime(file),
                      wasDerivedFrom = NULL,
                      wasGeneratedBy = NULL,
                      wasRevisionOf = NULL){
  
  if(is.null(file)) return(NULL)
  if(is_uri(file)) return(list(id = file))
  
  compact(
    c(dcat_distribution(file, 
                        id = id,
                        description = description,
                        meta_id = meta_id),
      wasGeneratedAtTime = as.character(wasGeneratedAtTime),
      wasDerivedFrom = wasDerivedFrom,
      wasGeneratedBy = wasGeneratedBy,
      wasRevisionOf = wasRevisionOf
    ))
}




prov_distribution <- function(data_in = NULL,
                              code = NULL, 
                              data_out = NULL,
                              meta = NULL){
  
  
  
  meta_obj <- dcat_distribution(meta, description = "Metadata document")
  code_obj <- lapply(code, dcat_script, 
                     description = "R code", meta_id = meta_obj$id)
  in_obj <- lapply(data_in, prov_data, 
                   description = "Input data", meta_id = meta_obj$id)
  
  in_obj_ids <- vapply(in_obj, `[[`, character(1L), "id")
  code_obj_ids <- vapply(code_obj, `[[`, character(1L), "id")
  
  out_ids <- vapply(data_out, hash_id, character(1L))
  time <- Sys.time()
  
  ## no code, no activity to record
    activity <- prov_activity(used = c(in_obj_ids, code_obj_ids),
                              generated = out_ids,
                              endedAtTime = time,
                              description = paste("Running R script")
                              )

  
  out_obj <- compact(lapply(data_out, prov_data, 
                       description = "output data",
                       wasDerivedFrom = in_obj_ids,
                       wasGeneratedAtTime = time,
                       wasGeneratedBy = list(activity)))
  

  compact(list(in_obj, code_obj, out_obj, meta_obj))
}      

