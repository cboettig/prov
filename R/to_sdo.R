

#' Convert DCAT2 Provenance to Schema.org
#' 
#' @param prov JSON-LD file in DCAT2 format
#' @param con Output, a [connection] object or character string
#' 
#' @importFrom jsonld jsonld_compact
#' @importFrom jsonlite toJSON fromJSON read_json
#' 
#' @export
#' @examples 
#' prov <- system.file("examples", "prov.json", package="prov")
#' dcat_to_sdo(prov)
#' 
to_sdo <- function(prov, con = stdout()){
  dcat <- system.file("context", "dcat_context.json", package="prov")
  sdo <- system.file("context", "sdo_context.json", package="prov")
  p <- jsonld::jsonld_compact(prov, dcat) 
  json <- jsonlite::fromJSON(p, simplifyVector = FALSE)
  sdo_context <- jsonlite::read_json(sdo)
  json[["@context"]] <- sdo_context
  p_sdo <- jsonlite::toJSON(json, auto_unbox = TRUE, pretty=TRUE)
  txt_sdo <- jsonld::jsonld_expand(p_sdo, sdo)
  compact_sdo <- jsonld::jsonld_compact(p_sdo, "http://schema.org/")

  writeLines(compact_sdo, con)
}

