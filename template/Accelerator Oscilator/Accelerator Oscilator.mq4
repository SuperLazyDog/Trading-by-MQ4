//+------------------------------------------------------------------+
//|                                                        test1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Xu Weida"
//#property link      "www.mql5.com"
#property version   "1.00"
#property strict
//--------------------------------------------------------------------
//　　　　　　　　　　　　　　　　最大ポジ： しばらくは制限なし 
//--------------------------------------------------------------------
//+------------------------------------------------------------------+
//|                    customer property                             |
//+------------------------------------------------------------------+
//------------マクロ------------
#define CLOSE_BUY "Buy"
#define CLOSE_SELL "Sell"
#define CLOSE_PROFIT "Profit"
#define CLOSE_LOSS "Loss"
#define FIXED_LOTS 0.1//固定ロット数
//------------定数------------



//------------変数------------
//double myLots = 0.0;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   printf("start test, remain: %d %s, %s, %f", AccountBalance(), AccountName(), AccountCurrency(), AccountFreeMargin());
   iSetLabel("test1", "Test1", 5, 20, 8, "Verdana", Red);
   string temp = IntegerToString(Year()) + "/" + IntegerToString(Month()) + "/" + IntegerToString(Day());
   iSetLabel("test2", temp, 5, 35, 8, "Verdana", Red);
   iSetLabel("test3", "version 1.0", 5, 50, 8, "Verdana", Red);
   printf("Close All");
   iCloseOrders(CLOSE_BUY);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---
   //------------------test機能-----------------------
   printf("end test");
   //-------------------------------------------------
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int count = 0;
//Accelerator Oscilator
double iACValues[3] = {};
int buyPositionCount = 0;
int sellPositionCount = 0;
int preProfit;
void OnTick() {
   //-------------------------------------------------
   //                  label set
   //-------------------------------------------------
   iSetLabel("main1", "Price: " + DoubleToStr(Close[0], 3), 5, 65, 8, "Verdana", Red);
   iSetLabel("main2", "----------------------------------------------", 5, 80, 8, "Verdana", Yellow);
   iSetLabel("main3", "AccoutEquity: " + DoubleToStr(AccountEquity(), 3), 5, 95, 8, "Verdana", Red);
   //iSetLabel("main4", "version 1.0", 5, 95, 8, "Verdana", Red);
   //-------------------------------------------------
   //                  ローカルプロパティ
   //-------------------------------------------------
   double myLots = 0.0;
   myLots = (AccountEquity()/MarketInfo(Symbol(), MODE_MARGINREQUIRED));
   int i;
   //iAC
   iACValues[0] = iAC(NULL, 0, 0);
   iACValues[1] = iAC(NULL, 0, 1); 
   iACValues[2] = iAC(NULL, 0, 2);
   
   
   
   
   //-------------------------------------------------
   //                    タスク
   //-------------------------------------------------
   //---------------------------
   //      处理已有订单
   //---------------------------
   int orderIndex = 0;
   const int allOrders = OrdersTotal();
   for (orderIndex = 0; orderIndex < allOrders; orderIndex++) {
      if (OrderSelect(orderIndex, SELECT_BY_POS)) {
          if  ((OrderProfit() < -5) && (OrderProfit() > -10)) {
            //printf("OrderProfit: %f", OrderProfit());
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
          }
          if  ((OrderProfit() > 0)&& (OrderProfit() > 5)) {
            //printf("OrderProfit: %f", OrderProfit());
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
          }
      }
   }
   //---------------------------
   //        开启买仓
   //---------------------------
   //如果在零点线之上，有两条绿色就可以做“买”单
   bool buyOverZeroWithTwoGreen = (iACValues[0] > iACValues[1])&&(iACValues[1] > iACValues[2])&&(iACValues[1] > 0);//　最新两条是绿且大于零，第三条不管。大胆做法
   //如果在零点线之下，有三条绿色就可以做“买”单
   bool buyBelowZeroWithThreeGreen = ((iACValues[0] > iACValues[1])&&(iACValues[1] > iACValues[2])&&(iACValues[2]>iAC(NULL, 0, 3))&&(iACValues[0] <0)); //最新三条为绿且小于零
   //执行开启买仓
   if (buyOverZeroWithTwoGreen||buyBelowZeroWithThreeGreen) {
      //关闭卖仓
      for (orderIndex = 0; orderIndex < allOrders; orderIndex++) {
         if (OrderSelect(orderIndex, SELECT_BY_POS)) {
            if  ((OrderProfit() < 0)&&(OrderProfit() > -10)&&(OrderType() == OP_SELL)) {
               OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
               sellPositionCount -= 1;
            }
         }
      }
      for (orderIndex = 0; orderIndex < OrdersTotal(); orderIndex++) {
         if (OrderSelect(orderIndex, SELECT_BY_POS)) {
            if (OrderType() == OP_BUY) {
               
            }
            if (OrderType() == OP_SELL) {
            }
         }
      }
      //发送订单  
      if (OrdersTotal() <= 2) {//(buyPositionCount + sellPositionCount < 4) {
         iOpenOrders(CLOSE_BUY, FIXED_LOTS, (int)MarketInfo(Symbol(), MODE_STOPLEVEL), 25); 
         buyPositionCount++;
      }
   }
   
   
   //---------------------------
   //        开启卖仓
   //---------------------------
   //如果在零点线之下，有两条红色就可以做“卖”单
   bool minusLoss = (iACValues[0] < iACValues[1]) && (iACValues[1] < iACValues[2]) && (iACValues[1] < 0); //最新两条红且小于零
   //如果在零点线之上，有三条红色就可以做“卖”单
   bool plusLoss = (iACValues[0] < iACValues[1])&&(iACValues[1] < iACValues[2])&&(iACValues[2] < iAC(NULL, 0, 3))&&(iACValues[0] > 0);//最新三条红色且大于零
   
   //执行开启卖仓·
   if (minusLoss||plusLoss) {
      //关闭买仓
      for (orderIndex = 0; orderIndex < allOrders; orderIndex++) {
         if (OrderSelect(orderIndex, SELECT_BY_POS)) {
            if  ((OrderProfit() < 0)&&(OrderProfit() > -10)&&(OrderType() == OP_BUY)) {
               OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
               buyPositionCount -= 1;
            }
         }
      }  
      //发送订单    
      if (OrdersTotal() <= 2) {//(buyPositionCount + sellPositionCount < 4) { 
         iOpenOrders(CLOSE_SELL, FIXED_LOTS, (int)MarketInfo(Symbol(), MODE_STOPLEVEL), 25);
         sellPositionCount++;
      }
      //iCloseOrders(CLOSE_BUY);
      //positionCount = 0;
   }
   
   //------------------test機能-----------------------
   /*if(count == 0) {
      printf("Open");
      iOpenOrders(CLOSE_BUY, 0.1, 100, 100);
      iDrawSign(CLOSE_BUY, Close[0]);
   }
   if(count == 4) {
      //printf("Close");
      //iCloseOrders(CLOSE_BUY);
      //count = -10000000;
      count = -50000000;
      printf("temp");
      printf("position: %d", OrdersTotal());
   }
   count++;*/
   /*printf("testing");
   printf("AccountEquity: %d", int(AccountEquity()));
   printf("AccountBalance: %d", int(AccountBalance()));
   printf("AccountName: %s", AccountName());
   printf("AccountCurrency: %s", AccountCurrency());
   printf("AccountFreeMargin: %d", int(AccountFreeMargin()));
   printf("Spread %f", MarketInfo(Symbol(), MODE_SPREAD));
   printf("myLots: %f", myLots);
   printf("EURJPY myLots: %f", AccountEquity()/MarketInfo("EURJPY", MODE_MARGINREQUIRED));*/
   //-------------------------------------------------
}

//+------------------------------------------------------------------+
//| customer function                                   |
//+------------------------------------------------------------------+
//------------------ポジを開く-------------------
void iOpenOrders(string myType, double myLots, int myStopLoss, int myTakeProfit) {
   double mySpread = MarketInfo(Symbol(), MODE_SPREAD); //今のスプレッドを取得
   int ticket;
   double buyStopLoss = Ask - myStopLoss*Point;
   double buyTakeProfit = Ask + myTakeProfit*Point;
   double sellStopLoss = Bid + myStopLoss*Point;
   double sellTakeProfit = Bid - myTakeProfit*Point;
   myLots = NormalizeDouble(myLots, 2);
   if(myStopLoss <= 0) {
      buyStopLoss = 0;
      sellStopLoss = 0;
   }
   if(myTakeProfit <= 0) {
      buyTakeProfit = 0;
      sellTakeProfit = 0;
   }
   if(myType == "Buy") {
      ticket = OrderSend(Symbol(), OP_BUY, myLots, Ask, int(mySpread), buyStopLoss, buyTakeProfit);
   }
   if(myType == "Sell") {
      ticket = OrderSend(Symbol(), OP_SELL, myLots, Bid, int(mySpread), sellStopLoss,sellTakeProfit);
   }
}

//-----------------ポジを閉じる-------------------
void iCloseOrders(string myType) {
   bool resulTemp;
   int CO_cnt;
   if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS) == false) {
      return;
   }
   //すべてのを閉じる
   if(myType == "All") {
      for(CO_cnt = OrdersTotal(); CO_cnt >= 0; CO_cnt--) {
         if(OrderSelect(CO_cnt, SELECT_BY_POS) == false) {
            continue;
         }else {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }   
      }
   }
   //買いポジションを閉じる
   if(myType == "Buy") {
      for(CO_cnt = OrdersTotal(); CO_cnt >= 0; CO_cnt--) {
         if(OrderSelect(CO_cnt, SELECT_BY_POS) == false) {
            continue;
         }else {
            if(OrderType() == OP_BUY) {
              resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }
      }
   }   

   //　売りポジションを閉じる
   if(myType == "Sell") {
      for(CO_cnt = OrdersTotal(); CO_cnt >= 0; CO_cnt--) {
         if(OrderSelect(OrderTicket(),SELECT_BY_POS) == false) {
            continue;
         }else {
            if(OrderType() == OP_SELL) {
               resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }
      }
   }
   
   //収益の上がるポジションを閉じる
   if(myType == "Profit") {
      for(CO_cnt = OrdersTotal(); CO_cnt >= 0; CO_cnt--) {
         if(OrderSelect(CO_cnt, SELECT_BY_POS) == false) {
            continue;
         }else {
            if(OrderProfit() > 0) {
               resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }
      }        
   }
   //損失をでるポジションを閉じる
   if(myType == "Loss") {
      for(CO_cnt = OrdersTotal(); CO_cnt >= 0; CO_cnt--) {
         if(OrderSelect(CO_cnt, SELECT_BY_POS) == false) {
            continue;
         }else {
            if(OrderProfit()<0) {
              resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }
      } 
   }             
}
//---------------stopLoss------------------
void iMoveStopLoss(int myStopLoss) {
   int mSLCnt;
   bool modifyTemp;
   if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS) == false){
      return;
   }
   if(OrdersTotal()>0){
      for(mSLCnt=OrdersTotal(); mSLCnt>=0; mSLCnt--){
         if(OrderSelect(mSLCnt, SELECT_BY_POS)==false){
            continue;
         }else{
            if(OrderProfit()>0&&OrderType()==OP_BUY&&((Close[0]-OrderStopLoss())>((2*myStopLoss)*Point))){
               modifyTemp = OrderModify(OrderTicket(), OrderOpenPrice(), Bid-Point*myStopLoss, OrderTakeProfit(), 0);
            }
            if(OrderProfit()>0&&OrderType()==OP_SELL&&((OrderStopLoss()-Close[0])>((2*myStopLoss)*Point))){
               modifyTemp = OrderModify(OrderTicket(), OrderOpenPrice(), Ask+Point*myStopLoss, OrderTakeProfit(),0);
            }
         }        
      }
   }
}   
//----------------new lots--------------------
//-----------interval trade no----------------
bool EAValid = false;
bool iTimeControl(int myStartHour, int myStartMinute, int myStopHour, int myStopMinute) {return false;}

//------------------label---------------------
void iSetLabel(string labelName, string labelDoc, int labelX, int labelY, int docSize, string docStyle, color docColor) {
   ObjectCreate(labelName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(labelName, labelDoc, docSize, docStyle, docColor);
   ObjectSet(labelName, OBJPROP_XDISTANCE, labelX);
   ObjectSet(labelName, OBJPROP_YDISTANCE, labelY);
}

//------------------mark----------------------
//red sell     green buy     red-green other
void iDrawSign(string mySignal, double myPrice) {
   if(mySignal == CLOSE_BUY) {
      ObjectCreate("BuyPoint-" + (string)Time[0], OBJ_ARROW_BUY, 0, Time[0], myPrice);
      ObjectSet("BuyPoint-" + (string)Time[0], OBJPROP_COLOR, Green);
      //ObjectSet("BuyPoint-" + (string)Time[0], OBJPROP_ARROWCODE, 241);
    }
    if(mySignal == CLOSE_SELL) {
      ObjectCreate("SellPoint-" + (string)Time[0], OBJ_ARROW_SELL, 0, Time[0], myPrice);
      ObjectSet("SellPoint-" + (string)Time[0], OBJPROP_COLOR, Red);
      //ObjectSet("SellPoint-" + (string)Time[0], OBJPROP_ARROWCODE, 242);
    }
    if(mySignal == "GreenMark") {
      ObjectCreate("GreenMark-" + (string)Time[0], OBJ_ARROW, 0, Time[0], myPrice);
    }
    if(mySignal == "RedMark") {
      ObjectCreate("RedMark-" + (string)Time[0], OBJ_ARROW, 0, Time[0], myPrice);
      ObjectSet("RedMark-" + (string)Time[0], OBJPROP_ARROWCODE, Red);
      ObjectSet("ReadMark-" + (string)Time[0], OBJPROP_ARROWCODE, 162);
    }
}

//--------Indicator line cross signal---------
string iCrossSignal(double myFast0, double mySlow0, double myFast1, double mySlow1) {
   string myCrossSignal = "N/A";
   if(myFast0 > mySlow0 && myFast1 <= mySlow1) {
      myCrossSignal = "UpCross";
   }
   if(myFast0 < mySlow0 && myFast1 >= mySlow1) {
      myCrossSignal = "DownCross";
   }
   return myCrossSignal;
}
//+------------------------------------------------------------------+
