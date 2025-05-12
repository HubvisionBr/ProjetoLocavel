#Include "totvs.ch""

User Function A105DELOK

Local nQuant := 0
    Local lRet := .T.

    IF !inclui
        nQuant := U_VLDZCP()

        IF nQuant > 0
            MsgInfo(" A105DELOK - Existem registros da Análise de SA aprovadas!")
            lRet := .F.
        Endif
    Endif

Return lret
