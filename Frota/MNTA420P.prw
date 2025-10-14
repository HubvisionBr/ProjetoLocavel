#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function MNTA420P()
    Local cBody := ""
    Local nOPCX := 0
    Local aPergs    := {}
    Local aRet      := {}
    Local cLocal    := Space(6)
    
    aAdd(aPergs, {1, "Local",  cLocal,  "", ".T.", "SNL", ".T.", 80,  .T.})
    
    // Parâmetro
    nOPCX := ParamIxb[1] // Inclusão, Alteração ou Exclusão
 
    If nOPCX == 3 .and. !Empty(M->TJ_CODBEM) .and. !Empty(M->TJ_SERVICO);
        .and. Alltrim(M->TJ_SITUACA) == "L" .and. Alltrim(M->TJ_TERCEIR) == "2";
        .and. !Empty(STL->TL_CODIGO) .and. Alltrim(STL->TL_TIPOREG) == "T"
        // Posição do cursor no bem
        SN1->(DbSetOrder(1))
        If SN1->(DbSeek(xFilial('SN1')+M->TJ_CODBEM))   
            // Coleta o local do usuário
            If ParamBox(aPergs, "Informe os parâmetros",@aRet)
                cBody := '{'
                cBody += '    "task": '
                cBody += '        {'
                cBody += '        "tsk_active": 1,'
                cBody += '        "tsk_integrationid": null,'
                cBody += '        "stn_id": 30,'
                cBody += '        "age_id": null,'
                cBody += '        "tea_integrationid": "'+Alltrim(aRet[1])+'",'
                cBody += '        "tsf_id": 1,'
                cBody += '        "loc_alternativeidentifier": "'+Alltrim(aRet[1])+'",'
                cBody += '        "ast_id": null,'
                cBody += '        "tty_id": 34,'//terceiro
                cBody += '        "tsk_scheduleinitialdatehour": "'+Year2Str(date())+"-"+Month2Str(date())+"-"+Day2Str(date())+'T'+time()+'.000Z",'
                cBody += '        "tsk_schedulefinaldatehour": null,'
                cBody += '        "tsk_observation": "FORNECEDOR: '+AllTrim(STL->TL_CODIGO)+'-'+NOMINSBRW(STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_LOJA)+' PLACA: '+AllTrim(SN1->N1_CHAPA)+' CHASSI: '+AllTrim(SN1->N1_CODBAR)+'",'
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
        Else
            MsgStop("Bem não encontrado: "+M->TJ_CODBEM)
        EndIf
    EndIf
 
Return .T.
