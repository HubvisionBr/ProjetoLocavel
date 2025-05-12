#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
/*/{Protheus.doc} FA080TIT 

//PE para não permitir usar bancos (SA6) diferentes do que está no caixinha (SET),
quando for o motivo de baixa do parâmetro MV_XMTCX1

@type function
@author HUBVISION
@since 16/12/2024

@history 
/*/

USER FUNCTION FA080TIT()

local lRet := .T.
local aAreaSEU := SEU->(getarea())
local aAreaSE5 := SE5->(getarea())
local cQuery := ""
// U_F560AUT
// PARAMETRO 1 -> 3 - Inclusao, 4 - Prestacao de Contas, 5 - Exclusao
// PARAMETRO 2 -> 00=Despesa;01=Adiantamento;02=Devolução;10=Mov.Banco/Caixinha;11=Mov.Caixinha/Banco
//Local cbanco := "001" //ParamIXB[1]

If cmotbx $ getmv("MV_XMTCX1")

    oDlg      := Nil
    cSelected := "001"
    
    DEFINE MSDIALOG oDlg TITLE "Seleção de Caixinha";
         FROM 0,0 TO 120,240 OF oMainWnd PIXEL

    @ 02,02 SAY "Selecione uma opção:"
    @ 02,60 GET cSelected PICT "@!" F3 "SET" ;                    // Exibe os índices como opções numéricas
        VALID .T. 

    @ 01,90 BUTTON "OK" ACTION oDlg:End()

    ACTIVATE MSDIALOG oDlg CENTER

    If !empty(cSelected)
    //    MsgInfo("Você selecionou: " + cSelected)
    Else
        MsgStop("Nenhuma opção válida foi selecionada!")
    EndIf

    lRet := .F.

    cPosSET := POSICIONE("SET",1,xFilial("SET")+ cSelected,"ET_CODIGO")
        
        If !empty(cPosSET)

            //lRet := .T.
            lRet := U_F560AUT(3,'00')
            
        Endif 
        
    If !lRet
        
    //    MsgAlert("Atencao o banco nao pode ser utilizado para esse motivo de baixa [CAIXINHA]."+ Chr(13) + Chr(13) + "ALTERE O BANCO OU MOTIVO DE BAIXA.")
    
    Else

        MsgInfo("Caixinha gerado: " + SEU->EU_NUM)
        
        If SE2->(FieldPos("E2_XNUMCX")) > 0 

            Reclock("SE2",.f.)
            Replace E2_XNUMCX with SEU->EU_NUM 
            SE2->(msunlock())

            If TCSQLEXEC(cQuery) < 0

                lRet := .F.
                MsgAlert("Atencao! Ocorreu uma falha na geracao da movimentacao do caixinha. Entre em contato com o suporte.")

            Endif
            
        Endif

    Endif

Endif

Restarea(aAreaSEU)
Restarea(aAreaSE5)

RETURN lRet
