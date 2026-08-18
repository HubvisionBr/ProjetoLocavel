#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"

User Function SF2460I()
    Local aArea    := GetArea()
    Local cNota    := SF2->F2_DOC
    Local cSerie   := SF2->F2_SERIE
    Local cCliente := SF2->F2_CLIENTE
    Local cLojaCli := SF2->F2_LOJA
    Local cChave   := SF2->F2_CHVNFE // Captura a Chave da NFe da nota de saída

    // Passa a chave da NFe como 6º parâmetro
    FWMsgRun(, {|| U_REMET(cNota, cSerie, cCliente, cLojaCli, 3, cChave)}, "Processando nota", "Aguarde...")
    
    RestArea(aArea)
Return

User Function REMET(cNota, cSerie, cCliente, cLojaCli, nOpc, cChaveNfe)
    Local aArea    := GetArea()
    Local aItemNF  := {}
    Local aLinha   := {}
    Local aCabNF   := {}
    Local aFiliais := FwLoadSM0()
    Local nPosFil  := 0
    Local cTes     := ""
    Local cCodFor  := ""
    Local cLojFor  := ""
    Local cOper    := ""
    Local cFilBkp  := cFilAnt
    Local lOk      := .F. // Variável para retornar se o processo deu certo

    Default cChaveNfe := ""
    
    Begin Transaction

    IF SF2->F2_TIPO == 'N'

        // Verifica a filial do cliente
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))
        SA1->(dbSeek(xFilial("SA1") + cCliente + cLojaCli))
        nPosFil := aScan(aFiliais, {|x| AllTrim(x[18]) == AllTrim(SA1->A1_CGC)})

        IF nPosFil > 0
            dbSelectArea("SA2")
            SA2->(dbSetOrder(3)) // CNPJ
            SA2->(dbSeek(xFilial("SA2") + SM0->M0_CGC))
            If Found()
                cCodFor := SA2->A2_COD
                cLojFor := SA2->A2_LOJA 
            Else
                MsgAlert("Filial de origem " + AllTrim(SM0->M0_CODFIL) + " - " + AllTrim(SM0->M0_FILIAL) + " não cadastrada como fornecedor!")
                DisarmTransaction()
                RestArea(aArea)
                Return .F.
            Endif

            IF aFiliais[nPosFil][2] <> cFilAnt // Se a filial de destino é diferente da origem

                // ************************************************
                // Cabeçalho da ExecAuto
                // ************************************************
                aCabNF := {;
                    {"F1_TIPO"    , "N"             , NIL},;
                    {"F1_FORMUL"  , "N"             , NIL},;
                    {"F1_DOC"     , cNota           , NIL},;
                    {"F1_SERIE"   , cSerie          , NIL},;
                    {"F1_EMISSAO" , SF2->F2_EMISSAO , NIL},;
                    {"F1_FORNECE" , cCodFor         , NIL},;
                    {"F1_LOJA"    , cLojFor         , NIL},;
                    {"F1_COND"    , SF2->F2_COND    , NIL},;
                    {"F1_CHVNFE"  , cChaveNfe       , NIL},;
                    {"F1_ESPECIE" , "NF"            , NIL};
                }

                cFilAnt := aFiliais[nPosFil][2] // Troca contexto para a Filial de Destino para validações de existência de SF1

                // POSICIONAMENTO CORRETO NA SF1
                dbSelectArea("SF1")
                SF1->(dbSetOrder(1))

                If (!SF1->(dbSeek(xFilial("SF1") + cNota + cSerie + cCodFor + cLojFor + "N")) .and. nOpc == 3) .or. ;
                   (SF1->(dbSeek(xFilial("SF1") + cNota + cSerie + cCodFor + cLojFor + "N")) .and. nOpc == 5)

                    If !ApMsgYesNo("Será " + IIF(nOpc == 3, "gerada", "excluída") + " a Nota de Entrada " + ALLTRIM(cNota) + " série " + ALLTRIM(cSerie) + ". Confirma ?", "Atenção")
                        cFilAnt := cFilBkp
                        DisarmTransaction()
                        RestArea(aArea)
                        Return .F.
                    Endif
                Else
                    IF nOpc == 3
                        MsgInfo("Nota Fiscal " + AllTrim(cNota) + " Serie " + AllTrim(cSerie) + " já existe na base de dados da filial " + cFilAnt + ". Verifique...", "Informação")
                        cFilAnt := cFilBkp
                        DisarmTransaction()
                        RestArea(aArea)
                        Return .F.
                    Endif
                Endif

                cFilAnt := cFilBkp // Retorna para Filial Origem para ler SD2

                // ************************************************
                // Monta array dos itens da nota
                // ************************************************
                aItemNF := {}
                
                dbSelectArea("SD2")
                SD2->(dbSetOrder(3))
                if SD2->(dbSeek(xFilial("SD2") + cNota + cSerie))
                    
                    cOper := SuperGetMv("LC_TRANSFI", , "")

                    While SD2->(!Eof()) .and. (cNota + cSerie) == (SD2->D2_DOC + SD2->D2_SERIE)
                        
                        // Mudança crucial: Posiciona o Produto e calcula TES NO CONTEXTO DA FILIAL DE DESTINO
                        cFilAnt := aFiliais[nPosFil][2]

                        DbSelectArea("SB1")
                        SB1->(DbSetOrder(1))
                        If !SB1->(MsSeek(xFilial("SB1") + SD2->D2_COD))
                            MsgStop("Produto " + SD2->D2_COD + " não encontrado na filial de destino (" + cFilAnt + ")!")
                            cFilAnt := cFilBkp
                            DisarmTransaction()
                            RestArea(aArea)
                            Return .F.
                        EndIf

                        // Garante estrutura da SB2 na filial de destino
                        CriaSb2(SB1->B1_COD, SB1->B1_LOCPAD)
                        
                        // Calcula TES Inteligente no Destino
                        cTes := MaTesInt(1, cOper, cCodFor, cLojFor, "F", SB1->B1_COD, Nil)

                        cFilAnt := cFilBkp // Volta temporariamente para ler dados do SD2 se necessário

                        // Montagem da linha com o D1_ITEM incluso
                        aLinha := {}
                        AADD(aLinha, {"D1_ITEM"   , SD2->D2_ITEM   , NIL}) // Campo OBRIGATÓRIO adicionado
                        AADD(aLinha, {"D1_COD"    , SD2->D2_COD    , NIL})
                        AADD(aLinha, {"D1_LOCAL"  , SB1->B1_LOCPAD , NIL})
                        AADD(aLinha, {"D1_UM"     , SD2->D2_UM     , NIL})
                        AADD(aLinha, {"D1_VUNIT"  , SD2->D2_PRCVEN , NIL})
                        AADD(aLinha, {"D1_QUANT"  , SD2->D2_QUANT  , NIL})
                        AADD(aLinha, {"D1_TOTAL"  , SD2->D2_TOTAL  , NIL})
                        AADD(aLinha, {"D1_OPER"   , cOper          , NIL})
                        AADD(aLinha, {"D1_TES"    , cTes           , NIL})
                        AADD(aLinha, {"D1_LOTECTL", SD2->D2_LOTECTL, NIL})
                        AADD(aLinha, {"D1_NUMLOTE", SD2->D2_NUMLOTE, NIL})
                        AADD(aLinha, {"D1_DTVALID", SD2->D2_DTVALID, NIL})

                        aAdd(aItemNF, aClone(aLinha))

                        SD2->(dbSkip())
                    EndDo
                Endif

                lMsErroAuto := .F.

                IF Len(aItemNF) > 0
                    // Altera contexto para a filial de destino para executar a inclusão
                    cFilAnt := aFiliais[nPosFil][2]

                    // Executa a inclusão da NF de Entrada
                    MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCabNF, aItemNF, nOpc)

                    If lMsErroAuto
                        MostraErro()
                        DisarmTransaction()
                        lOk := .F.
                    Else
                        lOk := .T.
                        IF nOpc == 3
                            MsgBox("Nota Fiscal de Entrada criada com sucesso na filial " + cFilAnt + " - Número: " + cNota + " / Série: " + cSerie, "A T E N Ç Ã O", "INFO")
                        ElseIf nOpc == 5
                            MsgBox("Nota Fiscal de Entrada estornada com sucesso na filial " + cFilAnt + " - Número: " + cNota + " / Série: " + cSerie, "A T E N Ç Ã O", "INFO")
                        Endif
                    EndIf
                Endif
                
                cFilAnt := cFilBkp // Restaura a filial de origem ao finalizar
            Endif
        Endif
    Endif

    End Transaction
    
    RestArea(aArea)
Return lOk
