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
extern int MagicNumber = 0xFFFFFFF;
extern double LOTS = 0.1;
//--------------------------------------------------------------------
//通貨ペア: USDJPY   時間足:Daily　 最大ポジ： 4 固定ロット数：0.1
//StopLoss:  MarketInfo(Symbol(), MODE_STOPLEVEL) 150
//--------------------------------------------------------------------
//+------------------------------------------------------------------+
//|                    customer property                             |
//+------------------------------------------------------------------+
//------------マクロ------------
//ポジションのタイプ
#define CLOSE_BUY "Buy"
#define CLOSE_SELL "Sell"
#define CLOSE_PROFIT "Profit"
#define CLOSE_LOSS "Loss"
#define CLOSE_ALL "All"
//#define FIXED_LOTS 0.1//固定ロット数
//SL, TP
#define FIXED_STOPLOSS 150//　SL
#define FIXED_TAKEPROFIT 180 //TP
//シグナルの種類
#define MARKET_INITIAL "INITIAL"
#define MARKET_RAISE "BUY"
#define MARKET_OSCILLATOR "OSCI"
#define MARKET_DOWN "SELL"
//トレンドの継続期間
#define INTERNAL_LENGTH_SHORT 2
#define INTERNAL_LENGTH_MIDDLE 5
#define INTERNAL_LENGTH_LONG 10
//------------定数------------



//------------変数------------
//double myLots = 0.0;

//+------------------------------------------------------------------+
//|                Expert initialization function                    |
//+------------------------------------------------------------------+
int OnInit() {
//---
   //-------------------------------------------------
   //                  入力のチェック
   //-------------------------------------------------
   if ((LOTS < MarketInfo(Symbol(), MODE_MINLOT)) || (LOTS > MarketInfo(Symbol(), MODE_MAXLOT))) {
      printf("Lots must be in range!");
      printf("Max Lots: %f", MarketInfo(Symbol(), MODE_MAXLOT));
      printf("Min Lots: %f", MarketInfo(Symbol(), MODE_MINLOT));
      return (INIT_FAILED);
   }
   //-------------------------------------------------
   //              ログメッセージとオブジェクト
   //------------------------------------------------- 
   printf("start test, remain: %d %s, %s, %f", AccountBalance(), AccountName(), AccountCurrency(), AccountFreeMargin());
   iSetLabel("test1", "Test1", 5, 20, 8, "Verdana", Red);
   string temp = IntegerToString(Year()) + "/" + IntegerToString(Month()) + "/" + IntegerToString(Day());
   iSetLabel("test2", temp, 5, 35, 8, "Verdana", Red);
   iSetLabel("test3", "version 1.1", 5, 50, 8, "Verdana", Red);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                Expert deinitialization function                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---
   //------------------test機能-----------------------
   //printf("end test");
   //-------------------------------------------------
}


//+------------------------------------------------------------------+
//|                      Expert tick function                        |
//+------------------------------------------------------------------+
int count = 0;
int buyPositionCount = 0;
int sellPositionCount = 0;
int preProfit;
void OnTick() {
   //iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
   /*iCloseOrders(CLOSE_ALL);
   iCloseOrdersWith(CLOSE_ALL, false, 55555, 0);*/
   //count++;
   //if (count == 1500) {
      //iCloseOrders(CLOSE_ALL);
   //}
   //printf("barNum: %d", Bars(Symbol(), 0));
   //-------------------------------------------------
   //                    test
   //-------------------------------------------------
   printf("OrderTotal: %d", OrdersTotal());
   printf("this program OrderTotal: %d", getOrdersTotal());
   printf("OrderTotal History: %d", OrdersHistoryTotal());
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
   //-------------------------------------------------
   //                    タスク
   //-------------------------------------------------
   //---------------------------
   //   すでにあるポジションをチェック
   //---------------------------
   sigProWithClose();
   iMoveStopLoss(FIXED_STOPLOSS);
   //---------------------------
   //        買ポジを開く
   //---------------------------
   if (sig.signal == MARKET_RAISE) {
      sig.isRise = true;
      sig.isDown = false;
      if ((getOrdersTotal() <= 4)&& isBarsUpdated()) {
         iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
         iDrawSign(CLOSE_BUY, Close[0]);
      }
   }
   //---------------------------
   //       売りポジを開く
   //---------------------------
   if (sig.signal == MARKET_DOWN) {
      sig.isRise = false;
      sig.isDown = true;
      if ((getOrdersTotal() <= 4)&& isBarsUpdated()) {
         iOpenOrders(CLOSE_SELL, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
         iDrawSign(CLOSE_SELL, Close[0]);
      }
   }
   
   /*if (sig.signal == MARKET_RAISE) {
      //売りポジを閉じる
      printf("close sell");
      iCloseOrders(CLOSE_SELL);
      iCloseOrdersWith(CLOSE_SELL, false, 1000, 0);
      iCloseOrdersWith(CLOSE_SELL, true, 10, 0);
   }else if (sig.signal == MARKET_DOWN) {
      //買いポジを閉じる
      printf("close buy");
      iCloseOrders(CLOSE_BUY);
      iCloseOrdersWith(CLOSE_BUY, false, 1000, 0);
      iCloseOrdersWith(CLOSE_BUY, true, 10, 0);
   }*/
}

//+------------------------------------------------------------------+
//|                      プロパティ関数                              
//+------------------------------------------------------------------+
//--------------------------------------------
//                stopLoss
//--------------------------------------------
void iMoveStopLoss(int myStopLoss) {
   int mSLCnt;
   bool modifyTemp;
   if (OrderSelect(OrdersTotal()-1, SELECT_BY_POS) == false){
      return;
   }
   if (OrdersTotal()>0){
      for (mSLCnt=OrdersTotal()-1; mSLCnt>=0; mSLCnt--){
         if (!OrderSelect(mSLCnt, SELECT_BY_POS)){
            continue;
         }
         if (OrderMagicNumber() != MagicNumber) {
            continue;
         }   
         if(OrderProfit()>0&&OrderType()==OP_BUY&&((Close[0]-OrderStopLoss())>((2*myStopLoss)*Point))){
            modifyTemp = OrderModify(OrderTicket(), OrderOpenPrice(), Bid-Point*myStopLoss, OrderTakeProfit(), 0);
         }
         
         if(OrderProfit()>0&&OrderType()==OP_SELL&&((OrderStopLoss()-Close[0])>((2*myStopLoss)*Point))){
            modifyTemp = OrderModify(OrderTicket(), OrderOpenPrice(), Ask+Point*myStopLoss, OrderTakeProfit(),0);
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
//|                        シグナル関数                             
//+------------------------------------------------------------------+

struct SignalPro {
   string preSignal;
   string signal;
   bool isRise;
   bool isDown;
   int countFromRaise;
   int countFromDown;
};
SignalPro sig = {MARKET_INITIAL, MARKET_INITIAL, false, false, 0, 0};
void sigProWithClose() {
   //　シグナルの取得
   sig.signal = getMarketSignal();
   printf("signal %s", sig.signal);
   //シグナル構造体の処理
   if (sig.signal == MARKET_DOWN) {
      sig.isDown = true;
      //sig.countFromDown = sig.countFromDown==0 ? 0:sig.countFromDown++;
      if (sig.countFromDown == 0) {
         sig.countFromDown =1;
      }else {
         sig.countFromDown++;
      }   
      sig.isRise = false;
      sig.countFromRaise = 0;
      
   }else if (sig.signal == MARKET_RAISE) {
      sig.isRise = true;
      //sig.countFromRaise = sig.countFromRaise==0 ? 0:sig.countFromRaise++;
      if (sig.countFromRaise == 0) {
         sig.countFromRaise =1;
      }else {
         sig.countFromRaise++;
      }  
      sig.isDown = false;
      sig.countFromRaise = 0;
   }else if (sig.signal == MARKET_OSCILLATOR) {
      if ((sig.isDown && sig.isRise) && (!sig.isDown && !sig.isRise)) {
         return;
      }
      if (sig.isDown) {
         sig.countFromDown++;
         sig.isRise = false;
         sig.countFromRaise = 0;
      }
      if (sig.isRise) {
         sig.countFromRaise++;
         sig.isDown = false;
         sig.countFromDown = 0;
      }      
   }
   //すでにあるオーダーを処理
   if (sig.signal == MARKET_OSCILLATOR) {//不安定のトレンド
      if (sig.isRise) {//この前が上昇トレンド
         if(sig.countFromRaise >= INTERNAL_LENGTH_MIDDLE) {
            //デバッグのための出力、最終的に要らない
            printf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
            printf("++++++++++++++++++++++++++++++++++++++++++++");
            printf("++++++++++++++++++++++++++++++++++++++++++++");
            printf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
            iCloseOrders(CLOSE_PROFIT);
            iCloseOrders(CLOSE_BUY);
         }
      }else if (sig.isDown) {//この前が下降トレンド
         if(sig.countFromDown >= INTERNAL_LENGTH_MIDDLE) {
            //デバッグのための出力、最終的に要らない
            printf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
            printf("--------------------------------------------");
            printf("--------------------------------------------");
            printf("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
            iCloseOrders(CLOSE_PROFIT);
            iCloseOrders(CLOSE_SELL);
         }
      }
   }else if (sig.signal == MARKET_RAISE) {//上昇トレンド
      iCloseOrders(CLOSE_SELL);
      if (sig.preSignal == MARKET_DOWN || sig.preSignal == MARKET_OSCILLATOR) {//この前が不安定また下降の場合
         //デバッグのための出力、最終的に要らない
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         printf("--------------------------------------------");
         printf("--------------------------------------------");
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         //この場合     ・利益が出るSellを閉じる
         iCloseOrdersWith(CLOSE_SELL, false, FIXED_TAKEPROFIT, 0);
         iCloseOrders(CLOSE_SELL);
      }else if (sig.preSignal == MARKET_RAISE) {//この前も上昇
         //デバッグのための出力、最終的に要らない
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         //この場合     ・全部のSellを閉じる
         iCloseOrders(CLOSE_SELL);
         iCloseOrdersWith(CLOSE_SELL, true, FIXED_STOPLOSS, 0);
      }
   }else if (sig.signal == MARKET_DOWN) {//下降トレンド
      iCloseOrders(CLOSE_BUY);
      if (sig.preSignal == MARKET_RAISE || sig.preSignal == MARKET_OSCILLATOR) {//この前が不安定また上昇の場合
         //デバッグのための出力、最終的に要らない
         printf("--------------------------------------------");
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         printf("++++++++++++++++++++++++++++++++++++++++++++");
         printf("--------------------------------------------");
         //この場合     ・利益が出るBuyを閉じる
         iCloseOrders(CLOSE_BUY);
         iCloseOrdersWith(CLOSE_BUY, false, FIXED_TAKEPROFIT, 0);
      }else if (sig.preSignal == MARKET_DOWN) {//この前も下降
      //デバッグのための出力、最終的に要らない
         printf("--------------------------------------------");
         printf("--------------------------------------------");
         printf("--------------------------------------------");
         printf("--------------------------------------------");
         //この場合     ・全部のBuyを閉じる
         iCloseOrders(CLOSE_BUY);
         iCloseOrdersWith(CLOSE_BUY, true, FIXED_STOPLOSS, 0);
      }
   }
   
   sig.preSignal = sig.signal;
   printf("preSignal: %s", sig.preSignal);
}   

//+------------------------------------------------------------------+
//|                        オーダー関数                             
//+------------------------------------------------------------------+
//--------------------------------------------
//               ロウソクの更新をチェック
//--------------------------------------------
struct barsPro {
   int preBars;
   int bars;
   bool isBarsUpdated;
} bars = {0, 0, false};

bool isBarsUpdated() {
   bars.bars = Bars(Symbol(), 0);
   bars.isBarsUpdated = bars.bars > bars.preBars ? true:false;
   bars.preBars = bars.bars;
   return bars.isBarsUpdated;
}
//--------------------------------------------
//             ポジションの総数をチェック  
//-------------------------------------------- 
struct OrderCount {
   int orderNum;
} numTemp = {0};
int getOrdersTotal() {
   int orderIndex;
   numTemp.orderNum = 0;
   for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
      if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
      if (isOwndOrder(OrderTicket())) {
         numTemp.orderNum++;
      }   
   }
   return numTemp.orderNum;
}
//--------------------------------------------
//               ポジションのチェック
//--------------------------------------------
struct AnalyzeOrderUUID {
   bool isOwned;
} analyzeUUID = {false};   
bool isOwndOrder(int ticket) {
   analyzeUUID.isOwned = false;
   ticket = OrderSelect(ticket, SELECT_BY_TICKET);
   if (OrderMagicNumber() == MagicNumber) {
      analyzeUUID.isOwned = true;
   }else {
      analyzeUUID.isOwned = false;
   }
   return analyzeUUID.isOwned;
}      
           
//--------------------------------------------
//                 ポジを開く
//--------------------------------------------
bool iOpenOrders(string myType, double myLots, int myStopLoss, int myTakeProfit) {
   double mySpread = MarketInfo(Symbol(), MODE_SPREAD); //今のスプレッドを取得
   int ticket = 0;//ダミー
   double buyStopLoss = Ask - myStopLoss*Point;
   double buyTakeProfit = Ask + myTakeProfit*Point;
   double sellStopLoss = Bid + myStopLoss*Point;
   double sellTakeProfit = Bid - myTakeProfit*Point;
   myLots = NormalizeDouble(myLots, 2);
   bool outTemp;
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
   outTemp = ticket == -1 ? false:true;
   if (!outTemp) {
      printf("orderSend error: %d", GetLastError());
   }
   return outTemp;
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
         if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if (isOwndOrder(OrderTicket())) {
            printf("OWNED");   
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }   
      }
   }
   //買いポジションを閉じる
   if(myType == "Buy") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwndOrder(OrderTicket())&&(OrderType() == OP_BUY)) {
           resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
   }   

   //　売りポジションを閉じる
   if(myType == "Sell") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwndOrder(OrderTicket())&&(OrderType() == OP_SELL)) {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
   }
   
   //収益の上がるポジションを閉じる
   if(myType == "Profit") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwndOrder(OrderTicket())&&(OrderProfit() > 0)) {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }        
   }
   //損失をでるポジションを閉じる
   if(myType == "Loss") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwndOrder(OrderTicket())&&(OrderProfit()<0)) {
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
      if (!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
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
   return true;
}

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








//----------------------------------------------------------------------
//                  インジケーター関数
//----------------------------------------------------------------------
//-------------------------------------------------------
//                    indicator
//-------------------------------------------------------
//----------------------------------------------------------------------
//                            Alligator
//----------------------------------------------------------------------
struct Alligator {
   double jaw, teeth, lips;
   bool isRise, isDown;
   int staredTimeShort;//5
   int staredTimeMiddle;//15
   int staredTimeLong;//30
   bool gatorRise, gatorDown;
};
Alligator alliTemp;
void alligatorPro() {
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
}   
string getMarketSignal() {
   alligatorPro();
   //----------------------------------------------------------------------
   //                           func Pro
   //----------------------------------------------------------------------
   string outtemp = MARKET_OSCILLATOR;
   if(alliTemp.gatorRise) {//Buy
      outtemp = MARKET_RAISE;
   }else if(alliTemp.gatorDown) { //Sell
      outtemp = MARKET_DOWN;
   }
   return outtemp;
}
//+------------------------------------------------------------------+
