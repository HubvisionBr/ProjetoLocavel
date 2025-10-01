#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function ATFA025()

	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ''
	Local oModelx := ''
	Local cIdPonto := ''
	Local cIdModel := ''

	If aParam <> NIL

		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		If cIdPonto == 'MODELCOMMITTTS'
            // Pega o modelo SNLMASTER
            oModelx := oObj:GetModel("SNLMASTER")
            // Envia na inclusão
            If oModelx:GetOperation() == MODEL_OPERATION_INSERT
                // Chama a função que envia local para o mobcode
                // enviaLocal(oModelx)
            EndIf
		EndIf
	EndIf
Return xRet

Static Function enviaLocal(oModelx)
    Local cBody := ""

    // Cria o corpo JSON
    cBody := '{'
    cBody += '    "data": ['
    cBody += '        {'
    cBody += '        "tsk_active": 1,'
    cBody += '        "tsk_integrationid": null,'
    cBody += '        "stn_id": 30,'
    cBody += '        "age_id": null,'
    cBody += '        "tea_integrationid": '+cTeam+','//Enviar codigo do time do mesmo campo de local
    cBody += '        "tsf_id": 1,'
    cBody += '        "loc_integrationid": '+cLoca+','//Enviar código vindo do campo novo de lista
    cBody += '        "ast_id": null,'
    cBody += '        "tty_id": 32,'
    cBody += '        "tsk_scheduleinitialdatehour": "'+Year2Str(date())+"-"+Month2Str(date())+"-"+Day2Str(date())+'T'+time()+'.000Z",'
    cBody += '        "tsk_schedulefinaldatehour": null,'
    // cBody += '        "tsk_observation": "Chassi - '+SN1->N1_CHASSIS+'",'
    cBody += '        "tsk_observation": "Chassi - '+SD1->D1_CHASSI+'",'
    cBody += '        "tsk_priority": null,'
    cBody += '        "tsk_technicalinstruction": null'
    cBody += '        }'
    cBody += '    ]'
    cBody += '}'

    U_EnvioMobCode(cBody)
Return
