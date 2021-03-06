//+------------------------------------------------------------------+
//|                                                        test1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SuperLazyDog"
//#property link      "www.mql5.com"
#property version   "1.01"
#property strict

//+------------------------------------------------------------------+
//|                           task                             
//+------------------------------------------------------------------+
// # TODO: 行の長さを短くするために条件式を分けて定数に代入 b1f35771-12db-439e-a59c-4435b91ed22c
// # TODO: add some process   2a30641c-d4e4-4e19-b586-f64d755ad8f8
// # TODO: add some process   bf61b0a4-9477-435a-96ee-6a73e03b8298



//終了 UUIDを追加
// !! # TODO: 時間足と通貨ペアの制限を課す   812b1d97-0acc-468c-bbcc-7e6fd2465159
// !! # TODO: インジケーター追加、損を拡大しているポジを閉じれるように  98e6dd15-4401-4a74-bf92-0be1e0aa65ad
// !! # OPTIMIZE:  この前のシグナル処理を改善。今のままだと使ったら収益悪化 dc045d74-2f17-4123-89f9-7472c14bedd7
// !! # OPTIMIZE: 損を出しているポジを閉じる。このままだと閉じるべ時やつが大体SLにたっさないと閉じられない 8944a7bb-47ed-4228-90b1-19db98f80471
//2017/06/19
// !! # OPTIMIZE: 通貨ペアチェック bc73f674-57d4-4594-8008-a90c8e7a85b5
// !! # OPTIMIZE: 証券会社の認められる最大ロット数と最小ロット数をチェックしてから入力値をチェックする仕組みにした 77d341e8-8e61-4e6a-8730-0a63543999f9
//2017/06/26
// !! # TODO: 差異を埋める処理をカプセル化   d94c46d4-8114-4e37-bac8-a429790b5aa9
//2017/07/04
// !! # TODO: 2014/06/01~2017/06/05収益を40万円突破 4d02ffae-3b11-4ed8-9854-f54bbe64d085

//パラメータ
extern int MagicNumber = 0xFFFFFFF;
extern double LOTS = 0.1;
extern int Positions = 1;
extern int Slippage = 3;

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
//#define FIXED_LOTS 0.1 //固定ロット数
//SL, TP
#define FIXED_STOPLOSS 150 //　SL
#define FIXED_TAKEPROFIT 150 //TP
//シグナルの種類
#define MARKET_INITIAL "INITIAL"
#define MARKET_RAISE "RAISE"
#define MARKET_OSCILLATOR "OSCI"
#define MARKET_DOWN "DOWN"
#define MARKET_MAYBE_RAISE "MAYBE_RAISE"
#define MARKET_MAYBE_DOWN "MAYBE_DOWN"
//トレンドの継続期間
#define INTERNAL_LENGTH_SHORT 3
#define INTERNAL_LENGTH_MIDDLE 9
#define INTERNAL_LENGTH_LONG 18
//範囲指定を無視するため
#define UNLIMITED_BORDER 0xFFFFFFF


//デフォルトの通貨ペアと時間足
// # TODO: 時間足と通貨ペアの制限を課す
#define SYMBOL_DEFAULT NULL
#define TIMEFRAME_DEFAULT 0

////桁数の相違のための処理
#define POINT ((mult == 0) ? Point : Point*mult)
//ドル建て、円建てに関する処理
#define MULTIPLE_BUY (currencyMultiple == 1 ? 1 : Bid)
#define MULTIPLE_SELL (currencyMultiple == 1 ? 1 : Ask)
//------------定数------------


//------------変数------------
//double myLots = 0.0;
int mult = 0;//桁数の相違のための処理
double currencyMultiple = 1;//異なる通貨建ての場合の処理 デフォルト: 1
//+------------------------------------------------------------------+
//|                Expert initialization function                    |
//+------------------------------------------------------------------+


int OnInit() {
//---
   // !! # TODO: 差異を埋める処理をカプセル化   d94c46d4-8114-4e37-bac8-a429790b5aa9
   //-------------------------------------------------
   //               差異を埋める処理をカプセル化
   //-------------------------------------------------
   multiCurrencyPro();
   // !! # TODO: 時間足と通貨ペアの制限を課す   812b1d97-0acc-468c-bbcc-7e6fd2465159
   //-------------------------------------------------
   //                通貨ペア、時間足制限
   //-------------------------------------------------
   // !! # OPTIMIZE: 通貨ペアチェック bc73f674-57d4-4594-8008-a90c8e7a85b5
   string strtemp = StringSubstr(Symbol(), 0, 6);
   //printf("your symbol: %s", strtemp);
   if(strtemp != "USDJPY" || Period() != 5) {
      //MessageBox("通貨ペア:USDJPY\n時間足: M5   にしてください。", "設定エラー");
      //Alert(INIT_FAILED);
      return (INIT_FAILED);
   }
   //-------------------------------------------------
   //                  入力のチェック
   //-------------------------------------------------
   if(Digits == 2 || Digits == 4) {
      mult = 1;
   } else {
      mult = 10;
   }
   /*printf("point: %f", Point);
   printf("mult: %f", mult);
   printf("POINT: %f", POINT);
   printf("Digits: %d", Digits);*/
   //-------------------------------------------------
   //                  入力のチェック
   //-------------------------------------------------
   //LOTS
   // !! # OPTIMIZE: 証券会社の認められる最大ロット数と最小ロット数をチェックしてから入力値をチェックする仕組みにした 77d341e8-8e61-4e6a-8730-0a63543999f9
   double maxLots = (MarketInfo(SYMBOL_DEFAULT, MODE_MAXLOT) == 0.0) ? 0.2 : MarketInfo(SYMBOL_DEFAULT, MODE_MAXLOT);
   double minLots = (MarketInfo(SYMBOL_DEFAULT, MODE_MINLOT) == 0.0) ? 0.01 : MarketInfo(SYMBOL_DEFAULT, MODE_MINLOT);
   if((LOTS < minLots) || (LOTS > maxLots)) {
      printf("test");
      printf("Lots must be in range!");
      printf("Max Lots: %f", minLots);
      printf("Min Lots: %f", maxLots);
      return (INIT_FAILED);
   }
   //Positions
   if(Positions < 1) {
      printf("Positions must over 0!");
      return (INIT_FAILED);
   }
   //-------------------------------------------------
   //              ログメッセージとオブジェクト
   //------------------------------------------------- 
   printf("start test, remain: %d %s, %s, %f", AccountBalance(), AccountName(), AccountCurrency(), AccountFreeMargin());
   iSetLabel("test1", "EagleEye Trader", 5, 20, 8, "Verdana", Red);
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
   //if(count == 1500) {
      //iCloseOrders(CLOSE_ALL);
   //}
   //printf("barNum: %d", Bars(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT));
   //-------------------------------------------------
   //                    test
   //-------------------------------------------------
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
   printf("Spread %f", MarketInfo(SYMBOL_DEFAULT, MODE_SPREAD));
   printf("myLots: %f", myLots);
   printf("EURJPY myLots: %f", AccountEquity()/MarketInfo("EURJPY", MODE_MARGINREQUIRED));*/
   //-------------------------------------------------
   //-------------------------------------------------
   //                  label set
   //-------------------------------------------------
   iSetLabel("main1", "Price: " + DoubleToStr(Close[0], 3), 5, 65, 8, "Verdana", Red);
   iSetLabel("main2", "----------------------------------------------", 5, 80, 8, "Verdana", Yellow);
   iSetLabel("main3", "AccoutEquity: " + DoubleToStr(AccountEquity(), 3), 5, 95, 8, "Verdana", Red);

   //iSetLabel("main4", "version 1.01", 5, 95, 8, "Verdana", Red);
   //-------------------------------------------------
   //                  ローカルプロパティ
   //-------------------------------------------------
   //-------------------------------------------------
   //                    タスク
   //-------------------------------------------------
   //ロウソクの更新をチェック
   if(!isBarsUpdated()) {
      //printf("まだ更新されていない");
      return;
   }
   //---------------------------
   //   すでにあるポジションをチェック
   //---------------------------
   sigProWithClose();
   //iMoveStopLoss(FIXED_STOPLOSS);
   //printf("sinal: %s", sig.signal);
   
   //---------------------------
   //        買ポジを開く
   //---------------------------
   if(sig.signal == MARKET_RAISE) {
      sig.isRise = true;
      sig.isDown = false;
      if((getOrdersTotal() < Positions)) {// && isBarsUpdated()) {
         iOpenOrders(CLOSE_BUY, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
         iDrawSign(CLOSE_BUY, Close[0]);
      }
   }
   //---------------------------
   //       売りポジを開く
   //---------------------------
   if(sig.signal == MARKET_DOWN) {
      sig.isRise = false;
      sig.isDown = true;
      if((getOrdersTotal() < Positions)) {// && isBarsUpdated()) {
         iOpenOrders(CLOSE_SELL, LOTS, FIXED_STOPLOSS, FIXED_TAKEPROFIT);
         iDrawSign(CLOSE_SELL, Close[0]);
      }
   }
}

//+------------------------------------------------------------------+
//|                       様々なヘルパー                              
//+------------------------------------------------------------------+
// !! # TODO: 差異を埋める処理をカプセル化   d94c46d4-8114-4e37-bac8-a429790b5aa9
void multiCurrencyPro() {
   if(AccountCurrency() == "USD") {
      currencyMultiple = 1;
   }else if(AccountCurrency() == "JPY") {
      currencyMultiple = 0xFFFFFFF;
   }else {
      //currencyMultiple = -1;
   }
}
//+------------------------------------------------------------------+
//|                      プロパティ関数                              
//+------------------------------------------------------------------+
//--------------------------------------------
//                stopLoss
//--------------------------------------------
void iMoveStopLoss(int myStopLoss) {
   int mSLCnt;
   bool modifyTemp = false;
   if(OrdersTotal()>0) {
      for(mSLCnt=OrdersTotal()-1; mSLCnt>=0; mSLCnt--) {
         if(!OrderSelect(mSLCnt, SELECT_BY_POS)) {
            continue;
         }
         if(OrderMagicNumber() != MagicNumber) {
            continue;
         }   
         if(isOwnedOrder(OrderTicket()) && (OrderProfit() > 0 && OrderType() == OP_BUY) && ((Close[0] - OrderStopLoss()) > ((2*myStopLoss)*POINT))) {
            modifyTemp = OrderModify(OrderTicket(), OrderOpenPrice(), Bid-POINT*myStopLoss, OrderTakeProfit(), 0);
         }
         
         if(isOwnedOrder(OrderTicket()) && (OrderProfit() > 0 &&OrderType() == OP_SELL ) && (( OrderStopLoss() - Close[0]) > ((2 * myStopLoss) * POINT))) {
            modifyTemp = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + POINT*myStopLoss, OrderTakeProfit(),0);
         }       
      }
   }
   if(!modifyTemp) {//失敗したらログに出力する
      printf("iMoveStopLoss() error: %d", GetLastError());
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
   bars.bars = Bars(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT);
   //printf("%d", bars.bars);
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
      if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
      if(isOwnedOrder(OrderTicket())) {
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

bool isOwnedOrder(int ticket) {
   analyzeUUID.isOwned = false;
   ticket = OrderSelect(ticket, SELECT_BY_TICKET);
   if(OrderMagicNumber() == MagicNumber) {
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
   //double mySpread = MarketInfo(SYMBOL_DEFAULT, MODE_SPREAD); //今のスプレッドを取得
   double mySpread = Slippage;
   int ticket = 0;//ダミー
   double buyStopLoss = Ask - myStopLoss*POINT;
   double buyTakeProfit = Ask + myTakeProfit*POINT;
   double sellStopLoss = Bid + myStopLoss*POINT;
   double sellTakeProfit = Bid - myTakeProfit*POINT;
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
      ticket = OrderSend(SYMBOL_DEFAULT, OP_BUY, myLots, Ask, int(mySpread), buyStopLoss, buyTakeProfit, "", MagicNumber);
      iDrawSign(CLOSE_BUY, Close[0]);
   }
   if(myType == "Sell") {
      ticket = OrderSend(SYMBOL_DEFAULT, OP_SELL, myLots, Bid, int(mySpread), sellStopLoss,sellTakeProfit, "", MagicNumber);
      iDrawSign(CLOSE_SELL, Close[0]);
   }
   outTemp = ticket == -1 ? false:true;
   if(!outTemp) {
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
         if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwnedOrder(OrderTicket())) {  
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage);
         } 
         if(resulTemp) {//失敗したらログに出力する
            printf("iCloseOrders() error: %d", GetLastError());
         }  
      }
   }
   //買いポジションを閉じる
   if(myType == "Buy") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwnedOrder(OrderTicket())&&(OrderType() == OP_BUY)) {
           resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage);
         }
         if(resulTemp) {//失敗したらログに出力する
            printf("iCloseOrders() error: %d", GetLastError());
         }
      }
   }   

   //　売りポジションを閉じる
   if(myType == "Sell") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwnedOrder(OrderTicket())&&(OrderType() == OP_SELL)) {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage);
         }
         if(resulTemp) {//失敗したらログに出力する
            printf("iCloseOrders() error: %d", GetLastError());
         }
      }
   }
   
   //収益の上がるポジションを閉じる
   if(myType == "Profit") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwnedOrder(OrderTicket())&&(OrderProfit() > 0)) {
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage);
         }
         if(resulTemp) {//失敗したらログに出力する
            printf("iCloseOrders() error: %d", GetLastError());
         }
      }        
   }
   //損失をでるポジションを閉じる
   if(myType == "Loss") {
      for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
         if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
         if(isOwnedOrder(OrderTicket())&&(OrderProfit()<0)) {
           resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
         if(resulTemp) {//失敗したらログに出力する
            printf("iCloseOrders() error: %d", GetLastError());
         }
      } 
   }             
}

//--------------------------------------------
//       特定条件を満たすポジションを閉じる
//--------------------------------------------
bool iCloseOrdersWith(string myType, bool isStopLoss, double max = UNLIMITED_BORDER, double min = 0) {
   int orderType = OP_SELLLIMIT;
   bool isAll = false;
   int orderIndex;
   bool resulTemp;
   //引数のチェック
   if((max <= min) || (max < 0) || (min < 0)) {
      printf("iCloseOrdersWith() error: wrong arguments");
      return false;
   }   
   //orderTypeを設定
   if(myType == CLOSE_BUY) {
      orderType = OP_BUY;
   } else if(myType == CLOSE_SELL) {
      orderType = OP_SELL;
   } else if(myType == CLOSE_ALL) {
      isAll = true;
   } else {
      printf("iCloseOrdersWith() error: unknown type");
      return false;
   }
   //最初に位置に行く
   if(OrdersTotal() == 0) {
      printf("iCloseOrdersWith() error: no orders");
      return false;
   }   
   if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS) == false) {
      printf("iCloseOrdersWith() error: no orders");
      return false;
   }
   
   //ポジションを閉じる
   for(orderIndex = OrdersTotal() - 1; orderIndex >= 0; orderIndex--) {
      if(!OrderSelect(orderIndex, SELECT_BY_POS)) {continue;}
      if(!isOwnedOrder(OrderTicket())) {continue;}
      if(isStopLoss) {//SL
         if(((OrderType() == orderType) || (isAll)) && (OrderProfit() < -min) && (OrderProfit() > -max)) {//(Buy or Sell) or All
            //printf("OrderProfit: %f", OrderProfit());
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }else { //TP
         if(((OrderType() == orderType) || (isAll)) && (OrderProfit() > min) && (OrderProfit() < max)) {//(Buy or Sell) or All
            //printf("OrderProfit: %f", OrderProfit());
            resulTemp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
      if(resulTemp) {//失敗したらログに出力する
         printf("iCloseOrders() error: %d", GetLastError());
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
//                 　　　　　　 インジケーター関数
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//                            　　 iAC
//----------------------------------------------------------------------
#define IAC_INDEX 0
struct IAC {
   double iACValues[5];
   bool isGreen[4];
   bool iACRaise;
   bool iACDown;
};
IAC iACTemp = {{}, {}, false, false};

bool isGreen(double tar, double ober) {
   if(tar > ober) {
      return true;
   }else {
      return false;
   }
}
         
void iACPro(int index = IAC_INDEX) {
   iACTemp.iACValues[0] = iAC(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, index);
   iACTemp.iACValues[1] = iAC(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, index+1); 
   iACTemp.iACValues[2] = iAC(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, index+2);
   iACTemp.iACValues[3] = iAC(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, index+3);
   iACTemp.iACValues[4] = iAC(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, index+4);
   iACTemp.isGreen[0] = (bool)isGreen(iACTemp.iACValues[0], iACTemp.iACValues[1]);
   iACTemp.isGreen[1] = (bool)isGreen(iACTemp.iACValues[1], iACTemp.iACValues[2]);
   iACTemp.isGreen[2] = (bool)isGreen(iACTemp.iACValues[2], iACTemp.iACValues[3]);
   iACTemp.isGreen[3] = (bool)isGreen(iACTemp.iACValues[3], iACTemp.iACValues[4]);

   bool buySec1 = (iACTemp.isGreen[3] && !iACTemp.isGreen[2] && iACTemp.isGreen[1] && iACTemp.isGreen[0]) && ((iACTemp.iACValues[4] > 0) && (iACTemp.iACValues[2] > 0));
   bool buySec2 = (!iACTemp.isGreen[3] && iACTemp.isGreen[2] && iACTemp.isGreen[1] && iACTemp.isGreen[0]) && ((iACTemp.iACValues[4] < 0) && (iACTemp.iACValues[0] < 0));
   bool buySec3 = (!iACTemp.isGreen[3] && !iACTemp.isGreen[2] && iACTemp.isGreen[1] && iACTemp.isGreen[0]) && ((iACTemp.iACValues[1] < 0) && (iACTemp.iACValues[0] > 0));
   iACTemp.iACRaise = (buySec1 || buySec2 || buySec3); 

   bool sellSec1 = (iACTemp.isGreen[3] && iACTemp.isGreen[2] && !iACTemp.isGreen[1] && !iACTemp.isGreen[0]) && (iACTemp.iACValues[2] < 0);
   bool sellSec2 = (iACTemp.isGreen[3] && !iACTemp.isGreen[2] && !iACTemp.isGreen[1] && !iACTemp.isGreen[0]) && ((iACTemp.iACValues[4] > 0) && (iACTemp.iACValues[0] > 0));
   bool sellSec3 = (iACTemp.isGreen[3] && iACTemp.isGreen[2] && !iACTemp.isGreen[1] && !iACTemp.isGreen[0]) && ((iACTemp.iACValues[1] > 0) && ( iACTemp.iACValues[0] < 0));
   iACTemp.iACDown = (sellSec1 || sellSec2 || sellSec3);
}

   
//----------------------------------------------------------------------
//                            Alligator
//----------------------------------------------------------------------
#define ALLIGATOR_INDEX 0
struct Alligator {
   double jaw, teeth, lips;
   //bool isRise, isDown;
   //int staredTimeShort;//5
   //int staredTimeMiddle;//15
   //int staredTimeLong;//30
   bool gatorRise, gatorDown;
};
Alligator alliTemp;

void alligatorPro(int index = ALLIGATOR_INDEX) {
   alliTemp.jaw = iAlligator(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORJAW, index);
   alliTemp.teeth = iAlligator(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORTEETH, index);
   alliTemp.lips = iAlligator(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, 13, 8, 8, 5, 5, 3, MODE_EMA, PRICE_MEDIAN, MODE_GATORLIPS, index);
   //printf("jaw: %f, teeth: %f, lips: %f", jaw, teeth, lips); 

   //lip > teeth > jaw 　上昇トレンド
   alliTemp.gatorRise = (Close[0] >= alliTemp.lips) && ((alliTemp.lips > alliTemp.teeth) && (alliTemp.teeth > alliTemp.jaw));

   //lip < teeth < jaw 下降トレンド
   alliTemp.gatorDown =  (Close[0] <= alliTemp.lips) && ((alliTemp.lips < alliTemp.teeth) && (alliTemp.teeth < alliTemp.jaw));
}

//----------------------------------------------------------------------
//                            Fractals
//----------------------------------------------------------------------
#define FRACTALS_INDEX 0
struct Fractals {
   double fractal;
   bool isNone;
   bool isUpper;
   bool isLower;
   bool isRaiseWithAlligator;
   bool isDownWithAlligator;
};
Fractals fracTemp = {0.0, false, false, false,false, false};

//fractalsの値を取得
void getFractals(int index = 0) {
   unsigned trueIndex = index + 2; //本当のインデックス
   double upper = iFractals(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, MODE_UPPER, trueIndex);
   double lower = iFractals(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, MODE_LOWER, trueIndex);
   if((upper == 0.0) && (lower == 0.0)) {
      fracTemp.isNone = true;
      fracTemp.fractal = 0.0;
      fracTemp.isLower = false;
      fracTemp.isUpper = false;
   }else {
      fracTemp.isNone = false;
      if(upper > lower) {
         fracTemp.isNone = false;
         fracTemp.isUpper = true;
         fracTemp.isLower = false;
         fracTemp.fractal = upper;
      }else {
         fracTemp.isNone = false;
         fracTemp.isUpper = false;
         fracTemp.isLower = true;
         fracTemp.fractal = lower;
      }      
   }
}

void fractalsPro(int index = FRACTALS_INDEX, int allIndex = IAC_INDEX) {
   getFractals(index);
   alligatorPro(allIndex);
   if((fracTemp.fractal < alliTemp.teeth) && fracTemp.isLower) { // raise
      fracTemp.isRaiseWithAlligator = true;
      fracTemp.isDownWithAlligator = false;
   }else if ((fracTemp.fractal > alliTemp.teeth) && fracTemp.isUpper) { //down
      fracTemp.isRaiseWithAlligator = false;
      fracTemp.isDownWithAlligator = true;
   }else {
      fracTemp.isRaiseWithAlligator = false;
      fracTemp.isDownWithAlligator = false;
   }
} 

//----------------------------------------------------------------------
//                         Bollinger Bands
//----------------------------------------------------------------------
#define BOLLINGER_INDEX 0
struct BollingerBands {
   double main;
   double upper;
   double lower;
   bool isRaise;
   bool isDown;
};
BollingerBands bollTemp = {0, 0, 0, false, false};

void getBollinger(int index) {
   bollTemp.main = iBands(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, 20, 2, 0, PRICE_CLOSE, MODE_MAIN, index);
   bollTemp.upper = iBands(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, index);
   bollTemp.lower = iBands(SYMBOL_DEFAULT, TIMEFRAME_DEFAULT, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, index);
   bollTemp.isRaise = (Low[0] < bollTemp.lower);//穿越下线
   bollTemp.isDown = (High[0] > bollTemp.upper);//穿越上线
}

void bollingerPro(int index = BOLLINGER_INDEX) {
   getBollinger(index);
}   

// !! # TODO: インジケーター追加、損を拡大しているポジを閉じれるように  98e6dd15-4401-4a74-bf92-0be1e0aa65ad
//----------------------------------------------------------------------
//                          シグナルを取得
//---------------------------------------------------------------------- 
#define DEFAULT_INDEX 0

string getMarketSignal() {
   bollingerPro();
   alligatorPro();
   iACPro();
   fractalsPro();
   
   string outtemp = MARKET_OSCILLATOR;
   // # TODO: 行の長さを短くするために条件式を分けて定数に代入
   
   if(((fracTemp.isRaiseWithAlligator) && alliTemp.gatorRise) || (bollTemp.isRaise)) {//raise
      outtemp = MARKET_RAISE;
   }else if(((fracTemp.isDownWithAlligator) && alliTemp.gatorDown) || (bollTemp.isDown)) { //down
      outtemp = MARKET_DOWN;
   }else if(alliTemp.gatorRise||fracTemp.isRaiseWithAlligator) { //maybe raise
      outtemp = MARKET_MAYBE_RAISE;
   }else if(alliTemp.gatorDown||fracTemp.isDownWithAlligator) { //maybe down
      outtemp = MARKET_MAYBE_DOWN;
   }
   
   return outtemp;
}


//+------------------------------------------------------------------+
//|                       シグナル処理関数                             
//+------------------------------------------------------------------+
struct SignalPro {
   string preSignal;
   string signal;
   bool isRise;
   bool isDown;
   int countFromRaise;
   int countFromDown;
   int countFromMaybeRaise;
   int countFromMaybeDown;
};
SignalPro sig = {MARKET_INITIAL, MARKET_INITIAL, false, false, 0, 0, 0, 0};
void sigProWithClose() {
// !! # OPTIMIZE:  この前のシグナル処理を改善。今のままだと使ったら収益悪化 dc045d74-2f17-4123-89f9-7472c14bedd7
   //　シグナルの取得
   sig.signal = getMarketSignal();
   printf("signal %s", sig.signal);
   //シグナル構造体の処理
   if(sig.signal == MARKET_DOWN) {//downになる
      sig.isDown = true;
      //sig.countFromDown = sig.countFromDown==0 ? 0:sig.countFromDown++;
      if(sig.countFromDown == 0) {
         sig.countFromDown = 1;
      }else {
         sig.countFromDown++;
      }   
      sig.isRise = false;
      sig.countFromRaise = 0;
      sig.countFromMaybeRaise = 0;
   }else if(sig.signal == MARKET_RAISE) {//raiseになる
      sig.isRise = true;
      //sig.countFromRaise = sig.countFromRaise==0 ? 0:sig.countFromRaise++;
      if(sig.countFromRaise == 0) {
         sig.countFromRaise =1;
      }else {
         sig.countFromRaise++;
      }  
      sig.isDown = false;
      // !! # FIXME: sig.countFromRaise = 0 ----->> sig.countFromDown = 0
      sig.countFromDown = 0;
      sig.countFromMaybeDown = 0;
   }else if(sig.signal == MARKET_OSCILLATOR) {//不安定
      if((sig.isDown && sig.isRise) && (!sig.isDown && !sig.isRise)) {
         return;
      }
      if(sig.isDown) {
         sig.countFromDown++;
         sig.isRise = false;
         sig.countFromRaise = 0;
         sig.countFromMaybeRaise = 0;
      }
      if(sig.isRise) {
         sig.countFromRaise++;
         sig.isDown = false;
         sig.countFromDown = 0;
         sig.countFromMaybeDown = 0;
      }      
   }else if(sig.signal == MARKET_MAYBE_RAISE) {//上がるかもしれない
      // # TODO: add some process   2a30641c-d4e4-4e19-b586-f64d755ad8f8
      sig.countFromMaybeRaise += 1;
      sig.countFromMaybeDown = 0;
      if(sig.countFromMaybeRaise > 5) {
        //sig.signal = MARKET_RAISE;
      }  
      if(sig.isDown) {//この前が下がる
         //sig.signal = MARKET_RAISE;
      }else if(sig.isRise) {//この前が上がる
      
      }   
   }else if(sig.signal == MARKET_MAYBE_DOWN) {//下がるかもしれない
      // # TODO: add some process   bf61b0a4-9477-435a-96ee-6a73e03b8298
      sig.countFromMaybeDown += 1;
      sig.countFromMaybeRaise = 0;
      if(sig.countFromMaybeDown > 5) {
         //sig.signal = MARKET_DOWN;
      }   
      if(sig.isRise) {//この前が上がる
         //sig.signal = MARKET_DOWN;
      }else if(sig.isDown) {//この前が下がる
      
      }
   }
   if((sig.signal == MARKET_MAYBE_DOWN) || (sig.signal == MARKET_MAYBE_RAISE)) {
      //sig.signal = MARKET_OSCILLATOR;
   }   
   
 // !! # OPTIMIZE: 損を出しているポジを閉じる。このままだと閉じるべ時やつが大体SLにたっさないと閉じられない 8944a7bb-47ed-4228-90b1-19db98f80471
   //すでにあるオーダーを処理
   
 // !! # TODO: 2014/06/01~2017/06/05収益を40万円突破 4d02ffae-3b11-4ed8-9854-f54bbe64d085
   if(sig.signal == MARKET_OSCILLATOR) {//不安定のトレンド
      iCloseOrdersWith(CLOSE_BUY, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3);
      iCloseOrdersWith(CLOSE_BUY, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3.74, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/4);
      
      iCloseOrdersWith(CLOSE_SELL, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/2.85);
      iCloseOrdersWith(CLOSE_SELL, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/1.8, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/4.2);
      
      /*iCloseOrdersWith(CLOSE_ALL, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3);
      iCloseOrdersWith(CLOSE_ALL, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/1.8, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/4.2);*/
   }else if(sig.signal == MARKET_RAISE) {//上昇トレンド
      iCloseOrdersWith(CLOSE_SELL, false, FIXED_TAKEPROFIT*MULTIPLE_SELL, FIXED_TAKEPROFIT*MULTIPLE_SELL/7);
      iCloseOrdersWith(CLOSE_SELL, true, FIXED_STOPLOSS*MULTIPLE_SELL/6.2, FIXED_STOPLOSS*MULTIPLE_SELL/7.27);
   }else if(sig.signal == MARKET_DOWN) {//下降トレンド
      iCloseOrdersWith(CLOSE_BUY, false, FIXED_TAKEPROFIT, FIXED_TAKEPROFIT*MULTIPLE_BUY/7.5);
      iCloseOrdersWith(CLOSE_BUY, true, FIXED_STOPLOSS*MULTIPLE_BUY/6.2, FIXED_STOPLOSS*MULTIPLE_BUY/7.97);
   }else if(sig.signal == MARKET_MAYBE_RAISE) {//maybe raise
      //iCloseOrders(CLOSE_LOSS);
      //-------------------------------------------------------------
      //                       上がるかもしれない
      //-------------------------------------------------------------
      iCloseOrdersWith(CLOSE_BUY, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3);
      iCloseOrdersWith(CLOSE_BUY, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/1.8, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3);
      
      iCloseOrdersWith(CLOSE_SELL, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/2.4);
      iCloseOrdersWith(CLOSE_SELL, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/1.8, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/4.2);
      
      
      
   }else if(sig.signal == MARKET_MAYBE_DOWN) {//maybe down
      //iCloseOrders(CLOSE_LOSS);
      //-------------------------------------------------------------
      //                       下がるかもしれない
      //-------------------------------------------------------------
      iCloseOrdersWith(CLOSE_BUY, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3);
      iCloseOrdersWith(CLOSE_BUY, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/1.8, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/4);
      
      iCloseOrdersWith(CLOSE_SELL, false, FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2), FIXED_TAKEPROFIT*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/3.2);
      iCloseOrdersWith(CLOSE_SELL, true, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/1.8, FIXED_STOPLOSS*((MULTIPLE_SELL+MULTIPLE_BUY)/2)/4.72);
   }    
   sig.preSignal = sig.signal;
   printf("preSignal: %s", sig.preSignal);
}   
//+------------------------------------------------------------------+

