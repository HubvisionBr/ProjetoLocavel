#Include "totvs.ch""

User Function MA106VLG

	Local nQuant := 0
	Local lRet := .T.
        Local lVldSA := SuperGetMv("LC_VLDSA ",,.F.)

	IF !inclui
                IF lVldSA
                        nQuant := U_VLDZCP2()

                        IF nQuant > 0
                                MsgInfo("Foi encontrada análise de SA pendente! Não será possível prosseguir!")
                                lRet := .F.
                        Else
                                nQuant := U_VLDZCP3()

                                IF nQuant > 0
                                        MsgInfo("Esta SA precisa ser analisada antes. Não será possível prosseguir!")
                                        lRet := .F.
                                Endif
                        Endif
                Endif
	Endif

Return lret

User Function VLDZCP2()

	Local cAlias := GetNextAlias()
	Local nQuant := 0

	BEGINSQL Alias cAlias

        SELECT COUNT(*) AS CONTAGEM
        FROM %TABLE:ZCP% ZCP 
        WHERE ZCP.%NOTDEL%
        AND ZCP_FILDES = %Exp:SCP->CP_FILIAL%
        AND ZCP_NUMSA = %Exp:SCP->CP_NUM%
        AND (ZCP_STATUS = ' ' OR ZCP_STATUS = 'A')
       
	ENDSQL

	IF !(cAlias)->(Eof())
		nQuant := (cAlias)->CONTAGEM
	Endif


Return nQuant

User Function VLDZCP3()

	Local cAlias := GetNextAlias()
	Local nQuant := 0

	BEGINSQL Alias cAlias

        SELECT COUNT(*) AS CONTAGEM  FROM %TABLE:SCP%  SCP
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
        AND CP_QUANT > (SELECT B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPSA FROM %TABLE:SB2%  WHERE D_E_L_E_T_ = ' ' AND B2_COD = CP_PRODUTO AND CP_LOCAL = B2_LOCAL AND CP_FILIAL = B2_FILIAL)
        ORDER BY CP_FILIAL, CP_NUM, CP_PRODUTO,M0_ESTENT,M0_CODMUN, B2_FILIAL

	ENDSQL


	IF !(cAlias)->(Eof())
		nQuant := (cAlias)->CONTAGEM
	Endif


Return nQuant
