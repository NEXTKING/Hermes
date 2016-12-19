// MoebiusKKM.h: interface for the CMoebiusKKM class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _MOEBIUSKKM_
#define _MOEBIUSKKM_

//#using <Platform.winmd>
//#using <Windows.UI.Popups>

#include "gstdafx.h"

#include "struct.h"
#include "MoebiusAux.h"

#ifdef _IOS
#include "IOSStreamInterface.h"
#endif

//#if defined(_MSC_VER) && !defined(WINAPI_FAMILY)
//#include "ExternC.h"
//#endif

#include "Device.h"

#include <thread>
#include <atomic>

class EXTEXPORT CMoebiusKKM
{
public:
    void ClrDTR();
    void SetDTR();
    
    BYTE KkmSysAtom28(BYTE *present, Coord&  coord);
    BYTE KkmGoodsPosPrintCommon(int pos, BYTE* pres, Coord& coord, char* pGoodsName, char* pGoodsCode, char* pDepNumber,
                                double& TotalSum, double Quantity, double price, BOOL fWeight, BOOL ServicePrint, BOOL Correction);
    
    BYTE mbs_buy(char* pGoodsName, char* pGoodsCode, char* pDepNumber, double TotalSum, double Quantity, double price, BOOL fWeight, BOOL fServicePrint, BOOL fCorrection, BYTE oprCodeEklz, BOOL fReturn);
    
    //*** 1. �����������/���������� **********************************************
    
    CMoebiusKKM();
    virtual ~CMoebiusKKM();
    
    EXTSTATIC CMoebiusKKM* pMoebiusKKM;
    
    //*** 2. ������� � ���������� ���������� COM-������ **************************
    
    BOOL ConnectPort();
    BOOL DisconnectPort(BOOL fInDllMain = FALSE);
    bool IsConnected();
#ifdef _IOS
    bool InitAppleSDK(iOSStreamInterface *pIAppleSDK);
#endif
    
    
    //*** 3. ������� � ���������� ���������� ������, �������� ��, �������� ������ *
    CResponseData* GetLastResponseData();
    void ResetLastResponseData();
    BYTE ClearOutput(BOOL flag);
    void ClearOutput();
    BYTE GetLastKkmErr();
    BOOL GetDSRStatus(long szTime);
    BOOL WaitDSR(long szTime);
    
    BYTE LastErrRekv;//�������� �� ������������
    
    EXTSTATIC BOOL m_AsyncMode;			//1
    EXTSTATIC DWORD m_OutputID;			//2
    EXTSTATIC DWORD m_KkmType;				//3
    EXTSTATIC BOOL m_fOutxDsrFlow;			//4
    EXTSTATIC char m_PPD[5];				//5
    EXTSTATIC BYTE m_Comm;					//6	26.02.2008
    EXTSTATIC DWORD m_Speed;					//7	26.02.2008
    EXTSTATIC BOOL m_fConnectPort;			//8
    EXTSTATIC BOOL m_fWaitingResponse;		//9
    EXTSTATIC BOOL m_fConsoleApl;			//16 26.02.2008
    
    BOOL fCmdFinish;		//9
    BOOL m_fExitTimerTreadFinish;
    BOOL m_fExitTreadFinish;
    BYTE PrevResponceCode;
    BOOL m_Done;
    int  LastTimeDataInTick;
    BYTE fStart;
    
    EXTSTATIC KkmState m_ks;				//10
    EXTSTATIC TotSendHost m_ksEx;			//11
    EXTSTATIC DWORD m_PauseSendByte;		//12 20.02.2008
    EXTSTATIC BYTE m_Precision;			//13
    EXTSTATIC BOOL m_fLetUseHandleMessage;	//14
    EXTSTATIC BOOL m_fPrintNDS;			//15
    
    EXTSTATIC BOOL m_fReceipt2Sleep;			//17 01.09.2008
    EXTSTATIC BYTE m_Ver;							//18 ���� ������� ����� �� �� ��������������, 28.06.2012 - ������ �������������
    
    EXTSTATIC TotSendHostNew m_ksExNew;			//19
    
    EXTSTATIC BOOL m_fProshDebug;					//20
    EXTSTATIC BYTE m_fRound;						//21
    EXTSTATIC BYTE m_CmdTimeOut;					//22
    EXTSTATIC BYTE m_DsrTimeOut;					//23
    
    EXTSTATIC KkmRegistrInfo m_RI;					//24 02.10.2010
    
    EXTSTATIC BYTE m_Zebra;							//25 10.02.2014
    
    KkmDopInfo m_DopInfo;
    
    //.............................................
    /*std::atomic<int>*/int *m_pQuit;
    
    //*** 4. ������� ������ � �������� *******************************************
    
    BYTE SetVatValue(int VatID, int VatValue);
    BYTE GetVatValue(int VatID, int* VatValue);
    BYTE SetVatSum(int VatID, int lVatSum);
    BYTE GetVatSum(int VatID, int* lVatSum);
    void ClearVatTableAndSum();
    
    //*** 5. ����� ���������� ������� ���������� �� ������ ***********************
    
    BYTE KkmOpenShift(Date* pDate, BYTE cmCode, char* pOperName);//, BYTE BufFlag);	//8
    BYTE KkmCloseShift(Date* pDate, BYTE toclr);									//9
    BYTE KkmGetShiftData(BYTE Pid);													//11
    BYTE KkmGetCommonData(BYTE Pid);//12
    BYTE KkmGetEKLData();//13
    BYTE KkmCasherChg(BYTE OperCode, char* OperName);//14
    BYTE KkmRoundSet(WORD mdRound);//22
    BYTE KkmRoundSet2(DWORD mdRoundNew);//22
    
    //	BYTE KkmRepeatCheck();//23
    BYTE KkmGetKKMInfo(char *pKkmInfo, BYTE oprCode);//28
    BYTE KkmMirror(BYTE StrCnt);//29
    BYTE KkmCommonReset(char* pFIPassword);//31 //ce++ LPCTSTR
    BYTE KkmChangeHeader(char* pHeader);//, int szHeader = 0);//33 //ce++ LPCTSTR
    BYTE KkmChangeHeaderEx(char* pHeader, int len);//, int szHeader = 0);//33 //ce++ LPCTSTR
    BYTE KkmPasswordChg(char* pPsw, char* pCurrentPpd);//34 //ce++ LPCTSTR
    BYTE KkmGetShiftInfo();//35
    BYTE KkmResetCheck();//36
    BYTE KkmGetTransPsw(char* psw, char *pPPD);//38//ce++ LPCTSTR
    BYTE KkmPrintVersion();//39
    
    BYTE KkmEKLZActivate(Date *pDate);//40
    BYTE KkmGetEKLZContrLent(DWORD SheftNum);//41
    BYTE KkmEKLZReport(BYTE ReportType, BYTE range, BYTE SelectType, Date *StartDate,
                       Date *EndDate, DWORD StartNum, DWORD EndNum, BYTE section);//42
    BYTE KkmGetEKLZChek(DWORD KPKnum);//43
    BYTE KkmEKLZGetShiftTotal(DWORD ShiftNum);//44
    BYTE KkmEKLZActivateReport();//45
    BYTE KkmEKLZActivateReport2Port();//45
    BYTE KkmEKLZCloseArchive();//46
    
    BYTE KkmPrnEKLInfo();//48
    BYTE KkmPrnEKLSale();//49
    BYTE KkmPrnEKLDep();//50
    BYTE KkmPrnEKLCassir();//51
    BYTE KkmPrnEKLStep();//52
    BYTE KkmGetDepData();//54
    BYTE KkmGetKKMInfoEx(char *pKkmInfoEx);//, BYTE oprCode);//55
    BYTE KkmGetKKMInfoExNew(char *pKkmInfoExNew); //55
    
    BYTE KkmGetDopInfo(char* pKkmDopInfo); //56
    BYTE KkmSetFirmInfo(char* pFirmInfo);//57
    BYTE KkmSendTextBlock(char* pBlock, int lenBlock);//63
    BYTE KkmGetRegistrInfo(char *pKkmRegistrInfo);//61
    
    BYTE SetIpConfig(char* id,char* ip_address, int port, char* IdIidk);
    BYTE GetBarrierState();
    BYTE FileReport(tm *timeptr1 , tm *timeptr2, int* RecNum, float* AllSum, int TransportType);
    
    //*** 6. ���������� ������� ��� �������������(����������) ������������ ���� **
    
    BYTE KkmMakeCheck(Date *date, BYTE DocType, BYTE oprCodeEklz);//, BYTE *tape, BYTE *copy);//15
    BYTE KkmSysAtom(BYTE *present, BYTE num, Coord coord);//16
    BYTE KkmTextAtom(BYTE *present, BYTE num, Coord coord, BYTE len, char *txt);
    BYTE KkmGoodsText(BYTE len, char *txt);
    BYTE KkmReceiptText(BYTE len, char *txt);
    BYTE KkmSumAtom(BYTE *present, BYTE num, Coord coord, char *sum, BOOL fBold = FALSE);
    BYTE KkmCurrCodeAtom(BYTE *present, BYTE num, Coord coord, BYTE cmCode);
    BYTE KkmNumAtom(BYTE *present, BYTE num, Coord coord, WORD numb);
    BYTE KkmCodeAtom(BYTE *present, BYTE num, Coord coord, DWORD cmCode);
    BYTE KkmFirmAtom(BYTE *present, BYTE num, Coord coord);
    
    BYTE KkmMakeCheckEx(Date *date, BYTE DocType, BYTE oprCodeEklz, BYTE CTFlag, BYTE LDFlag, BYTE SPCTFlag, BYTE SPLDFlag, BYTE PID);
    BYTE KkmSysAtomEx(BYTE *present, BYTE num, BYTE* coordb);
    BYTE KkmTextAtomEx(BYTE *present, BYTE num, BYTE* coordb, BYTE len, char *txt);
    BYTE KkmSumAtomEx(BYTE *present, BYTE num, BYTE* coordb, char *sum, BOOL fBold);
    BYTE KkmCurrCodeAtomEx(BYTE *present, BYTE num, BYTE* coordb, BYTE cmCode);
    BYTE KkmNumAtomEx(BYTE *present, BYTE num, BYTE* coordb, WORD numb);
    BYTE KkmCodeAtomEx(BYTE *present, BYTE num, BYTE* coordb, DWORD cmCode);
    BYTE KkmFirmAtomEx(BYTE *present, BYTE num, BYTE* coordb);
    
    //*** 7. ���������� ������� ��� �������������� ������������ ���� *************
    BYTE mbs_head(BYTE oprCodeEklz = 1, BYTE DptNum = 0, char* DptName = (char *)"0");//���� ��������� ����//���� ������� ����
    BYTE mbs_head2(BYTE oprCodeEklz = 1, BYTE DptNum = 0, char* DptName = (char *)"0", BYTE DocType = DOC_SALE);//���� ��������� ����//���� ������� ����
    BYTE mbs_RecItem(char* pGoodsName, char* pBarCode, char* pDepNumber, DWORD amt, DWORD Quantity, DWORD price,
                     DWORD VatInfo, BOOL fWeight, char* pUnitName=(char *)"");
    BYTE mbs_RecItemVoid(char* pGoodsName, char* pBarCode, char* pDepNumber, DWORD amt, DWORD Quantity, DWORD price,
                         DWORD VatInfo, BOOL fWeight, char* pUnitName=(char *)"");
    BYTE mbs_Subtotal(DWORD amt);
    BYTE mbs_put(int Amt, DWORD RecNum, DWORD PosID, BYTE DocType, BOOL fCrdCard=FALSE, BOOL fCredit=FALSE,
                 char* pDocName=NULL, char* pDocNum=NULL, BYTE oprCodeEklz=1, BOOL fNoDetail = FALSE, BOOL fTotalBold = FALSE);//�������� ����� � �����//������ ����� �� �����//������� � ������������ ����
    BYTE mbs_put2(int Amt, DWORD RecNum, DWORD PosID, BYTE DocType, BOOL fCrdCard=FALSE, BOOL fCredit=FALSE, BOOL fPayGoods = FALSE,
                  char* pDocName=NULL, char* pDocNum=NULL, BYTE oprCodeEklz=1, BOOL fNoDetail = FALSE, BOOL fTotalBold = FALSE, BOOL fPrintFerstSepr = TRUE);//�������� ����� � �����//������ ����� �� �����//������� � ������������ ����
    BYTE mbs_put4(int Amt, DWORD RecNum, DWORD PosID, BYTE DocType, BOOL fCrdCard=FALSE, BOOL fCredit=FALSE, BOOL fPayGoods = FALSE,
                  char* pDocName=NULL, char* pDocNum=NULL, BYTE oprCodeEklz=1, BOOL fNoDetail = FALSE, BOOL fTotalBold = FALSE, BOOL fPrintFerstSepr = TRUE, BOOL fCbrFormat = FALSE);//�������� ����� � �����//������ ����� �� �����//������� � ������������ ����
    BYTE mbs_put3(int Amt, DWORD RecNum, DWORD PosID, BYTE DocType, BYTE oprCodeEklz);//�������� ����� � �����//������ ����� �� �����//������� � ������������ ����
    
    BYTE mbs_pos(int pos, char* pGoodsName, char* pBarCode, char* pDepNumber, char* pUnitName, int amt,
                 int Quantity, int price, DWORD VatInfo, BOOL fVoid, BOOL fWeight, BOOL fSubtotal=FALSE);//���� ������� ����
    
    BYTE mbs_tot(int Total, int Chg, int Cash,
                 PaymentSt CardPay[], PaymentSt CreditPay[], char* TrLn, DWORD RecNum, DWORD PosID);//, long szTrLn);
    BYTE mbs_tot2(int Total, int Chg, int Cash, int PayGoods,
                  PaymentSt CardPay[], PaymentSt CreditPay[], char* TrLn, DWORD RecNum, DWORD PosID, DWORD NumRoom, DWORD NumTable);//, long szTrLn);
    BYTE mbs_tot_first_rec(int Total, int Chg, int Cash, int PayGoods,
                           PaymentSt CardPay[], PaymentSt CreditPay[], char* TrLn, DWORD RecNum, DWORD PosID, DWORD NumRoom, DWORD NumTable, BYTE fFirstRec);//, long szTrLn);
    
    BYTE mbs_sale(int Amt, DWORD DepNum, //DWORD RecNum, DWORD PosID,
                  int CardSum, int CreditSum, int CashSum, int ChgSum, BYTE oprCodeEklz, BOOL fTotalBold = FALSE);
    
    BYTE mbs_adjust_sum(BOOL fVoid, int Prc, int AllPriceSum, BOOL fPercentage, BOOL fSubtotal, int VatID, int DeltaPriceSum);
    BYTE mbs_adjust_sum(BOOL fVoid, int Prc, int AllPriceSum, BOOL fPercentage, BOOL fSubtotal, int VatID, int DeltaPriceSum,
                        char* dsc_descr/* = NULL*/);
    
    BYTE mbs_RecItemAdjust(int Prc, int AllPriceSum, BOOL fPercentage, int VatID, char* dsc_descr);
    BYTE mbs_RecItemAdjustVoid(int Prc, int AllPriceSum, BOOL fPercentage, int VatID, char* dsc_descr);
    BYTE mbs_SubtotalAdjust(int Prc, int AllPriceSum, BOOL fPercentage, char* dsc_descr);
    BYTE mbs_SubtotalAdjustVoid(int Prc, int AllPriceSum, BOOL fPercentage, char* dsc_descr);
    //*** 8. ������������ ������� ���������� �� ������ ***************************
    
    //BYTE DoPrintingDsrCtrl(long Station, BYTE *Data, long szData, long szInData, BYTE WaitDelay,
    //				BOOL fUseDSR, BOOL fDataRqst);
    
    BYTE DoPrinting(long Station, BYTE *Data, long szData, long szInData, BYTE WaitDelay,
                    /*BOOL fUseDSR = TRUE,*/ BOOL fDataRqst = FALSE);
    BYTE DoPrintingLastCmd();//(long Station = FPTR_S_RECEIPT_DLL);
    BYTE Prn_GetPrinterStatus(BYTE StType, BYTE* PrnStat);
    BYTE Prn_drawer_open ();
    BYTE Prn_drawer_chk(BYTE* DrwStat);
    BYTE Prn_tpm_write(long Station , char *data, int size);
    BYTE Prn_slp_insert(/*BOOL fStart, BYTE WaitTime*/);
    BYTE Prn_slp_remove(/*BOOL fStart*/);
    BYTE Prn_Paper_cut();
    
    //*** 9. ������� ������������ ������� ������� ��������� ������
    
    BYTE SetAddrUpdatePrinterState(long cbAddress);
    BYTE SetAddrDrawData(long cbAddress);
    
    BYTE SetAddrCreateOutputCompleteEvent(long cbAddress);
    
    //*************************************************************************
    
    BYTE KkmExec(BYTE code, WORD szOutData, WORD szInData, BYTE WaitDelay, BYTE Pid=0,BYTE oprCode=1, char* pPPD=NULL);// ce++ LPCTSTR
    BYTE AllData[512];
    long VatSum[16];
    
    // ------------------ "FiscaAndServicelFunction.h" ------------------
    BYTE KkmFactoryReg(char* pFactoryNumFM, char* pFactoryPsw, Date *pRegDate,
                       char* pRegNumKKM, char* pFiscalPsw);//1 ce++ LPCTSTR
    BYTE KkmFiscalProcess(char* pFactoryNum, char* pFiscalPsw, Date *pFiscalDate,
                          char* RegNumKKM, char* InnOwner, char* pAccesPsw);//2 ce++ LPCTSTR
    BYTE KkmPereregProcess(char* pFactoryNum, char* pFiscalPsw, Date *pFiscalDate,
                           char* pNewRegNumKKM, char* pInnOwner, char* pNewAccesPsw);//3 ce++ LPCTSTR
    BYTE KkmFiscalReport(char* psw, BYTE ReportType, BYTE range, Date *NowDate,
                         Date *StartDate, Date *EndDate, WORD StartNum, WORD EndNum);//4 ce++ LPCTSTR
    
    BYTE KkmMkItm(BOOL fNewFormat, Item* pItem);//47
    BYTE KkmMkItmNew(BOOL fNewFormat, ItemNew* pItem);//47
    BYTE KkmMkItmNewEx(BOOL fNewFormat, ItemNew* pItem, BYTE type);//47
    
    BYTE KkmPrnIDData();//53
    BYTE KkmPrnIDDataEx(int Code);//53
    
    BYTE KkmGetVerInternalNum(char* pInternalNum);//99
    
    // ================== "External" ====================================
    static double round(double val);
    static void prn_log(char *data);
    static void CatLogFile(DWORD MaxSizeOfLogFile);
    void prn_log_bin(char *data, int size);
    static void SetCurrDate(Date* pDate, BOOL fOnlyTime = FALSE);
    static void StrToDateTime(char* str, Date* dt, BOOL fTime);
    static int Text2Binary(char *pText, BYTE *pBinary, int MaxTextLen, BOOL fUseCheckSum);
    static int Binary2Text(BYTE *pBinary, char *pText, int szData);
    static int TextDataHandler(char *pBuffer, char **p_param);
    static BOOL IsCommEnable(int ComNum);
    BOOL moebius_init(int Comm, int Speed, char *qwerty, char* version);
#ifdef _ZWINRT
    BOOL moebius_initRT(char *DeviceName, int Speed, char *qwerty, char* version);
#endif
    BOOL moebius_uninit(BOOL fInDllMain);
    int moebius_send(int wsnum, char *buffer, int len);
#ifndef _MSC_VER
    static char* Itoa(int value, char* str, int radix);
#endif
    // ==================================================================
    
    /////////////////////////////////////////////////////////////////////
    static void StartPrintDataThread(void *lParam);
    void PrintDataThread();
    //...................................................................
    static void StartTimerThread(LPVOID lParam);
    void TimerThread();
    //...................................................................
    void UpdatePrinterState(long NewValue);
    void DrawData(CResponseData *pResp);
    void CreateOutputCompleteEvent(long OutputID, BYTE ResponceCode);
    BYTE SendData(CPrintData *pPrintData, BOOL InThread);
    BYTE DataModeRead(CResponseData* pResData, long& WaitingDataLen, long WaitDelay, BOOL fDataRqst);
    BYTE SendDataToKkm(CPrintData* pPrintData);
    BYTE GetInternalPrinterStatus(BYTE WaitDelay = 20);
    DWORD GetPowerState();
    
    // Implementation
    void (CALLBACK *callUpdatePrinterState)(long NewValue) = NULL;
    void (CALLBACK *callDrawData)(CResponseData* pResp) = NULL;//, char* pKkmErrMsg);
    void (CALLBACK *callCreateOutputCompleteEvent)(/*CPrintData*//*CResponseData* pPrintData*/long OutputID, BYTE ResponceCode) = NULL;
    
protected:
    CDevice* m_Device = NULL;
    
    struct fin VatTable[16];
    
    char LogFileName[256];
    
    void InitHeaderData(BYTE TypeCmd, WORD LenCmd, BYTE Pid, BYTE oprCode, char* pPPD);// ce++ LPCTSTR
    BYTE GetCheckSum(BYTE *pData, DWORD szData);
    BYTE GetPrinterData(BYTE* pCmd, BYTE szCmd, BYTE* pData, long* pszData, BYTE WaitTime/*, BOOL fUseDSR*/);
    void AddDataToResponseQueue(CResponseData* pResData, BYTE RespCode, DWORD DataLen);
    
    /////////////////////////////////////////////////////////////////////
    std::thread  *m_pPrintDataThread = NULL;
    std::thread  *m_pTimerThread = NULL;
    
    CQueue<CResponseData> *m_pResponseDataQueue = NULL;
    CQueue<CPrintData> *m_pPrintDataQueue = NULL;
    
public:
    semaphore *m_ThreadSleepEv = NULL;
    semaphore *m_ThreadSleepResponceEv = NULL;
    semaphore *m_ThreadResumeEv = NULL;
    CResponseData *pLastResData = NULL;
    
    std::mutex *m_pLockCallBackFuction = NULL;
};

#if defined(_MSC_VER) && !defined(WINAPI_FAMILY)
#include "ExternC.h"
#endif

#endif // !defined(AFX_MOEBIUSKKM_H__9CE2239E_7ED3_40DA_9A36_3ADAF7D97FB1__INCLUDED_)
