#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "MATR968.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ
Í»±±
±±ºPrograma  ³MATR968   ºAutor  ³Mary C. Hergert     º Data ³  03/08/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do RPS - Recibo Provisorio de Servicos - referenteº±±
±±º          ³ao processo da Nota Fiscal Eletronica de Sao Paulo.         º±±
±±º          ³Impressao grafica - sem integracao com word.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigafis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XMATR968()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local wnrel

	Local titulo	:= STR0001 //"Impressão RPS"
	Local aSays		:= {}, aButtons := {}, nOpca := 0
	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Local lAutomato	:= .T.//IsBlind()
	Local cRelease as character
	//Local cEndWeb		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=791840546"

	Private nomeprog := "MATR968"
	Private nLastKey := 0
	Private cPerg
	Private oPrint
	Private oMvMatNfSe := xMATSIGANFSE():New()

	cRelease 	:=  GetRPORelease()

	/*If !IsBlind() 
		If FindFunction("DlgRelVer")
			DlgRelVer("MATR968","Relatorio Lancamentos fiscais",cEndWeb )  
		EndIf
	EndIf
*/
	cString := "SF2"
	wnrel   := "MATR968"
	cPerg   := "MTR968"

	If lVerpesssen

		If lAutomato
			Pergunte(cPerg,.F.)
		EndIf

		AADD(aSays,"Impressão Fatura . Selecione os Parametrôs Abaixo !") //"Impressão do Recibo Provisório de Serviços - RPS"

		AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
		AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )

		If lAutomato
			FormBatch( Titulo, aSays, aButtons,, 160 )

			If nOpca == 0
				Return
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Configuracoes para impressao grafica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAutomato

			// ajusta o nome do arquivo
			cNomeArq := "MATR968_"+GetMv("MV_ESTADO")+".rel"

			// nome específico para Sorocaba
			If Upper(Alltrim(SM0->M0_CIDENT)) == "SOROCABA"
				cNomeArq := "MATR968_"+GetMv("MV_ESTADO")+"sorocaba"+".rel"
			EndIf

			oPrint := FWMsPrinter():New(cNomeArq,6,.T.,GetTempPath(),lAutomato, /*lTReport*/, /*oPrintSetup*/, /*cPrinter*/,/*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.F.)
		Else
			oPrint := TMSPrinter():New(STR0001)		//"Impressão RPS"
		EndIf

		oPrint:SetPortrait()					// Modo retrato
		oPrint:SetPaperSize(9)					// Papel A4

		If nLastKey = 27
			dbClearFilter()
			Return
		Endif

		If !lAutomato
			RptStatus({|lEnd| Mt968Print(@lEnd,wnRel,cString)},Titulo)
		Else
			Mt968Print(.F.,wnRel,cString)
		EndIf

		File2Printer(GetTempPath()+cNomeArq,"PDF")
		oPrint:cPathPDF := GetTempPath()
		oPrint:Preview()
		//ShellExecute("open", cNomeArq, "", GetTempPath(), 1) // Visualiza impressao grafica antes de imprimir
		ShellExecute("open", StrTran(cNomeArq,".rel",".pdf"), "", GetTempPath(), 1)

	EndIf

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³Mt968Print³ Autor ³ Mary C. Hergert       ³ Data ³ 03/08/06 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Chamada do Processamento do Relatorio                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³MATR968                                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mt968Print(lEnd,wnRel,cString)

	Local aAreaRPS		:= {}
	Local aPrintServ	:= {}
	Local aPrintObs		:= {}
	Local aTMS			:= {}
	Local aItensSD2     := {}
	Local cServ			:= ""
	Local cDescrServ	:= ""
	Local cCNPJCli		:= ""
	Local cTime			:= ""
	Local lNfeServ		:= AllTrim(SuperGetMv("MV_NFESERV",.F.,"1")) == "1"
	Local cFieldMsg		:= SuperGetMv("MV_CMPUSR",.F.,"")
	Local cLogo			:= ""
	Local cServPonto	:= ""
	Local cObsPonto		:= ""
	Local oQuery
	Local cVenci := ""
	Local cPedido := ""
	Local cBanco := ""
	Local cAgenci := ""
	local cConta := ""
	Local lMvLocBac		:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
	// Local cAliasSF3		:= "SF3"
	Local cAliasSF3		:= GetNextAlias()
	Local cCli			:= ""
	Local cIMCli		:= ""
	Local cEndCli		:= ""
	Local cBairrCli		:= ""
	Local cCepCli		:= ""
	Local cMunCli		:= ""
	Local cCodMun		:= ""
	Local cUFCli		:= ""
	Local cEmailCli		:= ""
	Local cCampos		:= ""
	Local cDescrBar     := SuperGetMv("MV_DESCBAR",.F.,"")
	Local cCodServ      := ""
	Local cF2_DOC   := ""
	Local cF2_SERIE     := ""
	Local cF2_SERIEV    := "" //série de visualização
	Local cF2_CLIENTE   := ""
	Local cF2_LOJA      := ""
	Local cF2_EMISSAO   := ""
	Local cKey          := ""
	Local cObsRio       := ""
	Local cLogAlter     := GetNewPar("MV_LOGRPS","") // caminho+nome do logotipo alternativo
	Local cTotImp       := ""
	Local cFontImp      := ""

	Local lCampBar      := !Empty(cDescrBar) .And. SB1->(FieldPos(cDescrBar)) > 0
	Local lDescrNFE		:= ExistBlock("MTDESCRNFE")
	Local lObsNFE		:= ExistBlock("MTOBSNFE")
	Local lCliNFE		:= ExistBlock("MTCLINFE")
	Local lPEImpRPS		:= ExistBlock("MTIMPRPS")
	Local lDescrBar     := GetNewPar("MV_DESCSRV",.F.)
	Local lImpRPS		:= .T.

	Local nValDed       := 0
	Local nTOTAL        := 0
	Local nDEDUCAO      := 0
	Local nBASEISS      := 0
	Local nALIQISS      := 0
	Local nVALISS       := 0
	Local nDescIncond   := 0
	Local nValLiq       := 0
	Local nVlContab     := 0
	Local nValDesc      := 0
	Local nAliqPis      := 0
	Local nAliqCof      := 0
	Local nAliqCSLL     := 0
	Local nAliqIR       := 0
	Local nAliqINSS     := 0
	Local _CQUERY      	:= ""
	Local nValPis       := 0
	Local nValCof       := 0
	Local nValCSLL      := 0
	Local nValIR        := 0
	Local nValINSS      := 0
	Local nTamNfelet    := 0
	Local cNatureza     := ""
	Local cRecIss       := ""
	Local cRecCof       := ""
	Local cRecPis       := ""
	Local cRecIR        := ""
	Local cRecCsl       := ""
	Local cRecIns		:= ""
	Local cTitulo		:= "" //FATURA DE SERVIÇOS
	Local nCopias		:= mv_par07
	Local nLinIni		:= 225
	Local nColIni		:= 225
	Local nColFim		:= 2175
	Local nLinFim		:= 2975
	Local nX			:= 1
	Local nY			:= 1
	Local nLinha		:= 0
	Local cPeriodo      := ""
	Local cAsPedido     := ""
	Local nCentro		:= nColFim - nColIni
	Local cCNPJIntSer	:= ""
	Local cCliIntSer	:= ""
	Local cMunPreSer	:= ""
	Local cNroInsObr	:= ""
	local cChave := ""
	Local cValAprTri	:= ""
	Local nValCOFINS	:= 0
	Local nValIRPF		:= 0
	Local nValCred		:= 0
	lOCAL cNomeB := ""

	Local	aSX3UtSbz 	:= FwSX3Util():GetAllFields("SBZ",.F.)
	Local	nPosRet :=0
	Local	lGetSX5 := .T.

	Local cMVTXPIS := SuperGetMv("MV_TXPIS"  )
	Local cMVTXCOF := SuperGetMv("MV_TXCOFIN")
	Local cMVALIRF := SuperGetMV("MV_ALIQIRF")
	Local cMVTXCSLL := SuperGetMv("MV_TXCSLL" )

	Local oFont10 	:= TFont():New("Courier New",8,8,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFont10n	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito
	Local oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
	Local oFont11n	:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)	//Negrito
	Local oFont14n	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)	//Negrito
	Local oFont09 	:= TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFont09n	:= TFont():New("Courier New",9,9,,.T.,,,,.T.,.F.)	//Negrito
	Local oFont08n	:= TFont():New("Courier New",8,8,,.T.,,,,.T.,.F.)	//Negrito

	Local oFontA08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA08n := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA09n := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA10n := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA11	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA11n := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA12n := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA13	:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA13n := TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA14	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA14n := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA16n := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA18	:= TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA18n := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	//Negrito
	Local oFontA20  := TFont():New("Arial",20,20,,.F.,,,,.T.,.F.)	//Normal s/negrito
	Local oFontA20n := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)	//Negrito
	Local cSelect   := ""
	Local nValBase := 0
	Local _CQUERY   := ""
	Local nAliquota := 0
	Local nMinPCC := SuperGetMv("MV_VL13137", .F. , 0)

	#IFDEF TOP
		Local cQuery    := ""
	#ELSE
		Local cChave    := ""
		Local cFiltro   := ""
	#ENDIF

	Private lRecife     := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "RECIFE",.T.,.F.)
	Private lJoinville  := Iif(GetNewPar("MV_ESTADO","xx") == "SC" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "JOINVILLE",.T.,.F.)
	Private lSorocaba   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "SOROCABA",.T.,.F.)
	Private lRioJaneiro := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "RIO DE JANEIRO",.T.,.F.)
	Private lBhorizonte := Iif(GetNewPar("MV_ESTADO","xx") == "MG" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "BELO HORIZONTE",.T.,.F.)
	Private lPaulista   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "SAO PAULO",.T.,.F.)
	Private lLondrina	:= Iif(GetNewPar("MV_ESTADO","xx") == "PR" .And. Upper(Alltrim(oMvMatNfSe:M0_CIDENT)) == "LONDRINA",.T.,.F.)

	dbSelectArea("SF3")
	dbSetOrder(6)

	nTamNfelet := TamSX3("F2_NFELETR")[1]+5 // Para impressão do SAY(), é necessário calcular mais 4 posiçõs refernte ao ano, + 1 posição referente a "/"

	#IFDEF TOP



		cCampos += ",D2_ALQIRRF,D2_VALIRRF,D2_BASEIRR "

		// If lRecife
		// 	cCampos += " ,D2_CODISS "
		// Endif
	/*
	If Empty(cCampos)
		cCampos := "%%"
	Else
		cCampos := "% " + cCampos + " %"
	Endif
	

	
	*/
		cTeste := ""
		cContrato := ""
		cPreco := ""
		cPeriodo := ""
		cProjeto := ""
		SC6->(DbSetOrder(4))
		If SC6->(DbSeek(xFilial("SC6") + cF2_DOC + cF2_SERIE))
			FPA->(DbSetOrder(3)) // FPA_FILIAL+FPA_AS+FPA_VIAGEM
			FPY->(DbSetOrder(1)) // FPY_FILIAL+FPY_PEDVEN+FPY_PROJET
			FPZ->(DbSetOrder(1)) // FPZ_FILIAL+FPZ_PEDVEN+FPZ_PROJET+FPZ_ITEM
			FP0->(DbSetOrder(1))
			cChave := SC6->C6_FILIAL + SC6->C6_NUM

			If FPY->(DbSeek(xFilial("FPY") + SC6->C6_NUM))
				While !SC6->(Eof()) .And. (SC6->C6_FILIAL + SC6->C6_NUM) == cChave

					If FPZ->(DbSeek(xFilial("FPZ") + SC6->C6_NUM + FPY->FPY_PROJET + SC6->C6_ITEM + cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
						cAsPedido  := FPZ->FPZ_AS
						cPeriodo   := FPZ->FPZ_PERLOC

						If FPA->(DbSeek(xFilial("FPA") + cAsPedido))

							// cTeste := RTRIM(FPA->FPA_DESGRU) + CHR(32) + RTRIM(FPA->FPA_XPLACA) + Replicate(CHR(32), 10) + DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM) + Replicate(CHR(32), 25) + RTRIM(Transform(FPA->FPA_PRCUNI, "@E 999,999,999.99")) + CHR(13) + CHR(10)
							cTeste := RTRIM(FPA->FPA_DESGRU)  + RTRIM(FPA->FPA_XPLACA) + DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM) +  RTRIM(Transform(FPA->FPA_PRCUNI, "@E 999,999,999.99")) + CHR(13) + CHR(10)





						ELSE
							oPrint:SAY(3000,390,"TESTE")

						EndIf
					EndIf

					// If !SC6->(EOF())
					SC6->(DbSkip())
					// Else
					// Exit
					// EndIf
				EndDo
			EndIf
		EndIf


		DbSelectArea("FP0")
		FP0-> (dbSetOrder(1))
		IF FP0->(DbSeek(xFilial("FP0")+ cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
			cContrato := FP0->FP0_XLOCAL
			cProjeto := FP0->FP0_PROJET
			// cConta := FPO->FP0_XCONTA
			// cAgenci:= FPO->FPO_XAGENC
			// cBanco := FPO0->FP0_XBANCO
		EndIf

		// // Banco
		// DbSelectArea("SC5")
		// SC5-> (dbSetOrder(1))
		// if SC5->(DbSeek(xFilial("SC5")+ cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
		// 	cBanco := SC5->C5_XBANCO
		// Endif

		// DbSelectArea("SA6")
		// SA6-> (DbSetOrder(1))
		// If SA6->(DbSeek(xFilial("SA6")+ cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC ))
		// 	cNomeB := SA6->A6_NOME
		// EndIf


		// // Agencia
		// DbSelectArea("SC5")
		// SC5-> (dbSetOrder(1))
		// if SC5->(DbSeek(xFilial("SC5")+ cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
		// 	cAgenci := SC5->C5_XAGENCI
		// Endif

		// // Conta
		// DbSelectArea("SC5")
		// SC5-> (dbSetOrder(1))
		// if SC5->(DbSeek(xFilial("SC5")+ cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
		// 	cConta := SC5->C5_XCONTA
		// Endif

		// DbSelectArea("FPA")
		// FPA->(dbSetOrder(1))
		// If FPA->(DbSeek(xFilial("FPA") + cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
		// 	cDescrServ := FPA->FPA_OBRA + FPA->FPA_GRUA + FPA_DESGRU + FPA->FPA_DTINI + FPA->FPA_DTFIM
		// 	Else
		// 	cDescrServ := "Locação de automóveis sem condutor"
		// 		Endif

		// Pedido venda Função

		DbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5") + cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
			cPedido := SC5->C5_NUM
		Else
			cPedido := "Pedido não encontrado"
		Endif

		// VENCIMENTO FUNÇÃO
		DbSelectArea("SE1")
		SE1->(dbSetOrder(2))
		If SE1->(dbSeek(xFilial("SE1") + cF2_CLIENTE + cF2_LOJA + cF2_DOC))
			If SE1->E1_NUM == cF2_DOC
				cVenci += DtoC(SE1->E1_VENCREA)
			Else
				cVenci := "NÃO ENCONTRADO"
			EndIf
		EndIf

		If TcSrvType()<>"AS/400"

			lQuery		:= .T.
			cAliasSF3	:= GetNextAlias()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se imprime ou nao os documentos cancelados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			cSelect:= "%"
			cSelect+= "F2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE,"
			cSelect+= IIF(SerieNfId("SF2",3,"F2_SERIE")<>"F2_SERIE","F2_SDOC,","") + "F2_CLIENTE,"
			cSelect+= "F2_LOJA,F2_BASEISS,F2_VALBRUT,F2_TIPO,F2_VALISS,F2_ESPECIE,"
			cSelect+= "D2_CODISS,F2_NFELETR,F2_EMINFE,F2_CODNFE,F2_CREDNFE "+cCampos
			cSelect+= "%"

			BeginSql Alias cAliasSF3
			COLUMN F2_EMISSAO AS DATE
			COLUMN F2_EMINFE AS DATE
			SELECT %Exp:cSelect%

			FROM %table:SF2% SF2 INNER JOIN %table:SD2% SD2 
			ON  SF2.F2_FILIAL   = SD2.D2_FILIAL        
			AND SF2.F2_DOC      = SD2.D2_DOC      
			AND SF2.F2_SERIE    = SD2.D2_SERIE      
			AND SF2.F2_TIPO     = SD2.D2_TIPO      
			AND SF2.F2_CLIENTE  = SD2.D2_CLIENTE      
			AND SF2.F2_LOJA     = SD2.D2_LOJA  
			AND SD2.%NotDel%    

			WHERE SF2.F2_FILIAL = %xFilial:SF2% AND
				SD2.D2_CF >= '5' AND
				SF2.F2_EMISSAO >= %Exp:mv_par01% AND
				SF2.F2_EMISSAO <= %Exp:mv_par02% AND
				SF2.F2_TIPO = 'N' AND
				// SD2.D2_CODISS <> %Exp:Space(TamSX3("D2_CODISS")[1])% AND
				SF2.F2_CLIENTE >= %Exp:mv_par03% AND
				SF2.F2_CLIENTE <= %Exp:mv_par04% AND
				SF2.F2_DOC     >= %Exp:mv_par05% AND
				SF2.F2_DOC     <= %Exp:mv_par06% AND
				// %Exp:cQuery%
				SF2.%NotDel%

			ORDER BY SF2.F2_EMISSAO,SF2.F2_SERIE,SF2.F2_DOC,SF2.F2_TIPO,SF2.F2_CLIENTE,SF2.F2_LOJA
			EndSql

			dbSelectArea(cAliasSF3)
		Else

		#ENDIF
		cArqInd := CriaTrab(NIL,.F.)
		cChave  := "DTOS(F2_EMISSAO)+F2_SERIE+F2_DOC+F2_TIPO+F2_CLIENTE+F2_LOJA"
		cFiltro := "F2_FILIAL == '" + xFilial("SF2") + "' .And. "
		cFiltro += "D2_CF >= '5" + SPACE(LEN(D2_CF)-1) + "' .And. "
		cFiltro += "DtOs(F2_EMISSAO) >= '" + Dtos(mv_par01) + "' .And. "
		cFiltro += "DtOs(F2_EMISSAO) <= '" + Dtos(mv_par02) + "' .And. "
		// cFiltro += "F2_TIPO == 'N' .And. D2_CODISS <> '" + Space(Len(D2_CODISS)) + "' .And. "
		cFiltro += "F2_TIPO == 'N' .And. "
		cFiltro += "F2_CLIENTE >= '" + mv_par03 + "' .And. F2_CLIENTE <= '" + mv_par04 + "' .And. "
		cFiltro += "F2_DOC >= '" + mv_par05 + "' .And. F2_DOC <= '" + mv_par06 + "'"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

		#IFDEF TOP
		Endif
	#ENDIF
	// nPosRet := aScan(aSX3UtSbz, "BZ_CODISS")
	// if nPosRet  > 0
	// 	cGetCodISS := GetSx3Cache("BZ_CODISS","X3_F3")
	// 	If  Alltrim(cGetCodISS) == "60"
	// 		lGetSX5 := .T.
	// 	Else
	// 		lGetSX5 := .F.
	// 	EndIf
	// Endif


	If lSorocaba
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (cAliasSF3)->(!Eof())

			ProcRegua(LastRec())
			If Interrupcao(@lEnd)
				Exit
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o SF2 para verificar NF Cupom nao sera processada     ³
			//³e valor da Carga Tributária - Lei 12.741			           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTotImp := ""
			cFontImp:= ""

			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA))
				If !Empty(SF2->F2_NFCUPOM)
					(cAliasSF3)->(dbSKip())
					Loop
				Endif

				//Lei Transparência - 12.741
				cTotImp := Iif(SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")

				//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
				SB1->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
					EndIf
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS := (cAliasSF3)->(GetArea())
			lImpRPS	 := .T.
			If lPEImpRPS
				lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
			Endif
			RestArea(aAreaRPS)

			If !lImpRPS
				(cAliasSF3)->(dbSKip())
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca a descricao do codigo de servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescrServ := ""




			If lGetSX5
				// SX5->(dbSetOrder(1))
				// If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->D2_CODISS))

				//TODO: fazer query para pegar os serviços de locação e imprimir aqui nesta variável -- GABRIEL




				cDescrServ := cTeste

				//TODO: Imprimir a data de vencimento na descrição da nota -- GABRIEL



				// Endif
			Else
				dbSelectArea("CCQ")
				CCQ->(dbSetOrder(1))
				If CCQ->(dbSeek(xFilial("CCQ")+(cAliasSF3)->D2_CODISS))
					cDescrServ := CCQ->CCQ_DESC
				Endif
			EndIf

			// If lDescrBar
			// 	SF2->(dbSetOrder(1))
			// 	SD2->(dbSetOrder(3))
			// 	SB1->(dbSetOrder(1))
			// 	If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA))
			// 		If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			// 			If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
			// 				cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
			// 			Endif
			// 		Endif
			// 	Endif
			// Endif

			// If !Empty(cCodServ)
			// 	cCodServ += " / "
			// EndIf

			// cCodServ += Alltrim((cAliasSF3)->D2_CODISS) + " - " + alltrim(cDescrServ)
			// cCodServ += "Locação de automóveis sem condutor" // //

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o pedido para discriminar os servicos prestados no documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cServ := ""
			If lNfeServ
				SC6->(dbSetOrder(4))
				SC5->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE))
					dbSelectArea("SX5")
					// SX5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) //.And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->D2_CODISS),6))
						// cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)+" | "+AllTrim(SubStr(X5Descri(),1,55))
						// If !Empty(cFieldMsg) .And. SC5->(FieldPos(cFieldMsg)) > 0 .And. !Empty(&("SC5->"+cFieldMsg))
						// 	cServ  := AllTrim(&("SC5->"+cFieldMsg))
						// Else
						// 	cServ  := AllTrim(SC5->C5_MENNOTA)
						// EndIf
						// cServ += CHR(13)+CHR(10)+" | "+AllTrim(SubStr(X5Descri(),1,55))
						cServ += cTeste
					Endif
				Endif
			Else
				// dbSelectArea("SX5")
				// SX5->(dbSetOrder(1))
				// If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->D2_CODISS),6))
				cServ := "Locação de automóveis sem condutor"
				// Endif
			Endif

			If Empty(cServ)
				cServ := cCodServ
			Endif

			//Lei Transparência
			If !Empty(cTotImp)
				cServ += CHR(13)+CHR(10)+cTotImp+cFontImp
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para compor a descricao a ser apresentada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS	:= (cAliasSF3)->(GetArea())
			cServPonto	:= ""
			If lDescrNFE
				cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
			Endif
			RestArea(aAreaRPS)
			If !(Empty(cServPonto))
				cServ := cServPonto
			Endif
			aPrintServ	:= M968Discri(cServ,10,999)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o Cliente/Fornecedor do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCNPJCli := ""
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA))
				If RetPessoa(SA1->A1_CGC) == "F"
					cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
				Endif
				cCli		:= SA1->A1_NOME
				cIMCli		:= SA1->A1_INSCRM
				cEndCli		:= SA1->A1_END
				cBairrCli	:= SA1->A1_BAIRRO
				cCepCli		:= SA1->A1_CEP
				cMunCli		:= SA1->A1_MUN
				cCodMun		:= SA1->A1_COD_MUN
				cUFCli		:= SA1->A1_EST
				cEmailCli	:= SA1->A1_EMAIL
			Else
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IntTms()
				aTMS := TMSInfSol((cAliasSF3)->F2_FILIAL,(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE)
				If Len(aTMS) > 0
					cCli		:= aTMS[04]
					If RetPessoa(Alltrim(aTMS[01])) == "F"
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aTMS[02]
					cEndCli		:= aTMS[05]
					cBairrCli	:= aTMS[06]
					cCepCli		:= aTMS[09]
					cMunCli		:= aTMS[07]
					cUFCli		:= aTMS[08]
					cEmailCli	:= aTMS[10]
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para trocar o cliente a ser impresso.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCliNFE
				aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
				// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
				If Len(aMTCliNfe) >= 12
					cCli		:= aMTCliNfe[01]
					cCNPJCli	:= aMTCliNfe[02]
					If RetPessoa(cCNPJCli) == "F"
						cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aMTCliNfe[03]
					cEndCli		:= aMTCliNfe[04]
					cBairrCli	:= aMTCliNfe[05]
					cCepCli		:= aMTCliNfe[06]
					cMunCli		:= aMTCliNfe[07]
					cUFCli		:= aMTCliNfe[08]
					cEmailCli	:= aMTCliNfe[09]
				Endif
			Endif

			cF2_DOC := (cAliasSF3)->F2_DOC
			cF2_SERIE   := (cAliasSF3)->F2_SERIE
			cF2_SERIEV  := (cAliasSF3)->&(SerieNfId("SF2",3,"F2_SERIE"))
			cF2_CLIENTE := (cAliasSF3)->F2_CLIENTE
			cF2_LOJA    := (cAliasSF3)->F2_LOJA
			cF2_EMISSAO := (cAliasSF3)->F2_EMISSAO

			nTOTAL   += (cAliasSF3)->F2_VALBRUT
			nDEDUCAO += 0
			nBASEISS += (cAliasSF3)->F2_BASEISS
			nALIQISS := 0
			nVALISS  += (cAliasSF3)->F2_VALISS

			cKey := (cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA

			(cAliasSF3)->(dbSkip())

			If  cKey <> (cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA .Or. ((cAliasSF3)->(Eof()))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtendo os Valores de PIS/COFINS/CSLL/IR/INSS da NF de saida                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF2->(dbSetOrder(1))
				If SF2->(dbSeek(xFilial("SF2")+cKey))
					If (SF2->F2_VALPIS + SF2->F2_VALCOFI + SF2->F2_VALCSLL) <= nMinPCC
						nValPis  := 0
						nValCof  := 0
						nValCSLL := 0
					Else
						nValPis  := SF2->F2_VALPIS
						nValCof  := SF2->F2_VALCOFI
						nValCSLL := SF2->F2_VALCSLL
					EndIf
					nValINSS := IIf((SF2->F2_VALINSS <= nMinPCC),0,SF2->F2_VALINSS)
					nValIR   := IIf((SF2->F2_VALIRRF <= nMinPCC),0,SF2->F2_VALIRRF)
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtendo as aliquotas de PIS/COFINS/CSLL/IR/INSS atraves da natureza da NF de saida       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SE1->(dbSetOrder(2))
				If SE1->(dbSeek(xFilial("SE1")+cF2_CLIENTE+cF2_LOJA+cF2_SERIE+cF2_DOC))
					While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SF3")+cF2_CLIENTE+cF2_LOJA+cF2_SERIE+cF2_DOC
						If SE1->E1_TIPO == MVNOTAFIS
							cNatureza := SE1->E1_NATUREZ
							Exit
						EndIf
						SE1->(dbSKip())
					EndDo
					SED->(dbSetOrder(1))
					If SED->(dbSeek(xFilial("SDE")+cNatureza))
						nAliqPis  := Iif( nValPis  > 0 , Iif( SED->ED_PERCPIS > 0 , SED->ED_PERCPIS , cMVTXPIS) , 0 )
						nAliqCof  := Iif( nValCof  > 0 , Iif( SED->ED_PERCCOF > 0 , SED->ED_PERCCOF , cMVTXCOF) , 0 )
						nALiqINSS := Iif( nValINSS > 0 , SED->ED_PERCINS , 0 )
						nAliqIR   := Iif( nValIR   > 0 , Iif( SED->ED_PERCIRF > 0 , SED->ED_PERCIRF , cMVALIRF) , 0 )
						nALiqCSLL := Iif( nValCSLL > 0 , Iif( SED->ED_PERCCSL > 0 , SED->ED_PERCCSL , cMVTXCSLL) , 0 )
					EndIf
				Else
					nAliqPis  := Iif( nValPis  > 0 ,cMVTXPIS  , 0 )
					nAliqCof  := Iif( nValCof  > 0 ,cMVTXCOF  , 0 )
					nAliqIR   := Iif( nValIR   > 0 ,cMVALIRF  , 0 )
					nALiqCSLL := Iif( nValCSLL > 0 ,cMVTXCSLL , 0 )
				EndIf

				aItensSD2 := {}
				SD2->(dbSetOrder(3))
				SB1->(dbSetOrder(1))
				If SD2->(dbSeek(xFilial("SD2")+cKey))
					Do While SD2->(!Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cKey
						SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))
						aAdd(aItensSD2,{SD2->D2_ITEM,SB1->B1_DESC,SD2->D2_QUANT,SD2->D2_PRCVEN,SD2->D2_TOTAL})
						SD2->(dbSkip())
					EndDo
				Endif

				ASort(aItensSD2,,,{|x,y| x[1]  < y[1] })

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Relatorio Grafico:                                                                                      ³
				//³* Todas as coordenadas sao em pixels	                                                                   ³
				//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
				//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to nCopias
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - CABECALHO DO RPS - LOGOTIPO - NUMERO E EMISSAO                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:SayBitmap(0110,0170, GetSrvProfString("Startpath","")+"SOROCABA.BMP" ,2350,1800) // o arquivo com o logo deve estar abaixo do rootpath (mp10\system)
					PrintBox( 0080,0080,3350,2330)
					PrintLine(0220,1850,0220,2330)
					PrintLine(0080,1850,0360,1850)
					PrintBox( 0080,0080,3350,2330)
					oPrint:Say(0120,0850,"Prefeitura de Sorocaba",oFontA13n)
					oPrint:Say(0180,0850,"Secretaria de Finanças",oFontA13n)
					oPrint:Say(0250,0500,"RECIBO PROVISÓRIO DE SERVIÇOS - RPS",oFontA16n)
					oPrint:Say(0100,1860,"Número do RPS",oFontA10)
					oPrint:Say(0160,1950,PadC(Alltrim(Alltrim(cF2_DOC) + Iif(!Empty(cF2_SERIEV)," / " + Alltrim(cF2_SERIEV),"")),15),oFontA10n)
					oPrint:Say(0235,1860,"Data de Emissão",oFontA10)
					oPrint:Say(0300,1950,PadC(cF2_EMISSAO,15),oFontA10n)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - PRESTADOR DE SERVICOS                                                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(0360,0080,0360,2330)
					oPrint:Say(0370,0965,"PRESTADOR DE SERVIÇOS",oFontA10n)
					oPrint:Say(0410,0100,"Nome/Razão Social:",oFontA08)
					oPrint:Say(0410,0370,PadR(Alltrim(FWSM0Util():get	FullName()),50),oFontA08n)
					oPrint:Say(0455,0100,"CNPJ:",oFontA08)
					oPrint:Say(0455,1640,"Inscrição Mobiliária: ",oFontA08)
					oPrint:Say(0455,0265,PadR(Transform(oMvMatNfSe:M0_CGC,"@R 99.999.999/9999-99"),50),oFontA08n)
					oPrint:Say(0455,1950,PadR(Alltrim(oMvMatNfSe:M0_INSCM),50),oFontA08n)
					oPrint:Say(0505,0100,"Endereço: ",oFontA08)
					oPrint:Say(0505,0265,PadR(Alltrim(oMvMatNfSe:M0_ENDENT),50) + " - Bairro: " + PadR(Alltrim(Alltrim(oMvMatNfSe:M0_BAIRENT) + " - CEP: " + Transform(oMvMatNfSe:M0_CEPENT,"@R 99999-999")),50) ,oFontA08n)
					oPrint:Say(0555,0100,"Município: ",oFontA08)
					oPrint:Say(0555,1050,"UF: ",oFontA08)
					oPrint:Say(0555,0265,PadR(Alltrim(oMvMatNfSe:M0_CIDENT),50),oFontA08n)
					oPrint:Say(0555,1120,PadR(Alltrim(oMvMatNfSe:M0_ESTENT),50),oFontA08n)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - TOMADOR DE SERVICOS                                                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(0600,0080,0600,2330)
					oPrint:Say(0610,0990,"TOMADOR DE SERVIÇOS",oFontA10n)
					oPrint:Say(0650,0100,"Nome/Razão Social:",oFontA08)
					oPrint:Say(0650,0370,PadR(Alltrim(cCli),40),oFontA08n)
					oPrint:Say(0695,0100,"CNPJ/CPF:",oFontA08)
					oPrint:Say(0695,0265,PadR(cCNPJCli,50),oFontA08n)
					oPrint:Say(0745,0100,"Endereço: ",oFontA08)
					oPrint:Say(0745,0265,PadR(Alltrim(cEndCli),50) + " - Bairro: " + PadR(Alltrim(Alltrim(cBairrCli) + " - CEP: " + Transform(cCepCli,"@R 99999-999")),50) ,oFontA08n)
					oPrint:Say(0795,0100,"Município: ",oFontA08)
					oPrint:Say(0795,1050,"UF: ",oFontA08)
					oPrint:Say(0795,1250,"E-mail: ",oFontA08)
					oPrint:Say(0795,0265,PadR(Alltrim(cMunCli),50),oFontA08n)
					oPrint:Say(0795,1120,PadR(Alltrim(cUFCli),50),oFontA08n)
					oPrint:Say(0795,1350,PadR(Alltrim(cEmailCli),50),oFontA08n)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - DESCRIMINACAO DOS SERVICOS                                                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					oPrint:Say(0855,0940,"Dteste",oFontA12n)
					PrintLine(0905,0080,0905,2330)
					oPrint:Say(0915,0100,"Descrição:",oFontA08)
					nLinha	:= 0950
					For nY := 1 to Len(aPrintServ)
						If nY > 10
							Exit
						Endif
						oPrint:Say(nLinha,0100,Alltrim(aPrintServ[nY]),oFontA08)
						nLinha 	:= nLinha + 39
					Next nY
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - ITENS DO RPS 25 ITEMS POR RPS SEGUNDO O WEB-SERVICES DA NFS-E                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(1335,0080,1335,2330)
					PrintLine(1335,1450,2645,1450)
					PrintLine(1335,1640,2645,1640)
					PrintLine(1335,1950,2645,1950)
					oPrint:Say(1345,0100,"Item",oFontA08)
					oPrint:Say(1345,1470,"Quantidade",oFontA08)
					oPrint:Say(1345,1660,"Valor Unitário",oFontA08)
					oPrint:Say(1345,1970,"Valor Total",oFontA08)
					nLinha	:= 1390
					For nY := 1 to Len(aItensSD2)
						If nY > 25
							Exit
						Endif
						oPrint:Say(nLinha,0100,PadR(aItensSD2[nY][01] + "    " + aItensSD2[nY][02],100),oFontA09)
						oPrint:Say(nLinha,1470,Transform(aItensSD2[nY][03], PesqPict("SD2","D2_QUANT" )),oFontA09)
						oPrint:Say(nLinha,1710,Transform(aItensSD2[nY][04], PesqPict("SD2","D2_PRCVEN")),oFontA09)
						oPrint:Say(nLinha,2020,Transform(aItensSD2[nY][05], PesqPict("SD2","D2_TOTAL" )),oFontA09)
						nLinha 	:= nLinha + 45
					Next nY
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - PIS / COFINS / INSS / IR / CSLL                                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2645,0080,2645,2330)
					PrintLine(2645,0530,2765,0530)
					PrintLine(2645,0980,2765,0980)
					PrintLine(2645,1430,2765,1430)
					PrintLine(2645,1880,2765,1880)
					oPrint:Say(2665,0210,"PIS("   +Transform(nAliqPis, "@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,0640,"COFINS("+Transform(nAliqCof, "@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,1090,"INSS("  +Transform(nAliqINSS,"@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,1580,"IR("    +Transform(nAliqIR  ,"@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,2000,"CSLL("  +Transform(nAliqCSLL,"@E 99.99") +"%):" ,oFontA09)

					oPrint:Say(2710,0230,"R$ " + Transform(nValPis ,PesqPict("SF3","F2_VALISS")),oFontA10n)
					oPrint:Say(2710,0675,"R$ " + Transform(nValCof ,PesqPict("SF3","F2_VALISS")),oFontA10n)
					oPrint:Say(2710,1125,"R$ " + Transform(nValINSS,PesqPict("SF3","F2_VALISS")),oFontA10n)
					oPrint:Say(2710,1575,"R$ " + Transform(nValIR  ,PesqPict("SF3","F2_VALISS")),oFontA10n)
					oPrint:Say(2710,2020,"R$ " + Transform(nValCSLL,PesqPict("SF3","F2_VALISS")),oFontA10n)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - VALOR TOTAL DO RPS                                                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2765,0080,2765,2330)
					oPrint:Say(2785,0950,"VALOR TOTAL DO RPS =",oFontA11n)
					oPrint:Say(2785,1950,"R$ " + Transform(nTOTAL,PesqPict("SF3","F2_VALBRUT")),oFontA11n)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - RODAPE - VALOR TODAL DE DEDUCOES - BASE DE CALCULO - ALIQUOTA - VALOR DO ISS                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2855,0080,2855,2330)
					PrintLine(2855,0642,2980,0642)
					PrintLine(2855,1204,2980,1204)
					PrintLine(2855,1766,2980,1766)

					oPrint:Say(2865,0100,"VL. Total Deduções:",oFontA08)
					oPrint:Say(2865,0662,"Base de Cálculo:"   ,oFontA08)
					oPrint:Say(2865,1224,"Alíquota:"          ,oFontA08)
					oPrint:Say(2865,1786,"Valor do ISS:"      ,oFontA08)

					oPrint:Say(2920,0360,"R$ " + Transform(nDEDUCAO,PesqPict("SF3","F2_BASEISS")),oFontA08n)
					oPrint:Say(2920,0890,"R$ " + Transform(nBASEISS,PesqPict("SF3","F2_BASEISS")),oFontA08n)
					oPrint:Say(2920,1640,Transform(nALIQISS,PesqPict("SF3","F3_ALIQICM"))+"%",oFontA08n)
					oPrint:Say(2920,2020,"R$ " + Transform(nVALISS ,PesqPict("SF3","F2_VALISS" )),oFontA08n)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - INFORMACOES IMPORTANTES                                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2980,0080,2980,2330)
					oPrint:Say(2990,0920,"INFORMAÇÕES IMPORTANTES",oFontA10n)
					oPrint:Say(3035,0100,"Este recibo Provisório de Serviços - RPS não é válido como documento fiscal. O prestador do serviço, no prazo de até 5 (cinco) dias da emissão deste RPS, deverá",oFontA08)
					oPrint:Say(3075,0100,"substituí-lo por uma Nota Fiscal de Serviços Eletrônica.",oFontA08)
					oPrint:Say(3170,0100,"* Valores para Alíquota e Valor de ISSQN serão calculados de acordo com o movimento econômico com base na tabela de faixa de faturamento.",oFontA08)
					If nCopias > 1 .And. nX < nCopias
						oPrint:EndPage()
					Endif

				Next nX
				cCodServ := ""
				cServ    := ""
				nTotal   := 0
				nDeducao := 0
				nBaseISS := 0
				nValISS  := 0
			EndIf
			If !((cAliasSF3)->(Eof()))
				oPrint:EndPage()
			Endif
		Enddo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (cAliasSF3)->(!Eof())
			ProcRegua(LastRec())
			If Interrupcao(@lEnd)
				Exit
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analisa Deducoes do ISS  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			nValDed := 0

			nValDed += 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor contabil ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlContab := (cAliasSF3)->F2_VALBRUT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o SF2 para verificar o horario de emissao do documento e Lei da Transparência³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF2->(dbSetOrder(1))
			cTime   := ""
			cTotImp := ""
			cFontImp:= ""

			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA))
				cTime := Transform(SF2->F2_HORA,"@R 99:99")
				//Lei Transparência - 12.741
				cTotImp := Iif(SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
				//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
				SB1->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
					EndIf
				EndIf
				cValAprTri := Iif(SF2->F2_TOTIMP>0, Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"/"+AlqLeiTran("SB1","SBZ")[2], "")
				// NF Cupom nao sera processada
				If !Empty(SF2->F2_NFCUPOM)
					(cAliasSF3)->(dbSKip())
					Loop
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS := (cAliasSF3)->(GetArea())
			lImpRPS	 := .T.
			If lPEImpRPS
				lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
			Endif
			RestArea(aAreaRPS)
			If !lImpRPS
				(cAliasSF3)->(dbSKip())
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca a descricao do codigo de servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescrServ := ""

			If lGetSX5
				// SX5->(dbSetOrder(1))
				// If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->D2_CODISS))
				cDescrServ := "Locação de automóveis sem condutor"
				// Endif
			Else
				dbSelectArea("CCQ")
				CCQ->(dbSetOrder(1))
				If CCQ->(dbSeek(xFilial("CCQ")+(cAliasSF3)->D2_CODISS))
					cDescrServ := "CCQ->CCQ_DESC"
				Endif
			EndIf
			lDescrBar := .t.
			lCampBar := .t.
			If lDescrBar
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				SB1->(dbSetOrder(1))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
							cDescrServ := If (lCampBar,SB1->(AllTrim(B1_DESC)),"cDescrServ")
						Endif
					Endif
				Endif
			Endif
			If lRecife
				cCodAtiv := "Locação de automóveis sem condutor"//Alltrim((cAliasSF3)->D2_CODISS)
			Else
				cCodServ := Alltrim((cAliasSF3)->D2_CODISS) + " - " + "123456"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o pedido para discriminar os servicos prestados no documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cServ := ""
			cPeriodo1 := ""
			cPreco1 := ""
			lNfeServ := .t.
			If lNfeServ
				SC6->(dbSetOrder(4))
				SC5->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE))
					dbSelectArea("SX5")
					SX5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) //.And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->D2_CODISS),6))
						// If !Empty(cFieldMsg) .And. SC5->(FieldPos(cFieldMsg)) > 0 .And. !Empty(&("SC5->"+cFieldMsg))
						// 	cServ  := AllTrim(&("SC5->"+cFieldMsg))
						// Else
						// 	cServ  := AllTrim(SC5->C5_MENNOTA)
						// EndIf
						// cServ += CHR(13)+CHR(10)+" | "+AllTrim(SubStr(X5Descri(),1,55))
						// cNroInsObr := SC5->C5_OBRA
						cServ += cTeste
						cPeriodo1 := cPeriodo
						cPreco1 := cPreco
					Endif
				Endif
			Else
				// dbSelectArea("SX5")
				// SX5->(dbSetOrder(1))
				// If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->D2_CODISS),6))
				cServ := "Locação de automóveis sem condutor"//AllTrim(SubStr(X5Descri(),1,55))
				// Endif
			Endif
			If Empty(cServ)
				cServ := cDescrServ
			Endif
			//Lei Transparência
			If !Empty(cTotImp) .And. !lPaulista
				cServ += CHR(13)+CHR(10)+cTotImp+cFontImp
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para compor a descricao a ser apresentada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS	:= (cAliasSF3)->(GetArea())
			cServPonto	:= ""
			If lDescrNFE
				cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
			Endif
			RestArea(aAreaRPS)
			If !(Empty(cServPonto))
				cServ := cServPonto
			Endif
			aPrintServ := Mtr968Mont(cServ,13,999)  // IMPRIME SERVIÇOS
			// cTeste := ""
			// cContrato := ""
			// cPreco := ""
			// cPeriodo := ""
			// cProjeto := ""

			// SC6->(DbSetOrder(4))
			// If SC6->(DbSeek(xFilial("SC6") + cF2_DOC + cF2_SERIE))
			// 	FPA->(DbSetOrder(3)) // FPA_FILIAL+FPA_AS+FPA_VIAGEM
			// 	FPY->(DbSetOrder(1)) // FPY_FILIAL+FPY_PEDVEN+FPY_PROJET
			// 	FPZ->(DbSetOrder(1)) // FPZ_FILIAL+FPZ_PEDVEN+FPZ_PROJET+FPZ_ITEM
			// 	FP0->(DbSetOrder(1))
			// 	cChave := SC6->C6_FILIAL + SC6->C6_NUM

			// 	If FPY->(DbSeek(xFilial("FPY") + SC6->C6_NUM))
			// 		While !SC6->(Eof()) .And. (SC6->C6_FILIAL + SC6->C6_NUM) == cChave

			// 			If FPZ->(DbSeek(xFilial("FPZ") + SC6->C6_NUM + FPY->FPY_PROJET + SC6->C6_ITEM + cF2_CLIENTE + cF2_LOJA + cF2_SERIE + cF2_DOC))
			// 				cAsPedido  := FPZ->FPZ_AS
			// 				cPeriodo   := FPZ->FPZ_PERLOC

			// 				If FPA->(DbSeek(xFilial("FPA") + cAsPedido))

			// 					cTeste := RTRIM(FPA->FPA_DESGRU) + CHR(32) + RTRIM(FPA->FPA_XPLACA) + Replicate(CHR(32), 10) + DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM) + Replicate(CHR(32), 25) + RTRIM(Transform(FPA->FPA_PRCUNI, "@E 999,999,999.99")) + CHR(13) + CHR(10)
			// 					cProjeto := FPA->FPA_PROJET


			// 					ELSE
			// 						oPrint:SAY(3000,390,"TESTE")

			// 				EndIf
			// 			EndIf

			// 			// If !SC6->(EOF())
			// 			SC6->(DbSkip())
			// 			// Else
			// 			// Exit
			// 			// EndIf
			// 		EndDo
			// 	EndIf
			// EndIf

			If lRioJaneiro
				cObsRio := ""
				nDescIncond := 0
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						SF4->(DbSetOrder(1))
						If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
							If SF2->F2_DESCONT > 0
								If SF4->F4_DESCOND == "1"
									cObsRio := " Deconto Condic. de (R$) "
									cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99"))
								Else
									nDescIncond := SF2->F2_DESCONT
								EndIf
							EndIf
						EndIf
					Endif
				Endif
			Endif

			cObserv := ""

			If lRioJaneiro
				cObsRio += "'Obrigatória a conversão em Nota Fiscal de Serviços Eletrônica – NFS-e – NOTA CARIOCA em até vinte dias.'" + " | "
			EndIf
			aAreaRPS := (cAliasSF3)->(GetArea())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para complementar as observacoes a serem apresentadas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cObsPonto	:= ""
			If lObsNFE
				cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
			Endif
			RestArea(aAreaRPS)
			cObserv 	:= cObserv + cObsPonto
			cObserv 	:= cObserv + cObsRio
			aPrintObs	:= Mtr968Mont(cObserv,11,675)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o cLiente/fornecedor do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCNPJCli := ""
			cRecIss  := ""
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA))
				If RetPessoa(SA1->A1_CGC) == "F"
					cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
				Endif
				cCli		:= SA1->A1_NOME
				cIMCli		:= SA1->A1_INSCRM
				cEndCli		:= SA1->A1_END
				cBairrCli	:= SA1->A1_BAIRRO
				cCepCli		:= SA1->A1_CEP
				cMunCli		:= SA1->A1_MUN
				cCodMun		:= SA1->A1_COD_MUN
				cUFCli		:= SA1->A1_EST
				cEmailCli	:= SA1->A1_EMAIL
				cRecIss     := SA1->A1_RECISS
				cRecCof     := SA1->A1_RECCOFI
				cRecPis     := SA1->A1_RECPIS
				cRecIR      := SA1->A1_RECIRRF
				cRecCsl     := SA1->A1_RECCSLL
				cRecIns     := SA1->A1_RECINSS
			Else
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IntTms()
				aTMS := TMSInfSol((cAliasSF3)->F2_FILIAL,(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE)
				If Len(aTMS) > 0
					cCli		:= aTMS[04]
					If RetPessoa(Alltrim(aTMS[01])) == "F"
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aTMS[02]
					cEndCli		:= aTMS[05]
					cBairrCli	:= aTMS[06]
					cCepCli		:= aTMS[09]
					cMunCli		:= aTMS[07]
					cUFCli		:= aTMS[08]
					cEmailCli	:= aTMS[10]
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para trocar o cliente a ser impresso.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCliNFE
				aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F2_DOC,(cAliasSF3)->F2_SERIE,(cAliasSF3)->F2_CLIENTE,(cAliasSF3)->F2_LOJA})
				// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
				If Len(aMTCliNfe) >= 12
					cCli		:= aMTCliNfe[01]
					cCNPJCli	:= aMTCliNfe[02]
					If RetPessoa(cCNPJCli) == "F"
						cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aMTCliNfe[03]
					cEndCli		:= aMTCliNfe[04]
					cBairrCli	:= aMTCliNfe[05]
					cCepCli		:= aMTCliNfe[06]
					cMunCli		:= aMTCliNfe[07]
					cUFCli		:= aMTCliNfe[08]
					cEmailCli	:= aMTCliNfe[09]
				Endif
			Endif
			If lBhorizonte .Or. lPaulista .Or. lLondrina
				nValDed     := 0
				nValDesc    := 0
				nDescIncond := 0
				nValLiq     := 0
				nVALISS     := 0
				nValPis     := 0
				nValCof     := 0
				nValCSLL    := 0
				nValIR      := 0
				nValINSS	:= 0
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
							// If Alltrim(SD2->D2_CODISS) == Alltrim((cAliasSF3)->D2_CODISS)
							SF4->(DbSetOrder(1))
							If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
								nValLiq  += SD2->D2_TOTAL
								nVALISS  += SD2->D2_VALISS
								nValPis  += SD2->D2_VALPIS
								nValCof  += SD2->D2_VALCOF
								nValCSLL += SD2->D2_VALCSL
								nValIR   += SD2->D2_VALIRRF
								nValINSS += SD2->D2_VALINS
								nValDesc += SD2->D2_DESCON
								If SF4->F4_DESCOND <> "1"
									nDescIncond := nValDesc
								EndIf
								If SF4->F4_AGREG == "D"
									nValDesc += SD2->D2_DESCICM
									nValLiq -= SD2->D2_DESCICM
									//Acrescenta o ISS no valor Contábil, pois o ISS foi deduzido na emissão da NF e
									//para a impressão correta do RPS é necessario soma-lo
									//nVlContab é impresso como valor da mercadoria para Belo Horizonte
									nVlContab := nVlContab + SD2->D2_DESCICM
								Endif
								nValDed += SD2->( D2_ABATISS + D2_ABATMAT )
							EndIf
							// Endif
							SD2->(dbSkip())
						Enddo
					Endif
				EndIf
				nRetFeder   := 0
				If cRecIss == "1"
					nValLiq := nValLiq - nValISS
				EndIf
				If cRecCof == "S"
					nValLiq    := nValLiq - nValCof
					nRetFeder  := nRetFeder + nValCof
				EndIf
				If cRecPis == "S"
					nValLiq := nValLiq - nValPis
					nRetFeder  := nRetFeder + nValPis
				EndIf
				If cRecCsl == "S"
					nValLiq := nValLiq - nValCsll
					nRetFeder  := nRetFeder + nValCsll
				EndIf
				If cRecIr == "1"
					nValLiq := nValLiq - nValIR
					nRetFeder  := nRetFeder + nValIR
				Endif
				If cRecIns == "S"
					nValLiq := nValLiq - nValINSS
					nRetFeder  := nRetFeder + nValINSS
				EndIf
				If  ( nValPis + nValCof + nValCSLL ) <= nMinPCC // Tratamento do PCC
					nValPis 		:= 0
					nValCof 	:= 0
					nValCSLL 	:= 0
				EndIf
				If nValIR <= nMinPCC
					nValIR := 0
				EndIf
				If nValINSS <= nMinPCC
					nValINSS := 0
				EndIf
			Endif

			If lJoinville
				SF2->(dbSetOrder(1))
				SB1->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F2_DOC+F2_SERIE)))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
							nValBase	:= Iif (Empty((cAliasSF3)->F2_BASEISS),0,(cAliasSF3)->F2_BASEISS)
							nAliquota	:= SB1->B1_ALIQISS
						Endif
					EndIf
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Relatorio Grafico:                                                                                      ³
			//³* Todas as coordenadas sao em pixels	                                                                   ³
			//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
			//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:StartPage()
			For nX := 1 to nCopias
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box no tamanho do RPS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Line(nLinIni,nColIni,nLinIni,nColFim)
				oPrint:Line(nLinIni,nColIni,nLinFim,nColIni)
				oPrint:Line(nLinIni,nColFim,nLinFim,nColFim)
				oPrint:Line(nLinFim,nColIni,nLinFim,nColFim)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados da empresa emitente do documento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//O arquivo com o logo deve estar abaixo do rootpath (mp8\system)
				/*If Empty(cLogAlter)
					cLogo := FisxLogo("1")
				Else
					cLogo := cLogAlter
				EndIf*/
				cLogo := GetSrvProfString('StartPath','')+'lgmid'+CEMPANT+'.png'
				if !File(cLogo)
					cLogo := GetSrvProfString('StartPath','')+'lgmid.png'
				endif
				if !File(cLogo)
					cLogo := GetSrvProfString('StartPath','')+'lgrl99.bmp'
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Título do Documento  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(160,nCentro/2-len(cTitulo),cTitulo + " " +"FATURA"  ,oFont12n)
				oPrint:SayBitmap(270,nColIni+10,cLogo,340,340)
				oPrint:Line(nLinIni,1800,612,1800)
				oPrint:Line(354,1800,354,nColFim)
				oPrint:Line(483,1800,483,nColFim)
				oPrint:Line(612,nColIni,612,nColFim)
				oPrint:Say(275,730,PadC(Alltrim(FWSM0Util():getSM0FullName()),50),oFont12n)
				oPrint:Say(305,680,PadC(Alltrim(oMvMatNfSe:M0_ENDENT),50),oFont10n)
				oPrint:Say(355,680,PadC(Alltrim(Alltrim(oMvMatNfSe:M0_BAIRENT) + " - " + Transform(oMvMatNfSe:M0_CEPENT,"@R 99999-999")),50),oFont10n)
				oPrint:Say(405,680,PadC(Alltrim(oMvMatNfSe:M0_CIDENT) + " - " + Alltrim(oMvMatNfSe:M0_ESTENT),50),oFont10n)
				oPrint:Say(455,680,PadC(Alltrim(STR0013) + Alltrim(oMvMatNfSe:M0_TEL),50),oFont10n) // Telefone:
				oPrint:Say(505,680,PadC(Alltrim(STR0014) + Transform(oMvMatNfSe:M0_CGC,"@R 99.999.999/9999-99"),50),oFont10n) // C.N.P.J.::
				oPrint:Say(555,680,PadC(Alltrim(STR0015) + Alltrim(oMvMatNfSe:M0_INSCM),50),oFont10n) // I.M.:
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Informacoes sobre a emissao do RPS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(250,1830,PadC(Alltrim(STR0016),15),oFont10n) // "Número/Série RPS"
				oPrint:Say(295,1830,PadC(Alltrim(Alltrim((cAliasSF3)->F2_DOC) + Iif(!Empty((cAliasSF3)->F2_SERIE)," / " + Alltrim((cAliasSF3)->F2_SERIE),"")),15),oFont08n)
				oPrint:Say(375,1830,PadC(Alltrim(STR0017),15),oFont10n) // "Data Emissão"
				oPrint:Say(420,1830,PadC((cAliasSF3)->F2_EMISSAO,15),oFont08n)
				oPrint:Say(510,1830,PadC(Alltrim("Vencimento:"),15),oFont10n) // "Vencimento"
				oPrint:Say(555,1830,"  "+cVenci,oFont08n)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados do destinatario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(648,nCentro/2-len(STR0019),STR0019,oFont11n) // "DADOS DO DESTINATÁRIO"
				oPrint:Say(685,250,STR0020,oFont10n) // "Nome/Razão Social:"
				oPrint:Say(745,250,STR0021,oFont10n) // "C.P.F./C.N.P.J.:"
				oPrint:Say(805,250,STR0022,oFont10n) // "Inscrição Municipal:"
				oPrint:Say(865,250,STR0024,oFont10n) // "Endereço:"
				oPrint:Say(925,250,STR0025,oFont10n) // "CEP:"
				oPrint:Say(985,250,STR0026,oFont10n) // "Município:"
				oPrint:Say(985,1800,STR0028,oFont10n) // "UF:"
				oPrint:Say(1045,250,STR0027,oFont10n) // "E-mail:"
				oPrint:Say(685,750,Alltrim(cCli),oFont10n)
				oPrint:Say(745,750,Alltrim(cCNPJCli),oFont10n)
				oPrint:Say(805,750,Alltrim(cIMCli),oFont10n)
				oPrint:Say(865,750,Alltrim(cEndCli) + " - " + Alltrim(cBairrCli) ,oFont10n)
				oPrint:Say(925,750,Transform(cCepCli,"@R 99999-999"),oFont10n)
				oPrint:Say(985,750,Alltrim(cMunCli),oFont10n)
				oPrint:Say(985,1900,Alltrim(cUFCli),oFont10n)
				oPrint:Say(1045,750,Alltrim(cEmailCli),oFont10n)
				oPrint:Line(1105,nColIni,1105,nColFim)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados do intermediario de serviço³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//oPrint:Say(1118,nCentro/2-len(STR0045),STR0045,oFont12n) // "INTERMEDIÁRIO DE SERVIÇOS"
				//oPrint:Say(1175,250,STR0021,oFont10n) // "C.P.F./C.N.P.J.:"
				//oPrint:Say(1175,950,STR0020,oFont10n) // "Nome/Razão Social:"
				//oPrint:Say(1175,520,Alltrim(cCNPJIntSer),oFont10)
				//oPrint:Say(1175,1255,Alltrim(cCliIntSer),oFont10)
				//oPrint:Line(1235,nColIni,1235,nColFim)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Discriminacao dos Servicos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(1182,nCentro/2-len(STR0029),STR0029,oFont12n) // "DISCRIMINAÇÃO DOS SERVIÇOS"
				oPrint:Say(1250,250,"ESPECIFICAÇÃO",oFont12n) // Veiculos 
				oPrint:Say(1250,600,"   PERIODO",oFont12n) //Periodo
				oPrint:Say(1250,1000,"Valor",oFont12n) // Valor 
			
				nLinha	:= 1300
				For nY := 1 to Len(aPrintServ)
					If nY > 15
						Exit
					Endif
					oPrint:Say(nLinha,250,Alltrim(aPrintServ[nY]),oFont10n)
					nLinha 	:= nLinha + 45
				Next
				oPrint:Line(1950,nColIni,1950,nColFim)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valores da prestacao de servicos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lBhorizonte
					//oPrint:Say(1880,nColIni,PadC(Alltrim(STR0030)+" R$ "+AllTrim(Transform(nVlContab,"@E 999,999,999.99")),100) ,oFont12n
					oPrint:Line(1850,610,1950,610) // CAIXA PEDIDO DE VENDA
					oPrint:Say(1900,240, ("Pedido de Venda: ") + (cPedido),oFont10n )
					oPrint:Line(1950,800,2050,800) // CAIXA PEDIDO DE VENDA
					oPrint:Say(2000,240, ("Projeto: ") + (cProjeto),oFont10n )
					oPrint:Say(2000,820, ("Contrato: ") + (cContrato),oFont10n )
					oPrint:Say(1900,400,PadC("TOTAL DA FATURA R$ "+AllTrim(Transform(nVlContab,"@E 999,999,999.99")),100) ,oFont12n)
					// oPrint:Line(1980,nColIni,1980,nColFim) //line comentada
				EndIf

				If lRecife
					oPrint:Say(1975,250,Alltrim(STR0043),oFont10n) // "Código do Serviço"
					oPrint:Say(2005,250,Alltrim(cCodAtiv),oFont10)
				ElseIf lBhorizonte
					oPrint:Say(1865,250,Alltrim(STR0043),oFont10n) // "Código do Serviço"
					oPrint:Say(1865,950,Alltrim(cCodServ),oFont10)
				ElseIf lPaulista .Or. lLondrina
					oPrint:Line(1950,582,2050,582)
					oPrint:Line(1950,972,2050,972)
					oPrint:Line(1950,1372,2050,1372)
					oPrint:Line(1950,1772,2050,1772)
					oPrint:Say(1965,250,Alltrim(STR0046),oFont10n) // "INSS (R$)"
					oPrint:Say(2005,280,Transform(nValINSS,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,600,Alltrim(STR0047),oFont10n) // "IRPF (R$)"
					oPrint:Say(2005,670,Transform(nValIR,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,1000,Alltrim(STR0048),oFont10n) // "CSLL (R$)"
					oPrint:Say(2005,1070,Transform(nValCSLL,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,1400,Alltrim(STR0049),oFont10n) // "COFINS (R$)"
					oPrint:Say(2005,1470,Transform(nValCof,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,1800,Alltrim(STR0050),oFont10n) // "PIS/PASEP (R$)"
					oPrint:Say(2005,1870,Transform(nValPis,"@E 999,999,999.99"),oFont10)
					oPrint:Line(2050,nColIni,2050,nColFim)
					oPrint:Say(2055,250,Alltrim(STR0031),oFont10n) // "Código do Serviço"
					oPrint:Say(2100,250,Alltrim(cCodServ),oFont10)
				Else
					// oPrint:Say(1975,250,Alltrim(STR0031),oFont10n) // "Código do Serviço"
					// oPrint:Say(2005,250,Alltrim(cCodServ),oFont10)
				EndIf

				If lBhorizonte
					oPrint:Line(1925,nColIni,1925,nColFim)
				ElseIf lPaulista .Or. lLondrina
					oPrint:Line(2145,nColIni,2145,nColFim)
				Else
					oPrint:Line(2050,nColIni,2050,nColFim)
				EndIf

				If lRioJaneiro
					oPrint:Line(2050,632,2150,632)
					oPrint:Line(2050,979,2150,979)
					oPrint:Line(2050,1446,2150,1446)
					oPrint:Line(2050,1736,2150,1736)
					oPrint:Say(2065,250,"Total deduções IRRF(R$)",oFont08n) // "Total deduções (R$)"
					oPrint:Say(2105,320,Transform(nValDed,"@E 999,999,999.99"),oFont09n)
					oPrint:Say(2065,647,Alltrim(STR0044),oFont08n) // "Desc.Incond. (R$)"
					oPrint:Say(2105,667,Transform(nDescIncond,"@E 999,999,999.99"),oFont09n)
					oPrint:Say(2065,1014,"Base de cálculo IRRF(R$)",oFont08n) // "Base de cálculo (R$)"
					oPrint:Say(2105,1134,Transform((cAliasSF3)->F2_BASEISS,"@E 999,999,999.99"),oFont09n)
					oPrint:Say(2065,1484,"Alíquota IRRF(%)",oFont08n) // "Alíquota (%)"
					// oPrint:Say(2105,1584,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)
					oPrint:Say(2105,1584,Transform(0,"@E 999.99"),oFont09n)
					oPrint:Say(2065,1791,"Alíquota IRRF(%)",oFont08n) // "Valor do ISS (R$)"
					oPrint:Say(2105,1881,Transform((cAliasSF3)->F2_VALISS,"@E 999,999,999.99"),oFont09n)
					oPrint:Line(2150,nColIni,2150,nColFim)
				ElseIf lBhorizonte
					oPrint:Say(1950,250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
					oPrint:Say(1950,920,Transform(nVlContab,"@E 999,999,999.99"),oFont09)
					oPrint:Say(1950,1250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
					oPrint:Say(1950,1870,Transform(nVlContab,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2000,250,Alltrim("(-)Descontos: "),oFont09n) // "Descontos"
					oPrint:Say(2000,920,Transform(nValDesc,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2000,1250,Alltrim("(-)Deduçoes: "),oFont08n) // "Deduções"
					oPrint:Say(2000,1870,Transform(nValDed,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2050,250,Alltrim("(-)Ret.Federais: "),oFont09n) // "Ret.Federais"
					oPrint:Say(2050,920,Transform(nRetFeder,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2050,1250,Alltrim("(-)Desc.Incond.: "),oFont09n) // "Desc.Incod"
					oPrint:Say(2050,1870,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2100,250,Alltrim("(-)ISS Ret.: "),oFont08n) // "ISS Ret."
					oPrint:Say(2100,920,Transform(IIf(cRecIss=="1",nValISS,0),"@E 999,999,999.99"),oFont09)
					oPrint:Say(2100,1250,Alltrim("(=)Base Cálc.: "),oFont08n) // "Base Cálc."
					oPrint:Say(2100,1870,Transform((cAliasSF3)->F2_BASEISS,"@E 999,999,999.99"),oFont09n)
					oPrint:Say(2150,250,Alltrim("Valor Liq.: "),oFont09n) // "Valor Liq."
					oPrint:Say(2150,920,Transform(nValLiq,"@E 999,999,999.99"),oFont09n) // o CERTO 
					oPrint:Say(2150,1250,Alltrim("Alíquota: "),oFont08n) // "Alíquota"
					// oPrint:Say(2150,1988,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)
					oPrint:Say(2150,1988,Transform(0,"@E 999.99"),oFont09)
					oPrint:Say(2200,1250,Alltrim("(=)Valor ISS: "),oFont08n) // "Valor ISS"
					oPrint:Say(2200,1870,Transform((cAliasSF3)->F2_VALISS,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2260,250,"PIS:" ,oFont09)
					oPrint:Say(2260,285,Transform(nValPis ,PesqPict("SF3","F2_VALISS")),oFont09)
					oPrint:Say(2260,630,"COFINS:" ,oFont09)
					oPrint:Say(2260,660,Transform(nValCof ,PesqPict("SF3","F2_VALISS")),oFont09)
					oPrint:Say(2260,1005,"IR:" ,oFont09)
					oPrint:Say(2260,1035,Transform(nValIR  ,PesqPict("SF3","F2_VALISS")),oFont09)
					oPrint:Say(2260,1380,"CSLL:" ,oFont09)
					oPrint:Say(2260,1410,Transform(nValCSLL,PesqPict("SF3","F2_VALISS")),oFont09)
					oPrint:Say(2260,1755,"INSS:" ,oFont09)
					oPrint:Say(2260,1785,Transform(nValINSS,PesqPict("SF3","F2_VALISS")),oFont09)
					/*oPrint:Say(2330,nColIni,PadC(Alltrim(STR0036),75),oFont10n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
					oPrint:Line(2380,nColIni,2380,nColFim)
					oPrint:Line(2380,712,2380,712)
					oPrint:Line(2380,920,2380,920)
					oPrint:Line(2380,1799,2380,1799)
					oPrint:Say(2400,250,Alltrim(STR0037),oFont09n) // "Número"
					oPrint:Say(2440,250,Padl(StrZero(Year((cAliasSF3)->F2_EMISSAO),4)+"/"+(cAliasSF3)->F2_NFELETR,nTamNfelet),oFont10)
					oPrint:Say(2400,727,Alltrim(STR0038),oFont09n) // "Emissão"
					oPrint:Say(2440,727,Padl(Transform(dToC((cAliasSF3)->F2_EMINFE),"@d"),10),oFont10)
					oPrint:Say(2400,935,Alltrim(STR0039),oFont09n) // "Código Verificação"
					oPrint:Say(2440,935,Alltrim((cAliasSF3)->F2_CODNFE),oFont10)
					oPrint:Say(2400,1808,Alltrim(STR0040),oFont09n) // "Crédito IPTU"
					oPrint:Say(2440,1861,Transform((cAliasSF3)->F2_CREDNFE,"@E 999,999,999.99"),oFont10)
					oPrint:Line(2500,nColIni,2500,nColFim)*/
					nLinha	:= 2330
					For nY := 1 to Len(aPrintObs)
						If nY > 11
							Exit
						Endif
						oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont09)
						nLinha 	:= nLinha + 50
					Next
				ElseIf lPaulista .Or. lLondrina
					cMunPreSer := UfCodIBGE(cUFCli)+cCodMun
					oPrint:Line(2145,582,2245,582)
					oPrint:Line(2145,972,2245,972)
					oPrint:Line(2145,1372,2245,1372)
					oPrint:Line(2145,1772,2245,1772)
					oPrint:Say(2160,250,"Total deduções IRRF(R$)",oFont08n) // "Total deduções (R$)"
					oPrint:Say(2200,280,Transform(nValDed,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,600,"Base de cálculo IRRF(R$)",oFont08n) // "Base de cálculo (R$)"
					oPrint:Say(2200,670,Transform((cAliasSF3)->F2_BASEISS,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,1000,"Alíquota IRRF(%)",oFont08n) // "Alíquota (%)"
					// oPrint:Say(2200,1070,Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2200,1070,Transform(0,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,1400,"Alíquota IRRF(%)",oFont08n) // "Valor do ISS (R$)"
					oPrint:Say(2200,1470,Transform((cAliasSF3)->F2_VALISS,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,1800,Alltrim(STR0051),oFont08n) // "Crédito (R$)"
					oPrint:Say(2200,1870,Transform(nValCred,"@E 999,999,999.99"),oFont10)
					oPrint:Line(2245,nColIni,2245,nColFim)
					//
					oPrint:Line(2245,920,2345,920)
					oPrint:Line(2245,1400,2345,1400)
					oPrint:Say(2260,250,Alltrim(STR0052),oFont08n) //"Municipio da Prestação do Serviço"
					oPrint:Say(2300,250,cMunPreSer,oFont10)
					oPrint:Say(2260,940,Alltrim(STR0053),oFont08n) //"Número da Inscrição da Obra"
					oPrint:Say(2300,940,cNroInsObr,oFont10)
					oPrint:Say(2260,1425,Alltrim(STR0054),oFont08n) //"Valor Aproximado dos Tributos/Fonte"
					oPrint:Say(2300,1425,cValAprTri,oFont10)
					oPrint:Line(2345,nColIni,2345,nColFim)
				Else
					oPrint:Line(2050,712,2150,712)
					oPrint:Line(2050,1199,2150,1199)
					oPrint:Line(2050,1686,2150,1686)
					oPrint:Say(2085,250,"Total deduções IRRF(R$)",oFont12n) // "Total deduções (R$)"
					// oPrint:Say(2105,370,Transform(nValDed,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2115,370,Transform((cAliasSF3)->D2_VALIRRF,"@E 999,999,999.99"),oFont10n)
					oPrint:Say(2085,737,"Base de cálculo IRRF(R$)",oFont12n) // "Base de cálculo (R$)"
					// oPrint:Say(2105,857,Iif(lJoinville,Transform(nValBase,"@E 999,999,999.99"),Transform((cAliasSF3)->F2_BASEISS,"@E 999,999,999.99")),oFont10)
					oPrint:Say(2115,857,Transform((cAliasSF3)->D2_BASEIRR,"@E 999,999,999.99"),oFont10n)
					oPrint:Say(2085,1224,"Alíquota IRRF(%)",oFont12n) // "Alíquota (%)"
					// oPrint:Say(2105,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99")),oFont10)
					// oPrint:Say(2105,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99")),oFont10)
					oPrint:Say(2115,1344,Transform((cAliasSF3)->D2_ALQIRRF,"@E 999,999,999.99"),oFont10n)
					oPrint:Say(2085,1711,"Valor Líquido da Fatura(R$)",oFont12n) // "Valor do ISS (R$)"
					// oPrint:Say(2105,1831,Transform((cAliasSF3)->F2_VALISS,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2115,1831,Transform(nVlContab - (cAliasSF3)->D2_VALIRRF,"@E 999,999,999.99"),oFont10n)
					oPrint:Line(2150,nColIni,2150,nColFim)
				EndIf

				If !(lBhorizonte .Or. lPaulista .Or. lLondrina)
				/*	oPrint:Say(2180,nCentro/2-len(STR0036),STR0036,oFont12n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
					oPrint:Line(2250,nColIni,2250,nColFim)
					oPrint:Line(2250,712,2350,712)
					oPrint:Line(2250,920,2350,920)
					oPrint:Line(2250,1799,2350,1799)
					oPrint:Say(2265,250,Alltrim(STR0037),oFont10n) // "Número"
					oPrint:Say(2305,250,Padl(StrZero(Year((cAliasSF3)->F2_EMISSAO),4)+"/"+(cAliasSF3)->F2_NFELETR,nTamNfelet),oFont10)
					oPrint:Say(2265,727,Alltrim(STR0038),oFont10n) // "Emissão"
					oPrint:Say(2305,727,Padl(Transform(dToC((cAliasSF3)->F2_EMINFE),"@d"),10),oFont10)
					oPrint:Say(2265,935,Alltrim(STR0039),oFont10n) // "Código Verificação"
					oPrint:Say(2305,935,Alltrim((cAliasSF3)->F2_CODNFE),oFont10)
					oPrint:Say(2265,1808,Alltrim(STR0040),oFont10n) // "Crédito IPTU"
					oPrint:Say(2305,1861,Transform((cAliasSF3)->F2_CREDNFE,"@E 999,999,999.99"),oFont10)
					oPrint:Line(2350,nColIni,2350,nColFim)*/
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Outras Informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lBhorizonte
					oPrint:Say(2183,nCentro/2-len("Banco de Pagamento"),"OUTRAS INFORMAÇÕES:",oFont14n) // "OUTRAS INFORMAÇÕES"
					nLinha	:= 2223
					oPrint:Say(2250,250,Alltrim("Dados para Pagamento:"),oFont14n) // "OUTRAS INFORMAÇÕES"
					oPrint:Say(2300,250,Alltrim("BANCO:"),oFont12n) // "BANCO"
					oPrint:Say(2300,390,cBanco,oFont10n)
					// oPrint:Say(2300,450,("(")+Alltrim(cNomeB)+(")"),oFont10n)
					oPrint:Say(2350,250,Alltrim("AGENCIA:"),oFont12n) // "AGENCIA"
					oPrint:Say(2350,390,cAgenci,oFont10n)
					oPrint:Say(2400,250,Alltrim("CONTA:"),oFont12n) // "CONTA"
					oPrint:Say(2400,390,cConta,oFont10n)
					For nY := 1 to Len(aPrintObs)
						If nY > 11
							Exit
						Endif
						oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont10)
						nLinha	:= nLinha + 50
					Next
					oPrint:Line(1850,nColIni,1850,nColFim)
				EndIF
				If nCopias > 1 .And. nX < nCopias
					oPrint:EndPage() 
				Endif
			Next
			(cAliasSF3)->(dbSkip())
			If !((cAliasSF3)->(Eof()))
				oPrint:EndPage()
			Endif
		Enddo
	EndIf

	If !lQuery
		RetIndex("SF2")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±±
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR968                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr968Mont(cString,nLinhas,nTotStr)

	Local aAux		:= {}
	Local aPrint	:= {}

	Local cMemo		:= ""
	Local cAux		:= ""

	Local nX		:= 1
	Local nY		:= 1
	Local nPosi		:= 1

	cString := SubStr(cString,1,nTotStr)

	For nY := 1 to Min(MlCount(cString,86),nLinhas)

		cMemo := MemoLine(cString,86,nY)

		// Monta a string a ser impressa ate a quebra
		Do While .T.
			nPosi 	:= At("|",cMemo)
			If nPosi > 0
				Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
				cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
			Else
				If !Empty(cMemo)
					Aadd(aAux,{cMemo,.F.})
				Endif
				Exit
			Endif
		Enddo
	Next

	For nY := 1 to Len(aAux)
		cMemo := ""
		If aAux[nY][02]
			Aadd(aPrint,aAux[nY][01])
		Else
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
			Do While !aAux[nY][02]
				nY += 1
				If nY > Len(aAux)
					Exit
				Endif
				cMemo += Alltrim(aAux[nY][01]) + Space(01)
			Enddo
			For nX := 1 to Min(MlCount(cMemo,86),nLinhas)
				cAux := MemoLine(cMemo,86,nX)
				Aadd(aPrint,cAux)
			Next
		Endif
	Next

Return(aPrint)

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³M968Discri³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Monta um array com a string quebrada em linhas com o tamanho³±±
	±±³          ³da capacidade de impressao da linha utilizado RPS Sorocaba  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³MATR968                                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Static Function M968Discri(cString,nLinhas,nTotStr)

// 	Local aAux		:= {}
// 	Local aPrint	:= {}

// 	Local cMemo		:= ""
// 	Local cAux		:= ""

// 	Local nX		:= 1
// 	Local nY		:= 1
// 	Local nPosi		:= 1

// 	cString := SubStr(cString,1,nTotStr)

// 	For nY := 1 to Min(MlCount(cString,130),nLinhas)

// 		cMemo := MemoLine(cString,130,nY)

// 		// Monta a string a ser impressa ate a quebra
// 		Do While .T.
// 			nPosi	:= At("|",cMemo)
// 			If nPosi > 0
// 				Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
// 				cMemo	:= SubStr(cMemo,nPosi+1,Len(cMemo))
// 			Else
// 				If !Empty(cMemo)
// 					Aadd(aAux,{cMemo,.F.})
// 				Endif
// 				Exit
// 			Endif
// 		Enddo
// 	Next

// 	For nY := 1 to Len(aAux)
// 		cMemo := ""
// 		If aAux[nY][02]
// 			Aadd(aPrint,aAux[nY][01])
// 		Else
// 			cMemo += Alltrim(aAux[nY][01]) + Space(01)
// 			Do While !aAux[nY][02]
// 				nY += 1
// 				If nY > Len(aAux)
// 					Exit
// 				Endif
// 				cMemo += Alltrim(aAux[nY][01]) + Space(01)
// 			Enddo
// 			For nX := 1 to Min(MlCount(cMemo,130),nLinhas)
// 				cAux := MemoLine(cMemo,130,nX)
// 				Aadd(aPrint,cAux)
// 			Next
// 		Endif
// 	Next

// Return(aPrint)
Static Function M968Discri(cString, nLinhas, nTotStr)

	Local aAux     := {}
	Local aPrint   := {}

	Local cMemo    := ""
	Local cAux     := ""

	Local nX       := 1
	Local nY       := 1
	Local nPosi    := 1

	cString := SubStr(cString, 1, nTotStr)

	// Alteração: Mudando o tamanho de linha de 130 para 300
	For nY := 1 to Min(MlCount(cString, 300), nLinhas)

		cMemo := MemoLine(cString, 300, nY)

		// Monta a string a ser impressa até a quebra
		Do While .T.
			nPosi := At("|", cMemo)
			If nPosi > 0
				Aadd(aAux, {SubStr(cMemo, 1, nPosi - 1), .T.})
				cMemo := SubStr(cMemo, nPosi + 1, Len(cMemo))
			Else
				If !Empty(cMemo)
					Aadd(aAux, {cMemo, .F.})
				Endif
				Exit
			Endif
		Enddo
	Next

	For nY := 1 to Len(aAux)
		cMemo := ""
		If aAux[nY][02]
			Aadd(aPrint, aAux[nY][01])
		Else
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
			Do While !aAux[nY][02]
				nY += 1
				If nY > Len(aAux)
					Exit
				Endif
				cMemo += Alltrim(aAux[nY][01]) + Space(01)
			Enddo
			For nX := 1 to Min(MlCount(cMemo, 300), nLinhas)
				cAux := MemoLine(cMemo, 300, nX)
				Aadd(aPrint, cAux)
			Next
		Endif
	Next

Return (aPrint)


/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³PrintBox  ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do BOX atrave³±±
	±±³          ³s do deslocamento dos pixels pelo for next                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³MATR968                                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Static Function PrintBox(nPosY,nPosX,nAltura,nTamanho)

// 	Local nX := 0

// 	For nX := 1 To 5
// 		oPrint:Box(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
// 	Next nX

// Return

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³PrintLine ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do PrintLine ³±±
	±±³          ³Atraves do deslocamento dos pixels pelo for next            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³MATR968                                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Static Function PrintLine(nPosY,nPosX,nAltura,nTamanho)

// 	Local nX := 0

// 	For nX := 1 To 5
// 		oPrint:Line(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
// 	Next nX

// Return

/*/{Protheus.doc} xMATSIGANFSE
Classe com as informações do parâmetro MV_MATNFSE ou do SigaMat.

@author Vitor Ribeiro
@since 22/11/2017
/*/
	Class xMATSIGANFSE

		// Atributos da classe
		Data M0_CODIGO	As String	ReadOnly
		Data M0_CODFIL	As String	ReadOnly
		Data M0_TEL		As String	ReadOnly
		Data M0_INSCM	As String	ReadOnly
		Data M0_INSC	As String	ReadOnly
		Data M0_CGC		As String	ReadOnly
		Data M0_NOME	As String	ReadOnly
		Data M0_NOMECOM	As String	ReadOnly
		Data M0_CODMUN	As String	ReadOnly
		Data M0_TPINSC	As Integer	ReadOnly
		Data M0_ENDENT	As String	ReadOnly
		Data M0_CEPENT	As String	ReadOnly
		Data M0_BAIRENT	As String	ReadOnly
		Data M0_CIDENT	As String	ReadOnly
		Data M0_COMPENT	As String	ReadOnly
		Data M0_ESTENT	As String	ReadOnly
		Data M0_ENDCOB	As String	ReadOnly
		Data M0_CEPCOB	As String	ReadOnly
		Data M0_BAIRCOB	As String	ReadOnly
		Data M0_CIDCOB	As String	ReadOnly
		Data M0_COMPCOB	As String	ReadOnly
		Data M0_ESTCOB	As String	ReadOnly

		// Metodos da classe
		Method New()

	EndClass

/*/{Protheus.doc} New
Metodo de inicialização da classe. 

@author Vitor Ribeiro
@since 22/11/2017
/*/
Method New() Class xMATSIGANFSE

	Local aMvMatNfSe := Separa(AllTrim(GetMv("MV_MATNFSE",,"")),";")

	If !Empty(aMvMatNfSe)
		Self:M0_CODIGO	:= IIf(ValType("aMvMatNfSe[01]")<>"U",AllTrim(aMvMatNfSe[01]),"")
		Self:M0_CODFIL	:= IIf(ValType("aMvMatNfSe[02]")<>"U",AllTrim(aMvMatNfSe[02]),"")
		Self:M0_TEL		:= IIf(ValType("aMvMatNfSe[03]")<>"U",AllTrim(aMvMatNfSe[03]),"")
		Self:M0_INSCM	:= IIf(ValType("aMvMatNfSe[04]")<>"U",AllTrim(aMvMatNfSe[04]),"")
		Self:M0_INSC	:= IIf(ValType("aMvMatNfSe[05]")<>"U",AllTrim(aMvMatNfSe[05]),"")
		Self:M0_CGC		:= IIf(ValType("aMvMatNfSe[06]")<>"U",AllTrim(aMvMatNfSe[06]),"")
		Self:M0_NOME	:= IIf(ValType("aMvMatNfSe[07]")<>"U",AllTrim(aMvMatNfSe[07]),"")
		Self:M0_NOMECOM	:= IIf(ValType("aMvMatNfSe[08]")<>"U",AllTrim(aMvMatNfSe[08]),"")
		Self:M0_CODMUN	:= IIf(ValType("aMvMatNfSe[09]")<>"U",AllTrim(aMvMatNfSe[09]),"")
		Self:M0_TPINSC	:= IIf(ValType("aMvMatNfSe[10]")<>"U",Val(AllTrim(aMvMatNfSe[10])),0)
		Self:M0_ENDENT	:= IIf(ValType("aMvMatNfSe[11]")<>"U",AllTrim(aMvMatNfSe[11]),"")
		Self:M0_CEPENT	:= IIf(ValType("aMvMatNfSe[12]")<>"U",AllTrim(aMvMatNfSe[12]),"")
		Self:M0_BAIRENT	:= IIf(ValType("aMvMatNfSe[13]")<>"U",AllTrim(aMvMatNfSe[13]),"")
		Self:M0_CIDENT	:= IIf(ValType("aMvMatNfSe[14]")<>"U",AllTrim(aMvMatNfSe[14]),"")
		Self:M0_COMPENT	:= IIf(ValType("aMvMatNfSe[15]")<>"U",AllTrim(aMvMatNfSe[15]),"")
		Self:M0_ESTENT	:= IIf(ValType("aMvMatNfSe[16]")<>"U",AllTrim(aMvMatNfSe[16]),"")
		Self:M0_ENDCOB	:= IIf(ValType("aMvMatNfSe[11]")<>"U",AllTrim(aMvMatNfSe[11]),"")
		Self:M0_CEPCOB	:= IIf(ValType("aMvMatNfSe[12]")<>"U",AllTrim(aMvMatNfSe[12]),"")
		Self:M0_BAIRCOB	:= IIf(ValType("aMvMatNfSe[13]")<>"U",AllTrim(aMvMatNfSe[13]),"")
		Self:M0_CIDCOB	:= IIf(ValType("aMvMatNfSe[14]")<>"U",AllTrim(aMvMatNfSe[14]),"")
		Self:M0_COMPCOB	:= IIf(ValType("aMvMatNfSe[15]")<>"U",AllTrim(aMvMatNfSe[15]),"")
		Self:M0_ESTCOB	:= IIf(ValType("aMvMatNfSe[16]")<>"U",AllTrim(aMvMatNfSe[16]),"")
	Else
		Self:M0_CODIGO	:= SM0->M0_CODIGO
		Self:M0_CODFIL	:= SM0->M0_CODFIL
		Self:M0_TEL		:= SM0->M0_TEL
		Self:M0_INSCM	:= SM0->M0_INSCM
		Self:M0_INSC	:= SM0->M0_INSC
		Self:M0_CGC		:= SM0->M0_CGC
		Self:M0_NOME	:= SM0->M0_NOME
		Self:M0_NOMECOM	:= SM0->M0_NOMECOM
		Self:M0_CODMUN	:= SM0->M0_CODMUN
		Self:M0_TPINSC	:= SM0->M0_TPINSC
		Self:M0_ENDENT	:= SM0->M0_ENDENT
		Self:M0_CEPENT	:= SM0->M0_CEPENT
		Self:M0_BAIRENT	:= SM0->M0_BAIRENT
		Self:M0_CIDENT	:= SM0->M0_CIDENT
		Self:M0_COMPENT	:= SM0->M0_COMPENT
		Self:M0_ESTENT	:= SM0->M0_ESTENT
		Self:M0_ENDCOB	:= SM0->M0_ENDCOB
		Self:M0_CEPCOB	:= SM0->M0_CEPCOB
		Self:M0_BAIRCOB	:= SM0->M0_BAIRCOB
		Self:M0_CIDCOB	:= SM0->M0_CIDCOB
		Self:M0_COMPCOB	:= SM0->M0_COMPCOB
		Self:M0_ESTCOB	:= SM0->M0_ESTCOB
	EndIf

Return
