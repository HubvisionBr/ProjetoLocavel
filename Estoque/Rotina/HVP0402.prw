#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

Static cTitle   := "Análise de SA"
Static MVC_TITLE := "Análise de SA"
Static MVC_VIEWDEF_NAME := "VIEWDEF.HVP0402"
Static MVC_ALIAS := "ZCP"

// Static cKey     := "FAKE"
// Static nTamFake := 15

/*/{Protheus.doc} User Function zGrid
Visualizacao de Grupos de Produtos em MVC (com tabela temporaria)
@type  Function
@author Atilio
@since  14/06/2020
@version version
@obs Foi baseado no exemplo de Izac Ciszevski (https://centraldeatendimento.totvs.com/hc/pt-br/articles/360047143634-MP-ADVPL-Criando-uma-tela-MVC-s%C3%B3-com-GRID)
/*/

User Function HVP0402()

	Local oBrowse

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return NIL

	**************************************
Static Function BrowseDef()
	Local oBrowse as object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCP")
	oBrowse:SetDescription(cTitle)
	oBrowse:SetMenuDef("HVP0402")
	oBrowse:AddLegend("ZCP_STATUS == ' '"						, "GREEN" ,"Aguardando análise" )
	oBrowse:AddLegend("ZCP_STATUS == 'A'"                       , "BLUE" ,"Analisado" )
	oBrowse:AddLegend("ZCP_STATUS == 'P'"                       , "RED"  ,"Aprovado" )
	oBrowse:AddLegend("ZCP_STATUS == 'R'"                       , "BLACK","Rejeitado" )
	oBrowse:AddFilter( "Filtro padrão", "ZCP_FILIAL = '"+xFilial("ZCP")+"' ", .T., .T. )
	oBrowse:ExecuteFilter()


RETURN oBrowse

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'AxPesqui'       	OPERATION 1 ACCESS 0	//"Pesquisar"
	ADD OPTION aRotina TITLE "Alterar"      ACTION 'U_HVP0402X()'	    OPERATION 4 ACCESS 0	//"Alterar"
	ADD OPTION aRotina TITLE "Enviar"       ACTION 'U_HVP0402E()'	    OPERATION 4 ACCESS 0	//"Alterar"

Return (aRotina)

User Function HVP0402X()

	IF ZCP->ZCP_STATUS $ 'P,R'
		MsgInfo("Registro já aprovado/rejeitado. Não pode ser alterado!")
	Else
		FWExecView('Análise de SA', MVC_VIEWDEF_NAME, MODEL_OPERATION_UPDATE, , { || .T. }, , 0)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Montagem do modelo dados para MVC

@return oModel - Objeto do modelo de dados

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function ModelDef()
	local oModel as object
	local oStrField as object
	local oStrGrid as object

// Estrutura Fake de Field
	oStrField := FWFormModelStruct():New()

	oStrField:addTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})
	oStrField:addField("String 01", "Campo de texto", "C_STRING1", "C", 15)

//Estrutura de Grid, alias Real presente no dicionário de dados
	oStrGrid := FWFormStruct(1, MVC_ALIAS)
	oModel := MPFormModel():New("HVP0402M")

	oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| loadHidFld()})

	oModel:addGrid("GRIDID", "CABID", oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadGrid(oMdl)})

	oModel:setDescription(MVC_TITLE)

	oModel:GetModel("GRIDID"):SetNoDeleteLine(.T.)
	oModel:GetModel("GRIDID"):SetNoInsertLine(.T.)

// É necessário que haja alguma alteração na estrutura Field
	oModel:setActivate({ |oModel| onActivate(oModel)})

return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} onActivate
Função estática para o activate do model

@param oModel - Objeto do modelo de dados

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function onActivate(oModel)

//Só efetua a alteração do campo para inserção
	if oModel:GetOperation() == MODEL_OPERATION_INSERT
		FwFldPut("C_STRING1", "FAKE" , /*nLinha*/, oModel)
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} loadGrid
Função estática para efetuar o load dos dados do grid

@param oModel - Objeto do modelo de dados

@return aData - Array com os dados para exibição no grid

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function LoadGrid(oModel)
	local aData as array
	local cAlias as char
	local cWorkArea as char
	local cTablename as char

	cWorkArea := Alias()
	cAlias := GetNextAlias()
	cTablename := "%" + RetSqlName(MVC_ALIAS) + "%"

	BeginSql Alias cAlias
    SELECT *
      FROM %exp:cTablename%
    WHERE D_E_L_E_T_ = ' '
    AND ZCP_FILIAL = %exp:xFilial("ZCP")%
    AND ZCP_NUMSA = %exp:ZCP->ZCP_NUMSA%
	EndSql

	aData := FwLoadByAlias(oModel, cAlias, MVC_ALIAS, , /*lCopy*/, .T.)

	(cAlias)->(DBCloseArea())

	if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
		DBSelectArea(cWorkArea)
	endif

return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} loadHidFld
Função estática para load dos dados do field escondido

@param oModel - Objeto do modelo de dados

@return Array - Dados para o load do field do modelo de dados

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function loadHidFld(oModel)
return {""}

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função estática do ViewDef

@return oView - Objeto da view, interface

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function viewDef()
	local oView as object
	local oModel as object
	local oStrCab as object
	local oStrGrid as object

// Estrutura Fake de Field
	oStrCab := FWFormViewStruct():New()

	oStrCab:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

//Estrutura de Grid
	oStrGrid := FWFormStruct(2, MVC_ALIAS )
	oModel := FWLoadModel("HVP0402")
	oView := FwFormView():New()

	oView:setModel(oModel)
	oView:addField("CAB", oStrCab, "CABID")
	oView:addGrid("GRID", oStrGrid, "GRIDID")
	oView:createHorizontalBox("TOHIDE", 0 )
	oView:createHorizontalBox("TOSHOW", 100 )
	oView:setOwnerView("CAB", "TOHIDE" )
	oView:setOwnerView("GRID", "TOSHOW")

	oView:setDescription( MVC_TITLE )

return oView

User Function HVP0402F()

	Local lRet      :=  .T.
	// Local lRet      :=  .T.
	Local oModel1 := FwModelActive()
	Local oModel2 := oModel1:GetModel("GRIDID")
	Local nLinAtu := oModel2:GetLine()

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + fwfldget("ZCP_PRODUT")))

	DbSelectArea("SAH")
	SAH->(DbSetOrder(1))
	SAH->(MsSeek(xFilial("SAH") + SB1->B1_UM))

	IF !SAH->AH_XFRACIO .and. (fwfldget("ZCP_QTDAPR") - INT(fwfldget("ZCP_QTDAPR"))) > 0
		MsgAlert("Unidade de medida não permite quantidade fracionada!")
		M->ZCP_QTDAPR := ZCP->ZCP_QTDAPR
		Return .F.
	Endif

	IF fwfldget("ZCP_QTDAPR") > fwfldget("ZCP_QUANT")
		MsgAlert("Quantidade aprovada não pode ser maior que a quantidade solicitada!")
		M->ZCP_QTDAPR := ZCP->ZCP_QTDAPR
		lRet := .F.
	Endif

	If lRet
		// GDFieldPut("ZCP_STATUS","A",nLinAtu)
		oModel2:LoadValue("ZCP_STATUS","A",nLinAtu)
	Endif


Return lRet

User Function HVP0402G()
	Local lRet := .T.

	IF ZCP->ZCP_STATUS $ 'P,R'
		MsgAlert("Registro já enviado. Não pode ser alterado!")
		lRet := .F.
	Endif

Return lRet

User Function HVP0402E()

	Local lRet := .T.
	Local cFilZCP := ZCP->ZCP_FILIAL
	Local cNumSA  := ZCP->ZCP_NUMSA
	Local aAreaZCP := ZCP->(GetArea())
	Local lPed := .F.
	Local cStatus := " 
	"

	Begin Transaction
		DbSelectArea("ZCP")
		ZCP->(DbSetOrder(1))
		ZCP->(MsSeek(cFilZCP + cNumSA))

		WHILE !ZCP->(Eof()) .and. (cFilZCP + cNumSA) == ZCP->(ZCP_FILIAL + ZCP_NUMSA)
			IF ZCP->ZCP_STATUS $ 'P,R, '
				IF ZCP->ZCP_STATUS == ' '
					cStatus := " "
				elseif ZCP->ZCP_STATUS == 'P'
					cStatus := "P"
				Else
					cStatus := "R"
				Endif
				lPed := .F.
			Else
				lPed := .T.
			Endif

			ZCP->(DbSkip())
		EndDo

		RestArea(aAreaZCP)

		IF lPed

			FWMsgRun(, {|| lRet := GerarPedido(ZCP->ZCP_FILDES)}, "Processando nota", "Aguarde...")

			IF !lRet
				MsgAlert("Não foi possível enviar. Contate o administrador!")
				DisarmTransaction()
				Return
			Endif
		Else
			IF cStatus == ' '
				MsgInfo("Registro ainda não foi analisado!")
				DisarmTransaction()
				Return
			Else
				MsgInfo("Registro já enviado anteriormente!")
				DisarmTransaction()
				Return
			Endif
		Endif

	End Transaction

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
	Local cCondPg  := SuperGetMv("LC_CONDPG",,"001")
	Local cFilZCP  := ZCP->ZCP_FILIAL
	Local cNumSA   := ZCP->ZCP_NUMSA
	Local aAreaZCP := ZCP->(GetArea())
	Local lRet := .T.
	Local nCusto := 0

	Private lMsErroAuto    := .F.

	IF nPosFil > 0
		cCGCCli := aFiliais[nPosFil][18]
		dbSelectArea("SA1")
		SA1->(dbSetOrder(3))
		IF SA1->(dbSeek(xFilial("SA1")+ cCGCCli))
			aCabPV := {}

			aAdd(aCabPV,{"C5_EMISSAO", dDataBase        ,Nil})
			aAdd(aCabPV,{"C5_TIPO"   ,"N"               ,Nil})
			// aAdd(aCabPV,{"C5_NATUREZ",cNaturez      			,Nil})
			aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD	    ,Nil})
			aAdd(aCabPV,{"C5_CLIENT" ,SA1->A1_COD	    ,Nil})
			aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA	    ,Nil})
			aAdd(aCabPV,{"C5_LOJAENT",SA1->A1_LOJA	    ,Nil})
			aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO      ,Nil})
			aAdd(aCabPV,{"C5_CONDPAG",cCondPg    		,Nil})

			//Leitura da SD1
			DbSelectArea("ZCP")
			ZCP->(DbSetOrder(1))
			ZCP->(MsSeek(cFilZCP + cNumSA))

			aTotItem := {}
			aItemPV := {}
			nItem := 1
			WHILE !ZCP->(Eof()) .and. (cFilZCP + cNumSA) == ZCP->(ZCP_FILIAL + ZCP_NUMSA)
				RecLock("ZCP",.F.)
				ZCP->ZCP_APROVA := RetCodUsr()
				ZCP->ZCP_DTAPRO := dDataBase
				nCusto := 0

				IF ZCP->ZCP_QTDAPR > 0
					ZCP->ZCP_STATUS := "P"

					aAdd(aItemPV,{"C6_ITEM",StrZero(nItem,TamSx3("C6_ITEM")[1]),Nil})
					nItem++
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1") + ZCP->ZCP_PRODUT))

					DbSelectArea("SB2")
					SB2->(DbSetOrder(1))
					IF !SB2->(MsSeek(xFilial("SB2") + SB1->B1_COD + ZCP->ZCP_LOCAL))
						DbSelectArea("SB2")
						SB2->(DbSetOrder(1))
						SB2->(MsSeek(ZCP->ZCP_FILDES + SB1->B1_COD))

						nCusto := SB2->B2_CM1
					Else
						nCusto := SB2->B2_CM1
						IF nCusto <= 0
							DbSelectArea("SB2")
							SB2->(DbSetOrder(1))
							SB2->(MsSeek(ZCP->ZCP_FILDES + SB1->B1_COD))

							nCusto := SB2->B2_CM1
						Endif
					Endif

					cOper := SuperGetMv("LC_TRANSFI",,"")
					cTes := MaTesInt( 2, cOper, SA1->A1_COD, SA1->A1_LOJA, "C", SB1->B1_COD, Nil)

					aAdd(aItemPV,{"C6_PRODUTO" ,SB1->B1_COD		,Nil})
					aAdd(aItemPV,{"C6_DESCRI"  ,SB1->B1_DESC	,nil})
					aAdd(aItemPV,{"C6_UM"      ,SB1->B1_UM		,nil})
					aAdd(aItemPV,{"C6_LOCAL"   ,ZCP->ZCP_LOCAL	,nil})
					aAdd(aItemPV,{"C6_OPER"    ,cOper	        ,nil})
					aAdd(aItemPV,{"C6_TES"     ,cTes	        ,nil})
					aAdd(aItemPV,{"C6_QTDVEN"  ,ZCP->ZCP_QTDAPR ,nil})    // Quantidade Vendida
					aAdd(aItemPV,{"C6_QTDLIB"  ,ZCP->ZCP_QTDAPR ,nil})    // Quantidade Liberada
					// aAdd(aItemPV,{"C6_PRUNIT"  ,Round(SB2->B2_CM1,2)     ,nil})    // Preço de Lista
					aAdd(aItemPV,{"C6_PRUNIT"  ,Round(nCusto,2)     ,nil})    // Preço de Lista
					// aAdd(aItemPV,{"C6_PRCVEN"  ,Round(SB2->B2_CM1,2)     ,nil})    // Preço de Venda
					aAdd(aItemPV,{"C6_PRCVEN"  ,Round(nCusto,2)     ,nil})    // Preço de Venda
					// aAdd(aItemPV,{"C6_VALOR"   ,(Round(SB2->B2_CM1,2)*ZCP->ZCP_QTDAPR)   ,Nil})
					aAdd(aItemPV,{"C6_VALOR"   ,(Round(nCusto,2)*ZCP->ZCP_QTDAPR)   ,Nil})
					aAdd(aItemPV,{"AUTDELETA"  , "N"                                                ,nil})
					//Adiciona item no Array de Itens
					aAdd(aTotItem,aItemPV)
					aItemPV := {}
				Else
					ZCP->ZCP_STATUS := "R"
				Endif

				ZCP->(MsUnlock())

				ZCP->(DbSkip())
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
			IF Len(aTotItem) > 0

				MATA410(aCabPV,aTotItem,3)

				IF lMsErroAuto
					MostraErro()
					lRet := .F.
				Else
					//Prepara documento de saída
					cDocGer := fGeraNFS(SC5->C5_NUM,SuperGetMv("LC_SERFAT",,"1"))
					IF !Empty(cDocGer)
						DbSelectArea("ZCP")
						ZCP->(DbSetOrder(1))
						ZCP->(MsSeek(cFilZCP + cNumSA))
						While !ZCP->(Eof()) .and. (cFilZCP + cNumSA) == ZCP->(ZCP_FILIAL + ZCP_NUMSA)
							RecLock("ZCP",.F.)
							ZCP->ZCP_NFISCA := cDocGer
							ZCP->ZCP_SER    := SuperGetMv("LC_SERFAT",,"1")
							ZCP->(MsUnlock())
							ZCP->(DbSkip())
						EndDo
					Else
						lRet := .F.
					Endif
				Endif
			EndIf
		Else
			MsgInfo("Filial destino "+aFiliais[nPosFil][2]+" - "+ALltrim(aFiliais[nPosFil][17])+" não está cadastrada como Cliente.")
			// GeraCliente()
			// GerarPedido(cFilOri)
		Endif
	Else
		MsgInfo("Filial não está na SM0.")
	Endif
	RestARea(aAreaZCP)
Return lRet

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
