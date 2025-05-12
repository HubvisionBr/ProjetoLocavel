#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

User Function HVP0402M()
	Local aArea := FWGetArea()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := Nil
	Local cIdPonto := ""
	Local cIdModel := ""
	Local oModel1 := Nil
	Local oModel2 := Nil
	Local nLinAtu := 0
	Local nTotLin := 0
	Local i

	//Se tiver parametros
	If aParam != Nil

		//Pega informacoes dos parametros
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		//Após carregar toda a tela e estar na adição de botões
		If  cIdPonto == "MODELCOMMITTTS"
			xRet := .T.

			//Intercepta o Model, a Grid e a View
			oModel1 := FwModelActive()
			oModel2 := oModel1:GetModel("GRIDID")
			nLinAtu := oModel2:GetLine()
			nTotLin := oModel2:GetQtdLine()

			For i := 1 to nTotLin
				IF i == 1
					cFilZCP := fwfldget("ZCP_FILORI")
					cNumSA  := fwfldget("ZCP_NUMSA")
				Endif

				DbSelectARea("SC0")
				SC0->(DbSetOrder(1))
				
			Next i
		EndIf

	EndIf

	FWRestArea(aArea)
Return xRet
