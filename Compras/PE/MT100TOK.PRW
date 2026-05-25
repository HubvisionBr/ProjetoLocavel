#INCLUDE "PROTHEUS.CH"

/*
Programa : MT100TOK
Descrição: Ponto de Entrada para validar a Data de Digitação do Documento de Entrada que não pode ser menor que a Data de
           Inclusão do Pedido de Compra
Uso      : MATA103 (Documento de Entrada)
Autor    : HC - MAR/2025
*/

User Function MT100TOK()

Local lBloqNFE  := GetMv("LV_XBLQNFE")    // MV_XBLQNFE - Lógico, conteúdo .T. (ativa validação), .F. (desativa validação)
Local lRet      :=.T.
Local aArea     := FwGetArea()
Local _nPos     := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_PEDIDO"})
Local _nPC      := aScan(aHeader,{|x|UPPER(AllTrim(x[2])) == "D1_TOTAL"})
Local cNumSc7   := ""
Local i         := 0
Local nTotNF    := 0
Local nTotPC    := 0
Local  _dPedido := CTOD("  /  /  ")

If lBloqNFE
	
	For i := 1 To Len(aCols)

		If !aCols[i][Len(aHeader)+1]  // Não considera quando a linha está deletada
			
			dbSelectArea("SC7")
			SC7->(DbSetOrder(1))//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
			If dbSeek(xFilial("SC7")+aCols[i][GdFieldPos("D1_PEDIDO")]+aCols[i][GdFieldPos("D1_ITEMPC")])
				
				// Verifica a Data de Emissão da Nota em relação à Data de Emissão do Pedido de Compras
						
				If !Empty(aCols[i][_nPos])
					_dPedido := CTOD("  /  /  ")
					_dPedido := SC7->C7_EMISSAO

					If dDemissao < _dPedido .Or. dDataBase > dDemissao
						// Verifica se existe log
						ZZV->(DbSetOrder(1))
						If ZZV->(DbSeek(xFilial('ZZV')+SC7->C7_NUM+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA))
							// Se existir, verifica se tá aprovado
							If ZZV->ZZV_STATUS == 'A'
								lRet := .T.
							Else// Se não estiver aprovado alerta
								FWAlertWarning("A NF Nº " + M->cNFISCAL + " foi emitida antes do Pedido de Compra Nº "+ aCols[i][_nPos] + CHR(13) + CHR(10) +;
												"e está em desacordo com as normas de Aprovação para Compras" + CHR(13) + CHR(10) +;
												"Para prosseguir com essa operação é necessária autorização da Diretoria", "Atenção!")
								lRet := .F.
								Exit
							EndIf
						Else// Se não existir, alerta e loga
							FWAlertWarning("A NF Nº " + M->cNFISCAL + " foi emitida antes do Pedido de Compra Nº "+ aCols[i][_nPos] + CHR(13) + CHR(10) +;
											"e está em desacordo com as normas de Aprovação para Compras" + CHR(13) + CHR(10) +;
											"Para prosseguir com essa operação é necessária autorização da Diretoria", "Atenção!")
							lRet := .F.
							// Loga
							grvZZV()
							Exit							
						EndIf
					EndIf
					// Soma total dos itens da NF
					nTotNF += aCols[i][_nPC]
					nTotPC += SC7->C7_TOTAL
					cNumSc7 := SC7->C7_NUM
				EndIf
			EndIf
		EndIf
	Next
	// Verifica se o Valor Total da NF que está sendo incluída é maior do que o Valor Total do Pedido de Compra						
	If nTotNF > nTotPC
		FWAlertWarning("A NF Nº " + M->cNFiscal + " está com o Valor Total maior do que o Pedido de Compra Nº "+ cNumSc7 + CHR(13) + CHR(10) +;
						CHR(13) + CHR(10) + "Verifique antes de Incluir a Nota", "Atenção")
		lRet := .F. 
	Else
		lRet := .T.   
	EndIf	
EndIf

FwRestArea(aArea)

Return lRet

Static Function grvZZV()
	If RecLock('ZZV',.T.)
		ZZV->ZZV_FILIAL		:= FwxFilial("ZZV")
		ZZV->ZZV_NUM		:= SC7->C7_NUM
		ZZV->ZZV_PRODUT		:= SC7->C7_PRODUTO
		ZZV->ZZV_FORNEC		:= SC7->C7_FORNECE
		ZZV->ZZV_LOJA		:= SC7->C7_LOJA
		ZZV->ZZV_QUANT		:= SC7->C7_QUANT
		ZZV->ZZV_PRECO  	:= SC7->C7_PRECO
		ZZV->ZZV_EMISSAO	:= SC7->C7_EMISSAO
		ZZV->ZZV_DOC    	:= M->cNFISCAL
		ZZV->ZZV_SERIE  	:= M->cSERIE
		ZZV->ZZV_NFEMIS		:= dDemissao
		ZZV->(MsUnlock())
	EndIf
Return
