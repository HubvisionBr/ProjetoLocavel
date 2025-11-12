#include "parmtype.ch"

User Function ATFA036()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
    Local nLinha := 0
    Local nQtdLinhas := 0
    Local cMsg := ""

    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)

        If cIdPonto == "FORMCOMMITTTSPOS"
            ApMsgInfo("Chamada após a gravação da tabela do formulário.")
            If AllTrim(ST9->T9_SITMAN) == "I"
                ST9->(RecLock("ST9",.F.))
					ST9->T9_SITMAN := "A"
					ST9->T9_SITBEM := "A"
                ST9->(MsUnLock())
            EndIf
        EndIf
    EndIf
Return xRet
