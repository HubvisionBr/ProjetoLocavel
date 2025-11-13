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

		If !Acols[n][Len(aHeader)+1]  // Não considera quando a linha quando está deletada
			
			dbSelectArea("SC7")

			If dbSeek(xFilial("SC7")+aCols[1][GdFieldPos("D1_PEDIDO")])
				
				// Verifica a Data de Emissão da Nota em relação à Data do Pedido de Compras
						
				If !Empty(aCols[i][_nPos])
					_dPedido := CTOD("  /  /  ")
					_dPedido := SC7->C7_EMISSAO

					If dDemissao < _dPedido
					   FWAlertWarning("A Data de Emissão da Nota Digitada é menor que a Data de Emissão do Pedido Nº "+ aCols[i][_nPos] + CHR(13) + CHR(10) +;
					               "Operação Não Permitida (Favor solicitar Autorização à Diretoria)", "Atenção!")
					   lRet:=.F.
					   Return lRet
					EndIf
				EndIf
			EndIf
		EndIf
	Next
EndIf

FwRestArea(aArea)

Return lRet
