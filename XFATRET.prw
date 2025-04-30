#INCLUDE "LOCR003.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
//#INCLUDE "TBICONN.CH"
//#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCR003.PRW
ITUP BUSINESS - TOTVS RENTAL
DEMONSTRATIVO DE FATURAMENTO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
USER FUNCTION XFATRET()
LOCAL   _AAREAOLD := GETAREA()
LOCAL   _AAREASM0 := SM0->(GETAREA())
Local cFilBkp	  := cFilAnt
PRIVATE CPERG     := "LOCP013"
Private c_Local   := GetTempPath()

	IF PERGPARAM(CPERG)
		//Valida se o usuùrio pode acessar informaùùes da filial indicada
		If LOCR00101(MV_PAR04, NIL)
			DBSELECTAREA("SM0")
			SM0->(DBSETORDER(1))
			IF SM0->(DBSEEK(CEMPANT+MV_PAR04))
				cFilAnt := MV_PAR04
				PROCESSA({|| IMPREL() } , STR0001 , STR0002 , .T.)  //"IMPRIMINDO FATURA..."###"AGUARDE..."
				//devolve a filial
				cFilAnt := cFilBkp
			ENDIF
		EndIf
	ENDIF

	SM0->(RESTAREA( _AAREASM0 ))
	RESTAREA( _AAREAOLD )

RETURN

/*
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù?ùù
ùùùPROGRAMA  ù IMPREL    ù AUTOR ù IT UP CONSULTORIA  ù DATA ù 03/08/2016 ùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù?ùù
ùùùDESCRICAO ù DEFINICAO DO LAYOUT DO RELATORIO                           ùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù?ùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
*/
STATIC FUNCTION IMPREL()
Local _CTIPO		:= ""
Local _APRODUTOS  	:= {}
Local _DDTINI		:= STOD("")
Local _DDTFIM		:= STOD("")
Local _CCONTRATO  	:= ""
Local _CEMPRESA   	:= ""
Local _COBSFAT   	:= ""
Local CCNPJ			:= ""
Local CEND			:= ""
Local CBAIRRO		:= ""
Local CCIDADE		:= ""
Local CCEP			:= ""
Local CUF			:= ""
Local CTEL			:= ""
Local CFAX			:= ""
Local cAliasSc6		:= GetNextAlias()
Local cPeriodo  	:= ""
Local cChave 		:= ""
Local CLOGO			:= ""
Local CARQUIVO   	:= ""
Local _CQUERY      	:= ""
Local cAsPedido		:= ""
Local I           	:= 0
Local NLIN        	:= 10
Local _NTOTAL      	:= 0
Local _NVALOR      	:= 0
Local nTamLin   	:= 10
Local AAREASM0		:= {}
Local aAreaSC6  	:= SC6->(GetArea())
Local aAreaFPA  	:= FPA->(GetArea())
Local OREPORT
Local OBRUSH      	:= TBRUSH():NEW("",CLR_HGRAY)
Local LADJUSTTOLEGACY := .F.
Local LDISABLESETUP   := .t.//DENNIS CALABREZ - CHAMADO 30566 08/03/23 - ALTERADO PARA .T., POIS ESTAVA COM PROBLEMAS COM O TOTVS PRINTER PARA A GERAùùO DO ARQUIVO DE IMPRESSùO
Local lLocr003A 	:= ExistBlock("LOCR003A")
Local lMvLocBac		:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integraùùo com Mùdulo de Locaùùes SIGALOC
Local oStatement
Local aObra         := {}
Local lGera			:= .F.
Local cVar 			:= ""
Local xT
Local cDescLogo		:= ""
Local cGrpCompany	:= ""
Local cCodEmpGrp	:= ""
Local cUnitGrp		:= ""
Local cFilGrp		:= ""
Local cCmpUsr       := GetMv("MV_CMPUSR",,"")
Local _cFinalQuery 	:= ""
Local aBindParam 	:= {}
//--------- GABRIEL 
Local cCampos		:= ""
Local cAliasSF3		:= GetNextAlias()
Local cF2_DOC   := ""
Local cF2_SERIE     := ""
Local cF2_SERIEV    := "" //sÈrie de visualizaÁ„o
Local cF2_CLIENTE   := ""
Local cF2_LOJA      := ""
Local cF2_EMISSAO   := ""







PRIVATE NMINLEFT   	:= 10
PRIVATE NMAXWIDTH 	:= 584
PRIVATE NMAXHEIGHT	:= 2900
PRIVATE NMEIO		:= ((NMAXWIDTH+NMINLEFT)/2)

	CARQUIVO := STR0003 + ALLTRIM(MV_PAR01) + " - " + ALLTRIM(MV_PAR02) + "_" + DTOS(DATE()) + ".PDF" //"FATURA "

	OREPORT := FWMSPRINTER():NEW(CARQUIVO , IMP_PDF , LADJUSTTOLEGACY , c_local, LDISABLESETUP, , , , , , .f., .f.)
	OREPORT:SETPORTRAIT()
	OREPORT:SETPAPERSIZE(9)
	OREPORT:SETVIEWPDF( .T. )

	//"TIMES NEW ROMAN"
	OFONT1    := TFONTEX():NEW(OREPORT,"COURIER",10,10,.T.,.T.,.F.)// 1
	OFONT2    := TFONTEX():NEW(OREPORT,"COURIER",08,08,.F.,.F.,.F.)// 1
	OFONT3    := TFONTEX():NEW(OREPORT,"COURIER",12,12,.T.,.T.,.F.)// 1
	OFONT4    := TFONTEX():NEW(OREPORT,"COURIER",12,12,.F.,.F.,.F.)// 1

	// --> BUSCA AS INFORMACOES DAS FILIAIS.
	AAREASM0 := SM0->(GETAREA())
	DBSELECTAREA("SM0")
	SM0->(DBSETORDER(1))
	IF SM0->(DBSEEK(CEMPANT+MV_PAR04))
		CEND     := ALLTRIM(SM0->M0_ENDCOB)
		CBAIRRO  := ALLTRIM(SM0->M0_BAIRCOB)
		CCIDADE  := ALLTRIM(SM0->M0_CIDCOB)
		CCEP 	 := TRANSFORM(ALLTRIM(SM0->M0_CEPENT), "@R 99999-999")	
		// CCEP     := ALLTRIM(SM0->M0_CEPENT)  // ALTERADO DE SUBSTR(SM0->M0_CEPENT,1,5) + '-' + SUBSTR(SM0->M0_CEPCOB,6,3) GABRIEL 14042025
		CUF	     := ALLTRIM(SM0->M0_ESTCOB)
		CTEL 	 := TRANSFORM(ALLTRIM(SM0->M0_TEL), "@R (99) 9999-9999")  
		CRAZAO 	 := ALLTRIM(SM0->M0_FULNAME) // GABRIEL 09042025
		// IF EMPTY(ALLTRIM(SM0->M0_FAX))
		// 	CFAX := ""
		// ELSE
		// 	CFAX := "(" + SUBSTR(SM0->M0_FAX,4,2) + ") " + SUBSTR(SM0->M0_FAX,7,4) + "-" + SUBSTR(SM0->M0_FAX,11,4)
		// ENDIF
		CCNPJ    := SUBSTR(SM0->M0_CGC,1,2) + "." + SUBSTR(SM0->M0_CGC,3,3) + "." + SUBSTR(SM0->M0_CGC,6,3) + "/" +;
					SUBSTR(SM0->M0_CGC,9,4) + "-" + SUBSTR(SM0->M0_CGC,13,2)
	ENDIF
	SM0->(RESTAREA(AAREASM0))
// LOGO GABRIEL 
// Pega informaÁıes da empresa logada
cCodEmpGrp := AllTrim(FWCodEmp())     // CÛdigo da empresa (ex: 03)
cFilGrp    := AllTrim(FWFilial())     // CÛdigo da filial (ex: 01)

// Caminho base da imagem
cCaminhoLogo := GetSrvProfString("StartPath", "")

// Monta nome do logo com "01" fixo no meio
cDescLogo := "01" + cCodEmpGrp + cFilGrp

// Tenta carregar o logo principal
cLogo := cCaminhoLogo + "lgmid" + cDescLogo + ".png"

// Fallback para logo padr„o
If !File(cLogo)
	cLogo := cCaminhoLogo + "lgmid.png"
EndIf

// Fallback final para bitmap padr„o
If !File(cLogo)
	cLogo := cCaminhoLogo + "lgrl99.bmp"
EndIf

	// // LOGO
	// //AJUSTE PARA SAIR O LOGO POR FILIAL LOGADA NO SISTEMA - DENNIS CARD 1334 - INICIO
	// cGrpCompany	:= AllTrim(FWGrpCompany())
	// cCodEmpGrp	:= AllTrim(FWCodEmp())
	// cUnitGrp	:= AllTrim(FWUnitBusiness())
	// cFilGrp		:= AllTrim(FWFilial())
	// If !Empty(cUnitGrp)
	// 	cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	// Else
	// 	cDescLogo	:= cEmpAnt + cFilAnt
	// EndIf
	// //CLOGO := GETSRVPROFSTRING("STARTPATH","") + "LOGO.JPG"
	// // CLOGO := GETSRVPROFSTRING("STARTPATH","") + "lgmid" + cDescLogo + ".png"
	// cLogo := GetSrvProfString('StartPath','')+'lgmid'+CEMPANT+'.png'
	// 			if !File(cLogo)
	// 				cLogo := GetSrvProfString('StartPath','')+'lgmid.png'
	// 			endif
	// 			if !File(cLogo)
	// 				cLogo := GetSrvProfString('StartPath','')+'lgrl99.bmp'
	// 			endif
	//AJUSTE PARA SAIR O LOGO POR FILIAL LOGADA NO SISTEMA - DENNIS CARD 1334 - FIM

	IF SELECT("TRBFAT") > 0
		TRBFAT->(DBCLOSEAREA())
	ENDIF

	//Montando a consulta dos pedidos
//	oStatement := FWPreparedStatement():New()
	oStatement := FwExecStatement():New()

	// --> (A) CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO.   (*INICIO*)
/*	_CQUERY := "SELECT "
	_CQUERY += "(SELECT SUM(E1_VALOR) FROM "+RETSQLNAME("SE1")+" SE1TMP1 (NOLOCK) WHERE SE1TMP1.E1_FILIAL = '"+XFILIAL("SE1")+"' AND XTEMP1.NUMFAT = SE1TMP1.E1_NUM AND XTEMP1.SERIE=SE1TMP1.E1_PREFIXO AND SE1TMP1.E1_TIPO IN ('IR-','CS-','PI-','CF-','IS-','IN-') AND SE1TMP1.D_E_L_E_T_ = '') AS 'VALRET2' "
	_CQUERY += ", XTEMP1.* "
	_CQUERY += "FROM "
	_CQUERY += "( "
*/
//--------------------------------------------------------------------------------------------------------------------------------------

	_CQUERY := " SELECT F2_FILIAL FILIAL, F2_SERIE SERIE, F2_DOC NUMFAT, F2_EMISSAO EMISSAO, MAX(COALESCE(F4_FINALID,?)) F4_FINALID, MAX(C6_NUM) PEDIDO, "  //'LOCAùùO DE BENS MùVEIS'
	_CQUERY += " 	   RTRIM(LTRIM(A1_NOME)) RAZSOC, A1_END A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_CGC, "
	_CQUERY += " 	   CASE WHEN A1_INSCR = ''"
	_CQUERY += " 			THEN 'ISENTO'"
	_CQUERY += " 			ELSE A1_INSCR   END A1_INSCR , SE1NF.E1_VENCTO VENCTO,"
	// _CQUERY += " 	   F2_VALBRUT, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET,"
	// _CQUERY += " 	   F2_VALBRUT - COALESCE(F2_DESCONT,0) - SUM(COALESCE(SE1IMP.E1_VALOR,0)) - SE1NF.E1_IRRF TOTAL,"  // ALTERADO 22042025 GABRIEL 
	// _CQUERY += " 	   F2_VALBRUT, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET,"
	_CQUERY += " 	   F2_VALBRUT, F2_VALIRRF, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET," //adicionado 29042025 gabriel
	_CQUERY += " 	   SUM(COALESCE(D2_VALIRRF,0)) D2_VALIRRF,"
	_CQUERY += " 	   SUM(COALESCE(D2_BASEIRR,0)) D2_BASEIRR,"
	_CQUERY += " 	   MAX(COALESCE(D2_ALQIRRF,0)) D2_ALQIRRF,"
	_CQUERY += " 	   F2_VALBRUT - COALESCE(F2_DESCONT,0) - SUM(COALESCE(SE1IMP.E1_VALOR,0)) - SE1NF.E1_IRRF TOTAL,"
	_CQUERY += " 	   CASE WHEN A1_ENDCOB = ''"
	_CQUERY += " 			THEN A1_END"
	_CQUERY += " 			ELSE A1_ENDCOB  END A1_ENDCOB  , "
	_CQUERY += " 	   CASE WHEN A1_BAIRROC = ''"
	_CQUERY += " 			THEN A1_BAIRRO"
	_CQUERY += " 			ELSE A1_BAIRROC END A1_BAIRROC , "
	_CQUERY += " 	   CASE WHEN A1_MUNC = ''"
	_CQUERY += " 			THEN A1_MUN"
	_CQUERY += " 			ELSE A1_MUNC    END A1_MUNC    , "
	_CQUERY += " 	   CASE WHEN A1_ESTC = ''"
	_CQUERY += " 			THEN A1_EST"
	_CQUERY += " 			ELSE A1_ESTC    END A1_ESTC    , "
	_CQUERY += " 	   CASE WHEN A1_CEPC = ''"
	_CQUERY += " 			THEN A1_CEP ELSE A1_CEPC END A1_CEPC,"
	_CQUERY += " 	   CASE WHEN A1_ENDENT = ''"
	_CQUERY += " 			THEN A1_END"
	_CQUERY += " 			ELSE A1_ENDENT  END A1_ENDENT  , "
	_CQUERY += " 	   CASE WHEN A1_BAIRROE = ''"
	_CQUERY += " 			THEN A1_BAIRRO"
	_CQUERY += " 			ELSE A1_BAIRROE END A1_BAIRROE , "
	_CQUERY += " 	   CASE WHEN A1_MUNE = ''"
	_CQUERY += " 			THEN A1_MUN"
	_CQUERY += " 			ELSE A1_MUNE    END A1_MUNE    , "
	_CQUERY += " 	   CASE WHEN A1_ESTE = ''"
	_CQUERY += " 			THEN A1_EST"
	_CQUERY += " 			ELSE A1_ESTE    END A1_ESTE    , "
	_CQUERY += " 	   CASE WHEN A1_CEPE = ''"
	_CQUERY += " 			THEN A1_CEP ELSE A1_CEPE END A1_CEPE, "
	_CQUERY += " 		A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF AS IRFAT, FPZ_PROJET, FP0_XLOCAL, FP0_XBANCO, FP0_XAGENC, FP0_XCONTA"
	_CQUERY += "		FROM " + RETSQLNAME("SF2") + " SF2 "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SA1") + " SA1    ON  SF2.F2_CLIENTE = A1_COD       AND  SF2.F2_LOJA = SA1.A1_LOJA "
	_CQUERY += "                                                    AND SA1.D_E_L_E_T_ = '' "
	
	If !empty(alltrim(xFilial("SA1")))
		_cQuery += " AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
	EndIf
	
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SD2") + " SD2    ON  SD2.D2_FILIAL  = F2_FILIAL    AND  SD2.D2_DOC  = F2_DOC "
	_CQUERY += "                                                    AND SD2.D2_SERIE   = F2_SERIE "
	_CQUERY += "                                                    AND SD2.D_E_L_E_T_ = '' "
	_CQUERY += " 	    INNER JOIN " + RETSQLNAME("SC6") + " SC6    ON  SC6.C6_FILIAL  = F2_FILIAL    AND  SC6.C6_NOTA = F2_DOC "
	_CQUERY += "                                                    AND SC6.C6_SERIE   = F2_SERIE     AND  SC6.C6_ITEM = D2_ITEM "
	_CQUERY += "                                                    AND SC6.D_E_L_E_T_ = '' "
	_CQUERY += " 	    INNER JOIN " + RETSQLNAME("FPZ") + " FPZ    ON  FPZ.FPZ_FILIAL = SC6.C6_FILIAL "
	_CQUERY += "                                                    AND FPZ.FPZ_PEDVEN = SC6.C6_NUM    "
	_CQUERY += "                                                    AND FPZ.FPZ_ITEM   = SC6.C6_ITEM   "
	_CQUERY += "                                                    AND FPZ.D_E_L_E_T_ = '' "
	_CQUERY += "        LEFT  JOIN " + RETSQLNAME("SF4") + " SF4    ON  SF4.F4_CODIGO  = D2_TES "
	_CQUERY += "                                                    AND SF4.D_E_L_E_T_ = '' "
	_CQUERY += "        LEFT  JOIN " + RETSQLNAME("SE1") + " SE1NF  ON  F2_FILIAL = SE1NF.E1_FILIAL   AND  F2_DOC = SE1NF.E1_NUM "
	_CQUERY += "                                                    AND F2_SERIE  = SE1NF.E1_PREFIXO "
	_CQUERY += "                                                    AND SE1NF.E1_TIPO  = 'NF' "
	_CQUERY += "                                                    AND SE1NF.D_E_L_E_T_ = '' "
	_CQUERY += " 	    LEFT  JOIN " + RETSQLNAME("SE1") + " SE1IMP ON  F2_FILIAL = SE1IMP.E1_FILIAL  AND  F2_DOC = SE1IMP.E1_NUM "
	_CQUERY += "                                                    AND F2_SERIE  = SE1IMP.E1_PREFIXO "
	_CQUERY += "                                                    AND SE1IMP.E1_TIPO IN ('IR-','CS-','PI-','CF-','IS-','IN-')"
	_CQUERY += "                                                    AND SE1IMP.D_E_L_E_T_ = '' "
	_CQUERY += " 	    LEFT  JOIN " + RETSQLNAME("SA6") + " SA6    ON  SA6.A6_FILIAL  = SE1NF.E1_FILIAL "
	_CQUERY += "                                                    AND SA6.A6_COD     = SE1NF.E1_PORTADO "
	_CQUERY += "                                                    AND SA6.A6_AGENCIA = SE1NF.E1_AGEDEP "
	_CQUERY += "                                                    AND SA6.A6_NUMCON  = SE1NF.E1_CONTA "
	_CQUERY += "                                                    AND SA6.D_E_L_E_T_ = '' "
	_CQUERY += " 	    LEFT JOIN " + RETSQLNAME("FP0") + " FP0    ON  FP0.FP0_FILIAL = SC6.C6_FILIAL "
	_CQUERY += "                                                    AND FP0.FP0_PROJET = FPZ.FPZ_PROJET "
	_CQUERY += "                                                    AND FP0.D_E_L_E_T_ = '' "
	_CQUERY += "   WHERE  F2_FILIAL = '" + XFILIAL("SF2") + "'"
	_CQUERY += "   AND  F2_DOC BETWEEN ? AND ? "  // inject 2 e 3
	_CQUERY += "   AND  F2_SERIE = ? " // inject 4
	_CQUERY += "   AND  SF2.D_E_L_E_T_ = ''"
	_CQUERY += "   AND  SF2.F2_TIPO NOT IN ('D','B') "
	_CQUERY += "   GROUP BY F2_FILIAL, F2_SERIE, F2_DOC , F2_EMISSAO ,  A1_NOME, A1_END , A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_CGC, A1_INSCR , SE1NF.E1_VENCTO,"
	_CQUERY += " 	     	F2_VALBRUT, F2_VALIRRF, F2_DESCONT, A1_ENDCOB, A1_BAIRROC, A1_MUNC, A1_ESTC, A1_CEPC,D2_VALIRRF,D2_BASEIRR,D2_ALQIRRF," //alterado gabriel 29042025
	_CQUERY += " 		    A1_ENDENT, A1_BAIRROE, A1_MUNE, A1_ESTE, A1_CEPE, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF, FPZ_PROJET, FP0_XLOCAL, FP0_XBANCO, FP0_XCONTA , FP0_XAGENC"

//--------------------------------------------------------------------------------------------------------------------------------------
	_CQUERY += " UNION ALL "
	_CQUERY += " SELECT F2_FILIAL FILIAL, F2_SERIE SERIE, F2_DOC NUMFAT, F2_EMISSAO EMISSAO, MAX(COALESCE(F4_FINALID,?)) F4_FINALID, MAX(C6_NUM) PEDIDO,"  //'LOCAùùO DE BENS MùVEIS' // inject 5
	_CQUERY += " 	   RTRIM(LTRIM(A2_NOME)) RAZSOC, A2_END A1_END, A2_BAIRRO A1_BAIRRO, A2_MUN A1_MUN, A2_EST A1_EST, A2_CEP A1_CEP, A2_CGC A1_CGC, "
	_CQUERY += " 	   CASE WHEN A2_INSCR = ''"
	_CQUERY += " 			THEN 'ISENTO'"
	_CQUERY += " 			ELSE A2_INSCR END A2_INSCR, SE1NF.E1_VENCTO VENCTO,"
	// _CQUERY += " 	   F2_VALBRUT, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET,"
	// _CQUERY += " 	   F2_VALBRUT - COALESCE(F2_DESCONT,0) - SUM(COALESCE(SE1IMP.E1_VALOR,0)) - SE1NF.E1_IRRF TOTAL," // alterado 22042025 GABRIEL 
	_CQUERY += " 	   F2_VALBRUT, F2_VALIRRF, F2_DESCONT, SUM(COALESCE(SE1IMP.E1_VALOR,0)) VALRET,"
	_CQUERY += " 	   SUM(COALESCE(D2_VALIRRF,0)) D2_VALIRRF,"
	_CQUERY += " 	   SUM(COALESCE(D2_BASEIRR,0)) D2_BASEIRR,"
	_CQUERY += " 	   MAX(COALESCE(D2_ALQIRRF,0)) D2_ALQIRRF,"
	_CQUERY += " 	   F2_VALBRUT - COALESCE(F2_DESCONT,0) - SUM(COALESCE(SE1IMP.E1_VALOR,0)) - SE1NF.E1_IRRF TOTAL,"
	_CQUERY += " 	   CASE WHEN A2_END = ''"
	_CQUERY += " 			THEN A2_END"
	_CQUERY += " 			ELSE A2_END END A1_ENDCOB,"
	_CQUERY += " 	   CASE WHEN A2_BAIRRO = ''"
	_CQUERY += " 			THEN A2_BAIRRO"
	_CQUERY += " 			ELSE A2_BAIRRO END A1_BAIRROC,"
	_CQUERY += " 	   CASE WHEN A2_MUN = ''"
	_CQUERY += " 			THEN A2_MUN"
	_CQUERY += " 			ELSE A2_MUN END A1_MUNC,"
	_CQUERY += " 	   CASE WHEN A2_EST = ''"
	_CQUERY += " 			THEN A2_EST"
	_CQUERY += " 			ELSE A2_EST END A1_ESTC,"
	_CQUERY += " 	   CASE WHEN A2_CEP = ''"
	_CQUERY += " 			THEN A2_CEP ELSE A2_CEP END A1_CEPC,"
	_CQUERY += " 	   CASE WHEN A2_END = ''"
	_CQUERY += " 			THEN A2_END"
	_CQUERY += " 			ELSE A2_END END A1_ENDENT,"
	_CQUERY += " 	   CASE WHEN A2_BAIRRO = ''"
	_CQUERY += " 			THEN A2_BAIRRO"
	_CQUERY += " 			ELSE A2_BAIRRO END A1_BAIRROE,"
	_CQUERY += " 	   CASE WHEN A2_MUN = ''"
	_CQUERY += " 			THEN A2_MUN"
	_CQUERY += " 			ELSE A2_MUN END A1_MUNE,"
	_CQUERY += " 	   CASE WHEN A2_EST = ''"
	_CQUERY += " 			THEN A2_EST"
	_CQUERY += " 			ELSE A2_EST END A1_ESTE,"
	_CQUERY += " 	   CASE WHEN A2_CEP = ''"
	_CQUERY += " 			THEN A2_CEP ELSE A2_CEP END A1_CEPE, "
	_CQUERY += " 		A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF AS IRFAT, FPZ_PROJET,FP0_XLOCAL, FP0_XBANCO, FP0_XAGENC, FP0_XCONTA"
	_CQUERY += "   FROM " + RETSQLNAME("SF2") + " SF2 INNER JOIN " + RETSQLNAME("SA2") + " SA2"
	_CQUERY += "     ON F2_CLIENTE = A2_COD"
	_CQUERY += "    AND F2_LOJA    = A2_LOJA"
	_CQUERY += "    AND SA2.D_E_L_E_T_ = ''"
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SD2") + " SD2"
	_CQUERY += "     ON D2_FILIAL = F2_FILIAL"
	_CQUERY += "    AND D2_DOC    = F2_DOC"
	_CQUERY += "    AND D2_SERIE  = F2_SERIE"
	_CQUERY += "    AND SD2.D_E_L_E_T_ = ''"
	_CQUERY += " 	   INNER JOIN " + RETSQLNAME("SC6") + " SC6"
	_CQUERY += " 	ON C6_FILIAL = F2_FILIAL"
	_CQUERY += "    AND C6_NOTA   = F2_DOC"
	_CQUERY += "    AND C6_SERIE  = F2_SERIE"
	_CQUERY += "    AND C6_ITEM   = D2_ITEM"
	_CQUERY += "    AND SC6.D_E_L_E_T_ = ''"
	_CQUERY += " 	    INNER JOIN " + RETSQLNAME("FPZ") + " FPZ    ON  FPZ.FPZ_FILIAL = SC6.C6_FILIAL "
	_CQUERY += "                                                    AND FPZ.FPZ_PEDVEN = SC6.C6_NUM    "
	_CQUERY += "                                                    AND FPZ.FPZ_ITEM   = SC6.C6_ITEM   "
	_CQUERY += "                                                    AND FPZ.D_E_L_E_T_ = '' "
	_CQUERY += "        LEFT JOIN " + RETSQLNAME("SF4") + " SF4"
	_CQUERY += "     ON F4_CODIGO = D2_TES"
	_CQUERY += "    AND SF4.D_E_L_E_T_ = ''"
	_CQUERY += "        LEFT JOIN " + RETSQLNAME("SE1") + " SE1NF"
	_CQUERY += "     ON F2_FILIAL = SE1NF.E1_FILIAL"
	_CQUERY += "    AND F2_DOC    = SE1NF.E1_NUM"
	_CQUERY += "    AND F2_SERIE  = SE1NF.E1_PREFIXO"
	_CQUERY += "    AND SE1NF.E1_TIPO  = 'NF'"
	_CQUERY += "    AND SE1NF.D_E_L_E_T_ = ''"
	_CQUERY += " 	   LEFT JOIN " + RETSQLNAME("SE1") + " SE1IMP"
	_CQUERY += "     ON F2_FILIAL = SE1IMP.E1_FILIAL"
	_CQUERY += "    AND F2_DOC    = SE1IMP.E1_NUM"
	_CQUERY += "    AND F2_SERIE  = SE1IMP.E1_PREFIXO"
	_CQUERY += "    AND SE1IMP.E1_TIPO   IN ('IR-','CS-','PI-','CF-','IS-','IN-')"
	_CQUERY += "    AND SE1IMP.D_E_L_E_T_ = ''"
	_CQUERY += " 	   LEFT JOIN " + RETSQLNAME("SA6") + " SA6"
	_CQUERY += "     ON A6_FILIAL  = SE1NF.E1_FILIAL"
	_CQUERY += "    AND A6_COD     = SE1NF.E1_PORTADO"
	_CQUERY += "    AND A6_AGENCIA = SE1NF.E1_AGEDEP"
	_CQUERY += "    AND A6_NUMCON  = SE1NF.E1_CONTA"
	_CQUERY += "    AND SA6.D_E_L_E_T_ = ''"
	_CQUERY += " 	    LEFT JOIN " + RETSQLNAME("FP0") + " FP0    ON  FP0.FP0_FILIAL = SC6.C6_FILIAL "
	_CQUERY += "                                                    AND FP0.FP0_PROJET = FPZ.FPZ_PROJET "
	_CQUERY += "                                                    AND FP0.D_E_L_E_T_ = '' "
	_CQUERY += "  WHERE F2_FILIAL = '" + XFILIAL("SF2") + "'"
	_CQUERY += "    AND F2_DOC BETWEEN ? AND ? " // inject 6 e 7
	_CQUERY += "    AND F2_SERIE = ? " // inject 8
	_CQUERY += "    AND SF2.D_E_L_E_T_ = ''"
	_CQUERY += "    AND SF2.F2_TIPO IN ('D','B') "
	_CQUERY += "  GROUP BY F2_FILIAL , F2_SERIE, F2_DOC, F2_EMISSAO, A2_NOME, A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP, A2_CGC, A2_INSCR, "
	// _CQUERY += " 		  SE1NF.E1_VENCTO, F2_VALBRUT, F2_DESCONT , A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP,D2_VALIRRF,D2_BASEIRR,D2_ALQIRRF," 
	_CQUERY += " 		  SE1NF.E1_VENCTO, F2_VALBRUT, F2_VALIRRF, F2_DESCONT , A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP,D2_VALIRRF,D2_BASEIRR,D2_ALQIRRF,"
	_CQUERY += " 		  A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_CEP, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE1NF.E1_IRRF, FPZ_PROJET, F4_FINALID, FP0_XLOCAL, FP0_XBANCO , FP0_XAGENC, FP0_XCONTA"
*/
//--------------------------------------------------------------------------------------------------------------------------------------

//	_CQUERY += ") AS XTEMP1 "
	_CQUERY += "  ORDER BY EMISSAO, NUMFAT"

	//Seta as variaveis da query
	oStatement:SetQuery(_CQUERY)
	oStatement:SetString(1, STR0004     ) //'LOCAùùO DE BENS MùVEIS'
	oStatement:SetString(2, MV_PAR01    )
	oStatement:SetString(3, MV_PAR02    )
	oStatement:SetString(4, MV_PAR03    )
	oStatement:SetString(5, STR0004     ) //'LOCAùùO DE BENS MùVEIS'
	oStatement:SetString(6, MV_PAR01    )
	oStatement:SetString(7, MV_PAR02    )
	oStatement:SetString(8, MV_PAR03    )
*/
	_cFinalQuery := ""
	_cFinalQuery := ChangeQuery(oStatement:GetFixQuery())

	MpSysOpenQuery(_cFinalQuery,"TRBFAT")

//--------------------------------------------------------------------------------------------------------------------------------------

	DbSelectArea("TRBFAT")
	DbGotop()
	WHILE TRBFAT->(!EOF())
		aBindParam := {}
		_CQUERY := "SELECT  SUM(E1_VALOR) AS VALRET2 "
		_CQUERY += "FROM "+RETSQLNAME("SE1")+" SE1TMP1 (NOLOCK) "
		_CQUERY += "WHERE SE1TMP1.E1_FILIAL  = '"+XFILIAL("SE1")+"' "
		_CQUERY += "  AND SE1TMP1.E1_NUM     = ? "
		Aadd(aBindParam , TRBFAT->NUMFAT )
		_CQUERY += "  AND SE1TMP1.E1_PREFIXO = ? "
		Aadd(aBindParam , TRBFAT->SERIE )
		_CQUERY += "  AND SE1TMP1.E1_TIPO IN ('IR-','CS-','PI-','CF-','IS-','IN-')
		_CQUERY += "  AND SE1TMP1.D_E_L_E_T_ = ''"

		_cQuery := ChangeQuery (_CQUERY)
		MPSysOpenQuery(_CQUERY,"TRBDIV",,,aBindParam)

		IF TRBDIV->(!EOF())
			_NVALOR := TRBDIV->VALRET2
		ENDIF

		TRBDIV->(DBCLOSEAREA())

//--------------------------------------------------------------------------------------------------------------------------------------
		INCPROC()

		OREPORT:STARTPAGE()

		_COBSFAT   := "" // removido da 94 ALLTRIM(POSICIONE("SC5",1,XFILIAL("SC5")+TRBFAT->PEDIDO,"C5_XOBSFAT"))
		_CTIPO	   := ""
		_CCONTRATO := ""
		_CEMPRESA  := ""
		_APRODUTOS := {}
		_DDTINI	   := STOD("")
		_DDTFIM	   := STOD("")

		NLIN := 25

		// --> MONTA AS CAIXAS
		// --> CABEùALHO
		// OREPORT:BOX( NLIN, NMINLEFT, NLIN+50, NMAXWIDTH,"-1" )
		NLIN +=  50 			// NLIN TOTAL:  75

		// --> INFORMAùùES DO PRESTADOR DO SERVIùO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMEIO     )
		OREPORT:BOX( NLIN, NMEIO   , NLIN+90, NMAXWIDTH )
		NLIN += 105 			// NLIN TOTAL: 180

		// --> INFORMAùùES DO TOMADOR DO SERVIùO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMAXWIDTH )
		NLIN += 102 			// NLIN TOTAL: 282

		// --> SERVIùOS
		//OREPORT:BOX( NLIN, NMINLEFT, NLIN+410, NMAXWIDTH )
		NLIN += 420 			// NLIN TOTAL: 702

		// FRANK 27/10/20
		//OREPORT:BOX( NLIN, NMINLEFT, NLIN+85, NMINLEFT+85 )
		//OREPORT:BOX( NLIN, NMINLEFT+85, NLIN+85, NMAXWIDTH )
		// --> INICIA A IMPRESSùO DAS INFORMAùùES
		NLIN :=  30
		OREPORT:SayBitmap( NLIN-30, NMINLEFT, cLogo,60,60)
		// OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN +=  15 			// NLIN TOTAL: 45

		// OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN +=  15 			// NLIN TOTAL: 60

		// OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN :=  38

		// OREPORT:SAYBITMAP(NLIN-8,NMINLEFT+3,CLOGO,0098,0040 )

		//OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)-20, STR0005, OFONT3:OFONT ) //"FATURA"
		OREPORT:SAY( NLIN, NMEIO-(len(STR0005)/2), STR0005, OFONT3:OFONT ) //"FATURA"
		

		_CEMPRESA := ALLTRIM(SM0->M0_NOMECOM)
		XT  := MLCOUNT(_CEMPRESA,30)
		FOR I:=1 TO XT
			// OREPORT:SAY( NLIN, NMINLEFT+103, MEMOLINE(_CEMPRESA ,30, I ), OFONT4:OFONT )
			NLIN +=  15
		NEXT I

		NLIN :=  53 			// NLIN TOTAL: 53

		//OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)-22, TRBFAT->NUMFAT, OFONT3:OFONT )
		OREPORT:SAY( NLIN, NMEIO- (len(alltrim(TRBFAT->NUMFAT))/2), alltrim(TRBFAT->NUMFAT), OFONT3:OFONT )
		NLIN +=  40 			// NLIN TOTAL: 93

		// OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREùO: "
		// OREPORT:SAY( NLIN, NMINLEFT+60, substr(CEND,1,51 ), OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMINLEFT+10, "RAZ√O SOCIAL:", OFONT1:OFONT ) //"FONE: "
		OREPORT:SAY( NLIN, NMINLEFT+75, CRAZAO, OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMEIO+10, "Natureza OP:", OFONT1:OFONT ) //"NATUREZA OPERAùùO: "
		OREPORT:SAY( NLIN, NMEIO+80, "LOCA«√O DE VEICULOS", OFONT2:OFONT ) // GABRIEL ( MUDADO DE F4_FINALID)
		NLIN +=  15 			// NLIN TOTAL: 108

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
	//	OREPORT:SAY( NLIN, NMINLEFT+50, ALLTRIM(SM0->M0_BAIRCOB), OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMINLEFT+50, substr(CBAIRRO,1,20), OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMEIO+10, "PROJETO: ", OFONT1:OFONT ) //STR0032 //"PROJETO: "
		OREPORT:SAY( NLIN, NMEIO+80, ALLTRIM(TRBFAT->FPZ_PROJET), OFONT2:OFONT )
		
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0009, OFONT1:OFONT ) //"CIDADE: "
	//	OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, ALLTRIM(SM0->M0_CIDCOB), OFONT2:OFONT )
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+35, substr(CCIDADE,1,24), OFONT2:OFONT )

		NLIN +=  15 			// NLIN TOTAL: 123

	//	_CVAR := SUBSTR(SM0->M0_CEPCOB,1,5) + '-' + SUBSTR(SM0->M0_CEPCOB,6,3)
		OREPORT:SAY( NLIN, NMINLEFT+10, STR0010, OFONT1:OFONT ) //"CEP: "
	//	OREPORT:SAY( NLIN, NMINLEFT+50, _CVAR, OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMINLEFT+50, CCEP, OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMEIO+10, "CONTRATO", OFONT1:OFONT ) //STR0032 //"CONTRATO: "
		OREPORT:SAY( NLIN, NMEIO+80, ALLTRIM(TRBFAT->FP0_XLOCAL), OFONT2:OFONT ) // GABRIEL   -- CERTO
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0011, OFONT1:OFONT ) //"UF: "
	//	OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, ALLTRIM(SM0->M0_ESTCOB), OFONT2:OFONT )
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CUF, OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 138

	//	_CVAR := "(" + SUBSTR(SM0->M0_TEL,4,2) + ") " + SUBSTR(SM0->M0_TEL,7,4) + "-" + SUBSTR(SM0->M0_TEL,11,4)
		// OREPORT:SAY( NLIN, NMINLEFT+10, "RAZ√O:", OFONT1:OFONT ) //"FONE: "
		// OREPORT:SAY( NLIN, NMINLEFT+50, CRAZAO, OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREùO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, substr(CEND,1,51 ), OFONT2:OFONT )

		/*
		IF EMPTY(ALLTRIM(SM0->M0_FAX))
			_CVAR := ""
		ELSE
			_CVAR := "(" + SUBSTR(SM0->M0_FAX,4,2) + ") " + SUBSTR(SM0->M0_FAX,7,4) + "-" + SUBSTR(SM0->M0_FAX,11,4)
		ENDIF
		*/
		// OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0012, OFONT1:OFONT ) //"FAX: "
	//	OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, _CVAR, OFONT2:OFONT ) gabriel
		// OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CTEL, OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0014, OFONT1:OFONT ) //"DATA EMISSùO: " //emiss„o
		OREPORT:SAY( NLIN, NMEIO+80, DTOC(STOD(TRBFAT->EMISSAO)), OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMEIO+160, STR0022, OFONT1:OFONT ) //"VENCTO: "  // gabriel
		OREPORT:SAY( NLIN, NMEIO+200, DTOC(STOD(TRBFAT->VENCTO)), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 153

		/*
		_CVAR := SUBSTR(SM0->M0_CGC,1,2) + "." + SUBSTR(SM0->M0_CGC,3,3) + "." + SUBSTR(SM0->M0_CGC,6,3) + "/" +;
				SUBSTR(SM0->M0_CGC,9,4) + "-" + SUBSTR(SM0->M0_CGC,13,2)
		*/
		OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
	//	OREPORT:SAY( NLIN, NMINLEFT+50, _CVAR, OFONT2:OFONT )
		OREPORT:SAY( NLIN, NMINLEFT+50, CCNPJ, OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0012, OFONT1:OFONT ) //"CCM: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CTEL, OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0017, OFONT1:OFONT ) //"NùMERO PEDIDO: "
		OREPORT:SAY( NLIN, NMEIO+80, TRBFAT->PEDIDO, OFONT2:OFONT )
		NLIN +=  25 			// NLIN TOTAL: 178

		// OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH) //GABRIEL
		OREPORT:SAY( NLIN-1, NMEIO-30, STR0018, OFONT3:OFONT ) //"DESTINATùRIO"
		NLIN +=  18 			// NLIN TOTAL: 196

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0019, OFONT1:OFONT ) //"RAZAO SOCIAL: "
		OREPORT:SAY( NLIN, NMINLEFT+75, ALLTRIM(TRBFAT->RAZSOC), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 211

		// OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREùO: "
		// OREPORT:SAY( NLIN, NMINLEFT+60, ALLTRIM(TRBFAT->A1_END), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
		OREPORT:SAY( NLIN, NMINLEFT+50, substr(TRBFAT->A1_BAIRRO,1,35), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO-80, STR0020, OFONT1:OFONT ) //"MUNICùPIO: "
		OREPORT:SAY( NLIN, NMEIO-26, substr(TRBFAT->A1_MUN,1,38), OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2), STR0011, OFONT1:OFONT ) //"UF: "
		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+20, ALLTRIM(TRBFAT->A1_EST), OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+60, STR0010, OFONT1:OFONT ) //"CEP: "
		
		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+80, TRANSFORM(ALLTRIM(TRBFAT->A1_CEP),"@R 99999-999"), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 226

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDERECO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, ALLTRIM(TRBFAT->A1_END), OFONT2:OFONT )

		// OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
		// OREPORT:SAY( NLIN, NMINLEFT+50, substr(TRBFAT->A1_BAIRRO,1,35), OFONT2:OFONT )

		// OREPORT:SAY( NLIN, NMEIO-80, STR0020, OFONT1:OFONT ) //"MUNICùPIO: "
		// OREPORT:SAY( NLIN, NMEIO-26, substr(TRBFAT->A1_MUN,1,38), OFONT2:OFONT )

		// OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2), STR0011, OFONT1:OFONT ) //"UF: "
		// OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+20, ALLTRIM(TRBFAT->A1_EST), OFONT2:OFONT )

		// OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+60, STR0010, OFONT1:OFONT ) //"CEP: "
		
		// OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+80, TRANSFORM(ALLTRIM(TRBFAT->A1_CEP),"@R 99999-999"), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 241

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
		OREPORT:SAY( NLIN, NMINLEFT+60, Alltrim(Transform(TRBFAT->A1_CGC, "@!R NN.NNN.NNN/NNNN-99")), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO-80, STR0021, OFONT1:OFONT ) //"INSCRIùùO ESTADUAL: "
		OREPORT:SAY( NLIN, NMEIO+15, ALLTRIM(TRBFAT->A1_INSCR), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 256

		// OREPORT:SAY( NLIN, NMINLEFT+10, STR0022, OFONT1:OFONT ) //"VENCTO: "
		// OREPORT:SAY( NLIN, NMINLEFT+60, DTOC(STOD(TRBFAT->VENCTO)), OFONT2:OFONT )
	//	OREPORT:SAY( NLIN, NMINLEFT+100, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT ) COMENTADO POR GUILHERME CORONADO
		NLIN +=  25 			// NLIN TOTAL: 281

		If SELECT("TRBPRD") > 0
			TRBPRD->(DBCLOSEAREA())
		EndIf

		//Montando a consulta dos pedidos
	// 	oStatement := NIL
	// 	oStatement := FWPreparedStatement():New()
	// 	_CQUERY := " SELECT CASE WHEN MAX(COALESCE(FPN_COD, '')) = ''"
	// 	_CQUERY += " 			THEN CASE WHEN FP0_MINPFT = '1'"
	// 	_CQUERY += " 					  THEN '2'"
	// 	_CQUERY += " 					  ELSE '1' END"
	// 	_CQUERY += " 			ELSE '3' END TIPO,"
	// 	_CQUERY += " 	   C6_ITEM, "
	// 	_CQUERY += " 	   CASE WHEN COALESCE(FPA_DESGRU, '') = ''"
	// 	_CQUERY += " 			THEN ''"
	// //	_CQUERY += " 			ELSE RTRIM(LTRIM(COALESCE(FPA_DESGRU, ''))) + ' / ' END + "
	// 	_CQUERY += " 			ELSE FPA_DESGRU END FPA_DESGRU,"
	// 	_CQUERY += " 	   CASE WHEN COALESCE(FPA_GRUA, '') = ''"
	// 	_CQUERY += " 			THEN ''"
	// //	_CQUERY += " 			ELSE RTRIM(LTRIM(COALESCE(FPA_GRUA, ''))) + ' / ' END +"
	// 	_CQUERY += " 			ELSE FPA_GRUA END FPA_GRUA,"
	// 	_CQUERY += " 	   CASE WHEN COALESCE(FPA_CARAC, '') = ''"
	// 	_CQUERY += " 			THEN ''"
	// //	_CQUERY += " 			ELSE RTRIM(LTRIM(COALESCE(FPA_CARAC, ''))) END PRODUTO,"
	// 	_CQUERY += " 			ELSE FPA_CARAC END FPA_CARAC,"
	// 	_CQUERY += " 	   C6_QTDVEN, C6_PRCVEN, C6_VALOR,"
	// 	_CQUERY += " 	   CASE WHEN MAX(COALESCE(FPN_COD, '')) = '' AND MAX(COALESCE(FPA_DTINI, '')) = ''"
	// 	_CQUERY += " 			THEN MIN(COALESCE(FPA_DTINI, ''))"
	// 	_CQUERY += " 			ELSE MIN(COALESCE(FPN_DTINIC, '')) END DTINI,"
	// 	_CQUERY += " 	   CASE WHEN MAX(COALESCE(FPN_COD, '')) = '' AND MAX(COALESCE(FPA_DTFIM, '')) = ''"
	// 	_CQUERY += "            THEN MAX(COALESCE(FPA_DTFIM, ''))"
	// 	_CQUERY += "            ELSE MAX(COALESCE(FPN_DTFIM, '')) END DTFIM, COALESCE(ZA0.FP0_XLOCAL, '') CONTRATO"
	// 	_CQUERY += "   FROM " + RETSQLNAME("SC5") + " SC5 "
	// 	_CQUERY += " INNER JOIN " + RETSQLNAME("SC6") + " SC6 (NOLOCK)"
	// 	_CQUERY += "     ON C5_FILIAL = C6_FILIAL"
	// 	_CQUERY += "    AND C5_NUM    = C6_NUM"
	// 	_CQUERY += "    AND SC6.D_E_L_E_T_ = ''"

	// 	If lMvLocBac

	// 		_CQUERY += " INNER JOIN " + RetSqlName("FPY") + " FPY ON "
	// 		_CQUERY += " FPY.FPY_FILIAL = '" + xFilial("FPY") +  "' "
	// 		_CQUERY += " 	AND FPY.D_E_L_E_T_ = ' ' "
	// 		_CQUERY += " 	AND FPY_PEDVEN = C5_NUM "
	// 		_CQUERY += " INNER JOIN " + RetSqlName("FPZ") + " FPZ ON "
	// 		_CQUERY += "    FPZ.FPZ_FILIAL = '" + xFilial("FPZ") +  "' " //3
	// 		_CQUERY += "    AND FPZ.D_E_L_E_T_ = ' '  "
	// 		_CQUERY += "    AND FPZ_PEDVEN = C5_NUM "
	// 		_CQUERY += "    AND FPZ_PROJET = FPY_PROJET " //4
	// 		_CQUERY += "   AND FPZ_ITEM = C6_ITEM "
	// 	EndIf

	// 	_CQUERY += " LEFT JOIN " + RETSQLNAME("FPN") + " ZLF (NOLOCK)"
	// 	_CQUERY += "     ON C5_FILIAL = FPN_FILIAL"
	// 	_CQUERY += "    AND C5_NUM    = FPN_NUMPV"
	// 	_CQUERY += "    AND ZLF.D_E_L_E_T_ = ''"
	// 	_CQUERY += " LEFT JOIN " + RETSQLNAME("FPA") + " ZAG (NOLOCK)"
	// 	_CQUERY += "     ON C6_FILIAL = FPA_FILIAL"
	// 	_CQUERY += "    AND ZAG.D_E_L_E_T_ = ''"
	// 	If lMvLocBac
	// 		_CQUERY += "   AND FPA_AS = FPZ_AS "
	// 	Else
	// 		_CQUERY += "   AND FPA_AS = C6_XAS "
	// 	EndIf
	// 	_CQUERY += " LEFT JOIN " + RETSQLNAME("FP0") + " ZA0 (NOLOCK)"
	// 	_CQUERY += "     ON FPA_FILIAL = FP0_FILIAL"
	// 	_CQUERY += "    AND FPA_PROJET = FP0_PROJET"
	// 	_CQUERY += "    AND ZA0.D_E_L_E_T_ = ''"
	// 	_CQUERY += "  WHERE C5_FILIAL = '" + XFILIAL("SC5") + "'"
	// 	_CQUERY += "    AND C6_NOTA   = ? " // Inject 1
	// 	_CQUERY += "    AND C6_SERIE  = ? " // Inject 2
	// 	_CQUERY += "    AND SC5.D_E_L_E_T_ = ''"
	// 	_CQUERY += "  GROUP BY FP0_MINPFT,ZA0.FP0_XLOCAL, C6_ITEM, C6_QTDVEN,FPA_DESGRU, FPA_GRUA, FPA_CARAC, C6_PRCVEN, C6_VALOR"
	// 	_CQUERY += "  ORDER BY C6_ITEM"'
	// *****************************************************************************************************
	// GABRIEL PAIVA ALTERA«√O 14042025
		//Montando a consulta dos pedidos
		oStatement := NIL
		oStatement := FWPreparedStatement():New()
		_CQUERY := " SELECT CASE WHEN MAX(COALESCE(FPN_COD, '')) = ''"
		_CQUERY += " 			THEN CASE WHEN FP0_MINPFT = '1'"
		_CQUERY += " 					  THEN '2'"
		_CQUERY += " 					  ELSE '1' END"
		_CQUERY += " 			ELSE '3' END TIPO,"
		_CQUERY += " 	   C6_ITEM, "
		_CQUERY += " 	   CASE WHEN COALESCE(FPA_DESGRU, '') = ''"
		_CQUERY += " 			THEN ''"
	//	_CQUERY += " 			ELSE RTRIM(LTRIM(COALESCE(FPA_DESGRU, ''))) + ' / ' END + "
		_CQUERY += " 			ELSE FPA_DESGRU END FPA_DESGRU,"
		_CQUERY += " 	   CASE WHEN COALESCE(FPA_GRUA, '') = ''"
		_CQUERY += " 			THEN ''"
	//	_CQUERY += " 			ELSE RTRIM(LTRIM(COALESCE(FPA_GRUA, ''))) + ' / ' END +"
		_CQUERY += " 			ELSE FPA_GRUA END FPA_GRUA,"
		_CQUERY += " 	   CASE WHEN COALESCE(FPA_CARAC, '') = ''"
		_CQUERY += " 			THEN ''"
	//	_CQUERY += " 			ELSE RTRIM(LTRIM(COALESCE(FPA_CARAC, ''))) END PRODUTO,"
		_CQUERY += " 			ELSE FPA_CARAC END FPA_CARAC,"
		_CQUERY += " 	   C6_QTDVEN, C6_PRCVEN, C6_VALOR,"
		_CQUERY += " 	   CASE WHEN MAX(COALESCE(FPN_COD, '')) = '' AND MAX(COALESCE(FPA_DTINI, '')) = ''"
		_CQUERY += " 			THEN MIN(COALESCE(FPA_DTINI, ''))"
		_CQUERY += " 			ELSE MIN(COALESCE(FPN_DTINIC, '')) END DTINI,"
		_CQUERY += " 	   CASE WHEN MAX(COALESCE(FPN_COD, '')) = '' AND MAX(COALESCE(FPA_DTFIM, '')) = ''"
		_CQUERY += "            THEN MAX(COALESCE(FPA_DTFIM, ''))"
		_CQUERY += "            ELSE MAX(COALESCE(FPN_DTFIM, '')) END DTFIM, COALESCE(ZA0.FP0_XLOCAL, '') CONTRATO,"
		_CQUERY += "        COALESCE(ZA0.FP0_XBANCO, '') AS FP0_XBANCO,"
		_CQUERY += "        COALESCE(ZA0.FP0_XAGENC, '') AS FP0_XAGENC,"
		_CQUERY += "        COALESCE(ZA0.FP0_XCONTA, '') AS FP0_XCONTA"
		_CQUERY += "   FROM " + RETSQLNAME("SC5") + " SC5 "
		_CQUERY += " INNER JOIN " + RETSQLNAME("SC6") + " SC6 (NOLOCK)"
		_CQUERY += "     ON C5_FILIAL = C6_FILIAL"
		_CQUERY += "    AND C5_NUM    = C6_NUM"
		_CQUERY += "    AND SC6.D_E_L_E_T_ = ''"

		If lMvLocBac

			_CQUERY += " INNER JOIN " + RetSqlName("FPY") + " FPY ON "
			_CQUERY += " FPY.FPY_FILIAL = '" + xFilial("FPY") +  "' "
			_CQUERY += " 	AND FPY.D_E_L_E_T_ = ' ' "
			_CQUERY += " 	AND FPY_PEDVEN = C5_NUM "
			_CQUERY += " INNER JOIN " + RetSqlName("FPZ") + " FPZ ON "
			_CQUERY += "    FPZ.FPZ_FILIAL = '" + xFilial("FPZ") +  "' " //3
			_CQUERY += "    AND FPZ.D_E_L_E_T_ = ' '  "
			_CQUERY += "    AND FPZ_PEDVEN = C5_NUM "
			_CQUERY += "    AND FPZ_PROJET = FPY_PROJET " //4
			_CQUERY += "   AND FPZ_ITEM = C6_ITEM "
		EndIf

		_CQUERY += " LEFT JOIN " + RETSQLNAME("FPN") + " ZLF (NOLOCK)"
		_CQUERY += "     ON C5_FILIAL = FPN_FILIAL"
		_CQUERY += "    AND C5_NUM    = FPN_NUMPV"
		_CQUERY += "    AND ZLF.D_E_L_E_T_ = ''"
		_CQUERY += " LEFT JOIN " + RETSQLNAME("FPA") + " ZAG (NOLOCK)"
		_CQUERY += "     ON C6_FILIAL = FPA_FILIAL"
		_CQUERY += "    AND ZAG.D_E_L_E_T_ = ''"
		If lMvLocBac
			_CQUERY += "   AND FPA_AS = FPZ_AS "
		Else
			_CQUERY += "   AND FPA_AS = C6_XAS "
		EndIf
		_CQUERY += " LEFT JOIN " + RETSQLNAME("FP0") + " ZA0 (NOLOCK)"
		_CQUERY += "     ON FPA_FILIAL = FP0_FILIAL"
		_CQUERY += "    AND FPA_PROJET = FP0_PROJET"
		_CQUERY += "    AND ZA0.D_E_L_E_T_ = ''"
		_CQUERY += "  WHERE C5_FILIAL = '" + XFILIAL("SC5") + "'"
		_CQUERY += "    AND C6_NOTA   = ? " // Inject 1
		_CQUERY += "    AND C6_SERIE  = ? " // Inject 2
		_CQUERY += "    AND SC5.D_E_L_E_T_ = ''"
		_CQUERY += "  GROUP BY FP0_MINPFT,ZA0.FP0_XLOCAL, C6_ITEM, C6_QTDVEN,FPA_DESGRU, FPA_GRUA, FPA_CARAC, C6_PRCVEN, C6_VALOR,"
		_CQUERY += "           ZA0.FP0_XBANCO, ZA0.FP0_XAGENC, ZA0.FP0_XCONTA"
		_CQUERY += "  ORDER BY C6_ITEM"
	//******************************************************************************************************

		//Seta as variaveis da query
		oStatement:SetQuery(_CQUERY)
		oStatement:SetString(1, TRBFAT->NUMFAT  )
		oStatement:SetString(2, MV_PAR03    	)

		//Recupera a consulta jù com os parùmetros injetados
		_CQUERY := oStatement:GetFixQuery()
		_cQuery := ChangeQuery(_cQuery)
		TCQUERY _CQUERY NEW ALIAS "TRBPRD"

		WHILE TRBPRD->(!EOF())
			IF !EMPTY(ALLTRIM(TRBPRD->DTINI))
				IF EMPTY(_DDTINI) .OR. STOD(TRBPRD->DTINI) < _DDTINI
					_DDTINI := STOD(TRBPRD->DTINI)
				ENDIF
			ENDIF

			IF !EMPTY(ALLTRIM(TRBPRD->DTFIM))
				IF STOD(TRBPRD->DTFIM) > _DDTFIM
					_DDTFIM := STOD(TRBPRD->DTFIM)
				ENDIF
			ENDIF

			_CTIPO     := TRBPRD->TIPO
			_CCONTRATO := ALLTRIM(TRBPRD->CONTRATO)
			 _CPRODUTO  := "ALLTRIM(TRBPRD->FPA_DESGRU)+' '+ALLTRIM(TRBPRD->FPA_GRUA)+' '+ALLTRIM(TRBPRD->FPA_CARAC)"
			XT  := MLCOUNT(_CPRODUTO,65)


			
	
			//Montando a consulta dos pedidos
			oStatement := NIL
			oStatement := FWPreparedStatement():New()

			//DENNIS CALABREZ - CHAMADO 30566 08/03/23 - AJUSTE NO FILTRO DA SC6 PARA A IMPRESSùO DOS ITENS NA FATURA - INICIO
// 			_cQuery := "SELECT C6_SERIE,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_PRCVEN,C6_VALOR, C6_VALDESC, FPZ_VALUNI, FPZ_TOTAL "
// 			If lMvLocBac
// 				_cQuery += " , FPZ_PERLOC PERLOC, FPZ_FROTA FROTA "  // ALTERADO DE FPZ_PERLOC PERLOC
// 			Else
// //				_cQuery += " , C6_XPERLOC PERLOC, ' ' FROTA "
// 			EndIf
// 			_cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
// 			If lMvLocBac
// 				_cQuery += " INNER JOIN " + RetSqlName("FPY") + " FPY ON "
// 				_cQuery += " 	FPY.FPY_FILIAL = '" + xFilial("FPY") +  "' "
// 				_cQuery += " 	AND FPY.D_E_L_E_T_ = ' ' "
// 				_CQUERY += " 	AND FPY_PEDVEN = C6_NUM "
// 				_cQuery += " INNER JOIN " + RetSqlName("FPZ") + " FPZ ON "
// 				_cQuery += "    FPZ.FPZ_FILIAL = '" + xFilial("FPZ") +  "' " //3
// 				_cQuery += "    AND FPZ.D_E_L_E_T_ = ' '  "
// 				_cQuery += "    AND FPZ_PEDVEN = C6_NUM "
// 				_cQuery += "    AND FPZ_PROJET = FPY_PROJET " //4
// 				_cQuery += "    AND FPZ_ITEM = C6_ITEM "
// 			EndIf
// 			//_cQuery += "WHERE SC6.C6_FILIAL = '" + MV_PAR04 + "' AND SC6.C6_NOTA = '" + TRBFAT->NUMFAT + "' AND "
// 			_cQuery += "WHERE SC6.C6_FILIAL = ? AND SC6.C6_NOTA = ? AND " // Inject 1 e 2
// 			_cquery += "SC6.D_E_L_E_T_=' ' "
_cQuery := "SELECT C6_SERIE, C6_PRODUTO, C6_ITEM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_VALDESC, FPZ_VALUNI, FPZ_TOTAL "

If lMvLocBac
    _cQuery += ", FPZ_PERLOC PERLOC, FPZ_FROTA FROTAX "
    _cQuery += ", FPA.FPA_XPLACA FROTA "
    _cQuery += ", FP0.FP0_XBANCO, FP0.FP0_XAGENC, FP0.FP0_XCONTA " // CAMPOS DA FP0
Else
//  _cQuery += ", C6_XPERLOC PERLOC, ' ' FROTA "
EndIf

_cQuery += "FROM " + RetSqlName("SC6") + " SC6 "

If lMvLocBac
    _cQuery += " INNER JOIN " + RetSqlName("FPY") + " FPY ON "
    _cQuery += "     FPY.FPY_FILIAL = '" + xFilial("FPY") + "' "
    _cQuery += "     AND FPY.D_E_L_E_T_ = ' ' "
    _cQuery += "     AND FPY_PEDVEN = C6_NUM "

    _cQuery += " INNER JOIN " + RetSqlName("FPZ") + " FPZ ON "
    _cQuery += "     FPZ.FPZ_FILIAL = '" + xFilial("FPZ") + "' "
    _cQuery += "     AND FPZ.D_E_L_E_T_ = ' ' "
    _cQuery += "     AND FPZ_PEDVEN = C6_NUM "
    _cQuery += "     AND FPZ_PROJET = FPY_PROJET "
    _cQuery += "     AND FPZ_ITEM = C6_ITEM "

    _cQuery += " LEFT JOIN " + RetSqlName("FPA") + " FPA ON "
    _cQuery += "     FPA.FPA_FILIAL = '" + xFilial("FPA") + "' "
    _cQuery += "     AND FPA.D_E_L_E_T_ = ' ' "
    _cQuery += "     AND FPA_PROJET = FPZ_PROJET "
    _cQuery += "     AND FPA_ITEREM = C6_ITEM "

    // JOIN COM FP0
    _cQuery += " LEFT JOIN " + RetSqlName("FP0") + " FP0 ON "
    _cQuery += "     FP0.FP0_FILIAL = '" + xFilial("FP0") + "' "
    _cQuery += "     AND FP0.D_E_L_E_T_ = ' ' "
    _cQuery += "     AND FP0.FP0_PROJET = FPZ.FPZ_PROJET "
EndIf

_cQuery += "WHERE SC6.C6_FILIAL = ? AND SC6.C6_NOTA = ? AND "
_cQuery += "SC6.D_E_L_E_T_=' ' "

			//Seta as variaveis da query
			oStatement:SetQuery(_cquery)
			oStatement:SetString(1, MV_PAR04    	)
			oStatement:SetString(2, TRBFAT->NUMFAT  )

			//Recupera a consulta jù com os parùmetros injetados
			_cquery := oStatement:GetFixQuery()

			_cQuery := ChangeQuery(_cQuery)
			//DENNIS CALABREZ - CHAMADO 30566 08/03/23 - AJUSTE NO FILTRO DA SC6 PARA A IMPRESSùO DOS ITENS NA FATURA -
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSc6,.T.,.F.)

			_APRODUTOS := {}
			//WHILE !SC6->(EOF()) .AND. SC6->C6_NOTA == TRBFAT->NUMFAT .AND. SC6->C6_FILIAL == MV_PAR04
			WHILE !(cAliasSc6)->(EOF())//DENNIS CALABREZ - CHAMADO 30566 08/03/23 - ALTERADO O ALIAS DE SC6 PARA TRBSC6
				IF (cAliasSc6)->C6_SERIE == MV_PAR03
					SB1->(DBSETORDER(1))
					SB1->(DBSEEK(XFILIAL("SB1")+(cAliasSc6)->C6_PRODUTO))
					//DENNIS CALABREZ - CHAMADO 30566 08/03/23 - ALTERADO O ALIAS DE SC6 PARA TRBSC6
					AADD(_APRODUTOS,{(cAliasSc6)->C6_ITEM,SB1->B1_DESC,CVALTOCHAR((cAliasSc6)->C6_QTDVEN),TRANSFORM((cAliasSc6)->FPZ_VALUNI,"@E 9,999,999,999.99"),TRANSFORM((cAliasSc6)->FPZ_TOTAL ,"@E 9,999,999,999.99"),(cAliasSc6)->PERLOC ,(cAliasSc6)->FROTA   })
				ENDIF
				(cAliasSc6)->(DBSKIP())
			ENDDO

			(cAliasSc6)->(DbCloseArea())

			_NTOTAL += TRBPRD->C6_VALOR

			TRBPRD->(DBSKIP())
		ENDDO

		TRBPRD->(DBCLOSEAREA())

		OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)

		IF _CTIPO == "2"
			OREPORT:SAY( NLIN-2, NMINLEFT+10, STR0023, OFONT1:OFONT ) //"ITEM"
			OREPORT:SAY( NLIN-2, NMINLEFT+40, "DISCRIMINA«√O/PLACA", OFONT1:OFONT ) //"DESCRIMINAùùO/ESPECIFICAùùO"

			OREPORT:SAY( NLIN-2, NMEIO-10, STR0025, OFONT1:OFONT ) //"PERùODO"

			OREPORT:SAY( NLIN-2, NMEIO+94, STR0026, OFONT1:OFONT ) //"QTD."
			OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)-20, STR0027, OFONT1:OFONT ) //"PREùO UNITùRIO"
			OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)+90, STR0028, OFONT1:OFONT ) //"PREùO TOTAL"
		ELSE
			OREPORT:SAY( NLIN-2, NMINLEFT+10, "DISCRIMINA«√O/PLACA", OFONT1:OFONT )	 //"DESCRIMINAùùO/ESPECIFICAùùO"

		ENDIF
		NLIN +=  15 		// 296


		DO CASE
		CASE _CTIPO == "1"
			//SIGALOC94-812 - 16/06/2023 - Jose Eulalio - PE para substituir as informaùùes de LOCAùùO DE EQUIPAMENTO
			If lLocr003A
				// NLIN := ExecBlock("LOCR003A" , .T. , .T. , {NLIN,TRBFAT->PEDIDO,_CCONTRATO,OREPORT})
			Else
				IF EMPTY(ALLTRIM(DTOS(_DDTINI))) .OR. EMPTY(ALLTRIM(DTOS(_DDTFIM)))
					OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0029 , OFONT2:OFONT ) //"LOCAùùO DE EQUIPAMENTOS - "
				ELSE
					OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0029 + DTOC(_DDTINI) + STR0030 + DTOC(_DDTFIM), OFONT2:OFONT ) //"LOCAùùO DE EQUIPAMENTOS - "###" A "
				ENDIF
				NLIN += nTamLin
				//imprime equipamento, numero de serie e periodo
				SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(DbSeek(xFilial("SC6") + TRBFAT->PEDIDO))
					FPA->(DbSetOrder(3)) //FPA_FILIAL+FPA_AS+FPA_VIAGEM
					FPY->(dbSetOrder(1)) //FPY_FILIAL+FPY_PEDVEN+FPY_PROJET
					FPZ->(dbSetOrder(1)) //FPZ_FILIAL+FPZ_PEDVEN+FPZ_PROJET+FPZ_ITEM
					cChave := SC6->(C6_FILIAL + C6_NUM)
					FPY->(dbSeek(xFilial("FPY")+SC6->C6_NUM))
					While !SC6->(Eof()) .And. SC6->(C6_FILIAL + C6_NUM) == cChave
						If lMvLocBac
							// FPZ->(dbSeek(xFilial("FPZ")+SC6->C6_NUM+FPY->FPY_PROJET+SC6->C6_ITEM)) // Rossana 11/11
							// cAsPedido	:= FPZ->FPZ_AS
							// cPeriodo  	:= FPZ->FPZ_PERLOC
						Else
							cAsPedido	:= SC6->C6_XAS
							cPeriodo  	:= SC6->C6_XPERLOC
						EndIf
						FPA->(DbSetOrder(3))
						If FPA->(DbSeek(xFilial("FPA") + cAsPedido))
							// oReport:SAY( NLIN-1, 020, "Equipamento: " + AllTrim(FPA->FPA_GRUA)    , oFont2:oFont )
							// oReport:SAY( NLIN-1, 220, "Num.Serie: "   + AllTrim(SC6->C6_NUMSERI)  , oFont2:oFont )
							// oReport:SAY( NLIN-1, 360, "Periodo: "     + AllTrim(cPeriodo)         , oFont2:oFont )
							NLIN += nTamLin
						EndIf
						SC6->(DbSkip())
					EndDo
				EndIf
			EndIf
			NLIN += 10 		// 311
		CASE _CTIPO == "2" .or. _CTIPO == "3"
		
		//Adidionado por Raphael - HV - 30/04/2025
			ASort(_APRODUTOS,,,{|x,y| x[1]  < y[1] })

			FOR I := 1 TO LEN(_APRODUTOS) //ALTERAR AGORA
				OREPORT:SAY( NLIN-1, NMINLEFT+10, _APRODUTOS[I,1], OFONT2:OFONT )
				OREPORT:SAY( NLIN-1, NMINLEFT+40, AllTrim(_APRODUTOS[I,2])+"/"+AllTrim(_APRODUTOS[I,7]), OFONT2:OFONT )

				OREPORT:SAY( NLIN-1, NMEIO-10, _APRODUTOS[I,6], OFONT2:OFONT )

				OREPORT:SAY( NLIN-1, NMEIO+94, _APRODUTOS[I,3], OFONT2:OFONT )
				OREPORT:SAY( NLIN-1,((NMEIO+NMAXWIDTH)/2)-23, _APRODUTOS[I,4], OFONT2:OFONT )
				OREPORT:SAY( NLIN-1,((NMEIO+NMAXWIDTH)/2)+74, _APRODUTOS[I,5], OFONT2:OFONT )
				NLIN += 10 	// 311
//				IF NLIN > 800
				IF NLIN > 750
					OREPORT:ENDPAGE()
					OREPORT:STARTPAGE()
					NLIN := 25
//---------------------------------------------------------------------------------------------------------------------

		// --> CABEùALHO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+50, NMAXWIDTH,"-1" )
		NLIN +=  50 			// NLIN TOTAL:  75

		// --> INFORMAùùES DO PRESTADOR DO SERVIùO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMEIO     )
		OREPORT:BOX( NLIN, NMEIO   , NLIN+90, NMAXWIDTH )
		NLIN += 105 			// NLIN TOTAL: 180

		// --> INFORMAùùES DO TOMADOR DO SERVIùO
		OREPORT:BOX( NLIN, NMINLEFT, NLIN+90, NMAXWIDTH )
		NLIN += 102 			// NLIN TOTAL: 282

		NLIN += 420 			// NLIN TOTAL: 702

		NLIN :=  30

		OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN +=  15 			// NLIN TOTAL: 45

		// OREPORT:SAYBITMAP(NLIN-20,NMINLEFT+3,CLOGO)

		OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN +=  15 			// NLIN TOTAL: 60

		OREPORT:FILLRECT( {NLIN, NMINLEFT+3, NLIN+10,NMAXWIDTH }, OBRUSH)
		NLIN :=  38

		// OREPORT:SAYBITMAP(NLIN-20,NMINLEFT+3,CLOGO,0108,0060 )

		OREPORT:SAY( NLIN, NMEIO-(len(STR0005)/2)-20, STR0005, OFONT3:OFONT ) //"FATURA"
/*


		_CEMPRESA := ALLTRIM(SM0->M0_NOMECOM)
		XT  := MLCOUNT(_CEMPRESA,30)
		FOR I:=1 TO XT
			OREPORT:SAY( NLIN, NMINLEFT+103, MEMOLINE(_CEMPRESA ,30, I ), OFONT4:OFONT )
			NLIN +=  15
		NEXT I


*/
		NLIN :=  53 			// NLIN TOTAL: 53

		OREPORT:SAY( NLIN, NMEIO- (len(alltrim(TRBFAT->NUMFAT))/2), alltrim(TRBFAT->NUMFAT), OFONT3:OFONT )
		NLIN +=  40 			// NLIN TOTAL: 93

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREùO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, substr(CEND,1,51 ), OFONT2:OFONT )


		OREPORT:SAY( NLIN, NMEIO+10, STR0007, OFONT1:OFONT ) //"NATUREZA OPERAùùO: "
		OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->F4_FINALID), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 108

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
		OREPORT:SAY( NLIN, NMINLEFT+50, substr(CBAIRRO,1,20), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+30, STR0032, OFONT1:OFONT ) //STR0032 //"CONTRATO: "
		OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->FP0_XLOCAL), OFONT2:OFONT ) // GABRIEL 09042025
		
		OREPORT:SAY( NLIN, NMEIO+10, "PROJETO: ", OFONT1:OFONT ) //STR0032 //"PROJETO: "
		OREPORT:SAY( NLIN, NMEIO+108, ALLTRIM(TRBFAT->FPZ_PROJET), OFONT2:OFONT ) // GABRIEL 
	
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0009, OFONT1:OFONT ) //"CIDADE: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+35, substr(CCIDADE,1,24), OFONT2:OFONT )

		NLIN +=  15 			// NLIN TOTAL: 123

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0010, OFONT1:OFONT ) //"CEP: "
		OREPORT:SAY(NLIN, NMINLEFT+50, TRANSFORM(CCEP, "@!R NNNNN-NNN"), OFONT2:OFONT) // ALTERADO 22042025 GABRIEL

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0011, OFONT1:OFONT ) //"UF: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CUF, OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 138

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0012, OFONT1:OFONT ) //"FONE: "
		OREPORT:SAY(NLIN, NMINLEFT+50, TRANSFORM(CTEL, "@R (99) 9999-9999"), OFONT2:OFONT)// ALTERADO 22042025 GABRIEL

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0013, OFONT1:OFONT ) //"FAX: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, CFAX, OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0014, OFONT1:OFONT ) //"DATA EMISSùO: "
		OREPORT:SAY( NLIN, NMEIO+80, DTOC(STOD(TRBFAT->EMISSAO)), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 153
		OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
		OREPORT:SAY( NLIN, NMINLEFT+50, CCNPJ, OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2), STR0016, OFONT1:OFONT ) //"CCM: "
		OREPORT:SAY( NLIN, ((NMINLEFT+NMEIO)/2)+30, ALLTRIM(SM0->M0_INSCM), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO+10, STR0017, OFONT1:OFONT ) //"NùMERO PEDIDO: "
		OREPORT:SAY( NLIN, NMEIO+80, TRBFAT->PEDIDO, OFONT2:OFONT )
		NLIN +=  25 			// NLIN TOTAL: 178

		OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)
		OREPORT:SAY( NLIN-1, NMEIO-30, "STR0018", OFONT3:OFONT ) //"DESTINATùRIO"
		NLIN +=  18 			// NLIN TOTAL: 196

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0019, OFONT1:OFONT ) //"RAZùO SOCIAL: "
		OREPORT:SAY( NLIN, NMINLEFT+75, ALLTRIM(TRBFAT->RAZSOC), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 211

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0006, OFONT1:OFONT ) //"ENDEREùO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, ALLTRIM(TRBFAT->A1_END), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 226

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0008, OFONT1:OFONT ) //"BAIRRO: "
		OREPORT:SAY( NLIN, NMINLEFT+50, substr(TRBFAT->A1_BAIRRO,1,35), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO-80, STR0020, OFONT1:OFONT ) //"MUNICùPIO: "
		OREPORT:SAY( NLIN, NMEIO-26, substr(TRBFAT->A1_MUN,1,38), OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2), STR0011, OFONT1:OFONT ) //"UF: "
		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+20, ALLTRIM(TRBFAT->A1_EST), OFONT2:OFONT )

		OREPORT:SAY( NLIN, ((NMEIO+NMAXWIDTH)/2)+60, STR0010, OFONT1:OFONT ) //"CEP: "
		OREPORT:SAY(NLIN, ((NMEIO+NMAXWIDTH)/2)+80, TRANSFORM(ALLTRIM(TRBFAT->A1_CEP), "@R 9999-999"), OFONT2:OFONT) // ALTERADO 22042025
		NLIN +=  15 			// NLIN TOTAL: 241

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0015, OFONT1:OFONT ) //"CNPJ: "
		OREPORT:SAY( NLIN, NMINLEFT+60, Alltrim(Transform(TRBFAT->A1_CGC, "@!R NN.NNN.NNN/NNNN-99")), OFONT2:OFONT )

		OREPORT:SAY( NLIN, NMEIO-80, STR0021, OFONT1:OFONT ) //"INSCRIùùO ESTADUAL: "
		OREPORT:SAY( NLIN, NMEIO+15, ALLTRIM(TRBFAT->A1_INSCR), OFONT2:OFONT )
		NLIN +=  15 			// NLIN TOTAL: 256

		OREPORT:SAY( NLIN, NMINLEFT+10, STR0022, OFONT1:OFONT ) //"VENCTO: "
		OREPORT:SAY( NLIN, NMINLEFT+60, DTOC(STOD(TRBFAT->VENCTO)), OFONT2:OFONT )
	//	OREPORT:SAY( NLIN, NMINLEFT+100, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT ) COMENTADO POR GUILHERME CORONADO
		NLIN +=  25 			// NLIN TOTAL: 281

		OREPORT:FILLRECT( {NLIN-10, 0010, NLIN,NMAXWIDTH }, OBRUSH)

		IF _CTIPO == "2"
			OREPORT:SAY( NLIN-2, NMINLEFT+10, STR0023, OFONT1:OFONT ) //"ITEM"
			OREPORT:SAY( NLIN-2, NMINLEFT+40, "DISCRIMINA«√O/PLACA", OFONT1:OFONT )	 //"DESCRIMINAùùO/ESPECIFICAùùO"

			OREPORT:SAY( NLIN-2, NMEIO-10, STR0025, OFONT1:OFONT ) //"PERùODO"

			OREPORT:SAY( NLIN-2, NMEIO+94, STR0026, OFONT1:OFONT ) //"QTD."
			OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)-20, STR0027, OFONT1:OFONT ) //"PREùO UNITùRIO"
			OREPORT:SAY( NLIN-2,((NMEIO+NMAXWIDTH)/2)+90, STR0028, OFONT1:OFONT ) //"PREùO TOTAL"
//		ELSE
//			OREPORT:SAY( NLIN-2, NMINLEFT+10, "DISCRIMINA«√O/PLACA", OFONT1:OFONT )	 //"DESCRIMINAùùO/ESPECIFICAùùO"

		ENDIF
		NLIN +=  15 		// 296

//---------------------------------------------------------------------------------------------------------------------
				ENDIF
			NEXT
/*
		CASE _CTIPO == "3"
			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0031, OFONT2:OFONT ) //"COMPLEMENTO DE LOCAùùO"
			NLIN +=  10 	// 311 */
		ENDCASE

		//IF NLIN < 455
		//	NLIN := 465
		//ELSE
			NLIN +=  20
		//ENDIF

		// Frank em 10/10/23 card 1182
		// 1. Pegar o conteùdo de todos os FP1_OBSFAT envolvidos
		// 2. Completar com o conteùdo do MV_CMPUSR
		// a cada FP1 e conteùdo do parùmetro pular linha chr(13)+chr(10)
		//--------------------------------------------------------------------------------
		// GABRIEL CALCULO ALIQUITAS 
		
	lQuery		:= .T.
			cAliasSF3	:= GetNextAlias()

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Verifica se imprime ou nao os documentos cancelados≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

// 			cSelect:= "%"
// 			cSelect+= "F2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE,"
// 			cSelect+= IIF(SerieNfId("SF2",3,"F2_SERIE")<>"F2_SERIE","F2_SDOC,","") + "F2_CLIENTE,"
// 			cSelect+= "F2_LOJA,F2_BASEISS,F2_VALBRUT,F2_TIPO,F2_VALISS,F2_ESPECIE,"
// 			cSelect+= "D2_CODISS,F2_NFELETR,F2_EMINFE,F2_CODNFE,F2_CREDNFE "+cCampos
// 			cSelect+= "%"

// 			BeginSql Alias cAliasSF3
// 			COLUMN F2_EMISSAO AS DATE
// 			COLUMN F2_EMINFE AS DATE
// 			SELECT %Exp:cSelect%

// 			FROM %table:SF2% SF2 INNER JOIN %table:SD2% SD2 
// 			ON  SF2.F2_FILIAL   = SD2.D2_FILIAL        
// 			AND SF2.F2_DOC      = SD2.D2_DOC      
// 			AND SF2.F2_SERIE    = SD2.D2_SERIE      
// 			AND SF2.F2_TIPO     = SD2.D2_TIPO      
// 			AND SF2.F2_CLIENTE  = SD2.D2_CLIENTE      
// 			AND SF2.F2_LOJA     = SD2.D2_LOJA  
// 			AND SD2.%NotDel%    

// 			WHERE SF2.F2_FILIAL = %xFilial:SF2% AND
// 				SD2.D2_CF >= '5' AND
// 				SF2.F2_EMISSAO >= %Exp:mv_par01% AND
// 				SF2.F2_EMISSAO <= %Exp:mv_par02% AND
// 				SF2.F2_TIPO = 'N' AND
// 				// SD2.D2_CODISS <> %Exp:Space(TamSX3("D2_CODISS")[1])% AND
// 				SF2.F2_CLIENTE >= %Exp:mv_par03% AND
// 				SF2.F2_CLIENTE <= %Exp:mv_par04% AND
// 				SF2.F2_DOC     >= %Exp:mv_par05% AND
// 				SF2.F2_DOC     <= %Exp:mv_par06% AND
// 				// %Exp:cQuery%
// 				SF2.%NotDel%

// 			ORDER BY SF2.F2_EMISSAO,SF2.F2_SERIE,SF2.F2_DOC,SF2.F2_TIPO,SF2.F2_CLIENTE,SF2.F2_LOJA
// 			EndSql

// 			dbSelectArea(cAliasSF3)
// 		Else

// 		#ENDIF
// 		cArqInd := CriaTrab(NIL,.F.)
// 		cChave  := "DTOS(F2_EMISSAO)+F2_SERIE+F2_DOC+F2_TIPO+F2_CLIENTE+F2_LOJA"
// 		cFiltro := "F2_FILIAL == '" + xFilial("SF2") + "' .And. "
// 		cFiltro += "D2_CF >= '5" + SPACE(LEN(D2_CF)-1) + "' .And. "
// 		cFiltro += "DtOs(F2_EMISSAO) >= '" + Dtos(mv_par01) + "' .And. "
// 		cFiltro += "DtOs(F2_EMISSAO) <= '" + Dtos(mv_par02) + "' .And. "
// 		// cFiltro += "F2_TIPO == 'N' .And. D2_CODISS <> '" + Space(Len(D2_CODISS)) + "' .And. "
// 		cFiltro += "F2_TIPO == 'N' .And. "
// 		cFiltro += "F2_CLIENTE >= '" + mv_par03 + "' .And. F2_CLIENTE <= '" + mv_par04 + "' .And. "
// 		cFiltro += "F2_DOC >= '" + mv_par05 + "' .And. F2_DOC <= '" + mv_par06 + "'"
// 		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
// 		//≥Verifica se imprime ou nao os documentos cancelados≥
// 		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

// 		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
// 		#IFNDEF TOP
// 			DbSetIndex(cArqInd+OrdBagExt())
// 		#ENDIF
// 		(cAliasSF3)->(dbGotop())
// 		SetRegua(LastRec())

// 		#IFDEF TOP
// 		Endif
// 	#ENDIF

// If  cKey <> (cAliasSF3)->F2_DOC+(cAliasSF3)->F2_SERIE+(cAliasSF3)->F2_CLIENTE+(cAliasSF3)->F2_LOJA .Or. ((cAliasSF3)->(Eof()))
// 				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
// 				//≥Obtendo os Valores de PIS/COFINS/CSLL/IR/INSS da NF de saida                             ≥
// 				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
// 				SF2->(dbSetOrder(1))
// 				If SF2->(dbSeek(xFilial("SF2")+cKey))
// 					If (SF2->F2_VALPIS + SF2->F2_VALCOFI + SF2->F2_VALCSLL) <= nMinPCC
// 						nValPis  := 0
// 						nValCof  := 0
// 						nValCSLL := 0
// 					Else
// 						nValPis  := SF2->F2_VALPIS
// 						nValCof  := SF2->F2_VALCOFI
// 						nValCSLL := SF2->F2_VALCSLL
// 					EndIf
// 					nValINSS := IIf((SF2->F2_VALINSS <= nMinPCC),0,SF2->F2_VALINSS)
// 					nValIR   := IIf((SF2->F2_VALIRRF <= nMinPCC),0,SF2->F2_VALIRRF)
// 				Endif
// 				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
// 				//≥Obtendo as aliquotas de PIS/COFINS/CSLL/IR/INSS atraves da natureza da NF de saida       ≥
// 				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
// 				SE1->(dbSetOrder(2))
// 				If SE1->(dbSeek(xFilial("SE1")+cF2_CLIENTE+cF2_LOJA+cF2_SERIE+cF2_DOC))
// 					While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SF3")+cF2_CLIENTE+cF2_LOJA+cF2_SERIE+cF2_DOC
// 						If SE1->E1_TIPO == MVNOTAFIS
// 							cNatureza := SE1->E1_NATUREZ
// 							Exit
// 						EndIf
// 						SE1->(dbSKip())
// 					EndDo
// 					SED->(dbSetOrder(1))
// 					If SED->(dbSeek(xFilial("SDE")+cNatureza))
// 						nAliqPis  := Iif( nValPis  > 0 , Iif( SED->ED_PERCPIS > 0 , SED->ED_PERCPIS , cMVTXPIS) , 0 )
// 						nAliqCof  := Iif( nValCof  > 0 , Iif( SED->ED_PERCCOF > 0 , SED->ED_PERCCOF , cMVTXCOF) , 0 )
// 						nALiqINSS := Iif( nValINSS > 0 , SED->ED_PERCINS , 0 )
// 						nAliqIR   := Iif( nValIR   > 0 , Iif( SED->ED_PERCIRF > 0 , SED->ED_PERCIRF , cMVALIRF) , 0 )
// 						nALiqCSLL := Iif( nValCSLL > 0 , Iif( SED->ED_PERCCSL > 0 , SED->ED_PERCCSL , cMVTXCSLL) , 0 )
// 					EndIf
// 				Else
// 					nAliqPis  := Iif( nValPis  > 0 ,cMVTXPIS  , 0 )
// 					nAliqCof  := Iif( nValCof  > 0 ,cMVTXCOF  , 0 )
// 					nAliqIR   := Iif( nValIR   > 0 ,cMVALIRF  , 0 )
// 					nALiqCSLL := Iif( nValCSLL > 0 ,cMVTXCSLL , 0 )
// 				EndIf

// 				aItensSD2 := {}
// 				SD2->(dbSetOrder(3))
// 				SB1->(dbSetOrder(1))
// 				If SD2->(dbSeek(xFilial("SD2")+cKey))
// 					Do While SD2->(!Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cKey
// 						SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))
// 						aAdd(aItensSD2,{SD2->D2_ITEM,SB1->B1_DESC,SD2->D2_QUANT,SD2->D2_PRCVEN,SD2->D2_TOTAL})
// 						SD2->(dbSkip())
// 					EndDo
// 				Endif

// 				ASort(aItensSD2,,,{|x,y| x[1]  < y[1] })








		//--------------------------------------------------------------------------------
		_cObsFat := ""
		SC6->(dbSetOrder(1))
		aObra := {}
		SC6->(dbSeek(xFilial("SC6")+TRBFAT->PEDIDO))
		While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+TRBFAT->PEDIDO
			If lMvLocBac
				FPZ->(dbSetOrder(1))
				FPZ->(dbSeek(xFilial("FPZ")+TRBFAT->PEDIDO))
				lGera := .F.
				While !FPZ->(Eof()) .and. FPZ->FPZ_PEDVEN == TRBFAT->PEDIDO
					If FPZ->FPZ_ITEM == SC6->C6_ITEM
						lGera := .T.
						Exit
					EndIF
					FPZ->(dbSkip())
				EndDo
				If lGera
					FPY->(dbSetOrder(1))
					If FPY->(dbSeek(xFilial("FPY")+TRBFAT->PEDIDO))
						If alltrim(FPY->FPY_STATUS) <> "1"
							lGera := .F.
						EndIf
					EndIf
				EndIf

				if lGera
					FPA->(dbSetOrder(3))
					If FPA->(dbSeek(xFilial("FPA")+FPZ->FPZ_AS))
						FP1->(dbSetOrder(1))
						If FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
							lGera := .T.
							For xT := 1 to len(aObra)
								If aObra[xT,1] == FP1->FP1_OBRA
									lGera := .F.
								EndIf
							Next
							If lGera
								aadd(aObra,{FP1->FP1_OBRA,FP1->FP1_OBSFAT})
							EndIf
						EndIF
					EndIf
				EndIf
			Else
				FPA->(dbSetOrder(3))
				If FPA->(dbSeek(xFilial("FPA")+SC6->C6_XAS))
					FP1->(dbSetOrder(1))
					If FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
						lGera := .T.
						For xT := 1 to len(aObra)
							If aObra[xT,1] == FP1->FP1_OBRA
								lGera := .F.
							EndIf
						Next
						If lGera
							aadd(aObra,{FP1->FP1_OBRA,FP1->FP1_OBSFAT})
						EndIf
					EndIF
				EndIf
			EndIF
			SC6->(dbSkip())
		EndDo
		For xT := 1 to len(aObra)
			_cObsFat += aObra[xT,2]
			_cObsFat += chr(13)+chr(10)
		Next
		SC5->(dbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5")+TRBFAT->PEDIDO))
		If !empty(cCmpUsr)
			cVar := "SC5->"+alltrim(cCmpUsr)
			_cObsFat += &(cVar)+chr(13)+chr(10)
		EndIf
		_cObsFat += chr(13)+chr(10)

		XT  := MLCOUNT(ALLTRIM(_COBSFAT),90)
		FOR I:=1 TO XT
			OREPORT:SAY( NLIN-1, NMINLEFT+10, MEMOLINE(_COBSFAT ,90, I ), OFONT2:OFONT )
			NLIN +=  10
		NEXT

		//NLIN := 505 		// 505

		IF _CTIPO == "1" .AND. !EMPTY(_CCONTRATO)
			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0032 + _CCONTRATO, OFONT2:OFONT )	 //"CONTRATO: "
		ENDIF
		NLIN +=  15 		// 520

		IF _CTIPO <> "3" .AND. !EMPTY(ALLTRIM(TRBFAT->A6_COD))
          //OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0033 + ALLTRIM(TRBFAT->A6_COD) + " AG " + ALLTRIM(TRBFAT->AGENCIA) + " CC " + ALLTRIM(TRBFAT->CONTA), OFONT2:OFONT )		 //"PAGAMENTO ATRAVùS DE DEPùSITO BANCùRIO "
			OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0033 + ALLTRIM(TRBFAT->A6_COD) + " AG " + ALLTRIM(TRBFAT->A6_AGENCIA) + '-' + ALLTRIM(TRBFAT->A6_DVAGE) + " CC " + ALLTRIM(TRBFAT->A6_NUMCON ) + '-' + ALLTRIM(TRBFAT->A6_DVCTA)  , OFONT2:OFONT )		 //"PAGAMENTO ATRAVùS DE DEPùSITO BANCùRIO "
		ENDIF
		NLIN +=  15 		// 535

		// OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0034, OFONT1:OFONT ) //'"OPERAùùO NùO SUJEITA A EMISSùO DE NOTA FISCAL DE SERVIùOS-VETADA A COBRANùA DE ISS CONF.'
		//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+20, 'OPERAùùO NùO SUJEITA A EMISSùO DE NOTA FISCAL DE SERVIùOS-VETADA A COBRANùA DE ISS CONF.', OFONT1:OFONT )
		//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT )
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)-50, "Valor Bruto:", OFONT1:OFONT )
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+68, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT )
		NLIN +=  15 		// 550

		// OREPORT:SAY( NLIN-6, NMINLEFT+10, 'LEI COMPLEMENTAR 116/03', OFONT1:OFONT )
			//OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2), STR0035, OFONT1:OFONT ) //"IMPOSTOS RETIDOS:"
			OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)-50, "Total deduÁıes IRRF(R$):", OFONT1:OFONT )  //  IMPOSTOS RETIDOS: GABRIEL 22042025
			// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*INICIO*)
		//	OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+90, TRANSFORM(TRBFAT->VALRET+TRBFAT->IRFAT,"@E 9,999,999,999.99"), OFONT2:OFONT )
			OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+68, TRANSFORM(TRBFAT->F2_VALIRRF,"@E 9,999,999,999.99"), OFONT2:OFONT )
			// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*FINAL* )
		NLIN +=  15 		// 565
		// OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+35, STR0036, OFONT1:OFONT ) //"DESCONTO:"
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)-50, "Base de c·lculo IRRF(R$):", OFONT1:OFONT ) // DESCONTO 22042025 GABRIEL 
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+68, TRANSFORM(TRBFAT->F2_VALBRUT,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		NLIN +=  15 		// 580
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)-50, "AlÌquota IRRF(%):", OFONT1:OFONT )  
		OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+68, TRANSFORM(TRBFAT->D2_ALQIRRF,"@E 9,999,999,999.99"), OFONT2:OFONT )
		OREPORT:SAY( NLIN+15, ((NMEIO+NMAXWIDTH)/2)-50, "Valor LÌquido:", OFONT1:OFONT ) //"TOTAL:" //gabriel 10042025
		// OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+50, "TOTAL:", OFONT1:OFONT )
		// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*INICIO*)
	    //OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+90, TRANSFORM(TRBFAT->TOTAL,"@E 9,999,999,999.99"), OFONT2:OFONT )
	    //OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+82, TRANSFORM(TRBFAT->F2_VALBRUT - TRBFAT->F2_DESCONT - _NVALOR,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		// nValorf := IIF(TRBFAT->D2_VALIRRF == 0, TRBFAT->F2_VALBRUT, TRBFAT->D2_BASEIRR - TRBFAT->D2_VALIRRF) // 22042025 GABRIEL 
		nValorf := TRBFAT->F2_VALBRUT - TRBFAT->F2_VALIRRF
		OREPORT:SAY( NLIN+15, ((NMEIO+NMAXWIDTH)/2)+68, TRANSFORM(nValorf,"@E 9,999,999,999.99"), OFONT2:OFONT )
		// OREPORT:SAY( NLIN+15, ((NMEIO+NMAXWIDTH)/2)+68, TRANSFORM(TRBFAT->D2_BASEIRR - TRBFAT->D2_VALIRRF,"@E 9,999,999,999.99"), OFONT2:OFONT ) // Rossana 
		// --> CORRECAO DO VALOR DOS IMPOSTOS RETIDOS NA EMISSAO DO RELATORIO   (*FINAL* )
		NLIN +=  30 		// 610
		OREPORT:SAY( NLIN+10, NMINLEFT+10, "Dados do Pagamento:", OFONT1:OFONT ) //"ENDEREùO COBRANùA"
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREùO COBRANùA", OFONT1:OFONT )
		// NLIN +=  15 		// 625
		// OREPORT:SAY( NLIN+20, NMINLEFT+10, "Banco:", OFONT2:OFONT ) //"ENDEREùO: " ALLTRIM(TRBFAT->A1_ENDCOB) + " / " + TRBFAT->A1_BAIRROC, OFONT2:OFONT
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, "BANCO: " + ALLTRIM(TRBFAT->A1_ENDCOB) + " / " + TRBFAT->A1_BAIRROC, OFONT2:OFONT ) //GABRIEL CERTO
		NLIN +=  15 		// 640
		// OREPORT:SAY( NLIN+10, NMINLEFT+10, "Banco:", OFONT2:OFONT )
		// OREPORT:SAY( NLIN+20, NMINLEFT+10, "Agencia: " , OFONT2:OFONT ) // GABRIEL CERTO BANCO
		// OREPORT:SAY( NLIN+30, NMINLEFT+10, "Conta: " , OFONT2:OFONT )
		OREPORT:SAY( NLIN+10, NMINLEFT+10, "Banco: "   + ALLTRIM(TRBFAT->FP0_XBANCO), OFONT2:OFONT )
		OREPORT:SAY( NLIN+20, NMINLEFT+10, "AgÍncia: " + ALLTRIM(TRBFAT->FP0_XAGENC), OFONT2:OFONT )
		OREPORT:SAY( NLIN+30, NMINLEFT+10, "Conta: "   + ALLTRIM(TRBFAT->FP0_XCONTA), OFONT2:OFONT )

		
		 //"CIDADE: "###"  CEP: " + ALLTRIM(TRBFAT->A1_MUNC) + "/" + TRBFAT->A1_ESTC + STR0039 + ALLTRIM(Transform(TRBFAT->A1_CEPC, "@R 99999-99")),
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, "CIDADE: " + ALLTRIM(TRBFAT->A1_MUNC) + "/" + TRBFAT->A1_ESTC + "  CEP: " + ALLTRIM(Transform(TRBFAT->A1_CEPC, "@R 99999-99")), OFONT2:OFONT )
		// NLIN +=  15 		// 655
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0040, OFONT1:OFONT ) //"ENDEREùO ENTREGA"
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREùO ENTREGA", OFONT1:OFONT )
		// NLIN +=  15 		// 670
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, STR0006 + ALLTRIM(TRBFAT->A1_ENDENT) + " / " + ALLTRIM(TRBFAT->A1_BAIRROE) + ", " +ALLTRIM(TRBFAT->A1_MUNE) + ", " + TRBFAT->A1_ESTE + ", " + ALLTRIM(Transform(TRBFAT->A1_CEPE, "@R 99999-99")), OFONT2:OFONT ) //"ENDEREùO: "
		// OREPORT:SAY( NLIN-1, NMINLEFT+10, "ENDEREùO: " + ALLTRIM(TRBFAT->A1_ENDENT) + " / " + ALLTRIM(TRBFAT->A1_BAIRROE) + ", " +ALLTRIM(TRBFAT->A1_MUNE) + ", " + TRBFAT->A1_ESTE + ", " + ALLTRIM(Transform(TRBFAT->A1_CEPE, "@R 99999-99")), OFONT2:OFONT )
		// NLIN +=  15 		// 685

	    //OREPORT:SAY( NLIN-1, NMINLEFT+10, "NUM. PEDIDO DO CLIENTE", OFONT1:OFONT )
		//NLIN := 725 		// 725
		// OREPORT:SAY( NLIN-1, NMINLEFT+20, STR0041, OFONT2:OFONT ) //"Nù FATURA"
		// OREPORT:SAY( NLIN-1, NMINLEFT+100, STR0042 + ALLTRIM(SM0->M0_NOMECOM) + STR0043, OFONT2:OFONT ) //"RECEBI(EMOS) DE "###", OS SERVIùOS CONSTANTES"
		// OREPORT:SAY( NLIN-1, NMINLEFT+100, "RECEBI(EMOS) DE " + ALLTRIM(SM0->M0_NOMECOM) + ", OS SERVIùOS CONSTANTES", OFONT2:OFONT )
		// NLIN +=  30 		// 755

		// OREPORT:SAY( NLIN-1, NMINLEFT+100, ALLTRIM(SM0->M0_CIDCOB) + " " + REPLICATE("_",7) + STR0044 + REPLICATE("_",30) + STR0045 + REPLICATE("_",10), OFONT2:OFONT ) //" , DE "###", DE "
		// OREPORT:SAY( NLIN-1, NMINLEFT+100, ALLTRIM(SM0->M0_CIDCOB) + " " + REPLICATE("_",7) + " , DE " + REPLICATE("_",30) + ", DE " + REPLICATE("_",10), OFONT2:OFONT )
		// OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)-15, REPLICATE("_",40), OFONT2:OFONT )
		// NLIN +=  15 		// 770
		// OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+30, STR0046, OFONT2:OFONT ) //"ASSINATURA"         GABRIEL 14042025
		// OREPORT:SAY( NLIN-1, ((NMEIO+NMAXWIDTH)/2)+30, "ASSINATURA", OFONT2:OFONT )


		NLIN +=  50
		OREPORT:SAY( NLIN+10, NMINLEFT+10, "OBSERVA«’ES:" , OFONT1:OFONT )
		OREPORT:SAY( NLIN+20, NMINLEFT+10, "Atividade sem incidÍncia sobre o ISSQN conforme lei complementar 116/2003" , OFONT2:OFONT )

		OREPORT:ENDPAGE()

		TRBFAT->(DBSKIP())
	ENDDO

	TRBFAT->(DBCLOSEAREA())

	RestArea(aAreaSC6)
	RestArea(aAreaFPA)

	OREPORT:SETVIEWPDF( .T. )
	OREPORT:PREVIEW()
	FREEOBJ(OREPORT)
	OREPORT := NIL

	oStatement:Destroy()
	FwFreeObj(oStatement)

RETURN

/*
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù?ùù
ùùùPROGRAMA  ù PERGPARAM ù AUTOR ù IT UP CONSULTORIA  ù DATA ù 03/08/2016 ùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù?ùù
ùùùDESCRICAO ù PERGUNTA DO RELATùRIO.                                     ùùù
ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
*/
STATIC FUNCTION PERGPARAM(CPERG)
LOCAL APERGS  := {}
LOCAL _CNOTAI := IIF(FIELDPOS("F2_DOC")>0	,SPACE(GETSX3CACHE("F2_DOC","X3_TAMANHO"))			,SPACE(09)			)
LOCAL _CNOTAF := IIF(FIELDPOS("F2_DOC")>0	,REPLICATE("Z",GETSX3CACHE("F2_DOC","X3_TAMANHO"))	,REPLICATE("Z",09)	)
LOCAL _CSERIE := IIF(FIELDPOS("F2_SERIE")>0	,SPACE(GETSX3CACHE("F2_SERIE","X3_TAMANHO"))		,SPACE(03)			)
LOCAL _CFILIAL:= SPACE(Len(cFilAnt))
LOCAL ARET    := {}
LOCAL LRET    := .F.

	AADD( APERGS ,{1,STR0047	,_CNOTAI ,"@!",".T.","SF2"  ,".T.", 50,.F.}) //"NOTA FISCAL DE: "
	AADD( APERGS ,{1,STR0048	,_CNOTAF ,"@!",".T.","SF2"  ,".T.", 50,.F.}) //"NOTA FISCAL ATù: "
	AADD( APERGS ,{1,STR0049    ,_CSERIE ,"@!",".T.","SERNF",".T.", 50,.F.}) //"SùRIE: "
	AADD( APERGS ,{1,STR0050    ,_CFILIAL,"@!",".T.","SM0"  ,".T.", 50,.F.}) //"FILIAL: "
	//AADD( APERGS ,{1,STR0050         ,_CFILIAL,"@!",".T.","SM0"  ,".T.", 50,.F.})
	IF PARAMBOX(APERGS , STR0051 , ARET , /*4*/ , /*5*/ , /*6*/ , /*7*/ , /*8*/ , /*9*/ , /*10*/ , .F.)  //"PARAMETROS "
		MV_PAR01 := ARET[1] 	// NOTA FISCAL INICIAL
		MV_PAR02 := ARET[2] 	// NOTA FISCAL FINAL
		MV_PAR03 := ARET[3] 	// SùRIE
		MV_PAR04 := ARET[4] 	// FILIAL
		LRET := .T.
	ENDIF

RETURN (LRET)

/*/{Protheus.doc} LOCR00101
@description	Valida se o usuùrio pode acessar informaùùes da filial indicada
@see			https://tdn.totvs.com/display/public/framework/FWLoadSM0
@author			Josù Eulùlio
@since     		03/08/2023
/*/

STATIC Function LOCR00101(cCodFil, lHelp)
Local lRet      := .F.
Local aLoadSm0	:= FWLoadSM0()
Local nPosFil	:= aScan(aLoadSm0, {|x| x[2] == cCodFil })

Default lHelp	:= .F.

	//se localizou a filial informada
	If nPosFil > 0
		//se o usuario tem acesso ù filial
		If aLoadSm0[nPosFil][11] .And. !lHelp
			lRet := .T.
		Else
			Help(NIL, NIL, "LOCR003_01", NIL, "Aùùo nùo permitida", 1, 0, NIL, NIL, NIL, NIL, NIL, { "Seu usuùrio nùo tem permissùo para acessar informaùùes da Filial indicada."}) // "Aùùo nùo permitida" #### "Seu usuùrio nùo tem permissùo para acessar informaùùes da Filial indicada."
		EndIf
	Else
		Help(NIL, NIL, "LOCR003_02", NIL, "Filial nùo localizada", 1, 0, NIL, NIL, NIL, NIL, NIL, { "Informe uma Filial vùlida no campo referente."}) // "Filial nùo localizada" #### Informe uma Filial vùlida no campo referente.
	EndIf

Return lRet
