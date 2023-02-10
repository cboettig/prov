
<!-- README.md is generated from README.Rmd. Please edit that file -->

# prov

<!-- badges: start -->

[![R-CMD-check](https://github.com/cboettig/prov/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cboettig/prov/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`prov` lets you easily generate provenance records for common workflows
using [DCAT-2](https://www.w3.org/TR/vocab-dcat-2/) and
[PROV-O](https://www.w3.org/TR/prov-o/) ontologies, using the JSON-LD
serialization for semantic (RDF) data.

### Motivation

The goal of `prov` is to provide an index for automated workflows which
use content-based storage. Storing data using a content-based system
provides a convenient mechanism for data management: every unique
version is automatically stored. Running the workflow repeatedly and
generating identical results creates the same output file, but different
results create different output. A simple implementation of such a
system is to name each file based on the SHA-256 hash of its contents.
The downside of content-based storage is that it can easily become
difficult to keep track of what’s what. `prov` provides a metadata
record to step into that gap. `prov` provides a relatively high-level
description of what scripts and what input data produced what results.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

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

We are now ready to stick the pieces together into a provenance record!

``` r
write_prov(input_data, code, output_data, prov = p)
```

Let’s take a look at the results:

``` r
writeLines(readLines(p))
#> {
#>   "@context": "http://schema.org/",
#>   "@graph": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "DataDownload",
#>       "identifier": [
#>         ["hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"],
#>         ["hash://md5/6463474bfe6973a81dc7cbc4a71e8dd1"]
#>       ],
#>       "name": "file1f931a6c548143.csv",
#>       "description": "Input data",
#>       "encodingFormat": "text/csv",
#>       "contentSize": 1783,
#>       "dateCreated": "2023-02-10"
#>     },
#>     {
#>       "type": ["DataDownload", "SoftwareSourceCode"],
#>       "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "identifier": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "name": "file1f931a6840b2cf.R",
#>       "description": "R code",
#>       "encodingFormat": "application/R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "DataDownload",
#>       "identifier": [
#>         ["hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"],
#>         ["hash://md5/08cbbf8dd1ac01cb2d2c5c708055de33"]
#>       ],
#>       "name": "file1f931a744df9e.csv",
#>       "description": "output data",
#>       "encodingFormat": "text/csv",
#>       "contentSize": 65,
#>       "dateCreated": "2023-02-10"
#>     },
#>     {
#>       "type": "Action",
#>       "id": "urn:uuid:3518cf5a-30e6-40eb-9cd8-d390217ae9d9",
#>       "description": "Running R script",
#>       "object": ["hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5", "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"],
#>       "result": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "endTime": "2023-02-10 22:43:49"
#>     }
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
write_prov(title = "An example dataset",
           input_data, code, output_data, prov = p)
```

Note that if `write_prov` gets neither a title, description, or creator,
it will not generate a Dataset element, but instead serialize a `graph`
of individual `distribution` objects.

``` r
writeLines(readLines(p))
#> [
#>   {
#>     "@id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>     "http://schema.org/contentSize": [
#>       {
#>         "@value": "1783",
#>         "@type": "http://www.w3.org/2001/XMLSchema#integer"
#>       }
#>     ],
#>     "http://schema.org/dateCreated": [
#>       {
#>         "@value": "2023-02-10",
#>         "@type": "http://schema.org/Date"
#>       }
#>     ],
#>     "http://schema.org/description": [
#>       {
#>         "@value": "Input data"
#>       }
#>     ],
#>     "http://schema.org/encodingFormat": [
#>       {
#>         "@value": "text/csv"
#>       }
#>     ],
#>     "http://schema.org/identifier": [
#>       {
#>         "@value": "hash://md5/6463474bfe6973a81dc7cbc4a71e8dd1"
#>       },
#>       {
#>         "@value": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>       }
#>     ],
#>     "http://schema.org/name": [
#>       {
#>         "@value": "file1f931a6c548143.csv"
#>       }
#>     ],
#>     "@type": [
#>       "http://schema.org/DataDownload"
#>     ]
#>   },
#>   {
#>     "@id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>     "http://schema.org/description": [
#>       {
#>         "@value": "R code"
#>       }
#>     ],
#>     "http://schema.org/encodingFormat": [
#>       {
#>         "@value": "application/R"
#>       }
#>     ],
#>     "http://schema.org/identifier": [
#>       {
#>         "@value": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       }
#>     ],
#>     "http://schema.org/name": [
#>       {
#>         "@value": "file1f931a6840b2cf.R"
#>       }
#>     ],
#>     "@type": [
#>       "http://schema.org/DataDownload",
#>       "http://schema.org/SoftwareSourceCode"
#>     ]
#>   },
#>   {
#>     "@id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>     "http://schema.org/contentSize": [
#>       {
#>         "@value": "65",
#>         "@type": "http://www.w3.org/2001/XMLSchema#integer"
#>       }
#>     ],
#>     "http://schema.org/dateCreated": [
#>       {
#>         "@value": "2023-02-10",
#>         "@type": "http://schema.org/Date"
#>       }
#>     ],
#>     "http://schema.org/description": [
#>       {
#>         "@value": "output data"
#>       }
#>     ],
#>     "http://schema.org/encodingFormat": [
#>       {
#>         "@value": "text/csv"
#>       }
#>     ],
#>     "http://schema.org/identifier": [
#>       {
#>         "@value": "hash://md5/08cbbf8dd1ac01cb2d2c5c708055de33"
#>       },
#>       {
#>         "@value": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       }
#>     ],
#>     "http://schema.org/name": [
#>       {
#>         "@value": "file1f931a744df9e.csv"
#>       }
#>     ],
#>     "@type": [
#>       "http://schema.org/DataDownload"
#>     ]
#>   },
#>   {
#>     "@id": "urn:uuid:61195c48-f67e-4b53-9ed6-b501c663cc9b",
#>     "http://schema.org/dateCreated": [
#>       {
#>         "@value": "2023-02-10",
#>         "@type": "http://schema.org/Date"
#>       }
#>     ],
#>     "http://schema.org/distribution": [
#>       {
#>         "@id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>       },
#>       {
#>         "@id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       },
#>       {
#>         "@id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       },
#>       {
#>         "@id": "urn:uuid:e781eef5-798f-42b3-8cea-c73bd7c636cc"
#>       }
#>     ],
#>     "http://schema.org/license": [
#>       {
#>         "@id": "https://creativecommons.org/publicdomain/zero/1.0/legalcode"
#>       }
#>     ],
#>     "http://schema.org/name": [
#>       {
#>         "@value": "An example dataset"
#>       }
#>     ],
#>     "@type": [
#>       "http://schema.org/Dataset"
#>     ]
#>   },
#>   {
#>     "@id": "urn:uuid:80450a4f-5962-4458-be45-19076eca7deb",
#>     "http://schema.org/description": [
#>       {
#>         "@value": "Running R script"
#>       }
#>     ],
#>     "http://schema.org/endTime": [
#>       {
#>         "@value": "2023-02-10 22:43:49"
#>       }
#>     ],
#>     "http://schema.org/object": [
#>       {
#>         "@value": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>       },
#>       {
#>         "@value": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       }
#>     ],
#>     "http://schema.org/result": [
#>       {
#>         "@value": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       }
#>     ],
#>     "@type": [
#>       "http://schema.org/Action"
#>     ]
#>   },
#>   {
#>     "@id": "urn:uuid:e781eef5-798f-42b3-8cea-c73bd7c636cc",
#>     "http://schema.org/description": [
#>       {
#>         "@value": "Running R script"
#>       }
#>     ],
#>     "http://schema.org/endTime": [
#>       {
#>         "@value": "2023-02-10 22:43:49"
#>       }
#>     ],
#>     "http://schema.org/object": [
#>       {
#>         "@value": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"
#>       },
#>       {
#>         "@value": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       }
#>     ],
#>     "http://schema.org/result": [
#>       {
#>         "@value": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>       }
#>     ],
#>     "@type": [
#>       "http://schema.org/Action"
#>     ]
#>   }
#> ]
```

## Schema.org compatibility

We can generate provenance data directly in Schema.org Dataset by
setting the optional `schema` argument when writing to JSON-LD:

``` r
write_prov(title = "An example dataset",
           creator = list(givenName = "John", familyName = "Public"),
           input_data, code, output_data, prov = p,
           schema = "http://schema.org", append = FALSE)
```

Note that `creator` must be given a named list with appropriate
schema.org elements, as it is uninterpreted.

``` r
writeLines(readLines(p))
#> {
#>   "@context": "http://schema.org/",
#>   "type": "Dataset",
#>   "id": "urn:uuid:14937019-8579-40ab-a8a2-f2673988678c",
#>   "name": "An example dataset",
#>   "creator": {
#>     "givenName": "John",
#>     "familyName": "Public"
#>   },
#>   "dateCreated": "2023-02-10",
#>   "license": "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
#>   "distribution": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "DataDownload",
#>       "identifier": [
#>         ["hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5"],
#>         ["hash://md5/6463474bfe6973a81dc7cbc4a71e8dd1"]
#>       ],
#>       "name": "file1f931a6c548143.csv",
#>       "description": "Input data",
#>       "encodingFormat": "text/csv",
#>       "contentSize": 1783,
#>       "dateCreated": "2023-02-10"
#>     },
#>     {
#>       "type": ["DataDownload", "SoftwareSourceCode"],
#>       "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "identifier": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "name": "file1f931a6840b2cf.R",
#>       "description": "R code",
#>       "encodingFormat": "application/R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "DataDownload",
#>       "identifier": [
#>         ["hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"],
#>         ["hash://md5/08cbbf8dd1ac01cb2d2c5c708055de33"]
#>       ],
#>       "name": "file1f931a744df9e.csv",
#>       "description": "output data",
#>       "encodingFormat": "text/csv",
#>       "contentSize": 65,
#>       "dateCreated": "2023-02-10"
#>     },
#>     {
#>       "type": "Action",
#>       "id": "urn:uuid:383160c8-69b9-4cac-baf0-45e8532c716e",
#>       "description": "Running R script",
#>       "object": ["hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5", "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"],
#>       "result": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "endTime": "2023-02-10 22:43:49"
#>     }
#>   ]
#> }
```

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
#>   "id": "urn:uuid:14937019-8579-40ab-a8a2-f2673988678c",
#>   "type": "Dataset",
#>   "creator": {
#>     "familyName": "Public",
#>     "givenName": "John"
#>   },
#>   "dateCreated": "2023-02-10",
#>   "distribution": [
#>     {
#>       "id": "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>       "type": "DataDownload",
#>       "contentSize": 1783,
#>       "dateCreated": "2023-02-10",
#>       "description": "Input data",
#>       "encodingFormat": "text/csv",
#>       "identifier": [
#>         "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "hash://md5/6463474bfe6973a81dc7cbc4a71e8dd1"
#>       ],
#>       "name": "file1f931a6c548143.csv"
#>     },
#>     {
#>       "id": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "type": [
#>         "DataDownload",
#>         "SoftwareSourceCode"
#>       ],
#>       "description": "R code",
#>       "encodingFormat": "application/R",
#>       "identifier": "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393",
#>       "name": "file1f931a6840b2cf.R"
#>     },
#>     {
#>       "id": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>       "type": "DataDownload",
#>       "contentSize": 65,
#>       "dateCreated": "2023-02-10",
#>       "description": "output data",
#>       "encodingFormat": "text/csv",
#>       "identifier": [
#>         "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51",
#>         "hash://md5/08cbbf8dd1ac01cb2d2c5c708055de33"
#>       ],
#>       "name": "file1f931a744df9e.csv"
#>     },
#>     {
#>       "id": "urn:uuid:383160c8-69b9-4cac-baf0-45e8532c716e",
#>       "type": "Action",
#>       "description": "Running R script",
#>       "endTime": "2023-02-10 22:43:49",
#>       "object": [
#>         "hash://sha256/439ba335c3d28dd0c1871f75bdffb389d5a3b23cf703275566700140c9523ae5",
#>         "hash://sha256/47a2e3f96b221143081d31624d423a611e36d6e063815fdd3768fddc2ede8393"
#>       ],
#>       "result": "hash://sha256/ce976335aa3d8b10e86bac4ed23424d4b1f87096484b76051c58be16a40a2d51"
#>     }
#>   ],
#>   "license": "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
#>   "name": "An example dataset"
#> }
```
