#Include 'Protheus.ch'

/*/{Protheus.doc} MNTA7662
description Ponto de Entrada para adicionar Botão na Rotina MNTA766 (Notificações)
@type function
@version 1.0
@author HC
@since 05/12/2025
@return aRotina
/*/

User Function MNTA7662()
    
    Local aRotina := {}
 
    If ValType(ParamIxb) == "A"
        aRotina := ParamIXB[1]
    EndIf
 
    aAdd(aRotina,{"Histórico Contratos"      ,"LOCA224()",0,4})
    aAdd(aRotina,{"Imprime Notificação/Multa","U_M7662REL()",0,9})
 
Return aRotina
User Function M7662REL()
    If ExistBlock("UFATR003")
//        If MsgYesNo("Deseja imprimir o relatório de Multa e Notificação?")
             U_UFATR003()
//        EndIf
    Else
        MsgStop("Rotina de Impressão não localizada. Contate o Administrador do Protheus","Atenção!")
    EndIf
Return
