#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

User Function ATFA060()

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

		If cIdPonto == 'MODELPOS'
            // Pega o modelo SNLMASTER
            oModelx := oObj:GetModel("GridFNR")
            // Envia na inclusão
            If oModelx:GetOperation() == MODEL_OPERATION_UPDATE
                // Chama a função que envia local para o mobcode
                enviaTrans(oModelx)
            EndIf
		EndIf
	EndIf
Return xRet

Static Function enviaTrans(oModelx)
    Local cBody := ""
    Local i := 0

    For i :=1 to 2
        SN1->(DbSetOrder(1))
        If SN1->(DbSeek(xFilial('SN1')+oModelx:GetValue("FNR_CBADES")))            
            // Cria o corpo JSON
            cBody := '{'
            cBody += '    "task": '
            cBody += '        {'
            cBody += '        "tsk_active": 1,'
            cBody += '        "tsk_integrationid": null,'
            cBody += '        "stn_id": 30,'
            cBody += '        "age_id": null,'
            cBody += '        "tea_integrationid": "'+Iif(i==1,oModelx:GetValue("FNR_LOCORI"),oModelx:GetValue("FNR_LOCDES"))+'",'//Enviar codigo do time do mesmo campo de local
            cBody += '        "tsf_id": 1,'
            cBody += '        "loc_alternativeidentifier": "'+Iif(i==1,oModelx:GetValue("FNR_LOCORI"),oModelx:GetValue("FNR_LOCDES"))+'",'//Enviar código vindo do campo novo de lista
            cBody += '        "ast_id": null,'
            cBody += '        "tty_id": 33,'//Tranferencia
            cBody += '        "tsk_scheduleinitialdatehour": "'+Year2Str(date())+"-"+Month2Str(date())+"-"+Day2Str(date())+'T'+time()+'.000Z",'
            cBody += '        "tsk_schedulefinaldatehour": null,'
            // cBody += '        "tsk_observation": "Chassi - '+SN1->N1_CHASSIS+'",'
            cBody += '        "tsk_observation": "TRANSFERENCIA DE FILIAL",'
            cBody += '        "tsk_priority": null,'
            cBody += '        "tsk_technicalinstruction": null,'
            cBody += '        "cf_placa": "'+SN1->N1_CHAPA+'",'
            cBody += '        "cf_chassi": "'+SN1->N1_CODBAR+'",'
            cBody += '        "cf_tipo": "'+Iif(i==1,"SAIDA","ENTRADA")+'",'
            cBody += '        "cf_modelo": "'+SN1->N1_DESCRIC+'",'
            cBody += '        "cf_marca": ""'
            cBody += '        }'
            cBody += '}'
        EndIf

        U_EnvioMobCode(cBody,"task/create")
    Next
Return
