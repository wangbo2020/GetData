# czce
getwd()
date2014<-generateDate("2014/10/1","2014/10/19")

data2014<-getData(date2014)

#generate date from start to end
generateDate<-function(start,end){
  date<-seq.Date(as.Date(start),as.Date(end),by="day")
  date<-as.character(date)
  return(date)
}


#get the czce data 

getData<-function(date2014){
  library(RCurl)
  part1<-"http://www.czce.com.cn/portal/exchange/"
  part2<-"/datadaily/"
  part3<-".txt"
  czceData<-data.frame()
  
  for(date in date2014){
  ##http://www.czce.com.cn/portal/exchange/2014/datadaily/20140930.txt
  date<-gsub("-","",date)
  year<-substr(date,1,4)
  Url<-paste0(part1,year,part2,date,part3)
  
    if(!url.exists(Url)){
      next
    }
    else{
      filename<-paste0("czce",date,".txt")
      if(!file.exists(filename)){
        download.file(Url,filename)
      }
      else{
      data<-read.table(filename,skip=1,sep=",")
      data<-data[(data[,1]!="С��")&(data[,1]!="�ܼ�"),]
      data$date<-date
      names(data)<-c("Ʒ���·�","�����","����","��߼�","��ͼ�","������","�����","�ǵ�1","�ǵ�2","�ɽ���(��)","������","������","�ɽ���(��Ԫ)","��������","����")
      rownames(data)<-1:nrow(data)
      czceData<-rbind(czceData,data)
      }
    }
  }
  return(czceData)
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




