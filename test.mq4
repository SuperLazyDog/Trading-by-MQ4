//+------------------------------------------------------------------+
//|                                                        test1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Xu Weida"
//#property link      "www.mql5.com"
#property version   "1.00"
#property strict
//パラメータ
extern int MagicNumber = 20170522;
extern double LOTS = 0.1;
//--------------------------------------------------------------------
//通貨ペア: USDJPY   時間足:Daily　 最大ポジ： 4 固定ロット数：0.1
//StopLoss:  MarketInfo(Symbol(), MODE_STOPLEVEL)
//--------------------------------------------------------------------
//+------------------------------------------------------------------+
//|                    customer property                             |
//+------------------------------------------------------------------+
//------------マクロ------------
#define CLOSE_BUY "Buy"
#define CLOSE_SELL "Sell"
#define CLOSE_PROFIT "Profit"
#define CLOSE_LOSS "Loss"
#define CLOSE_ALL "All"
//#define FIXED_LOTS 0.1//固定ロット数
#define FIXED_STOPLOSS 40 //　SL
#define FIXED_TAKEPROFIT 50 //TP

#define MARKET_INITIAL "INITIAL"
#define MARKET_RAISE "BUY"
#define MARKET_OSCILLATOR "OSCI"
#define MARKET_DOWN "SELL"
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
   iSetLabel("test3", "version 1.1", 5, 50, 8, "Verdana", Red);
   //printf("Close All");
   //iCloseOrders(CLOSE_BUY);
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
int buyPositionCount = 0;
int sellPositionCount = 0;
int preProfit;
struct SignalPro {
   string preSignal;
   string signal;
   bool isRise;
   bool isDown;
   int countFromRaise;
   int countFromDown;
};
SignalPro sig = {MARKET_INITIAL, MARKET_INITIAL, false, false, 0, 0};

void OnTick() {
   printf("SL: %d", MarketInfo(Symbol(), MODE_STOPLEVEL));
   //-------------------------------------------------
   //                    test
   //-------------------------------------------------
   //iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
   //iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
   //iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
   //iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
   //printf("OrderTotal: %d", OrdersTotal());
   //printf("this program OrderTotal: %d", getOrdersTotal());
   //printf("OrderTotal History: %d", OrdersHistoryTotal());
   if (OrdersTotal() == 50) {
      //iCloseOrders(CLOSE_ALL);
      count = 0;
   }
   //iOpenOrders(CLOSE_BUY, 0.1, 100, 100);
   //iDrawSign(CLOSE_BUY, Close[0]);
   //printf("barNum: %d", Bars(Symbol(), 0));
   /*if(count == 0) {
      printf("Open");
      iOpenOrders(CLOSE_BUY, 0.1, 100, 100);
      iDrawSign(CLOSE_BUY, Close[0]);
   }
   if(count == 8) {
      count = -2;
   }
   if(count == 4) {
      //printf("Close");
      //iCloseOrders(CLOSE_BUY);
      //count = -10000000;
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
   //-------------------------------------------------
   //                  label set
   //-------------------------------------------------
   iSetLabel("main1", "Price: " + DoubleToStr(Close[0], 3), 5, 65, 8, "Verdana", Red);
   iSetLabel("main2", "----------------------------------------------", 5, 80, 8, "Verdana", Yellow);
   iSetLabel("main3", "AccoutEquity: " + DoubleToStr(AccountEquity(), 3), 5, 95, 8, "Verdana", Red);
   //iSetLabel("main4", "version 1.0", 5, 95, 8, "Verdana", Red);
}

//+------------------------------------------------------------------+
//|                         オーダー関数                          
//+------------------------------------------------------------------+
//--------------------------------------------
//               ロウソクの更新をチェック
//--------------------------------------------
struct barsPro {
   int preBars;
   int bars;
} bars = {0, 0};

bool isBarsUpdated() {
   bool outTemp;
   bars.bars = Bars(Symbol(), 0);
   outTemp = bars.bars > bars.preBars ? true:false;
   bars.preBars = bars.bars;
   return outTemp;
}
//--------------------------------------------
//             オーダーの総数をチェック  
//--------------------------------------------
struct OrderCount {
   int orderNum;
} numTemp = {0};
int getOrdersTotal() {
   int orderIndex;
   numTemp.orderNum = 0;
   for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
      if (OrderMagicNumber() == MagicNumber) {
         numTemp.orderNum++;
      }   
   }
   return numTemp.orderNum++;
}            
//--------------------------------------------
//                 ポジを開く
//--------------------------------------------
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
      ticket = OrderSend(Symbol(), OP_BUY, myLots, Ask, int(mySpread), buyStopLoss, buyTakeProfit, "", MagicNumber);
      iDrawSign(CLOSE_BUY, Close[0]);
   }
   if(myType == "Sell") {
      ticket = OrderSend(Symbol(), OP_SELL, myLots, Bid, int(mySpread), sellStopLoss,sellTakeProfit, "", MagicNumber);
      iDrawSign(CLOSE_SELL, Close[0]);
   }
}

//--------------------------------------------
//               ポジを閉じる
//--------------------------------------------
void iCloseOrders(string myType) {
   bool resulTemp;
   int orderIndex;
   if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS) == false) {
      return;
   }
   //すべてのを閉じる
   if(myType == "All") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);  
      }
      printf("end to close all");
   }
   //買いポジションを閉じる
   if(myType == "Buy") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(OrderType() == OP_BUY) {
           resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
   }   

   //　売りポジションを閉じる
   if(myType == "Sell") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(OrderType() == OP_SELL) {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
   }
   
   //収益の上がるポジションを閉じる
   if(myType == "Profit") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(OrderProfit() > 0) {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }        
   }
   //損失をでるポジションを閉じる
   if(myType == "Loss") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(OrderProfit()<0) {
           resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      } 
   }             
}

//--------------------------------------------
//       特定条件を満たすポジションを閉じる
//--------------------------------------------
bool iCloseOrdersWith(string myType, bool isStopLoss, double max = 5, double min = 0) {
   int orderType = OP_SELLLIMIT;
   bool isAll = false;
   int orderIndex;
   bool temp;
   //引数のチェック
   if ((max <= min) || (max < 0) || (min < 0)) {
      printf("iCloseOrdersWith() error: wrong arguments");
      return false;
   }   
   //orderTypeを設定
   if (myType == CLOSE_BUY) {
      orderType = OP_BUY;
   } else if (myType == CLOSE_SELL) {
      orderType = OP_SELL;
   } else if (myType == CLOSE_ALL) {
      isAll = true;
   } else {
      printf("iCloseOrdersWith() error: unknown type");
      return false;
   }
   //ポジションを閉じる
   for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
      if (OrderSelect(orderIndex, SELECT_BY_POS)) {
         if (isStopLoss) {//SL
            if  (((OrderType() == orderType)||(isAll)) && (OrderProfit() < -min) && (OrderProfit() > -max)) {//(Buy or Sell) or All
               //printf("OrderProfit: %f", OrderProfit());
               temp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }else { //TP
            if  (((OrderType() == orderType)||(isAll)) && (OrderProfit() > min)&& (OrderProfit() < max)) {//(Buy or Sell) or All
               //printf("OrderProfit: %f", OrderProfit());
               temp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }   
      }
   }
   return true;
}

//+------------------------------------------------------------------+
//|                         プロパティ関数                          
//+------------------------------------------------------------------+
//--------------------------------------------
//                stopLoss
//--------------------------------------------
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
//--------------------------------------------
//                takeProfit
//--------------------------------------------

//--------------------------------------------
//                new lots
//--------------------------------------------


//--------------------------------------------
//            interval trade no
//--------------------------------------------
bool EAValid = false;
bool iTimeControl(int myStartHour, int myStartMinute, int myStopHour, int myStopMinute) {return false;}

//+------------------------------------------------------------------+
//|                        オブジェクト関数                          
//+------------------------------------------------------------------+
//--------------------------------------------
//                 label
//--------------------------------------------
void iSetLabel(string labelName, string labelDoc, int labelX, int labelY, int docSize, string docStyle, color docColor) {
   ObjectCreate(labelName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(labelName, labelDoc, docSize, docStyle, docColor);
   ObjectSet(labelName, OBJPROP_XDISTANCE, labelX);
   ObjectSet(labelName, OBJPROP_YDISTANCE, labelY);
}

//--------------------------------------------
//                  mark
//--------------------------------------------
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
//--------------------------------------------
//      Indicator line cross signal
//--------------------------------------------
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
//|                         インジケーター関数                          
//+------------------------------------------------------------------+
//---------------------------
//          iAC
//---------------------------
struct IAC {
   double iACValues[3];
   bool iACRaise;
   bool iACDown;
}; 
//---------------------------
//         Alligator
//---------------------------
struct Alligator {
   double jaw, teeth, lips;
   bool isRise, isDown;
   int staredTimeShort;//5
   int staredTimeMiddle;//15
   int staredTimeLong;//30
   bool gatorRise, gatorDown;
};


string getMarketSignal() {
   //----------------------------------------------------------------------
   //                            Alligator
   //----------------------------------------------------------------------
   //---------------------------
   //        Alligator
   //---------------------------
   Alligator alliTemp;
   alliTemp.jaw = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORJAW, 0);
   alliTemp.teeth = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORTEETH, 0);
   alliTemp.lips = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORLIPS, 0);
   //printf("jaw: %f, teeth: %f, lips: %f", jaw, teeth, lips); 
   //绿线>红线>蓝线，市场处于上涨阶段；
   //lip > teeth > jaw 　上昇トレンド
   alliTemp.gatorRise = (alliTemp.lips > alliTemp.teeth) && (alliTemp.teeth > alliTemp.jaw);
   //绿线<红线<蓝线，市场处于下跌阶段；
   //lip < teeth < jaw 下降トレンド
   alliTemp.gatorDown =  (alliTemp.lips < alliTemp.teeth) && (alliTemp.teeth < alliTemp.jaw);
   //----------------------------------------------------------------------
   //                             iAC
   //----------------------------------------------------------------------
   //---------------------------
   //          iAC
   //---------------------------
   IAC iACTemp;
   iACTemp.iACValues[0] = iAC(NULL, 0, 0);
   iACTemp.iACValues[1] = iAC(NULL, 0, 1); 
   iACTemp.iACValues[2] = iAC(NULL, 0, 2);
   //上昇トレンド
   /*//如果在零点线之上，有两条绿色就可以做“买”单
   bool iACPlusRaise = (iACValues[0] > iACValues[1])&&(iACValues[1] > iACValues[2])&&(iACValues[1] > 0);//最新两条是绿且大于零，第三条不管。大胆做法
   //如果在零点线之下，有三条绿色就可以做“买”单
   bool iACMinusRaise = ((iACValues[0] > iACValues[1])&&(iACValues[1] > iACValues[2])&&(iACValues[2]>iAC(NULL, 0, 3))&&(iACValues[0] <0)); //最新三条为绿且小于零
   bool isIACRaise = iACPlusRaise | iACMinusRaise;
   //下降トレンド
   //如果在零点线之下，有两条红色就可以做“卖”单
   bool iACMinusDown = (iACValues[0] < iACValues[1]) && (iACValues[1] < iACValues[2]) && (iACValues[1] < 0); //最新两条红且小于零
   //如果在零点线之上，有三条红色就可以做“卖”单
   bool iACPlusDown = (iACValues[0] < iACValues[1])&&(iACValues[1] < iACValues[2])&&(iACValues[2] < iAC(NULL, 0, 3))&&(iACValues[0] > 0);//最新三条红色且大于零
   bool isIACDown = iACPlusDown | iACMinusDown;*/
   //上升趋势
   //>0递增
   iACTemp.iACRaise = (iACTemp.iACValues[1] > 0) && (iACTemp.iACValues[1] < iACTemp.iACValues[0]);
   //<0递增   回调
   
   //下降趋势
   //>0递减   回调
   //<0递减
   iACTemp.iACDown = (iACTemp.iACValues[2] < 0) && (iACTemp.iACValues[2] > iACTemp.iACValues[1]) && (iACTemp.iACValues[1] > iACTemp.iACValues[0]);
   //----------------------------------------------------------------------
   //                           func Pro
   //----------------------------------------------------------------------
   string outtemp = MARKET_OSCILLATOR;
   if(alliTemp.gatorRise && iACTemp.iACRaise) {//Buy
      outtemp = MARKET_RAISE;
   }else if(alliTemp.gatorDown && iACTemp.iACDown) { //Sell
      outtemp = MARKET_DOWN;
   }
   return outtemp;
}
//+------------------------------------------------------------------+
