#include "rwmake.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRIAITEM  �Autor  �Flavia Emilia       � Data �  07/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � PROGRAMA PARA CRIACAO DO ITEM CONTABIL                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CRIAITEM()
Processa( {|| PrcCtb01()} ,OemToAnsi("Atualiza��o do Item Cont�bil - Fornecedores"),"Processando...")
Processa( {|| PrcCtb02()} ,OemToAnsi("Atualiza��o do Item Cont�bil - Clientes"),"Processando...")
Processa( {|| PrcCtb03()} ,OemToAnsi("Atualiza��o do Item Cont�bil - Bancos"),"Processando...")
Return

Static Function PrcCtb01()
*****************************************************************************************************
Local cItemCont := ""
dbSelectArea("SA2")
dbGoTop()      
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
    IncProc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	cItemCont := "F"+ALLTRIM(SA2->A2_COD) + ALLTRIM(SA2->A2_LOJA)
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") , ;
		CTD_ITEM   With cItemcont      , ;
		CTD_DESC01 With SA2->A2_NOME   , ;
		CTD_CLASSE With "2"            , ;
		CTD_NORMAL With "0"            , ;
		CTD_DTEXIS With ctod("01/01/1980") , ;
		CTD_BLOQ   With '2'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA2")
	dbSkip()
End
Return

Static Function PrcCtb02()
Local cItemCont := ""
dbSelectArea("SA1")
dbGoTop()
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
	incproc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	//IF Alltrim(xfilial("SA1"))<>""
	//	cItemCont := "C"+ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)
//	else
		cItemCont := "C"+ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)
//	endif
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") , ;
				CTD_ITEM   With cItemcont      , ;
				CTD_DESC01 With SA1->A1_NOME   , ;
				CTD_CLASSE With "2"            , ;
				CTD_NORMAL With "0"            , ;
				CTD_DTEXIS With ctod("01/01/1980") , ;
				CTD_BLOQ   With '2'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA1")
	dbSkip()
End
Return

Static Function PrcCtb03()
Local cItemCont := ""
dbSelectArea("SA6")
dbGoTop()
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
	incproc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	//IF Alltrim(xfilial("SA6"))<>""
	//	cItemCont := "C"+ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)
//	else
		cItemCont := "B"+ALLTRIM(SA6->A6_COD) + "/" + ALLTRIM(SA6->A6_AGENCIA) + "/" + ALLTRIM(SA6->A6_NUMCON) 
//	endif
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") , ;
				CTD_ITEM   With cItemcont      , ;
				CTD_DESC01 With SA6->A6_NOME   , ;
				CTD_CLASSE With "2"            , ;
				CTD_NORMAL With "0"            , ;
				CTD_DTEXIS With ctod("01/01/1980") , ;
				CTD_BLOQ   With '2'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA6")
	dbSkip()
End
Return
