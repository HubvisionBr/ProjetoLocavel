#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036.CH"

User Function AF036PRC()
    Local aArea := GetArea()
    // Se for baixa e o motivo for venda
    If IsInCallStack("AT36Baixa") .and. FN6->FN6_MOTIVO == "01" 
        // Chama rotina para preparar os dados para o envio ao MOBCOD
        U_UATFE001()
    EndIf
    RestArea(aArea)
Return
 