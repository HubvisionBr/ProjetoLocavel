#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function MNTA470() 
    Local aParam    := PARAMIXB
    Local oObj      := ''
    Local cIdPonto  := ''
    Local cIdModel  := ''
    Local lRetorno  := .T.
    Local aArea := TPN->(GetArea())
    Local nOpc      := 0
 
    If aParam <> NIL
        oObj            := aParam[1]
        cIdPonto        := aParam[2]
        cIdModel     := aParam[3]
        
        If cIdPonto == 'MODELCOMMITTTS'
            nOpc  := oObj:GetOperation()
            If nOpc == 3 // Inclusão
                SN1->(DbSetOrder(1))
                If SN1->(DbSeek(xFilial('SN1')+ST9->T9_CODBEM))  
                    // Posiona ba tabela SHB
                    SHB->(DbSetOrder(2))//HB_FILIAL+HB_CC
                    If SHB->(DbSeek(xFilial('SHB')+PADR(ST9->T9_CCUSTO,TamSx3("HB_CC")[1])))
                        // Envia saída para o mobcode
                        U_enviaTrans(SHB->HB_XMOBCOD,"SAIDA")
                        // Posiona ba tabela SHB novamente
                        SHB->(DbSetOrder(2))//HB_FILIAL+HB_CC
                        If SHB->(DbSeek(xFilial('SHB')+PADR(oObj:GetValue('TPN_CCUSTO'),TamSx3("HB_CC")[1])))
                            // Envia entrada para o mobcode
                            U_enviaTrans(SHB->HB_XMOBCOD,"ENTRADA")
                        EndIf
                    EndIf
                Else
                    MsgStop("Bem não cadastrado na tabela SN1 na filial "+xFilial('SN1')+".","Atenção")
                EndIf                
            EndIf
        EndIF
 
    EndIf
    RestArea(aArea)
 
Return lRetorno
