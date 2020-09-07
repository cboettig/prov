
<!-- README.md is generated from README.Rmd. Please edit that file -->

# prov

<!-- badges: start -->

[![R build
status](https://github.com/cboettig/prov/workflows/R-CMD-check/badge.svg)](https://github.com/cboettig/prov/actions)
<!-- badges: end -->

The goal of `prov` is to easily generate provenance records for common
workflows using [DCAT-2](https://www.w3.org/TR/vocab-dcat-2/) and
[PROV-O](https://www.w3.org/TR/prov-o/) ontologies, using the JSON-LD
serialization for semantic (RDF) data.

## Installation

You can install the released version of `prov` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("prov")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/prov")
```

## Quickstart

``` r
library(prov)
```

We’ll use temporary files for illustration only (CRAN policy). Really
you would have paths to all these files (or URI identifiers for them).

``` r
input_data <- tempfile(fileext = ".csv")
output_data <- tempfile(fileext = ".csv")
code <- tempfile(fileext = ".R")
p <- tempfile(fileext = ".json")
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
write_prov(input_data, code, output_data, prov = p)
```

Let’s take a look at the results:

``` r
writeLines(readLines(p))
#> {
#>   "@context": {
#>     "dcat": "http://www.w3.org/ns/dcat#",
#>     "prov": "http://www.w3.org/ns/prov#",
#>     "dct": "http://purl.org/dc/terms/",
#>     "sdo": "http://schema.org/",
#>     "cito": "http://purl.org/spar/cito/",
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
#>     "mediaType": "dcat:mediaType",
#>     "keyword": "dcat:keyword",
#>     "theme": "dcat:theme",
#>     "modified": "dcat:modified",
#>     "downloadURL": "dcat:downloadURL",
#>     "publisher": {
#>       "@id": "dcat:publisher",
#>       "@type": "@id"
#>     },
#>     "contactPoint": {
#>       "@id": "dcat:contactPoint",
#>       "@type": "@id"
#>     },
#>     "spatial": {
#>       "@id": "dct:spatial",
#>       "@type": "@id"
#>     },
#>     "temporal": {
#>       "@id": "dct:temporal",
#>       "@type": "@id"
#>     },
#>     "license": {
#>       "@id": "dct:license",
#>       "@type": "@id"
#>     },
#>     "creator": {
#>       "@id": "dcat:creator",
#>       "@type": "@id"
#>     },
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
#>       "@id": "cito:isDocumentedBy",
#>       "@type": "@id"
#>     },
#>     "distribution": {
#>       "@id": "dcat:distribution",
#>       "@type": "@id"
#>     },
#>     "Dataset": "dcat:Dataset",
#>     "Activity": "prov:Activity",
#>     "Distribution": "dcat:Distribution",
#>     "SoftwareSourceCode": "sdo:SoftwareSourceCode"
#>   },
#>   "@graph": [
#>     [
#>       {
#>         "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "type": "Distribution",
#>         "identifier": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "title": "file5a1d4d5f0c43.csv",
#>         "description": "Input data",
#>         "format": "text/csv",
#>         "byteSize": 1783,
#>         "wasGeneratedAtTime": "2020-09-07 19:53:36"
#>       }
#>     ],
#>     [
#>       {
#>         "type": ["Distribution", "SoftwareSourceCode"],
#>         "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>         "identifier": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>         "title": "file5a1d6aebb312.R",
#>         "description": "R code",
#>         "format": "application/R"
#>       }
#>     ],
#>     [
#>       {
#>         "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>         "type": "Distribution",
#>         "identifier": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>         "title": "file5a1dd5bbaa6.csv",
#>         "description": "output data",
#>         "format": "text/csv",
#>         "byteSize": 65,
#>         "wasGeneratedAtTime": "2020-09-07 19:53:36",
#>         "wasDerivedFrom": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "wasGeneratedBy": {
#>           "type": "Activity",
#>           "id": "urn:uuid:2f2049d1-edb8-4a3a-b461-de035905a347",
#>           "description": "Running R script",
#>           "used": ["hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5", "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"],
#>           "generated": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>           "endedAtTime": "2020-09-07 19:53:36"
#>         }
#>       }
#>     ]
#>   ]
#> }
```

If we include a `title`, these will be grouped as to group these into a
Dataset. We use `append=FALSE` to overwrite the previous record.

``` r
write_prov(input_data, code, output_data, prov = p,
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
write_prov(input_data, code, output_data, prov = p)


out <- lm(mpg ~ disp, data = mtcars)
write.csv(mtcars, input_data)
write.csv(out$coefficients, output_data)
write_prov(input_data, code, output_data, prov = p)
```

``` r
writeLines(readLines(p))
#> {
#>   "@context": {
#>     "dcat": "http://www.w3.org/ns/dcat#",
#>     "prov": "http://www.w3.org/ns/prov#",
#>     "dct": "http://purl.org/dc/terms/",
#>     "sdo": "http://schema.org/",
#>     "cito": "http://purl.org/spar/cito/",
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
#>     "mediaType": "dcat:mediaType",
#>     "keyword": "dcat:keyword",
#>     "theme": "dcat:theme",
#>     "modified": "dcat:modified",
#>     "downloadURL": "dcat:downloadURL",
#>     "publisher": {
#>       "@id": "dcat:publisher",
#>       "@type": "@id"
#>     },
#>     "contactPoint": {
#>       "@id": "dcat:contactPoint",
#>       "@type": "@id"
#>     },
#>     "spatial": {
#>       "@id": "dct:spatial",
#>       "@type": "@id"
#>     },
#>     "temporal": {
#>       "@id": "dct:temporal",
#>       "@type": "@id"
#>     },
#>     "license": {
#>       "@id": "dct:license",
#>       "@type": "@id"
#>     },
#>     "creator": {
#>       "@id": "dcat:creator",
#>       "@type": "@id"
#>     },
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
#>       "@id": "cito:isDocumentedBy",
#>       "@type": "@id"
#>     },
#>     "distribution": {
#>       "@id": "dcat:distribution",
#>       "@type": "@id"
#>     },
#>     "Dataset": "dcat:Dataset",
#>     "Activity": "prov:Activity",
#>     "Distribution": "dcat:Distribution",
#>     "SoftwareSourceCode": "sdo:SoftwareSourceCode"
#>   },
#>   "@graph": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "Distribution",
#>       "description": "Input data",
#>       "format": "text/csv",
#>       "identifier": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "title": "file5a1d4d5f0c43.csv",
#>       "byteSize": 1783,
#>       "wasGeneratedAtTime": "2020-09-07 19:53:37"
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
#>       "title": "file5a1d6aebb312.R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "Distribution",
#>       "description": "output data",
#>       "format": "text/csv",
#>       "identifier": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "title": "file5a1dd5bbaa6.csv",
#>       "byteSize": 65,
#>       "wasDerivedFrom": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "wasGeneratedAtTime": "2020-09-07 19:53:37",
#>       "wasGeneratedBy": [
#>         "urn:uuid:1e200059-6254-4b22-a1ae-fff535cb36b3",
#>         "urn:uuid:9fc1e821-8863-4e08-b7ef-84d52cb75123"
#>       ]
#>     },
#>     {
#>       "id": "urn:uuid:1e200059-6254-4b22-a1ae-fff535cb36b3",
#>       "type": "Activity",
#>       "description": "Running R script",
#>       "generated": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "endedAtTime": "2020-09-07 19:53:37",
#>       "used": [
#>         "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       ]
#>     },
#>     {
#>       "id": "urn:uuid:9fc1e821-8863-4e08-b7ef-84d52cb75123",
#>       "type": "Activity",
#>       "description": "Running R script",
#>       "generated": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "endedAtTime": "2020-09-07 19:53:37",
#>       "used": [
#>         "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       ]
#>     }
#>   ]
#> }
```

## Schema.org compatibility

Schema Dot Org (`sdo`) `Dataset`, used in [Google Dataset
Search](https://datasetsearch.research.google.com/), is based upon the
DCAT `Dataset` concept, and many terms can
[crosswalk](https://www.w3.org/TR/vocab-dcat-2/#dcat-sdo) directly
between DCAT2 and <http://schema.org> namespaces. `prov` allows
conversion between DCAT2 and Schema.org representation using an
alternative context. We are not aware of a mapping for most PROV-O
terms, but have based the mapping around translating `prov:Activity` to
`sdo:Action`, `prov:used` to `sdo:object`, and `prov:generated` to
`sdo:result`.

``` r
to_sdo(p)
#> {
#>   "@context": "http://schema.org/",
#>   "@graph": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "DataDownload",
#>       "contentSize": 1783,
#>       "dateCreated": "2020-09-07 19:53:37",
#>       "description": "Input data",
#>       "encodingFormat": "text/csv",
#>       "identifier": {
#>         "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>       },
#>       "name": "file5a1d4d5f0c43.csv"
#>     },
#>     {
#>       "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "type": [
#>         "DataDownload",
#>         "SoftwareSourceCode"
#>       ],
#>       "description": "R code",
#>       "encodingFormat": "application/R",
#>       "identifier": {
#>         "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       },
#>       "name": "file5a1d6aebb312.R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "DataDownload",
#>       "contentSize": 65,
#>       "dateCreated": "2020-09-07 19:53:37",
#>       "description": "output data",
#>       "encodingFormat": "text/csv",
#>       "identifier": {
#>         "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       },
#>       "name": "file5a1dd5bbaa6.csv"
#>     },
#>     {
#>       "id": "urn:uuid:1e200059-6254-4b22-a1ae-fff535cb36b3",
#>       "type": "Action",
#>       "description": "Running R script",
#>       "endTime": "2020-09-07 19:53:37",
#>       "object": [
#>         {
#>           "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>         },
#>         {
#>           "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>         }
#>       ],
#>       "result": {
#>         "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       }
#>     },
#>     {
#>       "id": "urn:uuid:9fc1e821-8863-4e08-b7ef-84d52cb75123",
#>       "type": "Action",
#>       "description": "Running R script",
#>       "endTime": "2020-09-07 19:53:37",
#>       "object": [
#>         {
#>           "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>         },
#>         {
#>           "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>         }
#>       ],
#>       "result": {
#>         "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       }
#>     }
#>   ]
#> }
```
