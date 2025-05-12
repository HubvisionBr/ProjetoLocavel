#Include "rwmake.ch"
#Include "protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} M460FIM 
avar as informações de no título a receber
//Ponto de entrada para gr
@type function
@author HUBVISION
@since 06/01/2024

@history 
/*/

User Function M460FIM()

//Local cChave		:= SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaATU		:= GetArea()
Local cGrpVei  := Getmv("MV_XGRPPRO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa funcao para gravacao dos dados do veiculo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If alltrim(funname()) = "ATFA036" 
    
    If alltrim(SN1->N1_PRODUTO) $ alltrim(cGrpVei) 
        
        cIdentAtiv := alltrim(SN1->N1_CHAPA) + " - " // Incluido depois, solicitado que a placa seja primeiro
        cIdentAtiv += alltrim(SN1->N1_DESCRIC) + " - " 
        // cIdentAtiv :=""+alltrim(SN1->N1_CHAPA)
        //cIdentAtiv +="AQUISICAO "+DtoC(SN1->N1_AQUISIC)+"/"
        cIdentAtiv += alltrim(SN1->N1_CODBAR)

        Reclock("SF2",.f.)
        Replace F2_MENNOTA with alltrim(SF2->F2_MENNOTA) + cIdentAtiv
        SF2->(MsUnLock())
        U_HISTSE1(cIdentAtiv)
    
    Endif

Endif

RestArea(aAreaSE1)
RestArea(aAreaSD2)
RestArea(aAreaATU)
RestArea(aAreaSF2)

Return
        

User Function HISTSE1(cIdentAtiv)
 
dbSelectArea("SE1")
dbSetOrder(1)      
If dbSeek(xFilial("SE1")+SF2->F2_SERIE + SF2->F2_DOC)
   While (E1_PREFIXO+E1_NUM) == (SF2->F2_SERIE+SF2->F2_DOC) .and. !Eof()
      RecLock("SE1",.F.)
      E1_HIST :=  cIdentAtiv
      MsUnLock()
      dbSkip()
   EndDo
Endif    

Return


