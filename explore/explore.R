library(jsonld)
library(jsonlite)
library(readr)
#remotes::install_github("cboettig/rdftools")
#library(rdftools)
flat <- jsonld::jsonld_flatten("inst/examples/biotime-schemaorg.json") 
View(fromJSON(flat))
jsonlite::write_json(flat, "inst/examples/flat.json", pretty = TRUE)
quads <- jsonld::jsonld_to_rdf("inst/examples/biotime-schemaorg.json") 
readr::write_lines(quads, "inst/examples/biotime.nq")
df <-  readr::read_delim("inst/examples/biotime.nq", " ", 
                         comment = "^^",
                         col_names = c("subject", "predicate", "object", "graph"))
