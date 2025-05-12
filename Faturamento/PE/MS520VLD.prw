#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.ch"
#INCLUDE "FWMVCDEF.CH"

User Function MS520VLD()
    Local aAreaSF2 := SF2->(GetArea())
    Local aAreaSD2 := SD2->(GetArea())
    //Estorna documento de remessa
    Local cNota   := SF2->F2_DOC
	Local cSerie  := SF2->F2_SERIE
	Local cCliente:= SF2->F2_CLIENTE
	Local cLojaCli:= SF2->F2_LOJA
    Local lRet := .T.

	FWMsgRun(, {|| U_REMET(cNota,cSerie,cCliente,cLojaCli,5)}, "Processando nota", "Aguarde...")

    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
Return lRet
