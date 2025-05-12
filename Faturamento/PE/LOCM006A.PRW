#INCLUDE "TOPCONN.CH"                                                                                                  
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
                                                                                                     
//-------------------------------------------------------------------
/*/{Protheus.doc}   LOCM006A
@description        Ponto de entrada ao final da gravação do pedido de vendas
@author             Gabriel Paiva  - Tvision
@since              10/03/2025
/*/
//------------------------------------------------------------------
User Function LOCM006A()

Local aAreaSC5 := SC5->(GetArea())
Local aAreaFP0 := FP0->(GetArea())
Local aAreaFPY := FPY->(GetArea())
    
cBanco := alltrim(C5_XBANCO)
cAgenc := alltrim(C5_XAGENC)
cConta := alltrim(C5_XCONTA)


U_BANCFP0(cBanco,cAgenc,cConta)


    RestArea(aAreaSC5)
    RestArea(aAreaFP0)
    RestArea(aAreaFPY)

RETURN .T.



User Function BANCFP0(cBanco, cAgenc, cConta)
    DbSelectArea("SC5")
    DbSetOrder(1)

    If DbSeek(xFilial("SC5") + FPY->FPY_PROJET)
        If (C5_NUM == FPY->FPY_PEDVEN)
            
            RecLock("SC5", .F.)  
            
            DbSelectArea("FP0")
            DbSetOrder(1)
            If DbSeek(xFilial("FP0") + FPY->FPY_PROJET)
                RecLock("FP0", .F.)  
                FPO->FPO_XBANCO := cBanco
                FPO->FPO_XAGENC := cAgenc
                FPO->FPO_XCONTA := cConta
                MsUnlock()  
            EndIf
            MsUnlock()  
        EndIf
    EndIf

    RETURN

/* 

DbSelectArea('SB1')
SB1->(DbSetOrder(1)) // Filial + Código 
//Se conseguir posicionar no produto
If SB1->(DbSeek(FWxFilial('SB1') + "COD_AAA"))
    RecLock('SB1', .F.)
        SB1->B1_X_CAMPO := "AAA"
    SB1->(MsUnlock())
EndIf

*/
