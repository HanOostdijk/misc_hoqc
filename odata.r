
#library(knitr)
library(curl)
#library(magrittr)
library(XML)
#library(dplyr)
#library(xtable)

std_namespaces = c(ns="http://www.w3.org/2005/Atom",
  m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata",
  d="http://schemas.microsoft.com/ado/2007/08/dataservices") 


get_cbs_data <- function (root, query=NULL, save_file_name = NULL) {
  # query  = "?$format=atom&$filter=GeneesmiddelengroepATC eq '100000'"
  if (!is.null(query)) {
    f  = paste0(root,URLencode(query))
  } else{
    f  = root
  }
  r  = curl_fetch_memory(f)
  x  = rawToChar(r$content)
  doc = xmlParse(x,asText =T)
  if (!is.null(save_file_name)) {
    saveXML(doc, save_file_name)
  }
  return(doc)
}

get_cbs_table_info <- function(doc) {
  m1    = xpathSApply(doc,"//@href/..", 
    function(x) c(xmlValue(x), xmlAttrs(x)[["href"]]))
  hrefs = m1[2,]
  names(hrefs) =m1[1,]
  return(hrefs)
}

copy_table <- function (ti,  mt = NULL, query= NULL, save_XML = NULL) {
  n1 = paste0('temp_', names(ti))
  if (is.null(save_XML)) {
    save_file_name = NULL
  } else if (nchar(save_XML) == 0) {
    save_file_name = paste0(n1, '.xml')
  } else {
    save_file_name = save_XML
  }
  t1    = get_cbs_data(ti, query, save_file_name = save_file_name)
  if (is.null(mt))
    return(t1)
  t1d = mt(t1)
}

data_table_fun <- function(doc) {
  t1n <- xpathApply(doc,
    '//ns:entry[1]//m:properties[1]/d:*',
    xmlName,
    namespaces = std_namespaces)
  t1d  = xpathSApply(doc, '//m:properties/d:*',xmlValue)
  t1d  = as.data.frame(matrix(t1d, ncol = length(t1n), byrow = T),
    stringsAsFactors =F)
  names(t1d) = t1n
  return(t1d)
}

prop_table_fun <- function(doc) {
  m     = xpathSApply(doc, '//m:properties/d:*',
    function(x)
      c(
        xpathSApply(xmlParent(x), './d:ID', xmlValue, namespaces = std_namespaces),
        xmlName(x),
        xmlValue(x)
      ))
  # m matrix: r1 number; r2 field ; r3 value
  uf    = unique(m[2, ])
  # "ID" "Position" "ParentID" "Type" "Key" "Title" "Description" "ReleasePolicy"
  # "Datatype" "Unit" "Decimals" "Default"
  nc    = length(uf)
  nr    = 1+max(as.numeric(m[1, ]))
  m2 = matrix(rep('', nr * nc), nrow = nr, ncol = nc)
  for (i in 1:nr) {
    m3 = m[, m[1, ] == paste(i-1)] # counting origin=0
    ix = match(m3[2, ], uf)
    m2[i, ix] = m3[3, ]
  }
  colnames(m2) = uf
  rownames(m2) = 1:nr
  as.data.frame(m2,stringsAsFactors =F)
}

couple_data <- function(
  df,        # data.frame with coded dimensions (e.g. read by copy_table)
  dv,        # character vector with the names of the dimensions
  tv,        # character vector with the names of the topics
  table_list # named vector with urls of sub tables 
  # (e.g. read by get_cbs_table_info)
) {
  tt = df %>% 
    mutate_each_(funs(as.numeric),tv$Key)  #topics -> numeric
  for (dim in dv$Key)  {
    if (dim == c('RegioS') ) {
      tt = couple_data_dim(tt, table_list['RegioS'],keep_code=T) # link RegioS
    } else {
      tt = couple_data_dim(tt, table_list[dim],keep_code=F) # link other dimensions
    }
  }
  return(tt)
}

couple_data_dim <- function(tt, dsn, keep_code=F) {
  dim  = names(dsn)
  tab1 = copy_table(dsn, data_table_fun) %>%
    select(Key, Title) %>%
    rename_(.dots = setNames('Title', paste0(dim, '_decode')))
  by1  = c('Key') ; names(by1) = dim
  tt = tt %>%
    inner_join(tab1, by = by1) %>%
    rename_(.dots = setNames(dim, paste0(dim, '_coded'))) %>%
    rename_(.dots = setNames(paste0(dim, '_decode'), dim))
  if (keep_code == F) {
    tt = tt %>%
      select_(.dots = setdiff(names(.), paste0(dim, '_coded')))
  }
  return(tt)
}

topic_vars <- function(props) 
  props %>%
  filter(Type=='Topic') %>%
  select(Key)

dim_vars <- function(props) {
  props %>%
    filter(Type %in% c('Dimension','TimeDimension','GeoDimension')) %>%
    select(Key)
}

