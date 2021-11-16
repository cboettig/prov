
# A dcat:Dataset is an abstract concept, and thus uses a UUID
schema_dataset <- function(
  distribution,
  id =  paste0("urn:uuid:", uuid::UUIDgenerate()),
  creator = NULL,
  title = NULL,
  description = NULL,
  issued = as.character(Sys.Date()),
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode")
{
  
  compact(list(
    type = "Dataset",
    id = id,
    name = title,
    description = description,
    creator = creator,
    issued = issued,
    license = license,
    distribution = distribution
  ))
  
}

schema_distribution <- function(file, 
                              id = hash_id(file),
                              description = NULL, 
                              meta_id = NULL){
  
  if(is.null(file)) return(NULL)
  if(is_uri(file)) return(list(id = file))
  ex <- compressed_extension(file)
  
  compact(list(
    id = id,
    type = "DataDownload",
    identifier = id, 
    name = basename(file),
    description = description,
    encodingFormat  = ex$format,
    contentSize = file.size(file)
  ))
}


schema_script <- function(code,  
                        description = "R code",
                        format = "application/R",
                        meta_id = NULL){
  
  if(is.null(code)) return(NULL)
  if(is_uri(code)) return(list(id = code))
  
  code_id <- hash_id(code)
  compact(list(
    type = c("SoftwareSourceCode"),
    id = code_id,
    identifier = code_id,
    name = basename(code),
    description = description,
    encodingFormat = format
  ))
}
schema_data <- function(file, 
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
    c(schema_distribution(file, 
                        id = id,
                        description = description),
      dateCreated = as.character(as.Date(wasGeneratedAtTime))
    ))
}


#' @importFrom uuid UUIDgenerate
schema_activity <- function(
  id = paste0("urn:uuid:", uuid::UUIDgenerate()),
  description = "Running R script",
  used = NULL, 
  generated = NULL,
  startedAtTime = NULL,
  endedAtTime = NULL
){
  compact(list(
    type = "Action",
    id = id,
    description = description,
    object = used,
    result = generated,
    startTime = startedAtTime,
    endTime = endedAtTime
  ))
}


schema_provenance <- function(data_in = NULL,
                              code = NULL, 
                              data_out = NULL,
                              meta = NULL){
  
  
  code_obj <- lapply(code, schema_script, 
                     description = "R code")
  in_obj <- lapply(data_in, schema_data, 
                   description = "Input data")
  
  in_obj_ids <- vapply(in_obj, `[[`, character(1L), "id")
  code_obj_ids <- vapply(code_obj, `[[`, character(1L), "id")
  
  out_ids <- vapply(data_out, hash_id, character(1L))
  time <- Sys.time()
  
  ## no code, no activity to record
  if(length(code_obj)>0){
    activity <- schema_activity(used = c(in_obj_ids, code_obj_ids),
                              generated = out_ids,
                              endedAtTime = time,
                              description = paste("Running R script")
    )
  } else {
    activity <- NULL
  }
  
  out_obj <- compact(lapply(data_out, schema_data, 
                            description = "output data",
                            wasDerivedFrom = in_obj_ids,
                            wasGeneratedAtTime = time,
                            wasGeneratedBy = list(activity)))
  
  
  compact(list(in_obj, code_obj, out_obj))
}      



