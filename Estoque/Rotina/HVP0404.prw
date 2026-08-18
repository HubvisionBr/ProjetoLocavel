#include "protheus.ch"
#include "fwmvcdef.ch"

#define MVC_TITLE "Saldo Geral dos Produtos"
#define MVC_ALIAS "SB2"
#define MVC_VIEWDEF_NAME "VIEWDEF.HVP0404"

/*/{Protheus.doc} U_MVCGRID
Função principal da rotina MVC
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
User function HVP0404()
//Inserção - Inclusão de itens
// FWExecView( getTitle(MODEL_OPERATION_INSERT), MVC_VIEWDEF_NAME, MODEL_OPERATION_INSERT)

//Visualização - Verificar os itens incluídos
FWExecView( getTitle(MODEL_OPERATION_VIEW), MVC_VIEWDEF_NAME, MODEL_OPERATION_VIEW, , { || .T. }, , 0)

//Alteração - Por ser um grid, a alteração já vai permitir a exclusão
// FWExecView( getTitle(MODEL_OPERATION_UPDATE), MVC_VIEWDEF_NAME, MODEL_OPERATION_UPDATE)

//Visualização - Verificar os itens adicionados, alterados ou excluidos
// FWExecView( getTitle(MODEL_OPERATION_VIEW), MVC_VIEWDEF_NAME, MODEL_OPERATION_VIEW)
return

/*/{Protheus.doc} getTitle
Retorna o título para a janela MVC, conforme operação
@param nOperation - Operação do modelo
@return cTitle - String com o título da janela
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
Static Function getTitle(nOperation)

Local cTitle as char

if nOperation == MODEL_OPERATION_INSERT
    cTitle := "Inclusão"
elseif nOperation == MODEL_OPERATION_UPDATE
    cTitle := "Alteração"
else
    cTitle := "Visualização"
endif

return cTitle

/*/{Protheus.doc} ModelDef
Montagem do modelo dados para MVC
@return oModel - Objeto do modelo de dados
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
Static Function ModelDef()

Local oModel    as object
Local oStrField as object
Local oStrGrid  as object

// Estrutura Fake de Field
oStrField := FWFormModelStruct():New()
oStrField:addTable("", {"C_STRING1"}, MVC_TITLE, {|| ""})
oStrField:addField("String 01", "Campo de texto", "C_STRING1", "C", 15)

//Estrutura de Grid, alias Real presente no dicionário de dados
// oStrGrid := FWFormStruct(1, MVC_ALIAS)
oStrGrid := FWFormStruct(1, MVC_ALIAS, {|x| Alltrim(x) + ";" $ "B2_FILIAL;B2_COD;B2_LOCAL;B2_QATU;"}) // Ajuste para exibir apenas Campos específicos na Tela MVC - 20260605 - HC
oStrGrid:AddField("Desc. Filial", "Descrição da Filial", "B2_DESCFIL", "C", 40, 0, , , , .F., , .F., , .T.)
oModel := MPFormModel():New("MIDMAIN")
oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| loadHidFld()})
oModel:addGrid("GRIDID", "CABID", oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| loadGrid(oMdl)})
oModel:setDescription(MVC_TITLE)

// É necessário que haja alguma alteração na estrutura Field
oModel:setActivate({ |oModel| onActivate(oModel)})

Return oModel

/*/{Protheus.doc} onActivate
Função estática para o activate do model
@param oModel - Objeto do modelo de dados
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
static function onActivate(oModel)

//Só efetua a alteração do campo para inserção
if oModel:GetOperation() == MODEL_OPERATION_INSERT
    FwFldPut("C_STRING1", "FAKE" , /*nLinha*/, oModel)
endif

Return

/*/{Protheus.doc} loadGrid
Função estática para efetuar o load dos dados do grid
@param oModel - Objeto do modelo de dados
@return aData - Array com os dados para exibição no grid
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
Static Function loadGrid(oModel)

Local aData      as array
Local cAlias     as char
Local cWorkArea  as char
Local cTablename as char
Local cWhere     as char

cWorkArea  := Alias()
cAlias     := GetNextAlias()
cTablename := "%" + RetSqlName(MVC_ALIAS) + "%"
cWhere     := "%'" + SB1->B1_COD + "'%"

BeginSql Alias cAlias
    SELECT SB2.*, SB2.R_E_C_N_O_ AS RECNO, M0_FILIAL AS B2_DESCFIL
      FROM %exp:cTablename% SB2
      INNER JOIN SYS_COMPANY FIL ON B2_FILIAL = M0_CODFIL
      AND FIL.M0_CODIGO = %exp:cEmpAnt%
      AND FIL.%notDel%
    WHERE SB2.%notDel%
    AND SB2.B2_COD    = %exp:cWhere%
    AND SB2.B2_FILIAL <> %exp:xFilial("SB2")%
    AND SB2.B2_QATU > 0
EndSql

aData := FwLoadByAlias(oModel, cAlias, MVC_ALIAS, "RECNO", /*lCopy*/, .T.)

(cAlias)->(DBCloseArea())

if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
    DBSelectArea(cWorkArea)
endif

return aData

/*/{Protheus.doc} loadHidFld
Função estática para load dos dados do field escondido
@param oModel - Objeto do modelo de dados
@return Array - Dados para o load do field do modelo de dados
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
Static Function loadHidFld(oModel)
Return {""}

/*/{Protheus.doc} ViewDef
Função estática do ViewDef
@return oView - Objeto da view, interface
@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
Static Function viewDef()
local oView as object
local oModel as object
local oStrCab as object
local oStrGrid as object

// Estrutura Fake de Field
oStrCab := FWFormViewStruct():New()
oStrCab:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

//Estrutura de Grid
//oStrGrid := FWFormStruct(2, MVC_ALIAS )
oStrGrid := FWFormStruct(2, MVC_ALIAS, {|x| Alltrim(x) + ";" $ "B2_FILIAL;B2_COD;B2_LOCAL;B2_QATU;"} )
oStrGrid:AddField("B2_DESCFIL", "01A", "Desc. Filial", "Descrição da Filial", , "C")
oModel   := FWLoadModel("HVP0404")
oView    := FwFormView():New()

oView:setModel(oModel)
oView:addField("CAB", oStrCab, "CABID")
oView:addGrid("GRID", oStrGrid, "GRIDID")
oView:createHorizontalBox("TOHIDE", 0 )
oView:createHorizontalBox("TOSHOW", 100 )
oView:setOwnerView("CAB", "TOHIDE" )
oView:setOwnerView("GRID", "TOSHOW")

oView:setDescription( MVC_TITLE )

Return oView
