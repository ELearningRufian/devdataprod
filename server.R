require(shiny)
require(quantmod)

BuyerGains<-function(Symbol, Expiration){
	OptionChain<-getOptionChain(Symbol, Exp=Expiration)
	CallStrike=OptionChain$calls$Strike
	PutStrike=OptionChain$puts$Strike
	CallOI=OptionChain$calls$OI
	PutOI=OptionChain$puts$OI
	## 1 contract = 100 shares, call value divided by 10000 => Millions of US$
	CallValue<-function(x){sum((CallStrike<x)*(x-CallStrike)*CallOI)/10000}
	PutValue<-function(x){sum((PutStrike>x)*(PutStrike-x)*PutOI)/10000}
	CallPutValue<-function(x){CallValue(x)+PutValue(x)}
	AllStrikes<-sort(unique(c(CallStrike,PutStrike)))
	## TODO: Detect minimum interval and insert "missing" strikes to generate an uniform series
	exp<-as.Date(substr(row.names(OptionChain$calls)[1], nchar(Symbol)+1,nchar(Symbol)+6),"%y%m%d")
	data.frame(strike=AllStrikes,
			puts=sapply(AllStrikes,PutValue),
			calls=sapply(AllStrikes,CallValue),
			expiration=rep_len(exp,length(AllStrikes)))  
}

shinyServer(
	function(input,output) {
		buyerGains<-reactive({BuyerGains(Symbol=input$symbol, Expiration=input$expirationDate)})
		output$expirationDate <- renderPrint({input$expirationDate})
		output$symbol <- renderPrint({input$symbol})
		output$mpval<-renderPrint({buyerGains()[,1][which.min(buyerGains()[,2]+buyerGains()[,3])]})
		output$plot<-renderPlot(
			{try(barplot(t(data.matrix(buyerGains()[2:3])),
				col=c("red","green"),
				main="Buyer Gains",
				names.arg=buyerGains()[,1],
				xlab="Stock price at expiration in US$",
				ylab="Millions of US$",
				legend.text=c("Put buyers' gain","Call buyers' gain")),
			silent=TRUE)})
	}
)