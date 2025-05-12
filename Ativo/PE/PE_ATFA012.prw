#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function ATFA012()

	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ''
	Local oModelx := ''
	Local cIdPonto := ''
	Local cIdModel := ''
	Local lIsGrid := .F.
	Local oSN1 := nil
	// Local oSN3 := nil

	default LPRE := .F.

	If aParam <> NIL

		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := ( Len( aParam ) > 3 )

		/*If lIsGrid
		nQtdLinhas := oObj:GetQtdLine()
		nLinha := oObj:nLine
		EndIf */

		If cIdPonto == 'FORMPOS'

			If lIsGrid
				ConOut("ATFA012 - FORMPOS - Valida GRID")
			Else
				ConOut("ATFA012 - FORMPOS - Não é GRID")
			EndIf

		ElseIf cIdPonto == 'FORMLINEPRE'
			If aParam[5] == 'DELETE'
				ConOut("ATFA012 - FORMLINEPRE - DELETE")
			EndIf

		ElseIf cIdPonto == 'FORMLINEPOS'
			ConOut("ATFA012 - FORMLINEPOS")

		ElseIf cIdPonto == 'MODELCOMMITTTS'
			ConOut("ATFA012 - MODELCOMMITTTS")

		ElseIf cIdPonto == 'MODELCOMMITNTTS'

			ConOut("ATFA012 - MODELCOMMITNTTS")

			oModelx := FWModelActive() //Carregando Model Ativo
			if oModelx:GetModel('SN1MASTER') <> nil
				oSN1 := oModelx:GetModel('SN1MASTER')
			endif
			
			_lLinDel := oModelx:GetOperation() == 5

			if oSN1 <> nil .and. (altera .or. inclui .or. _lLinDel)
				_lLinDel := oModelx:GetOperation() == MODEL_OPERATION_DELETE

				IF IsInCallStack("MATA103")
					RecLock("SN1",.F.)
					SN1->N1_CODBAR := SD1->D1_CHASSI
					SN1->(MsUnlock())
				Endif
			endif

		ElseIf cIdPonto == 'FORMCOMMITTTSPRE'

			ConOut("ATFA012 - FORMCOMMITTTSPRE")

		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'

			ConOut("ATFA012 - FORMCOMMITTTSPOS")

		ElseIf cIdPonto == 'MODELCANCEL'
			ConOut("ATFA012 - MODELCANCEL")

		ElseIf cIdPonto == 'BUTTONBAR'
			ConOut("ATFA012 - BUTTONBAR")

			xRet := {}

		ElseIf cIdPonto == 'MODELVLDACTIVE'
			ConOut("ATFA012 - MODELVLDACTIVE")

		EndIf
	EndIf
Return xRet
