#include "protheus.ch"
#include "fwmvcdef.ch"

#define MVC_TITLE "Saldos dos produtos"
#define MVC_ALIAS "SB2"
#define MVC_VIEWDEF_NAME "VIEWDEF.HVP0404"

//-------------------------------------------------------------------
/*/{Protheus.doc} U_MVCGRID
Função principal da rotina MVC

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
user function HVP0404()
//Inserção - Inclusão de itens
// FWExecView( getTitle(MODEL_OPERATION_INSERT), MVC_VIEWDEF_NAME, MODEL_OPERATION_INSERT)

//Visualização - Verificar os itens incluídos
FWExecView( getTitle(MODEL_OPERATION_VIEW), MVC_VIEWDEF_NAME, MODEL_OPERATION_VIEW, , { || .T. }, , 0)

//Alteração - Por ser um grid, a alteração já vai permitir a exclusão
// FWExecView( getTitle(MODEL_OPERATION_UPDATE), MVC_VIEWDEF_NAME, MODEL_OPERATION_UPDATE)

//Visualização - Verificar os itens adicionados, alterados ou excluidos
// FWExecView( getTitle(MODEL_OPERATION_VIEW), MVC_VIEWDEF_NAME, MODEL_OPERATION_VIEW)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} getTitle
Retorna o título para a janela MVC, conforme operação

@param nOperation - Operação do modelo

@return cTitle - String com o título da janela

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function getTitle(nOperation)
local cTitle as char

if nOperation == MODEL_OPERATION_INSERT
    cTitle := "Inclusão"
elseif nOperation == MODEL_OPERATION_UPDATE
    cTitle := "Alteração"
else
    cTitle := "Visualização"
endif

return cTitle

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
oModel := MPFormModel():New("MIDMAIN")

oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| loadHidFld()})

oModel:addGrid("GRIDID", "CABID", oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| loadGrid(oMdl)})

oModel:setDescription(MVC_TITLE)

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
static function loadGrid(oModel)
local aData as array
local cAlias as char
local cWorkArea as char
local cTablename as char
local cWhere as char

cWorkArea := Alias()
cAlias := GetNextAlias()
cTablename := "%" + RetSqlName(MVC_ALIAS) + "%"
cWhere := "%'" + SB1->B1_COD + "'%"

BeginSql Alias cAlias
    SELECT SB2.*, R_E_C_N_O_ AS RECNO
      FROM %exp:cTablename% SB2
    WHERE SB2.%notDel%
    AND SB2.B2_COD    = %exp:cWhere%
    AND SB2.B2_FILIAL <> %exp:xFilial("SB2")%
EndSql

aData := FwLoadByAlias(oModel, cAlias, MVC_ALIAS, "RECNO", /*lCopy*/, .T.)

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
oModel := FWLoadModel("HVP0404")
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
