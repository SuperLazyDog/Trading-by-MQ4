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
   //------------------test機能-----------------------
   printf("end test");
   //-------------------------------------------------
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
//-----------------------------------------------
//                 indicator
//-----------------------------------------------
//---------------------------
//          iAC
//---------------------------
double iACValues[3] = {};
//---------------------------
//         Alligator
//---------------------------
double jaw, teeth, lips;
bool isRise, isDown = false;
int staredTimeShort = 0;//5
int staredTimeMiddle = 0;//15
int staredTimeLong = 0;//30

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
   //----------------------------------------------------------------------
   //                            Alligator
   //----------------------------------------------------------------------
   //---------------------------
   //        Alligator
   //---------------------------
   jaw = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORJAW, 0);
   teeth = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORTEETH, 0);
   lips = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORLIPS, 0);
   printf("jaw: %f, teeth: %f, lips: %f", jaw, teeth, lips); 
   //緑>赤>青，上昇トレンド
   bool gatorRise = (lips > teeth) && (teeth > jaw);
   //緑<赤<青，下降トレンド
   bool gatorDown =  (lips < teeth) && (teeth < jaw);
   //-------------------------------------------------
   //                    タスク
   //-------------------------------------------------
   //---------------------------
   //    開かれたポジションを処理
   //---------------------------
   //上下変動激しい時
   //周期的に強制SL
   if (staredTimeShort == 5-1) {//周期5
      staredTimeShort = 0;
      iCloseOrdersWith(CLOSE_BUY, true, 100, 10);
      iCloseOrdersWith(CLOSE_SELL, true, 100, 10);
   }
   if (staredTimeMiddle == 15-1) {//周期15
      staredTimeMiddle = 0;
      iCloseOrdersWith(CLOSE_BUY, true, 200, 100);
      iCloseOrdersWith(CLOSE_SELL, true, 200, 100);
   }
   if (staredTimeLong == 30-1) {//周期30
      staredTimeLong = 0;
      iCloseOrdersWith(CLOSE_BUY, true, 500, 200);
      iCloseOrdersWith(CLOSE_SELL, true, 500, 200);
   }
   if (!gatorRise && !gatorDown) {
      if (isRise) {//この前が上昇トレンド
         iCloseOrdersWith(CLOSE_BUY, true, 10, 0);//SL
         iCloseOrdersWith(CLOSE_BUY, false, 1000, 0);//TP
      }
      if (isDown) {//この前が下降トレンド
         iCloseOrdersWith(CLOSE_SELL, true, 10, 0);//SL
         iCloseOrdersWith(CLOSE_SELL, false, 1000, 0);//TP
      }
      isRise = false;
      isDown = false;
      staredTimeShort += 1;
      staredTimeMiddle += 1;
      staredTimeLong += 1;
   }
   //---------------------------
   //      買いポジションを開く
   //---------------------------
   if (gatorRise) {
      isRise = true;
      isDown = false;
      if (OrdersTotal() <= 4) {
         iOpenOrders(CLOSE_BUY, FIXED_LOTS, (int)MarketInfo(Symbol(), MODE_STOPLEVEL), 500);
      }
      
   }
   //---------------------------
   //      売りポジションを開く
   //---------------------------
   if (gatorDown) {
      isRise = false;
      isDown = true;
      if (OrdersTotal() <= 4) {
         iOpenOrders(CLOSE_SELL, FIXED_LOTS, (int)MarketInfo(Symbol(), MODE_STOPLEVEL), 500);
      }
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


bool iCloseOrdersWith(string myType, bool isStopLoss, double max = 5, double min = 0) {
   int orderType;
   int orderIndex;
   //設定値をチェック
   if ((max <= min) || (max < 0) || (min < 0)) {
      printf("iCloseOrdersWith() error: wrong arguments");
      return false;
   }   
   //orderTypeを設定
   if (myType == CLOSE_BUY) {
      orderType = OP_BUY;
   } else if (myType == CLOSE_SELL) {
      orderType = OP_SELL;
   } else {
      printf("iCloseOrdersWith() error: unknown type");
      return false;
   }
   //条件を満たすポジションを閉じる
   for (orderIndex = 0; orderIndex < OrdersTotal(); orderIndex++) {
      if (OrderSelect(orderIndex, SELECT_BY_POS)) {
         if (isStopLoss) {//止损
            if  ((OrderProfit() < -min) && (OrderProfit() > -max) && (OrderType() == orderType)) {
               //printf("OrderProfit: %f", OrderProfit());
               bool temp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }else { //结利
            if  ((OrderProfit() > min)&& (OrderProfit() < max) && (OrderType() == orderType)) {
               //printf("OrderProfit: %f", OrderProfit());
               bool temp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
            }
         }   
      }
   }
   return true;
}
//+------------------------------------------------------------------+
