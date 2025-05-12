#INCLUDE 'Rwmake.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'TbIconn.ch'
#INCLUDE 'Topconn.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980P
Ponto Entrada MVC para nova rotina de Cadastro de Clientes
@author  Jerry Junior
@since   01/04/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function CRMA980()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oModel := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.

    If aParam <> NIL
        oModel   := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := (Len(aParam) > 3)
 
        If INCLUI .And. cIdPonto == "MODELCOMMITTTS"
            RecLock("CTD",.T.)

            cItemcont := "CLI" + SA1->A1_COD + SA1->A1_LOJA

            Replace CTD_FILIAL With xFilial("CTD") , ;
                    CTD_ITEM   With cItemcont      , ;
                    CTD_DESC01 With SA1->A1_NOME   , ;
                    CTD_CLASSE With "2"            , ;
                    CTD_NORMAL With "0"            , ;
                    CTD_DTEXIS With ctod("01/01/1980") , ;
                    CTD_BLOQ   With '2'
            CTD->(MsUnlock())

            RecLock("SA1",.F.)
            SA1->A1_XITEMCC := cItemcont
            SA1->(MsUnlock())
        EndIf
    EndIf



Return xRet
