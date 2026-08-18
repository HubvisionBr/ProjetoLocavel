#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function GERREMFIM()
    Local cBody := ""
    Local aPergs    := {}
    Local aRet      := {}
    Local cLocal    := Space(6)
    Local cChave    := FPA->FPA_PROJET
    Local aAreaFPA  := FPA->(GetArea())
    Local aAreaFP0  := FP0->(GetArea())
    
    aAdd(aPergs, {1, "Local",  cLocal,  "", ".T.", "SNL", ".T.", 80,  .T.})

    FP0->(DbSetOrder(1))
    FP0->(DbSeek(xFilial('FP0')+cChave))

    FPA->(DbSetOrder(1))//FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
    If FPA->(DbSeek(xFilial('FPA')+cChave))
        While !FPA->(Eof()) .and. FPA->FPA_FILIAL == FwxFilial("FPA") .and. FPA->FPA_PROJET == cChave        
            // Posição do cursor no bem
            SN1->(DbSetOrder(1))
            If SN1->(DbSeek(xFilial('SN1')+FPA->FPA_GRUA))   
                // Busca a movimentação
                ST9->(DbSetOrder(Order))
                If ST9->(DbSeek(xFilial('ST9')+FPA->FPA_GRUA))
                    If ST9->T9_STATUS == "20"
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
                            cBody += '        "tsk_observation": "Cliente: '+AllTrim(FP0->FP0_CLI)+AllTrim(FP0->FP0_LOJA)+'-'+AllTrim(FP0->FP0_CLINOM)+'",'
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
                    EndIf
                EndIf
            EndIf
            FPA->(DbSkip())
        EndDo
    EndIf
    RestArea(aAreaFPA)
    RestArea(aAreaFP0)
Return .T.
