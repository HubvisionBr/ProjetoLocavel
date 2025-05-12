#Include 'Protheus.ch'

User Function F560AUT(nOpc,cTipo,cCodEst)

Local aArray := {}
//Local aArray2:= {} // Utilizado na prestacao de contas
Local lRet   := .F.
//Local nOpc := 3 // 3 - Inclusao, 4 - Prestacao de Contas, 5 - Exclusao
Private lMsErroAuto := .F.

Do Case
  Case nOpc == 3
  //-----------------------------------------------------------------------
  // Programa de inclusao de movimentos no caixinha via rotina automatica |
  //-----------------------------------------------------------------------

  cNum := GetSxeNum("SEU","EU_NUM")
  
  aArray := { { "EU_NUM" , cNum , NIL },;
                   { "EU_CAIXA" , SET->ET_CODIGO , NIL },;
                   { "EU_TIPO" , cTipo , NIL },; //00 - Despesa, 01 - Adiantamento
                   { "EU_HISTOR" ,ALLTRIM(SUBSTR(CNOMEFOR,10,30)) , NIL },;
                   { "EU_NRCOMP" ,CTITULO , NIL },; 
                   { "EU_VALOR" , nVALPGTO , NIL },; 
                   { "EU_BENEF" , alltrim(cBENEF) , NIL },;
                   { "EU_DTDIGT" , ddatabase, NIL },;
                   { "EU_DTEMIS" , ddatabase, NIL },; 
                   { "EU_FORNECE" ,SUBSTR(CNOMEFOR,1,8) , NIL },;
                   { "EU_LOJA" , cLoja, NIL },;
                   { "EU_MOEDA" , 1, NIL },;
                   { "EU_VLMOED2" , 0, NIL },;
                   { "EU_XNATUREZ", SE2->E2_NATUREZ, NIL},;
                   { "EU_ENVUMOV" , '2', NIL },;
                   { "EU_NOME" , "LCTO AUTOMATICO CAIXINHA", NIL }}
                   
  MsExecAuto( { |x,y,z| FINA560(x,y,z)} ,0, aArray, 3) 

  If lMsErroAuto
    
    MostraErro()
  
  Else
    
    lRet := .T.
    ConfirmSX8()
    Reclock("SEU",.F.) //reforço
    Replace EU_XNATUREZ with SE2->E2_NATUREZ
    Replace EU_NATUREZ with SE2->E2_NATUREZ
    SEU->(msunlock())
    //Alert("Inclusao do movimento efetuada.")
  
  Endif

  Case nOpc == 5
  //-----------------------------------------------------------------------
  // Programa de exclusao de movimentos no caixinha via rotina automatica |
  //----------------------------------------------------------------------- 
  
    //aArray := { { "EU_NUM" , "0000000082", NIL } }
    aArray := { { "EU_NUM" , cCodEst, NIL } }
    MsExecAuto( { |x,y,z| FINA560(x,y,z)} ,0, aArray, 5) 

    If lMsErroAuto
      
      MostraErro()
    
    Else
      //Alert("Exclusao do movimento efetuada.")
      lRet := .T.
    
    Endif

EndCase

Return lRet
