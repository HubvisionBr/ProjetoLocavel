#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

Static cTitle   := "Análise de SA"
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

User Function HVP0401()
	Local aArea := GetArea()
	Private cAliasTmp := GetNextAlias()
    Private cAlias := GetNextAlias()
	Private oTempTable
    Private cKey := ""

	//Cria a temporária
	oTempTable := FWTemporaryTable():New(cAliasTmp)

	//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
	aFields := {}
	aAdd(aFields, {"SOLICIT",  "C", TamSX3('CP_NUM')[01]     ,    0})
	aAdd(aFields, {"ITEM"   ,  "C", TamSX3('CP_ITEM')[01]    ,    0})
	aAdd(aFields, {"QTDOR"  ,  "N", TamSX3('CP_QUANT')[01]   ,    TamSX3('CP_QUANT')[02]})
	aAdd(aFields, {"SLDLC"  ,  "N", TamSX3('CP_QUANT')[01]   ,    TamSX3('CP_QUANT')[02]})
	aAdd(aFields, {"QUANT"  ,  "N", TamSX3('CP_QUANT')[01]   ,    TamSX3('CP_QUANT')[02]})
	aAdd(aFields, {"SALDO"  ,  "N", TamSX3('CP_QUANT')[01]   ,    TamSX3('CP_QUANT')[02]})
	aAdd(aFields, {"QTDTRF" ,  "N", TamSX3('CP_QUANT')[01]   ,    TamSX3('CP_QUANT')[02]})
	aAdd(aFields, {"PRODUTO",  "C", TamSX3('CP_PRODUTO')[01] ,    0})
	aAdd(aFields, {"DESCRI" ,  "C", TamSX3('B1_DESC')[01] ,    0})
	aAdd(aFields, {"UM"     ,  "C", TamSX3('CP_UM')[01]      ,    0})
	aAdd(aFields, {"LOCDES" ,  "C", TamSX3('CP_LOCAL')[01]   ,    0})
	aAdd(aFields, {"FILORI" ,  "C", TamSX3('B2_FILIAL')[01]  ,    0})
	aAdd(aFields, {"DESFIL" ,  "C", 50                       ,    0})
	aAdd(aFields, {"LOCORI" ,  "C", TamSX3('B2_LOCAL')[01]   ,    0})
	aAdd(aFields, {"DTNECES",  "D", 8                        ,    0})
	aAdd(aFields, {"RECTMP" ,  "N", 10   ,    0})

	//Define as colunas usadas, adiciona indice e cria a temporaria no banco
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex("1", {"SOLICIT"} )
	oTempTable:Create()

	//Executa a inclusao na tela
	FWExecView('Análise de SA', "VIEWDEF.HVP0401", MODEL_OPERATION_UPDATE, , { || .T. }, , 0)

	// //Agora percorre todos os dados digitados
	// (cAliasTmp)->(DbGoTop())
	// While ! (cAliasTmp)->(EoF())
	//     MsgInfo("Código: " + (cAliasTmp)->XXCODIGO + ", Descrição: " + (cAliasTmp)->XXDESCRI, "Atenção")
	//     (cAliasTmp)->(DbSkip())
	// EndDo

	//Deleta a temporaria
	oTempTable:Delete()

	RestArea(aArea)
Return

Static Function ModelDef()
	Local oModel  As Object
	Local oStrField As Object
	Local oStrGrid As Object
	Local bLoad := {|oModel| fCarrGrid(oModel)}
	// Local aGatilhos := {}
	// Local nAtual    := 0

	//Criamos aqui uma estrutura falsa que sera uma tabela que ficara escondida no cabecalho
	oStrField := FWFormModelStruct():New()
	oStrField:AddTable(cAliasTmp , { 'SOLICIT' } , cTitle, {|| ''})
	oStrField:AddField('String 01' , 'Campo de texto' , 'SOLICIT' , 'C' , TamSX3('CP_NUM')[01])

    oStrField := FWFormModelStruct():New()
    oStrField:AddTable(cAliasTmp, {'SOLICIT'}, "Temporaria")
    oStrField:AddField(;
        "Num SA",;                                                                                  // [01]  C   Titulo do campo
        "Num SA",;                                                                                  // [02]  C   ToolTip do campo
        "SOLICIT",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3('CP_NUM')[01],;                                                                                  // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->SOLICIT,'')" ),;            // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual


	//Criamos aqui a estrutura da grid
	oStrGrid := FWFormModelStruct():New()
	oStrGrid:AddTable(cAliasTmp, {'SOLICIT', 'ITEM', 'PRODUTO', 'DESCRI', 'UM', 'QTDOR', 'QUANT', 'LOCDES', 'DTNECES', 'FILORI', 'DESFIL', 'SALDO', 'QTDTRF', 'LOCORI'}, "Temporaria")

	//Adiciona os campos da estrutura
	oStrGrid:AddField(;
	"Num SA",;                                                                                  // [01]  C   Titulo do campo
	"Num SA",;                                                                                  // [02]  C   ToolTip do campo
	"SOLICIT",;                                                                             // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_NUM')[01],;                                                                      // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->SOLICIT" ),;                        // [11]  B   Code-block de inicializacao do campo
	.T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Item",;                                                                                    // [01]  C   Titulo do campo
	"Item",;                                                                                    // [02]  C   ToolTip do campo
	"ITEM",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_ITEM')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ITEM" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Produto",;                                                                                    // [01]  C   Titulo do campo
	"Produto",;                                                                                    // [02]  C   ToolTip do campo
	"PRODUTO",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_PRODUTO')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->PRODUTO" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Descrição",;                                                                                    // [01]  C   Titulo do campo
	"Descrição",;                                                                                    // [02]  C   ToolTip do campo
	"DESCRI",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('B1_DESC')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->DESCRI" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"UM",;                                                                                    // [01]  C   Titulo do campo
	"UM",;                                                                                    // [02]  C   ToolTip do campo
	"UM",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_UM')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->UM" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Qtd SA",;                                                                                    // [01]  C   Titulo do campo
	"Qtd SA",;                                                                                    // [02]  C   ToolTip do campo
	"QTDOR",;                                                                                    // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_QUANT')[01],;                                                                                        // [05]  N   Tamanho do campo
	TamSX3('CP_QUANT')[02],;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->QTDOR" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Sld Atu",;                                                                                    // [01]  C   Titulo do campo
	"Sld Atu",;                                                                                    // [02]  C   ToolTip do campo
	"SLDLC",;                                                                                    // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_QUANT')[01],;                                                                                        // [05]  N   Tamanho do campo
	TamSX3('CP_QUANT')[02],;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->SLDLC" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Qtd Neces. SA",;                                                                                    // [01]  C   Titulo do campo
	"Qtd Neces. SA",;                                                                                    // [02]  C   ToolTip do campo
	"QUANT",;                                                                                    // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_QUANT')[01],;                                                                                        // [05]  N   Tamanho do campo
	TamSX3('CP_QUANT')[02],;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->QUANT" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Local SA",;                                                                                    // [01]  C   Titulo do campo
	"Local SA",;                                                                                    // [02]  C   ToolTip do campo
	"LOCDES",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_LOCAL')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->LOCDES" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Dt. Neces.",;                                                                                    // [01]  C   Titulo do campo
	"Dt. Neces.",;                                                                                    // [02]  C   ToolTip do campo
	"DTNECES",;                                                                                    // [03]  C   Id do Field
	"D",;                                                                                       // [04]  C   Tipo do campo
	8,;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->DTNECES" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Fil. Ori.",;                                                                                    // [01]  C   Titulo do campo
	"Fil. Ori.",;                                                                                    // [02]  C   ToolTip do campo
	"FILORI",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_FILIAL')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->FILORI" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Des. Fil.",;                                                                                    // [01]  C   Titulo do campo
	"Des. Fil.",;                                                                                    // [02]  C   ToolTip do campo
	"DESFIL",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	50,;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->DESFIL" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Item",;                                                                                    // [01]  C   Titulo do campo
	"Item",;                                                                                    // [02]  C   ToolTip do campo
	"SALDO",;                                                                                    // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_QUANT')[01],;                                                                                        // [05]  N   Tamanho do campo
	TamSX3('CP_QUANT')[02],;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->SALDO" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Qtd. Solicitada",;                                                                                    // [01]  C   Titulo do campo
	"Qtd. Solicitada",;                                                                                    // [02]  C   ToolTip do campo
	"QTDTRF",;                                                                                    // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_QUANT')[01],;                                                                                        // [05]  N   Tamanho do campo
	TamSX3('CP_QUANT')[02],;                                                                                         // [06]  N   Decimal do campo
	{|| ValidQtd()},;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->QTDTRF" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual
	oStrGrid:AddField(;
	"Loc. Ori.",;                                                                                    // [01]  C   Titulo do campo
	"Loc. Ori.",;                                                                                    // [02]  C   ToolTip do campo
	"LOCORI",;                                                                                    // [03]  C   Id do Field
	"C",;                                                                                       // [04]  C   Tipo do campo
	TamSX3('CP_LOCAL')[01],;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->LOCORI" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)

    oStrGrid:AddField(;
	"Recno.",;                                                                                    // [01]  C   Titulo do campo
	"Recno",;                                                                                    // [02]  C   ToolTip do campo
	"RECTMP",;                                                                                    // [03]  C   Id do Field
	"N",;                                                                                       // [04]  C   Tipo do campo
	10,;                                                                                        // [05]  N   Tamanho do campo
	0,;                                                                                         // [06]  N   Decimal do campo
	Nil,;                                                                                       // [07]  B   Code-block de validação do campo
	Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
	{},;                                                                                        // [09]  A   Lista de valores permitido do campo
	.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->RECTMP" ),;                               // [11]  B   Code-block de inicializacao do campo
	.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
	.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)
	// [14]  L   Indica se o campo é virtual

	// //Adicionando um gatilho, do codigo para data
	// aAdd(aGatilhos, FWStruTriggger( ;
		//     "XXCODIGO",;                                //Campo Origem
	//     "XXDATA",;                                  //Campo Destino
	//     "u_zGridGat()",;                            //Regra de Preenchimento
	//     .F.,;                                       //Irá Posicionar?
	//     "",;                                        //Alias de Posicionamento
	//     0,;                                         //Índice de Posicionamento
	//     '',;                                        //Chave de Posicionamento
	//     NIL,;                                       //Condição para execução do gatilho
	//     "01");                                      //Sequência do gatilho
	// )

	// //Percorrendo os gatilhos e adicionando na Struct
	// For nAtual := 1 To Len(aGatilhos)
	//     oStrGrid:AddTrigger( ;
		//         aGatilhos[nAtual][01],; //Campo Origem
	//         aGatilhos[nAtual][02],; //Campo Destino
	//         aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
	//         aGatilhos[nAtual][04];  //Bloco de código de execução do gatilho
	//     )
	// Next

	//Agora criamos o modelo de dados da nossa tela
	oModel := MPFormModel():New('HVP0401M',,{|| HVP0401A()},{|| HVP0401B()})
	oModel:AddFields('CABID', , oStrField, , , bLoad)
	oModel:AddGrid('GRIDID', 'CABID', oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPos*/, bLoad)
	oModel:SetRelation('GRIDID', { { 'SOLICIT', 'SOLICIT' } })
	oModel:SetDescription(cTitle)
	oModel:SetPrimaryKey({ 'SOLICIT' })

	//Ao ativar o modelo, irá alterar o campo do cabeçalho mandando o conteúdo FAKE pois é necessário alteração no cabeçalho
	// oModel:SetActivate({ | oModel | FwFldPut("SOLICIT", cKey) })
    //Desativando a exclusão de linhas
    // oModel:GetModel("GRIDID"):SetNoDeleteLine(.T.)
    // oModel:GetModel("GRIDID"):SetNoInsertLine(.T.)
Return oModel

Static Function ViewDef()
	Local oView    As Object
	Local oModel   As Object
	Local oStrCab  As Object
	Local oStrGrid As Object
	Local nOrdem := 1

	//Criamos agora a estrtutura falsa do cabeçalho na visualização dos dados
	oStrCab := FWFormViewStruct():New()
	oStrCab:AddField('SOLICIT' , '01' , 'String 01' , 'Campo de texto', , 'C')

	//Agora a estrutura da Grid
	oStrGrid := FWFormViewStruct():New()


	oStrGrid:AddField(;
	"QTDOR",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Quant. SA",;                    // [03]  C   Titulo do campo
	"Quant. SA",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@E 999,999,999.99",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
	oStrGrid:AddField(;
	"SLDLC",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Saldo Atu",;                    // [03]  C   Titulo do campo
	"Saldo Atu",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@E 999,999,999.99",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
	
	nOrdem++
	oStrGrid:AddField(;
	"QUANT",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Qtd Neces. SA",;                    // [03]  C   Titulo do campo
	"Qtd Neces. SA",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@E 999,999,999.99",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
    oStrGrid:AddField(;
	"QTDTRF",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Qtd Solicitada",;                    // [03]  C   Titulo do campo
	"Qtd Solicitada",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	"@E 999,999,999.99",;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
   oStrGrid:AddField(;
	"SALDO",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Sld Disp Fil",;                    // [03]  C   Titulo do campo
	"Sld Disp Fil",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	"@E 999,999,999.99",;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
    oStrGrid:AddField(;
	"PRODUTO",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Produto",;                    // [03]  C   Titulo do campo
	"Produto",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
    
	nOrdem++
	oStrGrid:AddField(;
	"DESCRI",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Descrição",;                    // [03]  C   Titulo do campo
	"Descrição",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
    oStrGrid:AddField(;
	"FILORI",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Fil Origem",;                    // [03]  C   Titulo do campo
	"Fil Origem",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
	oStrGrid:AddField(;
	"DESFIL",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Des. Fil",;                    // [03]  C   Titulo do campo
	"Des. Fil",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
    oStrGrid:AddField(;
	"LOCORI",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Loc Orig",;                    // [03]  C   Titulo do campo
	"Loc Orig",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
	oStrGrid:AddField(;
	"UM",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"UM",;                    // [03]  C   Titulo do campo
	"UM",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	nOrdem++
	oStrGrid:AddField(;
	"LOCDES",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Local",;                    // [03]  C   Titulo do campo
	"Local",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo


	nOrdem++
	oStrGrid:AddField(;
	"DTNECES",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Data",;                    // [03]  C   Titulo do campo
	"Data",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"D",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo


	nOrdem++
	//Adicionando campos da estrutura
	oStrGrid:AddField(;
	"SOLICIT",;                // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Solicitação",;                  // [03]  C   Titulo do campo
	"Solicitação",;                  // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
	
	nOrdem++
	 oStrGrid:AddField(;
	"ITEM",;                // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Item",;               // [03]  C   Titulo do campo
	"Item",;               // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
	
	nOrdem++
    oStrGrid:AddField(;
	"RECTMP",;                  // [01]  C   Nome do Campo
	StrZero(nOrdem,2),;                      // [02]  C   Ordem
	"Recno",;                    // [03]  C   Titulo do campo
	"Recno",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	"",;    // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo
    // {'SOLICIT', 'ITEM', 'PRODUTO', 'UM', 'QUANT', 'LOCAL', 'DTNECES', 'FILORI', 'SALDO', 'QTDTRF', 'LOCORI'}

	//Carrega o ModelDef
	oModel  := FWLoadModel('HVP0401')

	//Agora na visualização, carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
	oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:AddField('CAB', oStrCab, 'CABID')
	oView:AddGrid('GRID', oStrGrid, 'GRIDID')
	oView:CreateHorizontalBox('TOHID', 1)
	oView:CreateHorizontalBox('TOSHOW', 99)
	oView:SetOwnerView('CAB' , 'TOHID')
	oView:SetOwnerView('GRID', 'TOSHOW')
	//Agora define o CSS da grid
    oView:SetViewProperty("GRID", "SETCSS", {"QTableWidgetItem { selection-background-color: #FFFF00; selection-color: #FFFFFF; }"} ) 
	oView:SetDescription(cTitle)
Return oView

//Função acionada no bLoad, por se tratar de uma temporária com cabeçalho fake, foi usado FWLoadByAlias para carregar o default e depois adicionar via ponto de entrada
Static Function fCarrGrid(oSubModel)
	Local aReg  := {}

	If ( oSubModel:GetId() == "GRIDID" )
		aReg := FWLoadByAlias(oSubModel,oTempTable:GetAlias(),oTempTable:GetRealName())
	Else
		aReg := {{cKey},0}
	EndIf
Return aReg

/*/{Protheus.doc} User Function zGridGat
Função que será acionada pelo gatilho do campo código para o campo data
@type  Function
@author Atilio
@since 26/05/2022
/*/

User Function zGridGat()
	Local aArea      := FWGetArea()
	Local dDtRetorno := Date()

	FWRestArea(aArea)
Return dDtRetorno

Static Function ValidQtd()

    Local lRet      :=  .T.
    Local oModel1 := FwModelActive()
    Local oModel2 := oModel1:GetModel("GRIDID")
    Local oView1  := FWViewActive()
    // Local nQtLin  := oModel2:GetQtdLine()
    Local nRecAtu   := fwfldget("RECTMP")
    Local nQtdTrf   := &(ReadVar())
    // Local nQtdSA    := fwfldget("QTDOR")
    Local nQtdNe    := fwfldget("QUANT")
    Local nQtdNe2   := 0
	Local nQtdOri   := fwfldget("QTDTRF")
    Local nQtd      := 0
    Local cProd     := fwfldget("PRODUTO")
    Local cItem     := fwfldget("ITEM")
    Local nSaldo    := fwfldget("SALDO")
	Local nRet      := 0
	Local nQtdDig   := 0
	Local nLinAtu := oModel2:GetLine()
	// Local aSaveLines := FWSaveRows()

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + cProd))

	DbSelectArea("SAH")
	SAH->(DbSetOrder(1))
	SAH->(MsSeek(xFilial("SAH") + SB1->B1_UM))

	IF nQtdTrf < 0
		MsgAlert("Só permitido quantidade maior que zero!")
		nRet := nQtdOri
		Return .F.
	ENdif

	// IF SAH->AH_XFRACIO <> "S" .and. (nQtdTrf - INT(nQtdTrf)) > 0
	IF !SAH->AH_XFRACIO .and. (nQtdTrf - INT(nQtdTrf)) > 0
		MsgAlert("Unidade de medida não permite quantidade fracionada!")
		nRet := nQtdOri
		Return .F.
	Endif

	// IF SB1->B1_SEGUM == " " .and.  (nQtdTrf - INT(nQtdTrf)) > 0
	// 	nRet := nQtdOri
	// 	Return .F.
	// Endif

	// IF SB1->B1_SEGUM <> " " .and. SB1->B1_TPCONV == "D" .AND. (nQtdTrf - INT(nQtdTrf)) > 0
	// 	nRet := nQtdOri
	// 	Return .F.
	// Endif


    (cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(Eof())
          
        IF cProd == (cAliasTmp)->PRODUTO .and. cItem == (cAliasTmp)->ITEM   
            IF (cAliasTmp)->RECTMP <> nRecAtu
                nQtd += (cAliasTmp)->QTDTRF
			Else
				nQtdDig := (cAliasTmp)->QTDTRF
            Endif
        Endif
        
        (cAliasTmp)->(DbSkip())
    EndDo

    IF (nQtd + nQtdTrf) > (nQtdNe + nQtd + nQtdDig)
        MsgAlert("Quantidade a ser transferida ultrapassa a quantidade da SA.")
        Return .F.
    Else
        IF nQtdTrf > nSaldo
            MsgAlert("Quantidade a ser transferida ultrapassa o saldo da filial/armazém.")
			Return .F.
        EndIf
    Endif
	
	(cAliasTmp)->(DbGoTo(nRecAtu))

	RecLock(cAliasTmp,.F.)

	IF lRet
		(cAliasTmp)->QTDTRF := nQtdOri
		(cAliasTmp)->(DbGoTop())
		nQtdNe2 := nQtdNe + nQtdDig - nQtdTrf

		nLinha := 1
		While !(cAliasTmp)->(Eof())
			oModel2:GoLine(nLinha)
			
			IF cProd == (cAliasTmp)->PRODUTO .and. cItem == (cAliasTmp)->ITEM   
				// FwFldPut("QUANT",((nQtdSA - nSaldo)-(nQtd + nQtdTrf)),nLinha)
				// (cAliasTmp)->QUANT := (nQtdSA - (nQtdSA - nQtdNe) - (nQtd + nQtdTrf) + nQtdDig)
				(cAliasTmp)->QUANT := nQtdNe2
				oModel2:GoLine(nLinha)
				oModel2:LoadValue("QUANT",(cAliasTmp)->QUANT )
				// oModel2:LoadValue("QTDTRF",(cAliasTmp)->QTDTRF )

			Endif
			
			nLinha++

			(cAliasTmp)->(DbSkip())
		EndDo
		
		oModel2:GoLine(nLinAtu)
	Else
		(cAliasTmp)->QTDTRF := nRet
	Endif

	(cAliasTmp)->(MsUnlock())

	// FWRestRows( aSaveLines )
	// IF (nLinAtu+1) < nQtLin
	// 	oModel2:GoLine(nLinAtu+1)
	// Endif
	// oView1:GoNext()
    oView1:Refresh()

Return lRet


Static Function HVP0401A()
    Local lRet := .T. 

    (cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(Eof())
        //Verifica se já existe na ZCP
        DbSelectArea("ZCP")
        ZCP->(DbSetOrder(2))
        lFndZCP := ZCP->(MsSeek((cAliasTmp)->FILORI + (cAliasTmp)->PRODUTO + (cAliasTmp)->SOLICIT + (cAliasTmp)->ITEM ))

        IF (cAliasTmp)->QTDTRF > 0
            RecLock("ZCP",!lFndZCP)
            ZCP->ZCP_FILIAL  := (cAliasTmp)->FILORI      
            ZCP->ZCP_FILORI  := (cAliasTmp)->FILORI    
            ZCP->ZCP_FILDES  := xFilial("SCP")   
            ZCP->ZCP_NUMSA   := (cAliasTmp)->SOLICIT   
            ZCP->ZCP_ITEM    := (cAliasTmp)->ITEM  
            ZCP->ZCP_PRODUT  := (cAliasTmp)->PRODUTO   

            DbSelectArea("SB1")
            SB1->(MsSeek(xFilial("SB1") + (cAliasTmp)->PRODUTO ))
            ZCP->ZCP_DESCRI  := SB1->B1_DESC

            ZCP->ZCP_UM      := (cAliasTmp)->UM
            ZCP->ZCP_QUANT   := (cAliasTmp)->QTDTRF   
            ZCP->ZCP_SEGUM   := SB1->B1_SEGUM 
            ZCP->ZCP_DATPRF  := (cAliasTmp)->DTNECES
            ZCP->ZCP_LOCAL   := (cAliasTmp)->LOCORI
            ZCP->ZCP_EMISSA  := DDATABASE
            ZCP->ZCP_SOLICI  := RetCodUsr()

            ZCP->(MsUnlock())
        Else
            IF lFndZCP
                RecLock("ZCP",!lFndZCP)
                ZCP->(DbDelete())
                ZCP->(MsUnlock())
            Endif
        Endif
        
        (cAliasTmp)->(DbSkip())
    EndDo
Return lRet

Static Function HVP0401B(oModel)

Return .T.
