
# A dcat:Dataset is an abstract concept, and thus uses a UUID
schema_dataset <- function(
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
    name = title,
    description = description,
    creator = creator,
    dateCreated = issued,
    license = license,
    distribution = distribution,
    ...
  ))
  
}

is_url <- function(x) {
  grepl("^http[s]://", x)
}

schema_distribution <- function(file, 
                              id = NULL,
                              identifier = NULL,
                              description = NULL, 
                              meta_id = NULL){
  
  if(is.null(identifier))
    identifier = hash_id(file, algo= c("sha256", "md5"))
  
  if(is.null(id))
    id = identifier[[1]]
  
  if(is.null(file)) return(NULL)
  ex <- compressed_extension(file)
  
  contentUrl <- NULL
  if(is_url(file)) contentUrl <- file
  
  contentSize <- NULL
  
  if(file.exists(file))
    contentSize <- file.size(file)
  else if(is_url(file)) {
    contentSize <- httr::HEAD(file)$headers$`content-length`
  }
  
  
  compact(list(
    id = id,
    type = "DataDownload",
    identifier = identifier, 
    name = basename(file),
    description = description,
    encodingFormat  = ex$format,
    contentSize = as.integer(contentSize),
    contentUrl = contentUrl
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
    type = c("DataDownload", "SoftwareSourceCode"),
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
                      wasGeneratedAtTime = NULL,
                      wasDerivedFrom = NULL,
                      wasGeneratedBy = NULL,
                      wasRevisionOf = NULL){
  
  if(is.null(file)) return(NULL)
  if(grepl("^hash://", file)) return(list(id = file))
  
  
  if(is.null(wasGeneratedAtTime)) {
    if(file.exists(file))
      wasGeneratedAtTime <-file.mtime(file)
  }
  
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
                              data_out = NULL){
  
  
  code_obj <- lapply(unname(code), schema_script, 
                     description = "R code")
  in_obj <- lapply(unname(data_in), schema_data, 
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
  
  out_obj <- compact(lapply(unname(data_out), schema_data, 
                            description = "output data"))
  
  
  compact(c(in_obj, code_obj, out_obj, list(activity)))
}      



