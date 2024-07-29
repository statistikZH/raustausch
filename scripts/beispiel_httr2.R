# Install httr2 package if you haven't already
install.packages("httr2")

# Load the httr2 package
library(httr2)

# Base URL and endpoint
base_url <- 'https://ckan.opendata.swiss/api/3/action/'
endpoint <- 'organization_list'


# Make the GET request
response <- request(base_url) %>% 
  req_url_path_append(endpoint) %>% 
  req_perform()



# Parse the response body as JSON
response_body <- response %>%
  resp_body_json()
