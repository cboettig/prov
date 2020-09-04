


#' Write a provenance trace into JSON-LD using DCAT2 & PROV vocabularies  
#'
#' @param data_in path to input data
#' @param code path to code
#' @param data_out path to ou
#' @param meta 
#' @param creator 
#' @param title 
#' @param description 
#' @param issued 
#' @param license 
#' @param provdb 
#' @param append 
#'
#' @return
#' @export
#'
#' @examples
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
  if(is_uri(file)) return(file)
  
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
  code_obj <- dcat_script(code, description = "R code", meta_id = meta$id)
  in_obj <- prov_data(data_in, description = "Input data", meta_id = meta$id)
  
  out_id <- hash_id(data_out)
  time <- Sys.time()
  activity <- prov_activity(used = c(in_obj$id, code_obj$id),
                            generated = out_id,
                            endedAtTime = time,
                            description = paste("Running R script",
                                                basename(code))
                            )
  
  out_obj <- prov_data(data_out, 
                       id = out_id,
                       description = "output data",
                       wasDerivedFrom = in_obj$id,
                       wasGeneratedAtTime = time,
                       wasGeneratedBy = list(activity))
  

  compact(list(in_obj, code_obj, out_obj, meta_obj))
}      

