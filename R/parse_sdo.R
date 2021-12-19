
#' Extract information about DataDownload objects from schema.org-based prov
#' @param json input JSON-LD file
#' @return A data.frame with core metadata about each DataDownload object
#' @export
#' 
parse_sdo <- function(json){
  sdo <- jsonlite::read_json(json)
  graph <- sdo$`@graph`
  type <- lookup(graph, "type")
  
  dd <- ds <- data.frame()
  ## Handle both Dataset and DataDownload
  if("Dataset" %in% type){
    dataset <- graph[type == "Dataset"]
    ds <- parseDataset(dataset)
  }
  if("DataDownload" %in% type) {
    datadownload <- graph[type == "DataDownload"]
    dd <- parseDataDownload(datadownload)
  }
  #dplyr::bind_rows(ds,dd)
  rbind(ds,dd)
}


lookup <- function(x,name){
  vapply(x, extract, "",  name = name)
}
extract <- function(y, name){
  out <- tryCatch(y[[name]][[1]],
                  error = function(e) NA_character_,
                  finally = NA_character_)
  if(is.null(out) || length(out)==0) return(NA_character_)
  out
}


parseDataset <- function(dataset) {
  purrr::map_dfr(dataset, function(graph){
    type <- lookup(graph$distribution, "type")
    datadownload <- graph$distribution[type == "DataDownload"]
    df <- parseDataDownload(datadownload)
    df$version <- graph$version
    ## consider adding additional meta columns like version?
    df
  })
}


parseDataDownload <- function(datadownload){
  
  id <- lookup(datadownload, "id")
  name <- lookup(datadownload, "name")
  description <- lookup(datadownload, "description")
  date <- as.Date(lookup(datadownload, "dateCreated"))
  df <- data.frame(name, description, id, date)
  df <- df[df$description == "output data",]
  df$basename <- tools::file_path_sans_ext(df$name, TRUE)
  df$compression <- tools::file_ext(df$name)
  df$year <- lubridate::year(df$date)
  df$version <- NA
  df
}

