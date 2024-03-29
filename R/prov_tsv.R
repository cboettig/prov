
#' write provenance as tsv file
#' 
#' Write provenance metadata to a table. While this format is less expressive
#' than JSON-LD, it is also more efficient, particularly when data is appended.
#' At this time, only documents dcat:Distribution (schema:DataDownload) types. 
#' Column names are taken from DCAT but no official namespace is set.
#' @inheritParams write_prov
#' @param theme theme name
#' @param keyword keyword
#' @export
write_prov_tsv <- function(
  data_in = NULL,
  code = NULL, 
  data_out = NULL,
  meta = NULL,
  issued = as.character(Sys.Date()),
  theme = NA_character_,
  keyword = NA_character_,
  provdb = "prov.tsv",
  append = fs::file_exists(provdb)
  ){
  
    meta_id <- hash_id(meta)
    df <- rbind(
    row_distribution(data_in, "input data", issued, theme, keyword, isDocumentedBy = meta_id),
    row_distribution(data_out, "output data", issued, theme,  keyword, isDocumentedBy = meta_id),
    row_distribution(code, "code", issued, theme, keyword, isDocumentedBy = meta_id),
    row_distribution(meta, "metadata", issued, theme, keyword)
    )
    
    vroom::vroom_write(df, provdb, append = append)
}


row_distribution <- function(file, 
         description = NA, 
         issued = Sys.Date(),
         theme = NA,
         keyword = NA,
         isDocumentedBy = NA){
  if(is.null(file)) return(data.frame())
  
  
  ex <- compressed_extension(file)
  
  suppressWarnings({
  data.frame(
    "id"= hash_id(file),
    "type"= "Distribution",
    "title"= file,
    "description"= description,
    "issued"= issued,
    "format"= as_char(ex$format),
    "keyword"= keyword,
    "theme"= theme,
    "compressFormat"= as_char(ex$compressFormat),
    "byteSize"=  file.size(file),
    "isDocumentedBy"= as_char(isDocumentedBy))
  })
}
  
as_char <- function(x){
  if(is.null(x)) return(NA_character_)
  as.character(x)
}


