#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

User Function HVP0401M()
	Local aArea := FWGetArea()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := Nil
	Local cIdPonto := ""
	Local cIdModel := ""
	Local oModel
	Local oModelGrid
	Local oView

	//Se tiver parametros
	If aParam != Nil

		//Pega informacoes dos parametros
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		//Após carregar toda a tela e estar na adição de botões
		If cIdPonto == "BUTTONBAR"
			xRet := {}

			//Intercepta o Model, a Grid e a View
			oModel      := FWModelActive()
			oModelGrid  := oModel:GetModel("GRIDID")
			oView        := FWViewActive()

			//Limpando a grid
			If oModelGrid:CanClearData()
				oModelGrid:ClearData()
			EndIf

            cCodMun := "%CASE WHEN M0_ESTENT = '"+SM0->M0_ESTENT+"' THEN '1'||M0_ESTENT ELSE '2'||M0_ESTENT END M0_ESTENT%"

             BEGINSQL Alias cAlias

                SELECT CP_FILIAL, CP_NUM, CP_ITEM, CP_PRODUTO, B1_DESC, CP_UM, CP_QUANT,
                (CP_QUANT - (SELECT B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPSA FROM %TABLE:SB2%  WHERE D_E_L_E_T_ = ' 'AND B2_COD = CP_PRODUTO AND CP_LOCAL = B2_LOCAL AND CP_FILIAL = B2_FILIAL)) AS XQUANT , 
                CP_LOCAL, CP_DATPRF, B2_FILIAL, (B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPSA) AS SALDO, CASE WHEN ZCP_QUANT IS NOT NULL THEN ZCP_QUANT ELSE 0 END AS SOLICITACAO, B2_LOCAL, %EXP:cCodMun% , M0_CODMUN  FROM %TABLE:SCP%  SCP
                INNER JOIN %TABLE:SB2%  SB2
                ON B2_COD = CP_PRODUTO
                AND SB2.%NOTDEL%
                INNER JOIN %TABLE:SB1%  SB1
                ON CP_PRODUTO = B1_COD
                AND SB1.%NOTDEL%
                LEFT JOIN %TABLE:ZCP% ZCP 
                ON ZCP.%NOTDEL%
                AND ZCP_FILORI = B2_FILIAL
                AND ZCP_NUMSA = CP_NUM
                AND ZCP_ITEM = CP_ITEM
                AND ZCP_FILIAL = B2_FILIAL
                AND ZCP_PRODUT = CP_PRODUTO
                INNER JOIN SYS_COMPANY SM0
                ON M0_CODFIL = B2_FILIAL
                WHERE SCP.%NOTDEL%
                AND CP_FILIAL = %Exp:SCP->CP_FILIAL%
                AND CP_NUM = %Exp:SCP->CP_NUM%
                AND CP_PREREQU = ' '
                AND B2_QATU > 0
                AND (ZCP_QTDAPR = 0  OR ZCP_QTDAPR IS NULL)
                AND (ZCP_STATUS = ' ' OR ZCP_STATUS IS NULL)
                // AND (ZCP_STATUS = ' ' OR ZCP_STATUS IS NULL)
                AND CP_QUANT > (SELECT B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPSA FROM %TABLE:SB2%  WHERE D_E_L_E_T_ = ' ' AND B2_COD = CP_PRODUTO AND CP_LOCAL = B2_LOCAL AND CP_FILIAL = B2_FILIAL)
                ORDER BY CP_FILIAL, CP_NUM, CP_PRODUTO,M0_ESTENT,M0_CODMUN, B2_FILIAL

            ENDSQL
 
            // {'SOLICIT', 'ITEM', 'PRODUTO', 'UM', 'QUANT', 'LOCDES', 'DTNECES', 'FILORI', 'SALDO', 'QTDTRF', 'LOCORI'}
            nLinha := 1
            lContem := .F.
            IF !(cAlias)->(Eof())
                While !(cAlias)->(Eof())
                    DbSelectArea(cAliasTmp)

                    IF (cAlias)->CP_FILIAL <> (cAlias)->B2_FILIAL
                        lContem := .T.
                        RecLock(cAliasTmp,.T.)
                        // cKey := (cAlias)->CP_NUM 
                        oModelGrid:AddLine()
                        oModelGrid:GoLine(nLinha)

                        (cAliasTmp)->SOLICIT  := (cAlias)->CP_NUM 
                        oModelGrid:LoadValue("SOLICIT",(cAlias)->CP_NUM )
                        (cAliasTmp)->ITEM     := (cAlias)->CP_ITEM    
                        oModelGrid:LoadValue("ITEM",(cAlias)->CP_ITEM )
                        (cAliasTmp)->PRODUTO  := (cAlias)->CP_PRODUTO 
                        oModelGrid:LoadValue("PRODUTO",(cAlias)->CP_PRODUTO )
                        (cAliasTmp)->DESCRI  := (cAlias)->B1_DESC 
                        oModelGrid:LoadValue("DESCRI",(cAlias)->B1_DESC )
                        (cAliasTmp)->UM       := (cAlias)->CP_UM      
                        oModelGrid:LoadValue("UM",(cAlias)->CP_UM )
                        (cAliasTmp)->QTDOR       := (cAlias)->CP_QUANT      
                        oModelGrid:LoadValue("QTDOR",(cAlias)->CP_QUANT )
                        (cAliasTmp)->SLDLC       :=  ((cAlias)->CP_QUANT - (cAlias)->XQUANT   )    
                        oModelGrid:LoadValue("SLDLC", ((cAlias)->CP_QUANT - (cAlias)->XQUANT ))
                        (cAliasTmp)->QUANT    := (cAlias)->XQUANT - u_sumsolicit((cAlias)->CP_NUM,(cAlias)->CP_ITEM,(cAlias)->CP_PRODUTO)
                        oModelGrid:LoadValue("QUANT",(cAlias)->XQUANT - u_sumsolicit((cAlias)->CP_NUM,(cAlias)->CP_ITEM,(cAlias)->CP_PRODUTO))
                        (cAliasTmp)->LOCDES   := (cAlias)->CP_LOCAL  
                        oModelGrid:LoadValue("LOCDES",(cAlias)->CP_LOCAL )
                        (cAliasTmp)->DTNECES  := StoD((cAlias)->CP_DATPRF)
                        oModelGrid:LoadValue("DTNECES",StoD((cAlias)->CP_DATPRF) )
                        (cAliasTmp)->FILORI   := (cAlias)->B2_FILIAL  
                        oModelGrid:LoadValue("FILORI",(cAlias)->B2_FILIAL )
                        (cAliasTmp)->DESFIL   := FWFilialName(,(cAlias)->B2_FILIAL,1)
                        oModelGrid:LoadValue("DESFIL",FWFilialName(,(cAlias)->B2_FILIAL,1) )
                        (cAliasTmp)->SALDO    := (cAlias)->SALDO   
                        oModelGrid:LoadValue("SALDO",(cAlias)->SALDO )
                        (cAliasTmp)->QTDTRF   := (cAlias)->SOLICITACAO  
                        oModelGrid:LoadValue("QTDTRF",(cAlias)->SOLICITACAO )
                        (cAliasTmp)->LOCORI   := (cAlias)->B2_LOCAL  
                        oModelGrid:LoadValue("LOCORI",(cAlias)->B2_LOCAL )
                        (cAliasTmp)->RECTMP   := nLinha
                        oModelGrid:LoadValue("RECTMP",nLinha )
                        nLinha++
                        (cAliasTmp)->(MsUnlock())
                    EndIf
                    
                    (cAlias)->(DbSkip())
                EndDo
                
                IF !lContem
                    oModelGrid:SetNoUpdateLine(.T.)
                    MsgInfo("Não contém dados!")
                Endif
            Else
                oModelGrid:SetNoUpdateLine(.T.)
                MsgInfo("Não contém dados!")
            Endif


			//Posiciona na linha 1
			oModelGrid:GoLine(1)
            oModelGrid:SetNoDeleteLine(.T.)
            oModelGrid:SetNoInsertLine(.T.)
			oView:Refresh()

		EndIf

	EndIf

	FWRestArea(aArea)
Return xRet

User Function sumsolicit(cNumSa,cItem,cProd)

    Local nRet := 0
    Local cAliSum := GetNextAlias()

    BEGINSQL Alias cAliSum

        SELECT SUM(ZCP_QUANT) AS SOLICITADA FROM %TABLE:ZCP% ZCP 
        WHERE ZCP.%NOTDEL%
        AND ZCP_NUMSA = %Exp:cNumSA%
        AND ZCP_ITEM = %Exp:cItem%
        AND ZCP_PRODUT = %Exp:cProd%

    ENDSQL

    IF !(cAliSum)->(Eof())
        nRet := (cAliSum)->SOLICITADA
    Endif

REturn nRet
