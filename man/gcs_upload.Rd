% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/upload.R
\name{gcs_upload}
\alias{gcs_upload}
\alias{gcs_upload_set_limit}
\title{Upload a file of arbitrary type}
\usage{
gcs_upload(
  file,
  bucket = gcs_get_global_bucket(),
  type = NULL,
  name = deparse(substitute(file)),
  object_function = NULL,
  object_metadata = NULL,
  predefinedAcl = c("private", "bucketLevel", "authenticatedRead",
    "bucketOwnerFullControl", "bucketOwnerRead", "projectPrivate", "publicRead",
    "default"),
  upload_type = c("simple", "resumable")
)

gcs_upload_set_limit(upload_limit = 5000000L)
}
\arguments{
\item{file}{data.frame, list, R object or filepath (character) to upload file}

\item{bucket}{bucketname you are uploading to}

\item{type}{MIME type, guessed from file extension if NULL}

\item{name}{What to call the file once uploaded. Default is the filepath}

\item{object_function}{If not NULL, a \code{function(input, output)}}

\item{object_metadata}{Optional metadata for object created via \link{gcs_metadata_object}}

\item{predefinedAcl}{Specify user access to object. Default is 'private'. Set to 'bucketLevel' for buckets with bucket level access enabled.}

\item{upload_type}{Override automatic decision on upload type}

\item{upload_limit}{Upload limit in bytes}
}
\value{
If successful, a metadata object
}
\description{
Upload up to 5TB
}
\details{
When using \code{object_function} it expects a function with two arguments:
\itemize{
  \item \code{input} The object you supply in file to write from
  \item \code{output} The filename you write to
 }


By default the \code{upload_type} will be 'simple' if under 5MB, 'resumable' if over 5MB.  Use \link{gcs_upload_set_limit} to modify this boundary - you may want it smaller on slow connections, higher on faster connections.
  'Multipart' upload is used if you provide a \code{object_metadata}.

If \code{object_function} is NULL and \code{file} is not a character filepath,
  the defaults are:

\itemize{
  \item file's class is \code{data.frame} - \link[utils]{write.csv}
  \item file's class is \code{list} - \link[jsonlite]{toJSON}
 }

If \code{object_function} is not NULL and \code{file} is not a character filepath,
  then \code{object_function} will be applied to the R object specified
  in \code{file} before upload. You may want to also use \code{name} to ensure the correct
  file extension is used e.g. \code{name = 'myobject.feather'}

If \code{file} or \code{name} argument contains folders e.g. \code{/data/file.csv} then
  the file will be uploaded with the same folder structure e.g. in a \code{/data/} folder.
Use \code{name} to override this.
}
\section{scopes}{


Requires scopes \code{https://storage.googleapis.com/auth/devstorage.read_write}
  or \code{https://storage.googleapis.com/auth/devstorage.full_control}
}

\examples{

\dontrun{

## set global bucket so don't need to keep supplying in future calls
gcs_global_bucket("my-bucket")

## by default will convert dataframes to csv
gcs_upload(mtcars)

## mtcars has been renamed to mtcars.csv
gcs_list_objects()

## to specify the name, use the name argument
gcs_upload(mtcars, name = "my_mtcars.csv")

## when looping, its best to specify the name else it will take
## the deparsed function call e.g. X[[i]]
my_files <- list.files("my_uploads")
lapply(my_files, function(x) gcs_upload(x, name = x))

## you can supply your own function to transform R objects before upload
f <- function(input, output){
  write.csv2(input, file = output)
}

gcs_upload(mtcars, name = "mtcars_csv2.csv", object_function = f)

# upload to a bucket with bucket level ACL set
gcs_upload(mtcars, predefinedAcl = "bucketLevel")

# modify boundary between simple and resumable uploads
# default 5000000L is 5MB
gcs_upload_set_limit(1000000L)
}



}
