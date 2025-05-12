#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"

User Function SF2460I
	Local aArea := GetArea()
	Local cNota   := SF2->F2_DOC
	Local cSerie  := SF2->F2_SERIE
	Local cCliente:= SF2->F2_CLIENTE
	Local cLojaCli:= SF2->F2_LOJA

	FWMsgRun(, {|| U_REMET(cNota,cSerie,cCliente,cLojaCli,3)}, "Processando nota", "Aguarde...")
	
    RestArea(aArea)

Return

User Function REMET(cNota,cSerie,cCliente,cLojaCli,nOpc,cChaveNfe)
	Local aArea := GetArea()
	// Local cCGCFor
	Local aItemNF := {}
	Local aLinha  := {}
	Local aFiliais := FwLoadSM0()
	Local nPosFil
	Local cTes := ""
	Local lValida := .F.
	Default cChaveNfe := ""
	
	Begin Transaction

	IF SF2->F2_TIPO == 'N'

		//Verifica a filial do cliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+ cCliente + cLojaCli))
		nPosFil := aScan(aFiliais,{|x| alltrim(x[18]) == Alltrim(SA1->A1_CGC)})

		IF nPosFil > 0
			dbSelectArea("SA2")
			SA2->(dbSetOrder(3)) //CNPJ
			SA2->(dbSeek(xFilial("SA2")+ SM0->M0_CGC))
			If Found()
				cCodFor := SA2->A2_COD
				cLojFor := SA2->A2_LOJA	
			Else
				MsgAlert("Filial de origem " +Alltrim(SM0->M0_CODFIL)+ " - "+Alltrim(SM0->M0_FILIAL)+" não cadastrado como fornecedor!")
				DisarmTransaction()
				Return
			Endif

			IF aFiliais[nPosFil][2] <> cFilAnt //Se a filial de destino igual da origem

				//*************************
				//Cabecalho da execauto
				//*************************
				aCabNF := {{"F1_TIPO"		,"N"	        ,NIL},;
							{"F1_FORMUL"	,"N"			,NIL},;
							{"F1_DOC"		,cNota           ,NIL},;
							{"F1_SERIE"	    ,cSerie 		,NIL},;
							{"F1_EMISSAO"	,SF2->F2_EMISSAO,NIL},;
							{"F1_FORNECE"	,cCodFor     	,NIL},;
							{"F1_LOJA"	    ,cLojFor     	,NIL},;
							{"F1_COND" 	    ,SF2->F2_COND   ,NIL},;
							{"F1_CHVNFE"    ,cChaveNfe	    ,NIL},;
							{"F1_ESPECIE"	,"NF"    		,NIL}}

				If (!dbSeek( xFilial( "SF1" ) + cNota + cSerie + cCodFor + cLojFor + "N" ) .and. nopc == 3) .or. (dbSeek( xFilial( "SF1" ) + cNota + cSerie + cCodFor + cLojFor + "N" ) .and. nopc == 5)
					If !ApMsgYesNo("Será "+IIF(nOpc==3,"gerada","excluida")+" a Nota de Entrada  " + ALLTRIM(cNota) + "  série  " + ALLTRIM(cSerie) + ". Confirma ?","Atenção")
						DisarmTransaction()
						Return
					Endif
				Else
					IF nOpc == 3
						MsgInfo("Nota Fiscal " + Alltrim(cNota) + " Serie + " + Alltrim(cSerie) + " ja existe na base de dados. Verifique...","Informação",)
						DisarmTransaction()
						Return
					Endif
				Endif

				//************************************************
				//Monta array dos itens da nota
				//************************************************
				aItemNF := {}
				aLinha  := {}

				dbSelectArea("SD2")
				SD2->(dbSetOrder(3))
				SD2->(dbGoTop())
				if SD2->(dbSeek(xFilial("SD2")+ cNota + cSerie))
					While (cNota + cSerie) == SD2->(D2_DOC + D2_SERIE) .and. !Eof()
						cOper := SuperGetMv("LC_TRANSFI",,"")
						DbSelectArea("SB1")
						SB1->(DbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1") + SD2->D2_COD))
						cFilBkp := cFilAnt
						cFilAnt := aFiliais[nPosFil][2]
						CriaSb2(SB1->B1_COD,SB1->B1_LOCPAD)
						cFilAnt := cFilBkp
						cTes := MaTesInt( 1, cOper, cCodFor, cLojFor, "F", SB1->B1_COD, Nil)


						AADD(aLinha,{"D1_COD"		,SD2->D2_COD    ,NIL})
						AADD(aLinha,{"D1_LOCAL"		,SB1->B1_LOCPAD ,NIL})
						AADD(aLinha,{"D1_UM"		,SD2->D2_UM 	,NIL})
						AADD(aLinha,{"D1_VUNIT"		,SD2->D2_PRCVEN ,NIL})
						AADD(aLinha,{"D1_QUANT"		,SD2->D2_QUANT 	,NIL})
						AADD(aLinha,{"D1_TOTAL"		,SD2->D2_TOTAL	,NIL})
						AADD(aLinha,{"D1_OPER"		,cOper			,NIL})
						AADD(aLinha,{"D1_TES"		,cTes			,NIL})
						AADD(aLinha,{"D1_LOTECTL"	,SD2->D2_LOTECTL,NIL})
						AADD(aLinha,{"D1_NUMLOTE"	,SD2->D2_NUMLOTE,NIL})
						AADD(aLinha,{"D1_DTVALID"	,SD2->D2_DTVALID,NIL})

						aAdd( aItemNF, Aclone( aLinha ) )
						aLinha := {}

						SD2->(dbSkip())
					EndDo
				Endif

				lMsErroAuto := .F.

				IF Len(aItemNF) > 0
					cFilAnt := aFiliais[nPosFil][2]
					//****************************
					//Gera NF de Entrada
					//****************************

					MsExecAuto({|x,y,z| MATA103(x,y,z)},aCabNF,aItemNF,nOpc)

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					Else
						IF nOpc == 3
							MsgBox("Nota Fiscal de Entrada criada com o número/serie " + cNota + " / " + cSerie + ".","A T E N C A O","INFO")
						Endif
					EndIf
				Endif
				cFilAnt := cFilBkp
			Endif
		Endif
	Endif
	End Transaction
	
	RestArea(aArea)

Return
