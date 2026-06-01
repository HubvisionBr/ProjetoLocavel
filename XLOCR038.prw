#Include "LOCR038.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIF  3
 
//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas Pedido de Venda
#Define COL_01      0015
#Define COL_02      0040
#Define COL_03      0120
#Define COL_04      0160
#Define COL_05      0260
#Define COL_06      0300
#Define COL_07      0360
#Define COL_08      0400
#Define COL_09      0470

// Colunas Medi��o
#Define MCOL_01      0015
#Define MCOL_02      0050
#Define MCOL_03      0085
#Define MCOL_04      0170
#Define MCOL_05      0215
#Define MCOL_06      0200
#Define MCOL_07      0215
#Define MCOL_08      0260
#Define MCOL_09      0300
#Define MCOL_10      0345
#Define MCOL_11      0380
#Define MCOL_12      0420
#Define MCOL_13      0470

#Define COL_TOT      370

/*
{Protheus.doc} XLOCR038
Relatorio Pre-Faturamento (Demonstrativo)
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type Function
@changed OUT/2025 - HC
Especifico Locavel
*/

User Function XLOCR038()
Local aArea := GetArea()
     
    Processa({|| fMontaRel()}, STR0001) //"Aguarde parametrizacao..."
    RestArea(aArea)

Return
 
 // Func:  fMontaRel                             
 // Desc:  Funcao que monta o relatorio                            

Static Function fMontaRel()
Local cPathPDF  := ""
Local cArquivo  := ""
Local cQry038   := ""
Local cAlias038 := GetNextAlias()
Local cPerLoc   := ""
Local cPerLoc38A:= ""
Local cPedAtu   := ""
Local cNota     := ""
Local cQtdVen   := ""
Local nAtual    := 0
Local nTotal    := 0
Local nTotGeral := 0
Local nTotVeic  := 0
Local nColObs   := 470
Local nLargTit  := 0
Local nPagina   := 1
Local nValPed   := 0
Local nTotPed   := 0
Local nTotMed   := 0
Local nTotCus   := 0
Local nDiasPer  := 0
Local nFpgObs   := 200
Local nTamObs   := 0
Local nQtLinObs := 0
Local nLinObs   := 0
Local nPedDesc  := 0
Local nValItem  := 0
Local aAreaFp0  := FP0->(GetArea())
Local aAreaFpa  := FPA->(GetArea())
Local aAreaFpn  := FPN->(GetArea())
Local aAreaFpg  := FPG->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local lPriPed   := .T.
Local lPedido   := .T.
Local lPriMed   := .T.
Local lMedicao  := .F.
Local lPriCus   := .T.
Local lCustoExt := .F.
Local lContinua := .F.
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lLOCR038A := ExistBlock("LOCR038A") 
Local oStatement 
Local lPassou   := .F.
Local lForca    := File("C:\TEMP\R038.TXT")

Private nLinAtu   := 000
Private nTamLin   := 010
Private nLinFin   := 800
Private nColIni   := 010
Private nColFin   := 550
Private nColHora  := 470
Private nColMeio  := (nColFin-nColIni)/2

//Objeto de Impressao
Private oPrintPvt

//Variaveis auxiliares
Private dDataGer  := Date()
Private cHoraGer  := Time()
Private nPagAtu   := 1
Private cNomeUsr  := UsrRetName(RetCodUsr())
Private cCpoProj  := "TJ_PROJETO"
Private cCpoAs    := "TJ_AS"

//Fontes
Private cNomeFont := "Arial"
Private oFontGigN := TFont():New(cNomeFont, 9, -20, .T., .T., 5, .T., 5, .T., .F.)
Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
Private oFontTitN := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .F., 5, .T., 5, .T., .F.)
Private oBrush1   := TBrush():New( , CLR_HGRAY)

Private ECOL_01 := 015
Private ECOL_02 := 060
Private ECOL_03 := 120
Private ECOL_04 := 180
Private ECOL_05 := 250
Private ECOL_06 := 470
     
    //Definindo a pasta tempor�ria do Sistema Operacional/Local e o nome do arquivo com a data e hora (sem dois pontos)
    //cPathPDF  := GetTempPath()
    cPathPDF  := "c:\temp\"
    cArquivo  := "xlocr038_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
        
    //Criando o objeto do FWMsPrinter
    oPrintPvt := FWMsPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
    //Altera local de impressao para nao gerar problema em alguns ambientes
    oPrintPvt:cFilePrint := cPathPDF + cArquivo

    If Pergunte("LOCR038", .T.)

        //Setando atributos necess�rios do relatorio
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(60, 60, 60, 60)

        //Localiza o centro da p�gina
        nLargTit := oPrintPvt:nHorzSize()

        //Montando a consulta dos pedidos
        oStatement := FWPreparedStatement():New()
    
        cQry038 := " SELECT FP0_PROJET, FP0_CLI,FP0_LOJA, FP0_CLICON, FP0_NOMECO, FP0_XLOCAL, FP0_VENDED, FP0_NOMVEN, FP0_AGLUNF, SA1A. A1_NOME CLIFP0,SA1A. A1_CGC, "
        cQry038 += "        A3_NOME,SA1B. A1_COD CODSC5, SA1B. A1_LOJA LOJSC5, SA1B. A1_NOME CLISC5,  " 
        cQry038 += "        C6_NOTA, C6_SERIE,C6_DATFAT, C6_VALOR , C6_PRUNIT, C6_VALDESC, SC6.R_E_C_N_O_ RECSC6, " 
        cQry038 += "        C5_FILIAL, C5_NUM, C6_QTDVEN, C6_DESCRI," 
		If lMvLocBac
            cQry038 += "        FPZ_PERLOC PERLOC," 
        Else
            cQry038 += "        C6_XPERLOC PERLOC,"
        EndIf
        //cQry038 += "        FPA_NFREM , FPA_SERREM, FPA_DNFREM, FPA_GRUA, FPA_TIPOSE, FPA_VRHOR, FPA.R_E_C_N_O_ RECFPA "
        cQry038 += "        FPA_NFREM , FPA_SERREM, FPA_DNFREM, FPA_DESGRU, FPA_XPLACA, FPA_TIPOSE, FPA_VRHOR, FPA_CUSTO, FPA.R_E_C_N_O_ RECFPA, "
        cQry038 += "        T9_ANOMOD,T9_ANOFAB "
        cQry038 += " FROM " + RetSqlName("SC5") + " SC5 "

        cQry038 += " INNER JOIN " + RetSqlName("FP0") + " FP0 ON "
        //cQry038 += "    FP0_FILIAL = '" + xFilial("FP0") + "' " + CRLF
        cQry038 += "    FP0_FILIAL = ? " //1
        cQry038 += "    AND FP0.D_E_L_E_T_ = ' '  "

        If lMvLocBac
            //cQry038 += "    AND FP0_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
            cQry038 += "    AND FP0_PROJET = ? " //2
        Else
            cQry038 += "    AND FP0_PROJET = C5_XPROJET "
        EndIf

        cQry038 += " INNER JOIN " + RetSqlName("FPA") + " FPA ON "
        cQry038 += "    FPA_FILIAL = FP0_FILIAL "
        cQry038 += "    AND FPA.D_E_L_E_T_ = ' ' "
        cQry038 += "    AND FPA_PROJET = FP0_PROJET "

        If lMvLocBac
            /*cQry038 += " INNER JOIN " + RetSqlName("FPY") + " FPY ON " + CRLF
            cQry038 += "    FPY.FPY_FILIAL = '" + xFilial("SA1") + "' " + CRLF
            cQry038 += "    AND FPY.D_E_L_E_T_ = ' '  " + CRLF
            cQry038 += "    AND FPY_PEDVEN = C5_NUM " + CRLF
            cQry038 += "    AND FPY_PROJET = FPA_PROJET " + CRLF*/

            cQry038 += " INNER JOIN " + RetSqlName("FPZ") + " FPZ ON "
            //cQry038 += "    FPZ.FPZ_FILIAL = '" + xFilial("FPZ") + "' " + CRLF
            cQry038 += "    FPZ.FPZ_FILIAL = ? " //3
            cQry038 += "    AND FPZ.D_E_L_E_T_ = ' '  "
            cQry038 += "    AND FPZ_PEDVEN = C5_NUM "
            //cQry038 += "    AND FPZ_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
            cQry038 += "    AND FPZ_PROJET = ? " //4
            cQry038 += "   AND FPZ_AS = FPA_AS "
        EndIf
        
        cQry038 += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON "
        cQry038 += "    C6_FILIAL = C5_FILIAL "
        cQry038 += "    AND SC6.D_E_L_E_T_ = ' ' "
        cQry038 += "    AND C6_NUM = C5_NUM "

        If lMvLocBac
            cQry038 += "   AND C6_ITEM = FPZ_ITEM "
        Else
            cQry038 += "   AND C6_XAS = FPA_AS "
        EndIf

        // Pedidos Faturados 1=Sim, 2=Não, 3=Ambos
        If MV_PAR06 == 1
            cQry038 += "   AND C6_NOTA <> '' "   
        ElseIf MV_PAR06 == 2
            cQry038 += "   AND C6_NOTA = '' "   
        EndIf

        cQry038 += " INNER JOIN " + RetSqlName("SA1") + " SA1A ON "
        //cQry038 += "    SA1A.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
        cQry038 += "    SA1A.A1_FILIAL = ? " //5
        cQry038 += "    AND SA1A.D_E_L_E_T_ = ' '  "
        cQry038 += "    AND SA1A.A1_COD = FP0_CLI "
        cQry038 += "    AND SA1A.A1_LOJA = FP0_LOJA "

        cQry038 += " INNER JOIN " + RetSqlName("SA1") + " SA1B ON "
        //cQry038 += "    SA1B.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
        cQry038 += "    SA1B.A1_FILIAL = ? " // 6
        cQry038 += "    AND SA1B.D_E_L_E_T_ = ' '  "
        cQry038 += " AND SA1B.A1_COD = C5_CLIENTE "
        cQry038 += " AND SA1B.A1_LOJA = C5_LOJACLI "

        cQry038 += " LEFT JOIN " + RetSqlName("SA3") + " SA3 ON "
        //cQry038 += "    A3_FILIAL = '" + xFilial("SA3") + "' " + CRLF
        cQry038 += "    A3_FILIAL = ? " //7
        cQry038 += "    AND SA3.D_E_L_E_T_ = ' '  "
        cQry038 += "    AND A3_COD = FP0_VENDED "

        cQry038 += " LEFT JOIN " + RetSqlName("ST9") + " ST9 ON "
        cQry038 += " T9_FILIAL = '" + xFilial("ST9") + "' "
        cQry038 += " AND ST9.D_E_L_E_T_ = ' ' "
        cQry038 += " AND T9_PLACA = FPA_XPLACA "
        cQry038 += " AND T9_NOME = FPA_DESGRU "

        cQry038 += " WHERE "
        //cQry038 += "    C5_FILIAL = '" + xFilial("SC5") + "'  " + CRLF
        cQry038 += "    C5_FILIAL = ? " //8
        cQry038 += "    AND SC5.D_E_L_E_T_ = ' '  "
        cQry038 += "    AND C5_ORIGEM = 'LOCA021' " //Somento LOCA021 - informação passado pelo Lui em 18/05/2023
        If lMvLocBac
            //cQry038 += "    AND FPZ_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
            cQry038 += "    AND FPZ_PROJET = ? " //9
        Else
            //cQry038 += "    AND C5_XPROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
            cQry038 += "    AND C5_XPROJET = ? " //9
        EndIf
        //cQry038 += "    AND C5_NUM BETWEEN '" + AllTrim(MV_PAR02) + "' AND '" + AllTrim(MV_PAR03) + "' " + CRLF
        cQry038 += "    AND C5_NUM BETWEEN ? AND ? " //10 //11
        //cQry038 += "    AND C5_EMISSAO BETWEEN '" + DtoS(MV_PAR04) + "' AND '" + DtoS(MV_PAR05) + "' " + CRLF
        cQry038 += "    AND C5_EMISSAO BETWEEN ? AND ? " //12 // 13

        // n�o traz pedidos que est�o no Custo Extra
        //cQry038 += "    AND C5_NUM NOT IN (" + CRLF
        //cQry038 += "        SELECT FPG_PVNUM FROM " + RetSqlName("FPG") + CRLF

        If "ORACLE" $ Upper(TCGetDB()) .Or. lForca
            cQry038 += "    AND C5_NUM||C6_ITEM NOT IN ("
            cQry038 += "        SELECT FPG_PVNUM||FPG_PVITEM FROM " + RetSqlName("FPG")
        Else
            cQry038 += "    AND C5_NUM+C6_ITEM NOT IN ("
            cQry038 += "        SELECT FPG_PVNUM+FPG_PVITEM FROM " + RetSqlName("FPG")
        EndIf

        //cQry038 += "        WHERE FPG_FILIAL = '" + xFilial("FPG") + "' " + CRLF
        cQry038 += "        WHERE FPG_FILIAL = ? " //14
        cQry038 += "        AND D_E_L_E_T_ = ' ' "
        cQry038 += "        AND FPG_PVNUM <> '' "
        //cQry038 += "        AND FPG_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
        cQry038 += "        AND FPG_PROJET = ? " //15
        cQry038 += "        AND FPG_VALTOT > 0 "
        cQry038 += "    ) "

        cQry038 += " ORDER BY C6_NUM, PERLOC, FPA_SERREM, FPA_NFREM, C6_ITEM "

        nInject := 1
        oStatement:SetQuery(cQry038)
        oStatement:SetString(nInject,xFilial("FP0")      )
        If lMvLocBac
            oStatement:SetString(++nInject, AllTrim(MV_PAR01)   )
            oStatement:SetString(++nInject, xFilial("FPZ")      )
            oStatement:SetString(++nInject, AllTrim(MV_PAR01)   )
        EndIf
        oStatement:SetString(++nInject, xFilial("SA1")     )
        oStatement:SetString(++nInject, xFilial("SA1")     )
        oStatement:SetString(++nInject, xFilial("SA3")     )
        oStatement:SetString(++nInject, xFilial("SC5")     )
        oStatement:SetString(++nInject, AllTrim(MV_PAR01)  )
        oStatement:SetString(++nInject, AllTrim(MV_PAR02)  )
        oStatement:SetString(++nInject, AllTrim(MV_PAR03)  )
        oStatement:SetString(++nInject, DtoS(MV_PAR04)     )
        oStatement:SetString(++nInject, DtoS(MV_PAR05)     )
        oStatement:SetString(++nInject, xFilial("FPG")     )
        oStatement:SetString(++nInject, AllTrim(MV_PAR01)  )

        //Recupera a consulta ja com os parametros injetados
        cQry038 := oStatement:GetFixQuery()
        
        //Executa consulta
        IncProc(STR0002) //"Buscando Pedidos de Venda..."
        cQry038 := ChangeQuery(cQry038)
        DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry038),cAlias038,.T.,.T.)
        
        //Conta o total de registros, seta o tamanho da regua, e volta pro topo
        Count To nTotal
        (cAlias038)->(dbGoTop())
        ProcRegua(nTotal)
        nAtual := 0
        
        //Pedidos Faturamento Automatico
        If  !(cAlias038)->(EoF())

            lPassou   := .T.
            lContinua := .T.
            
            //Pega peri�odo
            //cPerLoc := (cAlias038)->C6_XPERLOC
            cPerLoc := RetPeriod((cAlias038)->C5_FILIAL,(cAlias038)->C5_NUM) //retorna menor e maior periodo do pedido

            While !(cAlias038)->(EoF())

                //posiciona nas tabelas para o PE LOCR037A
                SC6->(DbGoTo((cAlias038)->RECSC6))
                FPA->(DbGoTo((cAlias038)->RECFPA))
                
                //totalizadores
                nTotVeic += (cAlias038)->C6_QTDVEN
                //nValPed  += (cAlias038)->C6_VALOR
                //nTotPed  += (cAlias038)->C6_VALOR
                If FP0->FP0_AGLUNF = "1"  // Caso aglutine os itens do Pedido de Venda
                   nValPed  := (cAlias038)->C6_VALOR
                   nTotPed  := (cAlias038)->C6_VALOR
                Else
                   nValPed  += (cAlias038)->C6_VALOR
                   nTotPed  += (cAlias038)->C6_VALOR
                EndIf

                //Desconto
                nPedDesc += (cAlias038)->C6_VALDESC

                //Valor do Item // SIGALOC94-791 - 19/06/2023 - Jose Eulalio - Solicitado que seja apresentado o valor completo para que o desconto apareça apenas no total
                nValItem := (cAlias038)->C6_QTDVEN * (cAlias038)->C6_PRUNIT

                //Gera cabecalho
                GeraCabs(@nLinAtu,@nPagina,@lPriPed,@lPedido,@lPriMed,@lMedicao,@lPriCus,@lCustoExt,cAlias038,@cPerLoc,@cPedAtu,@cNota)

                //Ponto de Entrada para o usuario substituir informacoes
                If lLOCR038A
                    //Guarda o periodo
                    cPerLoc38A := (cAlias038)->PERLOC
                    nLinAtu    := ExecBlock("LOCR038A" , .T. , .T. , {nLinAtu,oPrintPvt,cPerLoc38A,nValPed,nPedDesc,cAlias038,cPedAtu})
                Else
                    //calcula dias do periodo
                    nDiasPer := CtoD(Substr((cAlias038)->PERLOC,14,10)) - CtoD(Substr((cAlias038)->PERLOC,1,10)) + 1 

                    //imprime os campos
                    cQtdVen := MascCampo("SC6","C6_QTDVEN",(cAlias038)->C6_QTDVEN) // pega mascara
                    cQtdVen := SubStr(cQtdVen,1,6)                                 //pega 6 caracteres iniciais
                    cQtdVen := IIf(At(",",cQtdVen,6),SubStr(cQtdVen,1,5),cQtdVen)  //caso a ultima posicao seja a virgula, apresenta somente o inteiro

                    oPrintPvt:SayAlign(nLinAtu, COL_01, cQtdVen                                             , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) // SIGALOC94-985 - 01/08/2023 - Jose Eulalio - Alterada a Mascara para utilizar a quantidade do RENTAL, pois caso o cliente utilize mais casas decimais para faturamento, não truncará no relatorio
                  //oPrintPvt:SayAlign(nLinAtu, COL_02, (cAlias038)->C6_DESCRI                              , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, COL_02, (cAlias038)->FPA_DESGRU                             , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                  //oPrintPvt:SayAlign(nLinAtu, COL_03, (cAlias038)->FPA_GRUA                               , oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, COL_03, (cAlias038)->FPA_XPLACA                             , oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, COL_04, (cAlias038)->PERLOC                                 , oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, COL_05, cValToChar(nDiasPer)                                , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                  //oPrintPvt:SayAlign(nLinAtu, COL_06, IIf((cAlias038)->FPA_TIPOSE == "S",STR0004,STR0003) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Sim" //"Não" 
                    oPrintPvt:SayAlign(nLinAtu, COL_06, (cAlias038)->T9_ANOMOD, oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) // 20260529 - HC
                    oPrintPvt:SayAlign(nLinAtu, COL_07, (cAlias038)->T9_ANOFAB, oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) // 20260529 - HC
                    oPrintPvt:SayAlign(nLinAtu, COL_08, MascCampo("FPA","FPA_VRHOR",(cAlias038)->FPA_VRHOR) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                  //oPrintPvt:SayAlign(nLinAtu, COL_08, MascCampo("SC6","C6_VALOR",(cAlias038)->C6_VALOR)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                  //oPrintPvt:SayAlign(nLinAtu, COL_08, MascCampo("SC6","C6_VALOR",nValItem)                , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, COL_09, MascCampo("FPA","FPA_VRHOR",(cAlias038)->FPA_VRHOR) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    
                    nLinAtu := nLinAtu + nTamLin
                
                    (cAlias038)->(DbSkip())
                        
                EndIf
                
                // apresenta o total
                If cPedAtu <> (cAlias038)->C5_NUM
                    // so imprime se nao tiver o PE
                    If !lLOCR038A
                        oPrintPvt:SayAlign(nLinAtu, COL_01 , "Qtd. Veiculos: " + MascCampo("SC6","C6_QTDVEN",nTotVeic), oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Qtd.Veiculos: "
                        oPrintPvt:SayAlign(nLinAtu, COL_04 , STR0005 + MascCampo("SC6","C6_VALOR",Max(nPedDesc,0))  , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Desconto: "
                        oPrintPvt:SayAlign(nLinAtu, COL_TOT, STR0006 + MascCampo("SC6","C6_VALOR",nValPed)          , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Total Pedido: "
                    EndIf
                    nLinAtu  := nLinAtu + nTamLin   
                    nValPed  := 0
                    nPedDesc := 0
                    nTotVeic := 0
                EndIf

            EndDo
        EndIf

        //fecha query PV
        (cAlias038)->(DbCloseArea())

        // Medicoes
        If MV_PAR07 == 1

            //atualiza variaveis para cabecalho
            lMedicao    := .T.
            lPriMed     := .T.
            lPedido     := .F.
            lPriPed     := .F.
            
            oStatement  := nil
            oStatement  := FWPreparedStatement():New()
            
            //monta consulta
            cQry038 := " SELECT FPN_FILIAL,FPN_COD,FPN_NUMPV,FPN_DTINIC,FPN_DTFIM,FPN_CONANT,FPN_POSCON,FPN_VALTOT,FPN_VALSER,  "
            //cQry038 += " FPA_HRFRAQ,FPA_VLHREX,FPA_GRUA,"
            cQry038 += " FPA_HRFRAQ,FPA_VLHREX,FPA_DESGRU,FPA_XPLACA,"
            cQry038 += " B1_UM, '0' NOVA, 0 QTDHR "
            cQry038 += " FROM " + RetSqlName("FPN") + " FPN "
            cQry038 += " INNER JOIN " + RetSqlName("FPA") + " FPA ON "
            cQry038 += " FPA_FILIAL = '" + xFilial("FPA") + "' "
            cQry038 += " AND FPA.D_E_L_E_T_ = ' ' "
            cQry038 += " AND FPA_AS = FPN_AS "
            cQry038 += " AND FPA_AS <> '' "
            cQry038 += " LEFT JOIN " + RetSqlName("ST9") + " ST9 ON "
            cQry038 += " T9_FILIAL = '" + xFilial("ST9") + "' "
            cQry038 += " AND ST9.D_E_L_E_T_ = ' ' "
            cQry038 += " AND T9_PLACA = FPA_XPLACA "
            cQry038 += " AND T9_NOME = FPA_DESGRU "
          //cQry038 += " AND T9_CODBEM = FPA_GRUA "
            cQry038 += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
            cQry038 += " B1_FILIAL = '" + xFilial("SB1") + "' "
            cQry038 += " AND SB1.D_E_L_E_T_ = ' ' "
            cQry038 += " AND FPA_PRODUT = B1_COD "
            
            cQry038 += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON "
            cQry038 += " SC5.C5_FILIAL ='" + xFilial("SC5") + "' "
            cQry038 += " AND SC5.D_E_L_E_T_ = '' "
            cQry038 += " AND SC5.C5_NUM = FPN.FPN_NUMPV "
            
            cQry038 += " AND SC5.C5_EMISSAO BETWEEN '"
            &('cQry038 += dtos(MV_PAR04)')
            cQry038 += "' AND  '"
            &('cQry038 += dtos(MV_PAR05)')
            cQry038 += "' "
                                    
            If MV_PAR06 == 1
                cQry038 += " AND SC5.C5_NOTA <> '' "   
            ElseIf MV_PAR06 == 2
                cQry038 += " AND SC5.C5_NOTA = '' "   
            EndIf
            
            cQry038 += " WHERE FPN_FILIAL = '" + xFilial("FPN") + "' "
            cQry038 += " AND FPN.D_E_L_E_T_ = ' ' "
            cQry038 += " AND FPN_NUMPV <> '' "
            
            cQry038 += " AND FPN_PROJET = '" 
            &('cQry038 += alltrim(MV_PAR01)')

            cQry038 += "' UNION "
            cQry038 += " SELECT FQL_FILIAL, FQL_COD, FQK.FQK_NUMPV, FQK.FQK_DTINIC, "
            cQry038 += " FQK.FQK_DTFIM, FQL_KMINI, FQL_KMFIM, FQL_VLRTOT, "
            cQry038 += " CASE WHEN FQL_TPISS = 'I' OR FQL_TPISS = 'X' THEN FQL_VLRTOT ELSE FQL_VLRTOT - FQL_VALISS END, "
           // cQry038 += " FPA_HRFRAQ, FPA_VLHREX, FPA_GRUA, B1_UM, '1' NOVA, FQL_QTDHR QTDHR "
            cQry038 += " FPA_HRFRAQ, FPA_VLHREX, FPA_DESGRU, FPA_XPLACA, B1_UM, '1' NOVA, FQL_QTDHR QTDHR "
            cQry038 += " FROM " + RetSqlName("FQL") + " FQL "
            cQry038 += " INNER JOIN "+ RetSqlName("FQK") + " FQK ON "
            
            cQry038 += " FQK.FQK_FILIAL = '"+xFilial("FQK")+"' AND FQK.FQK_COD = FQL.FQL_COD AND FQK.FQK_MEDSEQ = FQL.FQL_ORDEM AND FQK.FQK_NUMPV <> '' AND FQK.FQK_PROJET = '"
            &('cQry038 += AllTrim(MV_PAR01)')
            
            cQry038 += "' INNER JOIN "+ RetSqlName("FPA") + " FPA ON "
            cQry038 += " FPA_FILIAL = '"+xFilial("FPA")+"' "
            cQry038 += " AND FPA.D_E_L_E_T_ = ' ' AND FPA_AS = FQL_AS AND FPA_AS <> '' "
            cQry038 += " LEFT JOIN "+ RetSqlName("ST9") + " ST9 ON "
            cQry038 += " T9_FILIAL = '"+xFilial("ST9")+"' "
            cQry038 += " AND ST9.D_E_L_E_T_ = ' ' "
            cQry038 += " AND T9_PLACA = FPA_XPLACA "
            cQry038 += " AND T9_NOME = FPA_DESGRU "
            //cQry038 += " AND T9_CODBEM = FPA_GRUA "
            cQry038 += " INNER JOIN "+ RetSqlName("SB1") + " SB1 ON "
            cQry038 += " B1_FILIAL = '"+xFilial("SB1")+"' "
            cQry038 += " AND SB1.D_E_L_E_T_ = ' ' "
            cQry038 += " AND FPA_PRODUT = B1_COD "

            cQry038 += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON "
            cQry038 += " SC5.C5_FILIAL ='" + xFilial("SC5") + "' "
            cQry038 += " AND SC5.D_E_L_E_T_ = '' "
            cQry038 += " AND SC5.C5_NUM = FQK.FQK_NUMPV "

            cQry038 += " AND SC5.C5_EMISSAO BETWEEN '"
            &('cQry038 += dtos(MV_PAR04)')
            cQry038 += "' AND  '"
            &('cQry038 += dtos(MV_PAR05)')
            cQry038 += "' "

            If MV_PAR06 == 1
                cQry038 += " AND SC5.C5_NOTA <> '' "   
            ElseIf MV_PAR06 == 2
                cQry038 += " AND SC5.C5_NOTA = '' "   
            EndIf

            cQry038 += " WHERE FQL_FILIAL = '"+xFilial("FQL")+"' "
            cQry038 += " AND FQL.D_E_L_E_T_ = ' ' "

            oStatement:SetQuery(cQry038)
            //oStatement:SetString(1,AllTrim(MV_PAR01))      

            //Recupera a consulta já com os parâmetros injetados
            cQry038 := oStatement:GetFixQuery()

            //executa consulta
            IncProc(STR0007) //"Buscando Medicoes..."
            cQry038 := ChangeQuery(cQry038)
            DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry038),cAlias038,.T.,.T.)

            If !(cAlias038)->(EoF())

                lContinua := .T.
                
                If !lPassou
                    fImpCab1(@nPagina)
                EndIf

                While !(cAlias038)->(EoF())

                    //totalizador
                    nTotMed += (cAlias038)->FPN_VALSER

                    //monta cabeçalho
                    GeraCabs(@nLinAtu,@nPagina,@lPriPed,@lPedido,@lPriMed,@lMedicao,@lPriCus,@lCustoExt,cAlias038,@cPerLoc,@cPedAtu,@cNota)

                    oPrintPvt:SayAlign(nLinAtu, MCOL_01, (cAlias038)->FPN_COD               , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_02, (cAlias038)->FPN_NUMPV             , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_03, (cAlias038)->FPA_GRUA              , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_04, DtoC(StoD((cAlias038)->FPN_DTINIC)), oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_05, DtoC(StoD((cAlias038)->FPN_DTFIM)) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_06, MascCampo("FPN","FPN_POSCON",(cAlias038)->FPN_POSCON - (cAlias038)->FPN_CONANT)  , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_07, (cAlias038)->B1_UM                 , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_08, MascCampo("FPA","FPA_HRFRAQ",(cAlias038)->FPA_HRFRAQ)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_09, MascCampo("FPN","FPN_CONANT",(cAlias038)->FPN_CONANT)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_10, MascCampo("FPN","FPN_POSCON",(cAlias038)->FPN_POSCON)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    If (cAlias038)->NOVA == "0"
                        oPrintPvt:SayAlign(nLinAtu, MCOL_11, SomaHoras((cAlias038)->FPN_FILIAL,(cAlias038)->FPN_COD ), oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    Else
                        oPrintPvt:SayAlign(nLinAtu, MCOL_11, MascCampo("FQL","FQL_QTDHR",(cAlias038)->QTDHR), oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    EndIf
                    oPrintPvt:SayAlign(nLinAtu, MCOL_12, MascCampo("FPA","FPA_VLHREX",(cAlias038)->FPA_VLHREX)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_13, MascCampo("FPN","FPN_VALSER",(cAlias038)->FPN_VALSER)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)

                    nLinAtu := nLinAtu + nTamLin
                    
                    (cAlias038)->(DbSkip())

                EndDo

                //apresenta totalizador
                oPrintPvt:SayAlign(nLinAtu, COL_TOT, STR0008 + MascCampo("FPN","FPN_VALSER",nTotMed)   , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Total Medições: "
                nLinAtu := nLinAtu + nTamLin   

            EndIf

            (cAlias038)->(DbCloseArea())
        EndIf

        // Custo Extra
        If MV_PAR08 == 1

            //variaveis para cabeçalho
            lMedicao    := .F.
            lPriMed     := .F.
            lCustoExt   := .T.
            lPriCus     := .T.

            oStatement  := nil
            oStatement  := FWPreparedStatement():New()
            
            //monta consulta
            cQry038 := " SELECT FPG.R_E_C_N_O_ RECFPG, SC6.R_E_C_N_O_ RECSC6 FROM " + RetSqlName("FPG") + " FPG " 
            cQry038 += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON " 
            cQry038 += "    C6_FILIAL = '" + xFilial("SC6") + "'  " 
            cQry038 += "    AND SC6.D_E_L_E_T_ = ' '  " 
            cQry038 += "    AND C6_NUM = FPG_PVNUM " 
            cQry038 += "    AND C6_ITEM = FPG_PVITEM " 
            cQry038 += " WHERE FPG_FILIAL = '" + xFilial("FPG") + "' " 
            cQry038 += "    AND FPG.D_E_L_E_T_ = ' ' " 
            cQry038 += "    AND FPG_PVNUM <> '' " 
            /*cQry038 += "    AND FPG_PROJET = '" + AllTrim(MV_PAR01) + "' " 
            cQry038 += "    AND FPG_DTENT BETWEEN '" + DtoS(MV_PAR09) + "' AND '" + DtoS(MV_PAR10) + "' " 
            cQry038 += "    AND FPG_DOCORI BETWEEN '" + AllTrim(MV_PAR11) + "' AND '" + AllTrim(MV_PAR12) + "' " */
            cQry038 += "    AND FPG_PROJET = ? " 
            cQry038 += "    AND FPG_DTENT BETWEEN ? AND ? " 
            cQry038 += "    AND FPG_DOCORI BETWEEN ? AND ? " 
            cQry038 += " ORDER BY FPG_DTENT " 

            oStatement:SetQuery(cQry038)
            oStatement:SetString(1,AllTrim(MV_PAR01))      
            oStatement:SetString(2,dtos(MV_PAR09))      
            oStatement:SetString(3,dtos(MV_PAR10))      
            oStatement:SetString(4,AllTrim(MV_PAR11))      
            oStatement:SetString(5,AllTrim(MV_PAR12))      

            //Recupera a consulta já com os parâmetros injetados
            cQry038 := oStatement:GetFixQuery()

            //executa
            cQry038 := ChangeQuery(cQry038)
            IncProc(STR0009) //"Buscando Custos Extra..."
            DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry038),cAlias038,.T.,.T.)

            If  !(cAlias038)->(EoF())

                lContinua   := .T.
                lPedido     := .F.
                
                While !(cAlias038)->(EoF())

                    // cabecalho
                    GeraCabs(@nLinAtu,@nPagina,@lPriPed,@lPedido,@lPriMed,@lMedicao,@lPriCus,@lCustoExt,cAlias038,@cPerLoc,@cPedAtu,@cNota)

                    // posiciona no custo extra
                    FPG->(DbGoTo((cAlias038)->RECFPG))
                    SC6->(DbGoTo((cAlias038)->RECSC6))

                    // totalizador
                    nTotCus += Max(FPG->FPG_VALTOT,0)

                    //linha da observação
                    nLinObs := 0

                    oPrintPvt:SayAlign(nLinAtu, ECOL_01, AllTrim(FPG->FPG_PVNUM)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, ECOL_02, DtoC(FPG->FPG_DTENT)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, ECOL_03, MascCampo("FPG","FPG_QUANT",FPG->FPG_QUANT )  , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    //oPrintPvt:SayAlign(nLinAtu, ECOL_04, AllTrim(FPG->FPG_DESCRI)    , oFontDet, 0160, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, ECOL_04, AllTrim(FPG->FPG_DESCRI)    , oFontDet, 0160, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    If FPG->(FieldPos("FPG_OBSERV")) > 0    //proteger campo caso não exista
                        //calcula tamanho para a célula
                        nTamObs   := oPrintPvt:GetTextWidth(FPG->FPG_OBSERV,oFontDet)
                        nQtLinObs := Int(nTamObs / nFpgObs) 
                        nLinObs   := (nQtLinObs * 20) - nTamLin
                        //imprime a célula
                        oPrintPvt:SayAlign(nLinAtu, ECOL_05, (FPG->FPG_OBSERV)   , oFontDet, nFpgObs, nLinObs, COR_PRETO, PAD_JUSTIF  , 0) 
                        //calcula tamanho para adicionar proxima linha
                        nLinObs   := Max(Int(nLinObs / 3),nTamLin)

                    EndIf
                    oPrintPvt:SayAlign(nLinAtu, ECOL_06, MascCampo("FPG","FPG_VALTOT",FPG->FPG_VALTOT )  , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    nLinAtu := nLinAtu + nTamLin + nLinObs
                    
                    (cAlias038)->(DbSkip())

                EndDo

                //totalizador
                oPrintPvt:SayAlign(nLinAtu, COL_TOT, STR0010 + MascCampo("FPG","FPG_VALTOT",nTotCus)   , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Total Custo Extra: "
                nLinAtu := nLinAtu + nTamLin   

            EndIf

            (cAlias038)->(DbCloseArea())
        EndIf
                
        If lContinua

            // Se ainda tiver linhas sobrando na pagina, imprime o rodape final
            nLinAtu   := nLinAtu + nTamLin
            nTotGeral := nTotPed + nTotMed + nTotCus
            oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
            oPrintPvt:SayAlign(nLinAtu, 150, STR0011, oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0) //"Total Geral "
            nLinAtu   := nLinAtu + (nTamLin * 2) + 5
            oPrintPvt:SayAlign(nLinAtu, 0, STR0012 + AllTrim(Transform(nTotGeral,"@E 999,999,999.99")) + " (" + Extenso(nTotGeral,.F.,1) + " )" ,  oFontDetN, nLargTit, nTamLin, COR_PRETO, PAD_CENTER, 0) //"R$ "
            nLinAtu   := nLinAtu + (nTamLin * 2)

        Else
            oPrintPvt:SayAlign(nLinAtu, nColIni + 60, STR0013 , oFontDet , nColObs, nTamLin, COR_PRETO, PAD_JUSTIF , 0) //"Não existem registros para o filtro selecionado."
        EndIf

        oPrintPvt:Preview()

    EndIf 

    RestArea(aAreaFp0)
    RestArea(aAreaFpa)
    RestArea(aAreaFpn)
    RestArea(aAreaFpg)
    RestArea(aAreaSC6)

Return
 
/*---------------------------------------*
 | Func:  fImpCab1                       |
 | Desc:  Fun�ao que imprime o cabecalho |
 *--------------------------------------*/
Static Function fImpCab1(nPagina)
//Local cTexto 	:= ""
//Local cLogoRel	:= RetLogo()
Local nLinCab	:= 030
//Local nLogoH	:= 33
//Local nLogoW	:= 112
Local aEmpInfo	:= FWSM0Util():GetSM0Data()
Local cEmpNome	:= AllTrim(aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_FILIAL"})][2])
Local cEmpCom	:= AllTrim(aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_NOMECOM"})][2])
Local cNomeRel  := STR0014 //"Demonstrativo de Faturamento"
    
Default nPagina := 0

    //Iniciando P�gina
    oPrintPvt:StartPage()
    
    //Cabe�alho
	nLinCab += (nTamLin * 1.5)
	//oPrintPvt:SayBitmap( nLinCab, nColIni, cLogoRel, nLogoW, nLogoH)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cEmpNome, oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinCab, nColHora, DtoC(dDataGer) + " " + cHoraGer,	oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cNomeRel, oFontTitN, 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinCab, nColHora, cEmpCom + IIF(!Empty(cEmpCom),"/","") + cNomeUsr, oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColHora, STR0015 + cValToChar(nPagina), oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0) //"página "
    
    //Linha Separatoria
    nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, COR_CINZA)
	
    //Cabecalho das colunas
    nLinCab += nTamLin
     
    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinCab + 3
Return

/*/{Protheus.doc} fImpCab2
Imprime segundo cabecalho
@author Jose Eulalio
@since 16/05/2023
@type function
/*/
Static Function fImpCab2(cAlias038)

Local aAreaSa1 := SA1->(GetArea())
Local cCgc     := ""

Local cProjeto := (cAlias038)->FP0_PROJET
Local cCtr     := (CAlias038)->FP0_XLOCAL

    SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
    SA1->(DbSeek(xFilial("SA1") + (cAlias038)->(FP0_CLI+FP0_LOJA) ))
    cCgc := MascCgc(SA1->A1_CGC,SA1->A1_PESSOA)

    oPrintPvt:SayAlign(nLinAtu-08, nColIni, STR0016     + cProjeto, oFontTitN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Projeto: "
    oPrintPvt:SayAlign(nLinAtu-08, 100, " - Contrato: " + cCtr    , oFontTitN ,0240, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Contrato:"
  
	nLinAtu += nTamLin

    //Cabecalho 2
    oPrintPvt:SayAlign(nLinAtu, nColIni     , STR0017        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT, 0) //"Cliente:"
   // oPrintPvt:SayAlign(nLinAtu, nColIni + 50 , SA1->A1_NOME      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50, AllTrim(SA1->A1_COD) +"|" + AllTrim(SA1->A1_LOJA) + " - " + SA1->A1_NOME, oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni     , STR0018      , oFontDetN, 240, 20, COR_PRETO, PAD_LEFT   , 0) //"CNPJ:"
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50, cCgc         , oFontDet , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 - 40 , STR0019      , oFontDetN, 240, 20, COR_PRETO, PAD_LEFT   , 0) //"Inscr.Estadual:"
    oPrintPvt:SayAlign(nLinAtu, COL_06 + 20 , SA1->A1_INSCR, oFontDet , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    //oPrintPvt:SayAlign(nLinAtu, nColIni         , STR0020        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0) //"Contrato:"
    //oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , AllTrim((cAlias038)->FP0_NOMECO), oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    //oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_CONTATO   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    //oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , AllTrim((cAlias038)->FP0_CLICON) + " - " + (cAlias038)->FP0_NOMECO, oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 - 40, STR0021    , oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0) //"Fone:"
    oPrintPvt:SayAlign(nLinAtu, COL_06     , SA1->A1_TEL, oFontDet , 240, 20, COR_PRETO, PAD_LEFT, 0)
	nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni     , STR0022    , oFontDetN, 240, 20, COR_PRETO, PAD_LEFT   , 0) //"Endereco:"
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50, SA1->A1_END, oFontDet , 240, 20, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni      , STR0023       , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT, 0) //"Vendedor:"
    //oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_VEND      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50 , AllTrim((cAlias038)->FP0_VENDED) + " - " + (cAlias038)->FP0_NOMVEN, oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinAtu, COL_05 - 40  , STR0024, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0) //"Faturar para:"
    //oPrintPvt:SayAlign(nLinAtu, COL_06 + 20     , (cAlias038)->CLISC5  , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    //oPrintPvt:SayAlign(nLinAtu, COL_06 + 15     , AllTrim((cAlias038)->CODSC5) +"|" + AllTrim((cAlias038)->LOJSC5) + " - " + (cAlias038)->CLISC5  , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_05 + 15, AllTrim((cAlias038)->CODSC5) +"|" + AllTrim((cAlias038)->LOJSC5) + " - " + (cAlias038)->CLISC5, oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinAtu, COL_08 , "Centro de Custo: ", oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinAtu, COL_08 + 70, ((cAlias038)->FPA_CUSTO), oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)

    //Linha Separatoria
    //nLinAtu += (nTamLin * 2)
    //oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
	
    //Cabecaalho das colunas
    nLinAtu += nTamLin

    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinAtu + 3

    RestArea(aAreaSa1)

Return
 
//---------------------------------------------------------------------
/*/{Protheus.doc} RetLogo
Retorna logotipo da empresa
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function RetLogo()
Local cLogo := SuperGetMv("MV_LOCXLOG",.F.,"C:\itup\img\logo_totvs.jpg") // define via parametro o logo do relatorio

// se não pega logo customizado
If Empty(cLogo) .Or. !File(cLogo)
	/*
	cLogo := "LGMID" + cEmpAnt + cFilAnt + ".PNG"
	If !File(cLogo)
		cLogo := "LGMID" + cEmpAnt + ".PNG"
	EndIf
	If !File(cLogo)
		cLogo := "LGMID.PNG"
	EndIf
	*/
	If !File(cLogo)
		cLogo := "lgrl" + cEmpAnt + ".bmp"
	EndIf
	If !File(cLogo)
		cLogo := "lgrl.bmp"
	EndIf
	If !File(cLogo)
		cLogo := ""
	EndIf
EndIf

Return cLogo

//---------------------------------------------------------------------
/*/{Protheus.doc} MascCgc
Retorna CGC com máscara para CPF ou CNPJ
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function MascCgc(cCgc,cPessoa)
Local cMascara  := ""

    If cPessoa == "F"
        cMascara := "@R 999.999.999-99"
    Else
        cMascara := "@!R NN.NNN.NNN/NNNN-99"
    EndIf

    cCgc := Transform(cCgc,cMascara)

Return cCgc

//---------------------------------------------------------------------
/*/{Protheus.doc} MascCampo
Retorna valor de acordo com a mascara do campo
@author Jose Eulalio
@since 16/05/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function MascCampo(cAliasMasc,cCampoMasc,xValor)
Local cRet      := ""
Local cMascara  := PesqPict( cAliasMasc, cCampoMasc )

    cRet := AllTrim(Transform(xValor,cMascara))

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraCabs
Gera os cabeçalhos de acordo a necesidade
@author Jose Eulalio
@since 16/05/2023
/*/
//---------------------------------------------------------------------
Static Function GeraCabs(nLinAtu,nPagina,lPriPed,lPedido,lPriMed,lMedicao,lPriCus,lCustoExt,cAlias038,cPerLoc,cPedAtu,cNota)

    If (lPedido .And. (lPriPed .Or. cPedAtu <> (cAlias038)->C5_NUM )) .Or. nLinAtu + nTamLin > (nLinFin - 60)

        //Imprime o cabeçalho
        If lPriPed .Or.  nLinAtu + nTamLin > (nLinFin - 60)
            fImpCab1(@nPagina)
            If lPedido
                fImpCab2(cAlias038)
            EndIf
        EndIf
        
        If lPedido
            //cPerLoc     := (cAlias038)->C6_XPERLOC
            cPerLoc     := RetPeriod((cAlias038)->C5_FILIAL,(cAlias038)->C5_NUM)

            //cabe�alho 1� linha
            nLinAtu := nLinAtu + 03
            oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin , nColFin }, oBrush1, "-2")
            oPrintPvt:SayAlign(nLinAtu, COL_02, STR0025 + cPerLoc, oFontDetN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Período de Faturamento: "
            oPrintPvt:SayAlign(nLinAtu, COL_05, STR0026 + (cAlias038)->C5_NUM, oFontDetN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Pedido de Venda: "
            nLinAtu := nLinAtu + nTamLin
        EndIf

    EndIf

    If lMedicao .And. lPriMed
        nLinAtu := nLinAtu + nTamLin

        oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
        oPrintPvt:SayAlign(nLinAtu, 150, STR0027, oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0) //"MEDIÇÕES "

        nLinAtu := nLinAtu + nTamLin + 10

        oPrintPvt:SayAlign(nLinAtu, MCOL_01, STR0028      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Medição"
        oPrintPvt:SayAlign(nLinAtu, MCOL_02, STR0029      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"P.Venda"
        oPrintPvt:SayAlign(nLinAtu, MCOL_03, STR0030   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Patrimônio"
        oPrintPvt:SayAlign(nLinAtu, MCOL_04, STR0031   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Dt Inicial"
        oPrintPvt:SayAlign(nLinAtu, MCOL_05, STR0032     , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Dt Final"
        oPrintPvt:SayAlign(nLinAtu, MCOL_06, STR0033        , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Quant"
        oPrintPvt:SayAlign(nLinAtu, MCOL_07, STR0034           , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"UN"
        oPrintPvt:SayAlign(nLinAtu, MCOL_08, STR0035   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Contratado"
        oPrintPvt:SayAlign(nLinAtu, MCOL_09, STR0036   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Cont.Inic."
        oPrintPvt:SayAlign(nLinAtu, MCOL_10, STR0037   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Cont.Final"
        oPrintPvt:SayAlign(nLinAtu, MCOL_11, STR0038      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Cobrado"
        oPrintPvt:SayAlign(nLinAtu, MCOL_12, STR0039   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Vlr. Unit."
        oPrintPvt:SayAlign(nLinAtu, MCOL_13, STR0040   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Vlr. Total"
        
        nLinAtu := nLinAtu + nTamLin
        
        lPriPed := .F.
        lPriMed := .F.
    EndIf

    If lCustoExt .And. lPriCus
        nLinAtu := nLinAtu + nTamLin

        oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
        oPrintPvt:SayAlign(nLinAtu, 150, STR0041, oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0) //"CUSTO EXTRA "

        nLinAtu := nLinAtu + nTamLin + 10

        oPrintPvt:SayAlign(nLinAtu, ECOL_01, STR0042, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Ped.Venda"
        oPrintPvt:SayAlign(nLinAtu, ECOL_02, STR0043, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Data Base"
        oPrintPvt:SayAlign(nLinAtu, ECOL_03, STR0044, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Quantidade"
        oPrintPvt:SayAlign(nLinAtu, ECOL_04, STR0045, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Descrição"
        oPrintPvt:SayAlign(nLinAtu, ECOL_05, STR0046, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Observação"
        oPrintPvt:SayAlign(nLinAtu, ECOL_06, STR0047, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Valor Total"

        nLinAtu := nLinAtu + nTamLin
        
        lPriMed := .F.
        lPriCus := .F.
    EndIf

    If lPedido
        If (lPriPed .Or. cNota <> AllTrim((cAlias038)->FPA_NFREM) + "-" + AllTrim((cAlias038)->FPA_SERREM) .Or. cPedAtu <> (cAlias038)->C5_NUM) 

            lPriPed     := .F.
            cNota       := AllTrim((cAlias038)->FPA_NFREM) + "-" + AllTrim((cAlias038)->FPA_SERREM)
            cPedAtu     := (cAlias038)->C5_NUM

            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)

            oPrintPvt:SayAlign(nLinAtu, COL_02      , STR0048, oFontDetN , 0240, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Remessa: "
            oPrintPvt:SayAlign(nLinAtu, COL_02 + 50 , cNota, oFontDet  , 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)

            oPrintPvt:SayAlign(nLinAtu, COL_04, STR0049, oFontDetN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Data: "
            oPrintPvt:SayAlign(nLinAtu, COL_04 + 50, DtoC(StoD((cAlias038)->FPA_DNFREM)), oFontDet , 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)

            nLinAtu := nLinAtu + nTamLin

            oPrintPvt:SayAlign(nLinAtu, COL_01, STR0050, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Qtd"
            oPrintPvt:SayAlign(nLinAtu, COL_02, STR0051, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Equipamento" // "Desc. Prod"
            oPrintPvt:SayAlign(nLinAtu, COL_03, STR0052, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Bem" // "Placa"     //"Bem" // "Cód. Bem"
            oPrintPvt:SayAlign(nLinAtu, COL_04, STR0053, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Periodo"
            oPrintPvt:SayAlign(nLinAtu, COL_05, STR0054, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Qtd.Dias"
          //oPrintPvt:SayAlign(nLinAtu, COL_06, STR0055, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Subs"
            oPrintPvt:SayAlign(nLinAtu, COL_06, "Ano Veiculo", oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Ano"
            oPrintPvt:SayAlign(nLinAtu, COL_07, "Ano Fabricacao", oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0) //"Ano"
            oPrintPvt:SayAlign(nLinAtu, COL_08, STR0056, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Valor Base"
            oPrintPvt:SayAlign(nLinAtu, COL_09, STR0047, oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0) //"Valor Total"
            
            nLinAtu := nLinAtu + nTamLin

        EndIf
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaHoras
Retorna as horas de uma medicao
@author Jose Eulalio
@since 16/05/2023
@type function
/*/
//---------------------------------------------------------------------
Static Function SomaHoras(cFilFPP,cCodFPP,lNova)
Local cHoras    := ""
Local nHoras    := 0
Local aAreaFPP  := FPP->(GetArea())
Default lNova   := .F.

    If !lNova
        FPP->(DbSetOrder(1)) //FPP_FILIAL+FPP_COD+FPP_ITEM+DTOS(FPP_DTMEDI)
        If FPP->(DbSeek(cFilFPP+cCodFPP))
            While !(FPP->(Eof())) .And. FPP->(FPP_FILIAL+FPP_COD) == cFilFPP+cCodFPP
                nHoras += FPP->FPP_QTDHR
                FPP->(DbSkip())
            EndDo
        EndIf
    EndIF

    cHoras := cValToChar(nHoras)

    RestArea(aAreaFPP)

Return cHoras

//---------------------------------------------------------------------
/*/{Protheus.doc} RetPeriod
Retorna String com maior e menor periodo de um pedido
@author Jose Eulalio
@since 18/05/2023
/*/
//---------------------------------------------------------------------
Static Function RetPeriod(cFilialPV,cNumPv)
Local cNewPeriod := ""
Local cPerLoc    := ""
Local dDataMin   := StoD("")
Local dDataMax   := StoD("")
Local dDataAux   := StoD("")
Local aAreaSC6   := SC6->(GetArea())
Local aAreaFPZ   := FPZ->(GetArea())
Local lMvLocBac	 := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integracao com Modulo de Locacoes SIGALOC

    //Posiciona no pedido
    SC6->(DbSetOrder(1))
    If SC6->(DbSeek(xFilial("SC6") + cNumPV))
        //pega periodo , dependendo se tem integração com Backoffice
        If lMvLocBac
            FPZ->(dbSetOrder(1))
            FPZ->(dbSeek(xFilial("FPZ")+SC6->C6_NUM))
        EndIf
        //roda todos os periodos do pedio para pegar o menor e o maior
        While !( SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == cFilialPV+cNumPv
            //pega periodo da linha
            If lMvLocBac
                cPerLoc := FPZ->FPZ_PERLOC
            Else
                cPerLoc := SC6->C6_XPERLOC
            EndIf
            //pega menor data
            dDataAux := CtoD(Substr(cPerLoc,1,10)) 
            If Empty(dDataMin) .Or. dDataAux < dDataMin
                dDataMin := dDataAux
            EndIf
            //pega maior data
            dDataAux := CtoD(Substr(cPerLoc,14,10)) 
            If Empty(dDataMax) .Or. dDataAux > dDataMax
                dDataMax := dDataAux
            EndIf
            SC6->(DbSkip())
        EndDo
        //retorna string com menor e maior periodos
        cNewPeriod := DtoC(dDataMin) + STR0057 + DtoC(dDataMax) //" A "
    EndIf

    RestArea(aAreaSC6)
    RestArea(aAreaFPZ)

Return cNewPeriod
