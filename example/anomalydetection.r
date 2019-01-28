library("AnomalyDetection")
library("RCurl")
library("rjson")

handler <- function(fn,data,...) {
	args=(as.list(match.call()))

	str<-substr(data, 0, 8)
	if(str=='http:\\' || str =='https://')
	{
 			json_data <- fromJSON(getURL(data)) 
			json_data_frame <- as.data.frame(json_data)
			json_data_frame$value <- as.numeric(as.character(json_data_frame$value))
			data<-json_data_frame
	}
	



	args$fn<-NULL 
	args$data<-NULL
	args[[1]]<-data

 
  

		error<-""
		warning<-""
		
 		result = tryCatch(
 		{
			  if(fn=="AnomalyDetectionTs")
				{
					result <-  suppressWarnings(do.call('AnomalyDetectionTs', args) )

				}
				if(fn=="AnomalyDetectionVec")
				{
					result <-   suppressWarnings(do.call('AnomalyDetectionVec', args) )
				}
				return (result$anoms)
		}, 
		warning = function(w) 
		{
     		return (w) 
		}, 
		error = function(e) 
		{
			return (e)
 		}, 
 		finally = {

 		})



	return (result)


}

