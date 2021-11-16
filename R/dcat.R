
# A dcat:Dataset is an abstract concept, and thus uses a UUID
dcat_dataset <- function(
  distribution,
  id =  paste0("urn:uuid:", uuid::UUIDgenerate()),
  creator = NULL,
  title = NULL,
  description = NULL,
  issued = as.character(Sys.Date()),
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
  ...)
{
  
  compact(list(
    type = "Dataset",
    id = id,
    title = title,
    description = description,
    creator = creator,
    issued = issued,
    license = license,
    distribution = distribution,
    ...
  ))
  
}

## dcat:distribution is a particular serialization
## and thus uses a content-based identifier
dcat_distribution <- function(file, 
                              id = hash_id(file),
                              description = NULL, 
                              meta_id = NULL){
  
  if(is.null(file)) return(NULL)
  if(is_uri(file)) return(list(id = file))
  ex <- compressed_extension(file)
  
  compact(list(
    id = id,
    type = "Distribution",
    identifier = id, 
    title = basename(file),
    description = description,
    format  = ex$format,
    compressFormat = ex$compressFormat,
    byteSize = file.size(file),
    isDocumentedBy = meta_id
  ))
}


dcat_script <- function(code,  
                        description = "R code",
                        format = "application/R",
                        meta_id = NULL){
  
  if(is.null(code)) return(NULL)
  if(is_uri(code)) return(list(id = code))
  
  code_id <- hash_id(code)
  compact(list(
    type = c("Distribution", "SoftwareSourceCode"),
    id = code_id,
    identifier = code_id,
    title = basename(code),
    description = description,
    format = format,
    isDocumentedBy = meta_id
  ))
}


#' @importFrom uuid UUIDgenerate
dcat_activity <- function(
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

dcat_data <- function(file, 
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




dcat_provenance <- function(data_in = NULL,
                            code = NULL, 
                            data_out = NULL,
                            meta = NULL){
  
  
  
  meta_obj <- dcat_distribution(meta, description = "Metadata document")
  code_obj <- lapply(code, dcat_script, 
                     description = "R code", meta_id = meta_obj$id)
  in_obj <- lapply(data_in, dcat_data, 
                   description = "Input data", meta_id = meta_obj$id)
  
  in_obj_ids <- vapply(in_obj, `[[`, character(1L), "id")
  code_obj_ids <- vapply(code_obj, `[[`, character(1L), "id")
  
  out_ids <- vapply(data_out, hash_id, character(1L))
  time <- Sys.time()
  
  ## no code, no activity to record
  if(length(code_obj)>0){
    activity <- dcat_activity(used = c(in_obj_ids, code_obj_ids),
                              generated = out_ids,
                              endedAtTime = time,
                              description = paste("Running R script")
    )
  } else {
    activity <- NULL
  }
  
  out_obj <- compact(lapply(data_out, dcat_data, 
                            description = "output data",
                            meta_id = meta_obj$id,
                            wasDerivedFrom = in_obj_ids,
                            wasGeneratedAtTime = time,
                            wasGeneratedBy = list(activity)))
  
  
  compact(list(in_obj, code_obj, out_obj, meta_obj))
}      


