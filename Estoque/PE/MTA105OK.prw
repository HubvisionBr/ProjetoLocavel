#Include "totvs.ch""

User Function MTA105OK

    Local nQuant := 0
    Local lRet   := .T.
    Local i      := 1
    Local nPosPrd := aScan(aHeader,{| x | Alltrim(x[2]) == "CP_PRODUTO"})
    // Local nPosNum := aScan(aHeader,{| x | Alltrim(x[2]) == "CP_NUM"})
    Local nPosIte := aScan(aHeader,{| x | Alltrim(x[2]) == "CP_ITEM"})
    // Local nPosQtd := aScan(aHeader,{| x | Alltrim(x[2]) == "CP_QUANT"})
    Local aDel  := {}
    // Local aAlt  := {}
    Local aProd := {}

    For i := 1 to Len(aCols)
         IF !aCols[i][Len(aHeader)+1]
            IF aScan(aProd,{|x| x == aCols[i][nPosPrd]}) > 0 //Se encontrar o produto no array, dá mensagem dizendo que tem produto repetido
                MsgInfo("MTA105OK - Existem produtos repetidos nesta SA!")
                Return .F.
            Else
                aAdd(aProd,aCols[i][nPosPrd])
            Endif
         Endif
    Next 
    

    IF !inclui
        nQuant := U_VLDZCP()

        IF nQuant > 0
            MsgInfo("MTA105OK - Existem registros da Análise de SA aprovadas!")
            Return .F.
        Endif

        IF altera
            For i := 1 to Len(aCols)
                IF aCols[i][Len(aHeader)+1]
                    // IF aAlter[i] //Se registro foi alterado
                    //     MsgAlert("MTA105OK - Não é possível alterar informações da linha. Delete a linha e insira uma nova!")
                    //     Return .F.
                    // Else
                        DbSelectArea("ZCP")
                        ZCP->(DbSetOrder(5))
                        If ZCP->(MsSeek(xFilial("ZCP") + aCols[i][nPosPrd] + SCP->CP_NUM + aCols[i][nPosIte] ))
                            While (xFilial("ZCP") + aCols[i][nPosPrd] + SCP->CP_NUM + aCols[i][nPosIte]) == (ZCP->ZCP_FILDES + ZCP->ZCP_PRODUT + ZCP->ZCP_NUMSA + ZCP->ZCP_ITEM)
                                IF ZCP->ZCP_STATUS $ 'P,R'
                                    MsgAlert("MTA105OK - Não é possível alterar/deletar informações da linha, pois já houve análise da SA.")
                                    Return .F.
                                Else
                                    // RecLock("ZCP",.F.)
                                    // ZCP->(DbDelete())
                                    // ZCP->(MsUnlock())
                                    aAdd(aDel,{aCols[i][nPosPrd],SCP->CP_NUM,aCols[i][nPosIte]})
                                Endif
                                ZCP->(Dbskip())
                            EndDo
                        // Else
                        //     aAdd(aDel,{aCols[i][nPosPrd],SCP->CP_NUM,aCols[i][nPosIte]})
                        EndIf
                    // Endif
                Else 
                    IF aAlter[i] //Se registro foi alterado
                        DbSelectArea("ZCP")
                        ZCP->(DbSetOrder(5))
                        If ZCP->(MsSeek(xFilial("ZCP") + aCols[i][nPosPrd] + SCP->CP_NUM + aCols[i][nPosIte] ))
                            While (xFilial("ZCP") + aCols[i][nPosPrd] + SCP->CP_NUM + aCols[i][nPosIte]) == (ZCP->ZCP_FILDES + ZCP->ZCP_PRODUT + ZCP->ZCP_NUMSA + ZCP->ZCP_ITEM)
                                IF ZCP->ZCP_STATUS $ 'P,R'
                                    MsgAlert("MTA105OK - Não é possível alterar informações da linha. Delete a linha e insira uma nova!")
                                    Return .F.
                                Else
                                    RecLock("ZCP",.F.)
                                    ZCP->(DbDelete())
                                    ZCP->(MsUnlock())
                                Endif
                                ZCP->(Dbskip())
                            EndDo
                        Endif
                    Endif
                Endif
            Next i
        Endif
    Endif

    For i := 1 to Len(aDel)
        DbSelectArea("ZCP")
        ZCP->(DbSetOrder(5))
        If ZCP->(MsSeek(xFilial("ZCP") + aDel[i][1] + aDel[i][2] + aDel[i][3] ))
            RecLock("ZCP",.F.)
            ZCP->(DbDelete())
            ZCP->(MsUnlock())
        EndIf
    Next i

Return lret

User Function VLDZCP()

    Local nQuant := 0
    Local cAlias := GetNextAlias()
    Local cFiltro := ""

    Pergunte("MTA105",.F.)

    IF MV_PAR02 == 1
        cFiltro := "% CP_PRODUTO = '"+SCP->CP_PRODUTO+"' AND CP_ITEM = '"+SCP->CP_ITEM+"' %"
    ELSE
        cFiltro := "% 1 = 1 %"
    Endif


    BEGINSQL Alias cAlias

        SELECT COUNT(*) AS CONTAGEM FROM %TABLE:SCP%  SCP
        INNER JOIN %TABLE:SB2%  SB2
        ON B2_COD = CP_PRODUTO
        AND SB2.%NOTDEL%
        LEFT JOIN %TABLE:ZCP% ZCP 
        ON ZCP.%NOTDEL%
        AND ZCP_FILORI = B2_FILIAL
        AND ZCP_NUMSA = CP_NUM
        AND ZCP_ITEM = CP_ITEM
        AND ZCP_FILIAL = B2_FILIAL
        AND ZCP_PRODUT = CP_PRODUTO
        WHERE SCP.%NOTDEL%
        AND CP_FILIAL = %Exp:SCP->CP_FILIAL%
        AND CP_NUM = %Exp:SCP->CP_NUM%
        AND %exp:cFiltro%
        AND CP_PREREQU = ' '
        // AND ZCP_QTDAPR > 0
        AND ZCP_STATUS IN ('P','R')
       
    ENDSQL

     IF !(cAlias)->(Eof())
        nQuant := (cAlias)->CONTAGEM
    Endif

Return nQuant
