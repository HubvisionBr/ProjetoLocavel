#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function MNTA420P()
    Local cBody := ""
    Local nOPCX := 0
    Local aPergs    := {}
    Local aRet      := {}
    Local cLocal    := Space(6)
    Local cChave    := ""
    Local cQuery    := ""
    Local nRecnoFQ4 := 0
    
    aAdd(aPergs, {1, "Local",  cLocal,  "", ".T.", "SNL", ".T.", 80,  .T.})
    
    // Parâmetro
    // nOPCX := ParamIxb[1] // Inclusão, Alteração ou Exclusão
 
    // If nOPCX == 3 .and. !Empty(M->TJ_CODBEM) .and. !Empty(M->TJ_SERVICO);
    //     .and. Alltrim(M->TJ_SITUACA) == "L" .and. Alltrim(M->TJ_TERCEIR) == "2";
    //     .and. !Empty(STL->TL_CODIGO) .and. Alltrim(STL->TL_TIPOREG) == "T"

        FPA->(DbSetOrder(1))//FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
        If FPA->(DbSeek(xFilial('FPA')+cChave))
            While !FPA->(Eof()) .and. FPA->FPA_FILIAL == FwxFilial("FPA") .and. FPA->FPA_PROJET == cChave        
                // Posição do cursor no bem
                SN1->(DbSetOrder(1))
                If SN1->(DbSeek(xFilial('SN1')+FPA->FPA_GRUA))   
                    // Busca a movimentação
                    cQuery := " SELECT R_E_C_N_O_ as RECNO FROM " + RetSqlName("FQ4")+;
                        " WHERE D_E_L_E_T_ = '' AND FQ4_FILIAL = '"+FwxFilial("FQ4")+"'"+;
                        " AND FQ4_PROJET = '"+FPA->FPA_PROJET+"' AND FQ4_CODBEM = '"+FPA->FPA_GRUA+"' "+;
                        " AND FQ4_STATUS = '20' "

                    If (nRecnoFQ4 := MPSysScalar(cQuery , 'RECNO')) > 0
                        FQ4->(DbGoTo(nRecnoFQ4))
                        // Coleta o local do usuário
                        If ParamBox(aPergs, "Informe os parâmetros",@aRet)
                            cBody := '{'
                            cBody += '    "task": '
                            cBody += '        {'
                            cBody += '        "tsk_active": 1,'
                            cBody += '        "tsk_integrationid": null,'
                            cBody += '        "stn_id": 20,'
                            cBody += '        "age_id": null,'
                            cBody += '        "tea_integrationid": "'+Alltrim(aRet[1])+'",'
                            cBody += '        "tsf_id": 1,'
                            cBody += '        "loc_alternativeidentifier": "'+Alltrim(aRet[1])+'",'
                            cBody += '        "ast_id": null,'
                            cBody += '        "tty_id": 31,'//Movimentação
                            cBody += '        "tsk_scheduleinitialdatehour": "'+Year2Str(date())+"-"+Month2Str(date())+"-"+Day2Str(date())+'T'+time()+'.000Z",'
                            cBody += '        "tsk_schedulefinaldatehour": null,'
                            cBody += '        "tsk_observation": "Cliente: '+AllTrim(FQ4->FQ4_CODCLI)+AllTrim(FQ4->FQ4_LOJCLI)+'-'+AllTrim(FQ4->FQ4_NOMCLI)+'",'
                            cBody += '        "tsk_priority": null,'
                            cBody += '        "tsk_technicalinstruction": null,'
                            cBody += '        "cf_placa": "'+SN1->N1_CHAPA+'",'
                            cBody += '        "cf_chassi": "'+SN1->N1_CODBAR+'",'
                            cBody += '        "cf_tipo": "'+"SAIDA"+'",'
                            cBody += '        "cf_modelo": "'+SN1->N1_DESCRIC+'",'
                            cBody += '        "cf_marca": ""'
                            cBody += '        }'
                            cBody += '}'

                            U_EnvioMobCode(cBody,"task/create")
                        EndIf
                    // Else
                    //     // Mensagem de erro
                    //     MsgInfo("Não existe movimentação de saída para a grua "+FPA->FPA_GRUA+" no projeto "+FPA->FPA_PROJET)   
                    EndIf
                EndIf
                FPA->(DbSkip())
            EndDo
        EndIf
    // EndIf
 
Return .T.
