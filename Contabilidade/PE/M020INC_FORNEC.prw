//PONTO DE ENTRADA NO CADASTRO DE FORNECEDORES PARA CRIAÇÃO
//DO ITEM CONTÁBIL NA TABELA CTD E GRAVAÇÃO NO CAMPO A2_XITEMCC
//DATA CRIAÇÃO: 06/01/2021 - JEAN VALÕES - NP3 

#Include "Rwmake.ch"
#Include "Topconn.ch
           
User Function M020INC
Local _nOp     := PARAMIXB
Local aAreaSA2 := SA2->(GetArea())
Local aAreaCTD := CTD->(GetArea())

DbSelectArea("CTD")
CTD->(DbSetOrder(1))
If _nOp <> 3
	If !(CTD->(DbSeek(xFilial("CTD")+"F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA))))
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL   := xFilial("CTD") 
		CTD->CTD_ITEM	  := "FOR"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
		CTD->CTD_CLASSE   := "2"          
		CTD->CTD_DESC01   := SA2->A2_NOME
		CTD->CTD_BLOQ	  := "2"    
	   	CTD->CTD_DTEXIS   := CTOD("01/01/1980")
	   	CTD->CTD_ITLP 	  := "FOR"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
		CTD->(MsUnLock())          

		SA2->A2_XITEMCC   := "FOR"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
	EndIF
ElseIf _nOp == 3
	If !(CTD->(DbSeek(xFilial("CTD")+"F"+ALLTRIM(M->A2_COD)+ALLTRIM(M->A2_LOJA))))
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL   := xFilial("CTD") 
		CTD->CTD_ITEM	  := "FOR"+ALLTRIM(M->A2_COD)+ALLTRIM(M->A2_LOJA)
		CTD->CTD_CLASSE   := "2"          
		CTD->CTD_DESC01   := M->A2_NOME
		CTD->CTD_BLOQ	  := "2"    
	   	CTD->CTD_DTEXIS   := CTOD("01/01/1980")
	   	CTD->CTD_ITLP 	  := "FOR"+ALLTRIM(M->A2_COD)+ALLTRIM(M->A2_LOJA)
		CTD->(MsUnLock())          

		M->A2_XITEMCC   := "FOR"+ALLTRIM(M->A2_COD)+ALLTRIM(M->A2_LOJA)
	EndIF
Endif	
RestArea(aAreaSA2)
RestArea(aAreaCTD)

Return(.T.)   
