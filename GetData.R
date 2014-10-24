library(XML)
library(jsonlite)
library(RCurl)
library(RSQLite)

generateDate<-function(start,end){
  date<-seq.Date(as.Date(start),as.Date(end),by="day")
  date<-as.character(date)
  return(date)
}

dates<-generateDate("2014/10/15","2014/10/16")





# save the data to SQLite database


GetSave<-function(){
  czceData<-czce(dates)
  cffexData<-cffex(dates)
  shfeData<-shfe(dates)
  dceData<-dce(dates)
  drive<-dbDriver("SQLite")
  futureDB<-dbConnect(drive,"futureDB.db")
  dbWriteTable(futureDB,"cffexData",cffexData)
  dbWriteTable(futureDB,"czceData",czceData)
  dbWriteTable(futureDB,"shfeData",shfeData)
  dbWriteTable(futureDB,"dceData",dceData)
  dbDisconnect(futureDB)
}
GetSave()

#sink ,logging ,log4r  

# get data from czce 
czce<-function(dates){
  part1<-"http://www.czce.com.cn/portal/exchange/"
  part2<-"/datadaily/"
  part3<-".txt"
  czceData<-data.frame()
  
  for(date in dates){
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
        data<-data[(data[,1]!="小计")&(data[,1]!="总计"),]
        data$date<-date
        names(data)<-c("品种月份","昨结算","今开盘","最高价","最低价","今收盘","今结算","涨跌1","涨跌2","成交量(手)","空盘量","增减量","成交额(万元)","交割结算价","日期")
        rownames(data)<-1:nrow(data)
        czceData<-rbind(czceData,data)
      }
    }
  }
  return(czceData)
}


# get data from cffex
cffex<-function(dates){
  part1<-"http://www.cffex.com.cn/fzjy/mrhq/"
  part2<-"/index.xml"
  cffexData<-data.frame()
  for(date in dates){
    date<-gsub("-","/",sub("-","",date))
    urlString<-paste0(part1,date,part2)
    conUrl<-try(xmlParse(urlString,isURL = TRUE), silent=TRUE ) 
    tryError <- inherits(conUrl, "try-error")
    if(tryError){
      next
    }
    else{
      dailyData<-xmlToDataFrame(urlString)
      cffexData<-rbind(cffexData,dailyData)
    }
  }
  return(cffexData)
  
  # another method instead of xmlToDataFrame
  #doc<-xmlTreeParse(Url,useInternal=TRUE)
  #top<-xmlRoot(doc)
  #numdaily<-length(names(top))
  #name<-names(top[[1]])
  #n<-length(name)
  #for(j in 1:numdaily){
  #  daily<-top[[j]]
  #  name<-names(daily)
  #  for(i in 1:n){
  #    name1<-name[i]
  #    #data[j,i]<-getvalue(name[i],j)
  #    data[j,i]<-xmlValue(top[[j]][[name1]])
  #  }
  #}
  #names(data)<-names(top[[1]])
}


# get data from shfe
shfe<-function(dates){
  part1<-"http://www.shfe.com.cn/data/dailydata/kx/kx"
  part2<-".dat"
  shfeData<-data.frame()
  for(date in dates){
    date<-gsub("-","",date)
    Urlstring<-paste0(part1,date,part2)
    dat<-readLines(con=Urlstring,encoding="UTF-8")
    jsData<-fromJSON(dat)
    if(nrow(jsData$o_curinstrument)==1){
      next
    }else
      shfeData<-rbind(shfeData,jsData$o_curinstrument)
  }
  return(shfeData)
}


# get data from dce
dce<-function(dates){
  part1<-"http://www.dce.com.cn/PublicWeb/MainServlet?action=Pu00012_download&Pu00011_Input.trade_date="
  part2<-"&Pu00011_Input.variety=all&Pu00011_Input.trade_type=0&Submit2=%CF%C2%D4%D8%CE%C4%B1%BE%B8%F1%CA%BD"
  dceData<-data.frame()
  
  for(date in dates){
    date<-gsub("-","",date)
    Url<-paste0(part1,date,part2)
    
    doc<-htmlTreeParse(Url,useInternal=TRUE)
    content<-xpathSApply(doc,"//p[@align='center']",xmlValue)
    
    
    if(class(content)=="character"){
      next
    }
    else{
      filename<-paste0("dce",date,".txt")
      if(!file.exists(filename)){
        download.file(Url,filename)
      }
      else{
        data<-read.table(filename,skip=3,sep=",",header=TRUE,fill=TRUE)
        #data<-data[(data[,1]!="小计")&(data[,1]!="总计"),]
        data$date<-date
        rownames(data)<-1:nrow(data)
        dceData<-rbind(dceData,data)
      }
    }
  }
  return(dceData)
}
