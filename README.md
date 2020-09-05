
<!-- README.md is generated from README.Rmd. Please edit that file -->

# index

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/index/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/index/actions)
<!-- badges: end -->

The goal of `index` is to easily generate provenance records for common
workflows using [DCAT-2](https://www.w3.org/TR/vocab-dcat-2/) and
[PROV-O](https://www.w3.org/TR/prov-o/) ontologies, using the JSON-LD
serialization for semantic (RDF) data.

## Installation

You can install the released version of index from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("index")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/index")
```

## Quickstart

``` r
library(index)
```

We’ll use temporary files for illustration only (CRAN policy). Really
you would have paths to all these files (or URI identifiers for them).

``` r
input_data <- tempfile(fileext = ".csv")
output_data <- tempfile(fileext = ".csv")
code <- tempfile(fileext = ".R")
prov <- tempfile(fileext = ".json")
```

Here’s a minimal workflow that generates output data from input data:

``` r
out <- lm(mpg ~ disp, data = mtcars)

write.csv(mtcars, input_data)
write.csv(out$coefficients, output_data)
```

Let’s make a dummy `.R` script just for this example.

``` r
writeLines("out <- lm(mpg ~ disp, data = mtcars)", code)
```

We are now ready to stick the pieces together into a provenance record\!

``` r
write_prov(input_data, code, output_data, prov = prov)
```

Let’s take a look at the results:

``` r
cat(paste(readLines(prov), collapse = "\n"))
#> {
#>   "@context": {
#>     "dcat": "http://www.w3.org/ns/dcat#",
#>     "prov": "http://www.w3.org/ns/prov#",
#>     "dct": "http://purl.org/dc/terms/",
#>     "id": "@id",
#>     "type": "@type",
#>     "identifier": {
#>       "@id": "dct:identifier",
#>       "@type": "@id"
#>     },
#>     "title": "dct:title",
#>     "description": "dct:description",
#>     "issued": "dct:issued",
#>     "format": "dct:format",
#>     "license": {
#>       "@id": "dct:license",
#>       "@type": "@id"
#>     },
#>     "creator": "dct:creator",
#>     "compressFormat": "dcat:compressFormat",
#>     "byteSize": "dcat:byteSize",
#>     "wasGeneratedAtTime": "prov:wasGeneratedAtTime",
#>     "startedAtTime": "prov:startedAtTime",
#>     "endedAtTime": "prov:startedAtTime",
#>     "wasDerivedFrom": {
#>       "@id": "prov:wasDerivedFrom",
#>       "@type": "@id"
#>     },
#>     "wasGeneratedBy": {
#>       "@id": "prov:wasGeneratedBy",
#>       "@type": "@id"
#>     },
#>     "generated": {
#>       "@id": "prov:generated",
#>       "@type": "@id"
#>     },
#>     "used": {
#>       "@id": "prov:used",
#>       "@type": "@id"
#>     },
#>     "wasRevisionOf": {
#>       "@id": "prov:wasRevisionOf",
#>       "@type": "@id"
#>     },
#>     "isDocumentedBy": {
#>       "@id": "http://purl.org/spar/cito/isDocumentedBy",
#>       "@type": "@id"
#>     },
#>     "distribution": {
#>       "@id": "dcat:distribution",
#>       "@type": "@id"
#>     },
#>     "Dataset": "dcat:Dataset",
#>     "Activity": "prov:Activity",
#>     "Distribution": "dcat:Distribution",
#>     "SoftwareSourceCode": "http://schema.org/SoftwareSourceCode"
#>   },
#>   "@graph": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "Distribution",
#>       "identifier": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "title": "file35938ef1ec5.csv",
#>       "description": "Input data",
#>       "format": "text/csv",
#>       "byteSize": 1783,
#>       "wasGeneratedAtTime": "2020-09-05 00:29:07"
#>     },
#>     {
#>       "type": ["Distribution", "SoftwareSourceCode"],
#>       "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "identifier": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "title": "file35936bb0ee27.R",
#>       "description": "R code",
#>       "format": "application/R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "Distribution",
#>       "identifier": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "title": "file359377d62a1d.csv",
#>       "description": "output data",
#>       "format": "text/csv",
#>       "byteSize": 65,
#>       "wasGeneratedAtTime": "2020-09-05 00:29:07",
#>       "wasDerivedFrom": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "wasGeneratedBy": {
#>         "type": "Activity",
#>         "id": "urn:uuid:06708e28-e264-4587-8ec4-09d40d87968c",
#>         "description": "Running R script file35936bb0ee27.R",
#>         "used": ["hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5", "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"],
#>         "generated": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>         "endedAtTime": "2020-09-05 00:29:07"
#>       }
#>     }
#>   ]
#> }
```

If we include a `title`, these will be grouped as to group these into a
Dataset. We use `append=FALSE` to overwrite the previous record.

``` r
write_prov(input_data, code, output_data, prov = prov,
            title = "example dataset with provenance",  append= FALSE)
```

## Reproducible workflows

A key feature of content-based provenance trace is that we can run this
again and again: If we use the same data and get the same result, all
our objects have the same ID. By default, these repeated calls append
results to the `prov` file, but the only new data added indicates a new
`Activity` running the code at a different time, but generating the same
result.

``` r
out <- lm(mpg ~ disp, data = mtcars)
write.csv(mtcars, input_data)
write.csv(out$coefficients, output_data)
write_prov(input_data, code, output_data, prov = prov)


out <- lm(mpg ~ disp, data = mtcars)
write.csv(mtcars, input_data)
write.csv(out$coefficients, output_data)
write_prov(input_data, code, output_data, prov = prov)
```

``` r
cat(paste(readLines(prov), collapse = "\n"))
#> {
#>   "@context": {
#>     "dcat": "http://www.w3.org/ns/dcat#",
#>     "prov": "http://www.w3.org/ns/prov#",
#>     "dct": "http://purl.org/dc/terms/",
#>     "id": "@id",
#>     "type": "@type",
#>     "identifier": {
#>       "@id": "dct:identifier",
#>       "@type": "@id"
#>     },
#>     "title": "dct:title",
#>     "description": "dct:description",
#>     "issued": "dct:issued",
#>     "format": "dct:format",
#>     "license": {
#>       "@id": "dct:license",
#>       "@type": "@id"
#>     },
#>     "creator": "dct:creator",
#>     "compressFormat": "dcat:compressFormat",
#>     "byteSize": "dcat:byteSize",
#>     "wasGeneratedAtTime": "prov:wasGeneratedAtTime",
#>     "startedAtTime": "prov:startedAtTime",
#>     "endedAtTime": "prov:startedAtTime",
#>     "wasDerivedFrom": {
#>       "@id": "prov:wasDerivedFrom",
#>       "@type": "@id"
#>     },
#>     "wasGeneratedBy": {
#>       "@id": "prov:wasGeneratedBy",
#>       "@type": "@id"
#>     },
#>     "generated": {
#>       "@id": "prov:generated",
#>       "@type": "@id"
#>     },
#>     "used": {
#>       "@id": "prov:used",
#>       "@type": "@id"
#>     },
#>     "wasRevisionOf": {
#>       "@id": "prov:wasRevisionOf",
#>       "@type": "@id"
#>     },
#>     "isDocumentedBy": {
#>       "@id": "http://purl.org/spar/cito/isDocumentedBy",
#>       "@type": "@id"
#>     },
#>     "distribution": {
#>       "@id": "dcat:distribution",
#>       "@type": "@id"
#>     },
#>     "Dataset": "dcat:Dataset",
#>     "Activity": "prov:Activity",
#>     "Distribution": "dcat:Distribution",
#>     "SoftwareSourceCode": "http://schema.org/SoftwareSourceCode"
#>   },
#>   "@graph": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "Distribution",
#>       "description": "Input data",
#>       "format": "text/csv",
#>       "identifier": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "title": "file35938ef1ec5.csv",
#>       "byteSize": 1783,
#>       "wasGeneratedAtTime": "2020-09-05 00:29:07"
#>     },
#>     {
#>       "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "type": [
#>         "Distribution",
#>         "SoftwareSourceCode"
#>       ],
#>       "description": "R code",
#>       "format": "application/R",
#>       "identifier": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "title": "file35936bb0ee27.R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "Distribution",
#>       "description": "output data",
#>       "format": "text/csv",
#>       "identifier": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "title": "file359377d62a1d.csv",
#>       "byteSize": 65,
#>       "wasDerivedFrom": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "wasGeneratedAtTime": "2020-09-05 00:29:07",
#>       "wasGeneratedBy": [
#>         "urn:uuid:7c727777-8ce8-4b9d-9da4-6b9435a1990f",
#>         "urn:uuid:82b093b1-1543-40f5-b708-687f8de40715"
#>       ]
#>     },
#>     {
#>       "id": "urn:uuid:7c727777-8ce8-4b9d-9da4-6b9435a1990f",
#>       "type": "Activity",
#>       "description": "Running R script file35936bb0ee27.R",
#>       "generated": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "endedAtTime": "2020-09-05 00:29:07",
#>       "used": [
#>         "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       ]
#>     },
#>     {
#>       "id": "urn:uuid:82b093b1-1543-40f5-b708-687f8de40715",
#>       "type": "Activity",
#>       "description": "Running R script file35936bb0ee27.R",
#>       "generated": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "endedAtTime": "2020-09-05 00:29:07",
#>       "used": [
#>         "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       ]
#>     }
#>   ]
#> }
```
