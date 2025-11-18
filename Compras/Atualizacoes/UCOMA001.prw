#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Aprova Doc. Entrada"
 
// Área de trabalho
User Function UCOMA001()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de integração CobCloud
    oBrowse:SetAlias("ZZV")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "ZZV->ZZV_STATUS == 'A'", "GREEN", "Aprovado" )
    oBrowse:AddLegend( "ZZV->ZZV_STATUS == 'B'", "RED",    "Bloqueado" )
     
    //Ativa a Browse
    oBrowse:Activate()
Return Nil

// Define o Menu
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.UCOMA001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Aprovar'    ACTION 'u_COMA001A'     OPERATION 6                      ACCESS 0 //OPERATION X
    // ADD OPTION aRot TITLE 'Processar'    ACTION 'u_FINA001B'     OPERATION 6                      ACCESS 0 //OPERATION X
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
// Define o modelo de dados
Static Function ModelDef()
    Local oModel         := Nil
    Local oFldZZV         := FWFormStruct(1, 'ZZV')
     
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('MDLZZV')
    oModel:AddFields('ZZVMASTER',/*cOwner*/,oFldZZV)

     // Configura a chave primária do modelo para a tabela ZZVMASTER
    oModel:GetModel("ZZVMASTER"):SetPrimaryKey({"ZZV_FILIAL", "ZZV_CHAVE"})
     
    //Setando as descrições
    oModel:SetDescription(cTitulo)
    oModel:GetModel('ZZVMASTER'):SetDescription('Modelo Grupo')
     
Return oModel

// Define a View
Static Function ViewDef()
    Local oView        := Nil
    Local oModel        := FWLoadModel('UCOMA001')
    Local oFldZZV        := FWFormStruct(2, 'ZZV')
    //Estruturas das tabelas e campos a serem considerados
    // Local aStruZZV    := ZZV->(DbStruct())
    // Local nAtual        := 0
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_ZZV',oFldZZV,'ZZVMASTER')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',100)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZZV','CABEC')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_ZZV',cTitulo)
     
Return oView

// Excuta Aprovação
User Function COMA001A()
    If ZZV->ZZV_STATUS == "A"
        If MsgYesNo("O item se encontra Aprovado, gostaria de bloquear?")
            If RecLock('ZZV',.F.)
                ZZV->ZZV_STATUS := "B"
                ZZV->(MsUnlock())
            EndIf
            MsgInfo("Item bloqueado com sucesso.")
        Else
            MsgInfo("Cancelado pelo usuário.")
        EndIf
    Else
        If MsgYesNo("O item se encontra Bloqueado, gostaria de Aprovar?")
            If RecLock('ZZV',.F.)
                ZZV->ZZV_STATUS := "A"
                ZZV->(MsUnlock())
            EndIf
            MsgInfo("Item Aprovado com sucesso.")
        Else
            MsgInfo("Cancelado pelo usuário.")
        EndIf
    EndIf
Return 

