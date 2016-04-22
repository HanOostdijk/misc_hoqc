# misc_hoqc
Miscellaneous examples of small projects. See my other repositories for more projects

Currently it contains these examples with R (and knitr and RMarkdown):

- postcode: shows how to use the Google Maps Geocoding API to get information about an address. The address can be a postal code and the information returned contains e.g. location, country and coordinates
- spatial1: shows how to select the information from a map-file that is needed for a map of a municipality and the municipalities that surround it. With this information a (ggplot2) map is made.
- spatial2: comparable with spatial2. Here a very detailed 'Kadaster' map is used with many layers to create a customized map of Amstelveen and Schiphol. Features: selection from and combining of map sheets. 
- odata_cbs: this entry (with text in Dutch) describes how to read data from the CBS (Statistics Netherlands, also known as the Dutch Central Bureau of Statistics) with the OData Protocol. 
- odata_cbs_plot: this entry also describes how to read data from the CBS with the OData Protocol. The data is merged with CBS map information to present the data in the form of a map.
- debug1: expands on an idea of John Mount that facilitates debugging of a function by saving the arguments at the time that it fails in an RDS file. 
- tedcsv : shows how to read the csv version of the TED database that contains records about European public procurement. It is a large file with embedded separators and sometimes a missing last field. Selected data is copied to a data.frame and from there to a Mongodb database. Examples of JSON queries on the database are included.
