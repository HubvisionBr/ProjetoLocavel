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
Local i         := 0
Local  _dPedido := CTOD("  /  /  ")

If lBloqNFE
	
	For i := 1 To Len(aCols)

		If !aCols[n][Len(aHeader)+1]  // Não considera quando a linha está deletada
			
			dbSelectArea("SC7")

			If dbSeek(xFilial("SC7")+aCols[1][GdFieldPos("D1_PEDIDO")])
				
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
				EndIf
			EndIf
		EndIf
	Next
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
