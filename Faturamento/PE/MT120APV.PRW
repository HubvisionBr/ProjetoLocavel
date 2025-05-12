#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include "totvs.ch"

/*/{Protheus.doc} MT120APV 

LOCALIZAÇÃO : Function MT120APV - 
O Ponto de Entrada MT120APV é responsavel pela gravação do grupo de aprovação do Pedido de Compras e/ou Autorização de Entrega.

@type function
@author HUBVISION
@since 23/12/2024

@history 
[Funcionamento]
Ponto de entrada para alterar grupo de aprovação do pedido


*****/

User Function MT120APV()

//Local cGrupoAprov := 'xxxxx'
//Local cPedido  :=  PARAMIXB
// Local ExpC1 := Nil
// Local ExpC2 := Nil
Local cNumC7 := SC7->C7_NUM
// Local cQuery := ""
// Local cAliasNew := GetNextAlias()
//Local cAprov := SC7->C7_APROV
Local cGrp := "" //Grupo de aprovação
Local aAreaSAL := SAL->(getarea())
Local aAreaSC7 := SC7->(getarea())
Local aAreaSB1 := SB1->(getarea())
Local lVeiculo := .F. // produto veiculo vai para um grupo específico de aprovação
Local cGrupo   := GetMv("MV_PCAPROV")
Local cGrpVei  := Getmv("MV_XGRPPRO")
Local aGrpVei  := Separa(cGrpVei,",")
Local nX

If Type("ALTERA") == "U"
    
    ALTERA := .F.

Endif

If Type("INCLUI") == "U"
    
    INCLUI := .F.

Endif

If ALTERA .or. INCLUI
    SC7->(DbSetOrder(1))
    SC7->(MsSeek(xFilial("SC7") + cNumC7 ))

    While SC7->(!EOF()) .and. SC7->C7_NUM == cNumC7 .and. SC7->C7_FILIAL == xFilial("SC7")

        cPosSB1 := POSICIONE("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_GRUPO")
        
        For nX := 1 To Len(aGrpVei)
            If Alltrim(cPosSB1) == aGrpVei[nX]
                lVeiculo := .T. //altera grupo de aprovadores                       
                Exit
            Endif
        Next nX

        SC7->(dbSkip())
    Enddo
    
    If lVeiculo   
        cGrp := getmv("MV_XGRPVEC")
        MsgInfo("Grupo de aprovadores direcionado para o grupo "+getmv("MV_XGRPVEC")+" parametro MV_XGRPVEC." , "Atencao")
    Else
       
        dbSelectArea("SY1")
        SY1->(dbSetOrder(3))
        If SY1->(MsSeek(xFilial()+Retcodusr()))
            If !Empty(SY1->Y1_GRAPROV)
                cGrpSAL := GetAdvFVal("SAL","AL_COD",xFilial("SAL")+SY1->Y1_GRAPROV,2)

                If !Empty(cGrpSAL)
                    cGrupo := SY1->Y1_GRAPROV
                Endif						
            Endif
        EndIf
        
        cGrp := If(Empty(SC7->C7_APROV),cGrupo,SC7->C7_APROV)
    Endif
    
    
Endif

RestArea(aAreaSC7)
RestArea(aAreaSAL)
RestArea(aAreaSB1)

Return cGrp
