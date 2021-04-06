# Take JSON-LD as input, return a table that has a row
# for each subject and columns for each property associated with it.
# 
# Note that certain properties may be vector-valued (subject _:b0 wasGeneratedBy _:b1,_:b2)
# which does not permit a tabular representation.  
rdf_properties <- function(df, strip_namespace=TRUE, collapse = NULL) {
  if(strip_namespace){
    predicate <- df$predicate
    predicate <- gsub(">$", "", gsub("^<", "", predicate))
    predicate <- gsub(".*#(\\w+)$", "\\1", basename(predicate))
    df$predicate <- predicate
  }

  ## Collapse vector-valued 
  if(!is.null(collapse)){
  df <- df %>% 
    group_by(subject, predicate) %>%
    summarise(object = paste(object, collapse=collapse),
              .groups = "drop")
  }
  
  suppressWarnings({
    out <- df %>% 
      tidyr::pivot_wider(c("subject"), 
                         names_from = "predicate",
                         values_from = object)
    })
  if(any(vapply(out, is.list, logical(1L))))
    out <- tidyr::unnest(out, dplyr::everything())
  
  apply_datatype(out)
}

apply_datatype <- function(df){
  cols <- colnames(df)
  for(col in cols){
    values <- df[[col]]
    if(all(grepl("\\^\\^<http://www.w3.org/2001/XMLSchema#integer>", values))){
      df[[col]] <- as.integer(gsub("\\^\\^<http://www.w3.org/2001/XMLSchema#integer>", "", values))
    }
    ## Add other types
    
    ## Lastly, strip any unresolved type declarations, leaving as char data
    if(all(grepl("\\^\\^<.*", values))){
      df[[col]] <- as.integer(gsub("\\^\\^.*", "", values))
    }
  }
  df
}


rdf_filter <- function(df, key, value = NULL){
  tmp <- filter(df, grepl(key, predicate))
  if(!is.null(value)){
    tmp <- filter(tmp, object == value)
    tmp <- inner_join(select(tmp, subject), df, by = "subject")
  }
  tmp
}
