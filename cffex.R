# cffex
cffexData<-xmlparse("201410/20")


xmlparse<-function(date){
  library(XML)
  part1<-"http://www.cffex.com.cn/fzjy/mrhq/"
  part2<-"/index.xml"
  Url<-paste0(part1,date,part2)
  
  doc<-xmlTreeParse(Url,useInternal=TRUE)
  top<-xmlRoot(doc)
  numdaily<-length(names(top))
  name<-names(top[[1]])
  n<-length(name)
  data<-data.frame()
  
  for(j in 1:numdaily){
    daily<-top[[j]]
    name<-names(daily)
    for(i in 1:n){
      name1<-name[i]
      #data[j,i]<-getvalue(name[i],j)
      data[j,i]<-xmlValue(top[[j]][[name1]])
    }
  }
  names(data)<-names(top[[1]])
  return(data)
}
getvalue<-function(name,j){
  return(xmlValue(top[[j]][[name]]))
}



library(RSQLite)
drive<-dbDriver("SQLite")
cffexdb<-dbConnect(drive,"cffex.db")
dbListTables(cffexdb)
dbListFields(cffexdb,"cffexData")

dbWriteTable(cffexdb,"cffexData",cffexData)
dbDisconnect(exampledb)

sql<-"select * from cffexData"
cffexData<-dbSendQuery(cffexdb,sql)
chunk<-fetch(cffexData)
dim(chunk)

dbColumnInfo(cffexData)
dbGetStatement(cffexData)
dbGetRowCount(cffexData)
dbClearResult(cffexData)







# tryCatch(curlPerform(url = "http://www.cffex.com.cn/fzjy/mrhq/201410/19/index.xml"),
#         COULDNT_RESOLVE_HOST = function(x) cat("resolve problem\n"),
#         error = function(x) cat(class(x), "got it\n"))


