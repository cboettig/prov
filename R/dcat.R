
dcat_dataset <- function(
  distribution,
  creator = NULL,
  title = NULL,
  description = NULL,
  issued = as.character(Sys.Date()),
  license = "https://creativecommons.org/publicdomain/zero/1.0/legalcode")
{
  
  dataset_id <- multihash_ids(lapply(distribution, `[[`, "id"))
  
  compact(list(
    type = "Dataset",
    id = dataset_id,
    title = title,
    description = description,
    creator = creator,
    issued = issued,
    license = license,
    distribution = distribution
  ))
  
}


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
  if(is_uri(code)) return(list(id = file))
  
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