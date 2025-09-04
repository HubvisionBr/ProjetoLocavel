#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE 'COLORS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
#include "parmtype.ch"
#INCLUDE "FWADAPTEREAI.CH"
#Include "TBICODE.CH"
#include 'fileio.ch'

/*
Nome: MT103FIM
Documentação: link da totvs
Explicação: 
*/

User Function MT103FIM()
    Local nOpcao := PARAMIXB[1]
    Local nConfirma := PARAMIXB[2]
    // Local oUmov := NP3F0201():New()
    Local aAreaSD1 := SD1->(GetArea())
	Local cPedido := SD1->D1_PEDIDO
	Local aAreaSC7 := SC7->(GetArea())
	//Valida se NF é de filial diferente do Pedido
	IF !Empty(cPedido)
		DbSelectArea("SC7")
		SC7->(DbSetOrder(14))
		IF SC7->(MsSeek(xFilial("SC7") + cPedido))
			IF SC7->C7_FILIAL <> SF1->F1_FILIAL
				//Gera pedido de venda e fatura
				GerarPedido(SC7->C7_FILIAL)
			Endif
		Endif
	Endif
	
	// Se for inclusão, se a ação foi confirmada e a nota tiver chassi informado
    If nOpcao == 3 .and. nConfirma == 1 .and. !Empty(SD1->D1_CHASSI)
        // // Cria a NFE na tabela de integração
        // DbSelectArea("ZZB")
        // ZZB->(DbSetOrder(1))
        // If !ZZB->(DbSeek(xFilial('ZZB')+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_XCHASSI))
        //     If RecLock('ZZB',.t.)
        //         ZZB->ZZB_FILIAL := SD1->D1_FILIAL
        //         ZZB->ZZB_DOC := SD1->D1_DOC
        //         ZZB->ZZB_SERIE := SD1->D1_SERIE
        //         ZZB->ZZB_FORNEC := SD1->D1_FORNECE
        //         ZZB->ZZB_LOJA := SD1->D1_LOJA
        //         ZZB->ZZB_CHASSI := SD1->D1_XCHASSI
        //         ZZB->ZZB_STATUS := ""
        //         ZZB->(MsUnlock())
        //     EndIf
        // EndIf
        // // Posiciona na TES
        // SF4->(DbSetOrder(1))// F4_FILIAL+F4_CODIGO
        // If SF4->(DbSeek(xFilial('SF4')+SD1->D1_TES))
        //     // Atualiza Ativo
        //     If SF4->F4_ATUATF == "S"
        //         If RecLock('SN1',.f.)
        //             SN1->N1_XCHASSI := SD1->D1_XCHASSI
        //             SN1->N1_XMARCA  := SD1->D1_XMARCA
        //             SN1->N1_XMODELO := SD1->D1_XMODELO
        //             SN1->N1_XPLACA  := SD1->D1_XPLACA
        //             SN1->(MsUnlock())
        //         EndIf
        //     EndIf
        // EndIf
        // If oUmov:EnvToUmov()
        //     If !IsBlind()
        //         MsgInfo("NFE integrada ao Umov.")
        //     Else
        //         Conout("NFE integrada ao Umov.")
        //     EndIf
        // Else
        //     If !IsBlind()
        //         MsgAlert(oUmov:GetError())
        //     Else
        //         Conout(oUmov:GetError())
        //     EndIf
        // EndIf
        // LOC001-JLS-21/05/2025
        U_UCOME001()
        RestArea(aAreaSD1)
    EndIF

	RestArea(aAreaSC7)
Return

Static Function GerarPedido(cFilOri)

	Local aFiliais := FwLoadSM0()
	Local nPosFil  := aScan(aFiliais,{|x| alltrim(x[2]) == Alltrim(cFilOri)})
	Local cCGCCli  := ""
	Local aCabPV   := {}
	Local aTotItem := {}
	Local aItemPV  := {}
	Local nItem    := 1
	Local aItens   := {}
	Local i        := 1
	// Local cFilBkp := cFilAnt

	Private lMsErroAuto    := .F.

	IF nPosFil > 0
		cCGCCli := aFiliais[nPosFil][18]
		dbSelectArea("SA1")
		SA1->(dbSetOrder(3))
		IF SA1->(dbSeek(xFilial("SA1")+ cCGCCli))
			aCabPV := {}

			aAdd(aCabPV,{"C5_EMISSAO", SF1->F1_EMISSAO  ,Nil})
			aAdd(aCabPV,{"C5_TIPO"   ,"N"               ,Nil})
			// aAdd(aCabPV,{"C5_NATUREZ",cNaturez      			,Nil})
			aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD	    ,Nil})
			aAdd(aCabPV,{"C5_CLIENT" ,SA1->A1_COD	    ,Nil})
			aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA	    ,Nil})
			aAdd(aCabPV,{"C5_LOJAENT",SA1->A1_LOJA	    ,Nil})
			aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO      ,Nil})
			aAdd(aCabPV,{"C5_CONDPAG",SF1->F1_COND		,Nil})

			//Leitura da SD1
			DbSelectArea("SD1")
			SD1->(DbSetOrder(1))
			SD1->(MsSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

			aTotItem := {}
			aItemPV := {}
			nItem := 1
			While !SD1->(Eof()) .and. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
				aAdd(aItemPV,{"C6_ITEM",StrZero(nItem,TamSx3("C6_ITEM")[1]),Nil})
				nItem++
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1") + SD1->D1_COD))

				cOper := SuperGetMv("LC_TRANSFI",,"")
				cTes := MaTesInt( 2, cOper, SA1->A1_COD, SA1->A1_LOJA, "C", SB1->B1_COD, Nil)

				aAdd(aItemPV,{"C6_PRODUTO" ,SB1->B1_COD		,Nil})
				aAdd(aItemPV,{"C6_DESCRI"  ,SB1->B1_DESC	,nil})
				aAdd(aItemPV,{"C6_UM"      ,SB1->B1_UM		,nil})
				aAdd(aItemPV,{"C6_LOCAL"   ,SB1->B1_LOCPAD	,nil})
				aAdd(aItemPV,{"C6_OPER"    ,cOper	        ,nil})
				aAdd(aItemPV,{"C6_TES"     ,cTes	        ,nil})
				aAdd(aItemPV,{"C6_QTDVEN"  ,SD1->D1_QUANT   ,nil})    // Quantidade Vendida
				aAdd(aItemPV,{"C6_QTDLIB"  ,SD1->D1_QUANT   ,nil})    // Quantidade Liberada
				aAdd(aItemPV,{"C6_PRUNIT"  ,SD1->D1_VUNIT   ,nil})    // Preço de Lista
				aAdd(aItemPV,{"C6_PRCVEN"  ,SD1->D1_VUNIT   ,nil})    // Preço de Venda
				aAdd(aItemPV,{"C6_VALOR"   ,SD1->D1_TOTAL   ,Nil})
				aAdd(aItemPV,{"AUTDELETA"  , "N"                                                ,nil})
				//Adiciona item no Array de Itens
				aAdd(aTotItem,aItemPV)
				aItemPV := {}
				SD1->(DbSkip())
			EndDo

			lMsErroAuto := .F.
			aCabPV := FWVetByDic(aCabPV,"SC5")

			aItens := {}
			For i := 1 to Len(aTotItem)
				aItem := {}
				aItem := FWVetByDic(aTotItem[i],"SC6")
				aAdd(aItens,{})
				aItens[Len(aItens)] := aItem
			Next

			aTotItem := aItens

			DbSelectArea("SC5")
			DbSelectArea("SC6")

			// cFilAnt := aFiliais[nPosFil][2]
			
			MATA410(aCabPV,aTotItem,3)

			IF lMsErroAuto
				MostraErro()
			Else
				//Prepara documento de saída
				cDocGer := fGeraNFS(SC5->C5_NUM,SuperGetMv("LC_SERFAT",,"1"))
			Endif
			// cFilAnt := cFilBkp
		Endif
	Endif
Return

Static Function fGeraNFS(cNumPed,cSerie)

	Local aPvlDocS := {}
	Local cEmbExp := ""
	Local lOk     := .T.
	Local cDocGer := ""

	DbselectArea("SC5")
	SC5->(DbSetOrder(1))

	lOk := SC5->(MsSeek(xFilial("SC5")+cNumPed))

	IF lOk
		
		DbselectArea("SC6")
		DbselectArea("SC9")
		DbselectArea("SB1")
		DbselectArea("SB2")
		DbselectArea("SF4")


		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))

		//É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
		//Pergunte("MT460A",.F.)

		// Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
		While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

			SC9->(DbSetOrder(1))
			SC9->(MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)) //FILIAL+NUMERO+ITEM

			SE4->(DbSetOrder(1))
			SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

			SB2->(DbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)) //FILIAL+PRODUTO+LOCAL

			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

			AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				SC9->C9_PRCVEN,;
				SC9->C9_PRODUTO,;
				.F.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo())})

			SC6->(DbSkip())
		EndDo

		IF Len(aPvlDocS) > 0

			cDocGer := MaPvlNfs(/*aPvlNfs*/        aPvlDocS,;  // 01 - Array com os itens a serem gerados
						/*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
						/*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
						/*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
						/*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
						/*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
						/*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
						/*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
						/*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
						/*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
						/*lECF*/            .F.,;       // 11 - Cupom Fiscal
						/*cEmbExp*/         cEmbExp,;   // 12 - Número do Embarque de Exportação
						/*bAtuFin*/         {||},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
						/*bAtuPGerNF*/      {||},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
						/*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
						/*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
						/*dDataMoe*/        dDatabase,; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
						/*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais

		Endif
	Endif

Return cDocGer
