
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
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode"
  ){
  
  files <- prov_distribution(data_in, code, data_out, meta)
  dcat_dataset(distribution = files,
               creator = creator,
               title = title,
               description = description,
               issued = issued,
               license = licence)
  
}


prov_activity <- function(
  id = paste0("urn:uuid:", uuid::UUIDgenerate()),
  description = paste("Running R script", basename(code)),
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
                      description = NULL, 
                      meta_id = NULL,
                      wasGeneratedAtTime = file.mtime(file),
                      wasDerivedFrom = NULL,
                      wasGeneratedBy = NULL,
                      wasRevisionOf = NULL){
  
  compact(
    c(dcat_distribution(file, description, meta_id),
      wasGeneratedAtTime = wasGeneratedAtTime,
      wasDerivedFrom = wasDerivedFrom,
      wasGeneratedBy = wasGeneratedBy,
      wasRevisionOf = wasRevisionOf
    ))
}


prov_distribution <- function(data_in = NULL,
                              code = NULL, 
                              data_out = NULL,
                              meta = NULL){
  
  meta_obj <- prov_data(meta, description = "Metadata document")
  code_obj <- dcat_script(code, meta_id = meta_id)
  in_obj <- prov_data(data_in, "Input data", meta$id)
  
  out_id <- hash_id(data_out)
  time <- Sys.time()
  activity <- prov_activity(used = c(in_obj$id, code_obj$id),
                            generated = out_id,
                            endedAtTime = time)
  
  out_obj <- prov_data(data_out, 
                       id = out_id,
                       description = "output data",
                       wasDerivedFrom = in_obj$id,
                       wwasGeneratedAtTime = time,
                       wasGeneratedBy = activity)
  

  compact(list(in_obj, code_obj, out_obj, meta_obj))
}      

