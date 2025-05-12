#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
#include "parmtype.ch"
#Include "TBICODE.CH"
#include "vkey.ch"


User Function MT100LOK()
    Local nPosPrd := ascan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_COD"})
    Local cChassi := aCols[n][aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_CHASSI"})]
    // Local dValid := aCols[n][aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_DTVALID"})]
	Local cProduto := ""
    Local cGrpVei := SuperGetMv("HV_GPVEIC",,"0501")
	Local bRet := .T.
    Local aAreaSBM := SBM->(GetArea())
    Local aAreaSB1 := SB1->(GetArea())

    If nPosPrd > 0
        cProduto := aCols[n][nPosPrd]
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(MsSeek(xFilial("SB1") + cProduto))

        IF SB1->B1_GRUPO $ cGrpVei .and. cTipo == "N" //Se o tipo for normal e o grupo de produto for veículo
            If Empty(cChassi)
                bRet := .F.
                If IsBlind()
                    ConOut("MT100LOK - Informe o chassi")
                Else
                    MsgInfo("MT100LOK - Informe o chassi")
                Endif
            Endif
        ENdif
    Endif

    RestArea(aAreaSBM)
    RestArea(aAreaSB1)

Return bRet
