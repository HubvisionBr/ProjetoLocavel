#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
User Function MT103EXC()

    Local lRet := .T.
    Local aFiliais := FwLoadSM0()
    //Verifica se a exclus�o est� sendo feita manualmente pela rotina de Documento de Entrada
    //E n�o permite se ele tiver origem de uma transfer�ncia

    IF !IsInCallStack("U_REMET")
        dbSelectArea("SA2")
        SA2->(dbSetOrder(1))
        SA2->(dbSeek(xFilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA))
        nPosFil := aScan(aFiliais,{|x| alltrim(x[18]) == Alltrim(SA2->A2_CGC)})

        If nPosFil > 0
            MsgInfo("Nota fiscal de transfer�ncia. Exclua na origem!")
            lRet := .F.
        Endif
    Endif

Return lRet
