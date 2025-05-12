#include 'protheus.ch'
#include 'totvs.ch'
// ----------------------------------------------------------------------------------------------------------------------------
// {Protheus.doc} MNTA115 
// Puxar informa��es de placa + chassi da SN010 para ST9010
// Ponto de entrada que ao converter um bem para veiculo ir� puxar placa + chassi 
// @type function
// @author T-VISON Gabriel Paiva 
// @since 24/02/2025
// @version P12
// ----------------------------------------------------------------------------------------------------------------------------

User Function MNTA1151()
    Local aAtvNBEM  := PARAMIXB[1]
    Local aAreaST9  := GetArea()
    Local x
    Local cCATBEM   := GetMV("MV_CATBEM")
    Local aAreaSN1 := SN1->(GetArea())

    If Len(aAtvNBEM) > 0 .and. !Empty(cCATBEM)

        dbSelectArea("ST9")
        dbSetOrder(1)

        For x:= 1 To Len(aAtvNBEM)
            If dbSeek(xFilial("ST9")+aAtvNBem[x][1] )
                RecLock('ST9',.F.)
                ST9->T9_CATBEM   := cCATBEM
                ST9->(MsUnLock())
                dbSelectArea("SN1")
                SN1->(dbSetOrder(1))
                SN1->(dbSeek(xFilial("SN1")+aAtvNBem[x][1]))
                cPlaca := alltrim(SN1->N1_CHAPA)
                cChassi := alltrim(SN1->N1_CODBAR)
                U_GRAVPLACA(cPlaca,cChassi)
            EndIf
        Next
    EndIf

    RestArea( aAreaST9 )
    RestArea(aAreaSN1)

Return .T.

    User Function GRAVPLACA(cPlaca,cChassi)
dbSelectArea("ST9")
ST9->(dbSetOrder(1))
if ST9->(dbseek(xFilial("ST9")+SN1->N1_CODBEM))
    while (ST9->T9_CODBEM) == (SN1->N1_CODBEM) .and. !Eof ()
        Reclock("ST9", .F. )
        ST9->T9_PLACA := cPlaca
        ST9->T9_CHASSI := cChassi
          ST9->(MsUnLock())
      ST9->(dbSkip())
   EndDo
Endif 
   
Return
