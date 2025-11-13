#Include "TOTVS.CH"
#Include "MSOLE.CH" 
#Include "PROTHEUS.CH"
  
/*                                                                        
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³ LVCOMR01          							    13/10/25  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprimir Pedido de Compras Grafico                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Locavel - HC (OUT/2025)                         º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function LVCOMR01(cOpcEx)

Private cDesc1
Private cDesc2
Private cDesc3
Private _cString
Private aOrd
Private j
Private oFont1
Private oFont2
Private oFont3
Private oFont4
Private oFont5
Private oFont6
Private oFont7
Private lAuto      := .F.
Private nPag       := 1
Private nPagd      := 0
Private NumPed     := Space(6)
Private cPFornec, cEmailForn, cEmailNome, cFornece, cObsPed, cPedEntr
Private cPerg      := "LVCOMR01", cMsg, nLinha, nLinhaD, nLinhaO, cObs   
Private oDlg,oGet
Private cGet1      := Space(2)
Private cCodIni,cCodFim
Private lAux       := .F. 
Private nValIpi    := 0 
Private nVAlICMs   := 0 
Private nLinMaxIte := 1840 // 1700 

Default cOpcEx := '1'

//  Verifica as perguntas selecionadas                           
//  Variaveis utilizadas para parametros                         
//  mv_par01	   	   Do Pedido                                 
//  mv_par02       	   Ate o Pedido 	                         
//  mv_par03	       Da Data                                   
//  mv_par04           Ate a Data                  	     	     
//  mv_par05           Unidade de Medida           	     	     
//  mv_par06           Nr.Vias                                   
//  mv_par07           Qual Moeda?                               

ValidPerg()
            
If cOpcEx == '1' // Via Menu ou Outras Ações
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIF                   

	cParam1 := MV_PAR01
	cParam2 := MV_PAR02
	dParam3 := MV_PAR03
	dParam4 := MV_PAR04
	nParam5 := MV_PAR05
	nParam6 := MV_PAR06
	nParam7 := MV_PAR07

Else	
	cParam1 := SC7->C7_NUM
	cParam2 := SC7->C7_NUM
	dParam3 := SC7->C7_EMISSAO
	dParam4 := SC7->C7_EMISSAO
	nParam5 := 1
	nParam6 := 1
	nParam7 := 1
End If
	
RptStatus({||Relato()})

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³ RELATO   ºAutor  ³ Leandro Eber    º Data ³  17/09/15      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function Relato()

Local nOrder
Local cCondBus
Local nSavRec
Local aSavRec    := {}
Local nRegSM0	 := SM0->(Recno())
Local cEmpAnt	 := SM0->M0_CODIGO
Local ncw 		 := 0           
Local i          := 0

Private lEnc     := .F.
Private cTitulo
Private oFont, cCode, oPrn
Private cCGCPict, cCepPict    
Private lPrimPag := .T. 
Private nTotPag  := 0
Private nReem
Private dDtEntrega

// Pictures de Campos Padrão

cCepPict  := PesqPict("SA2","A2_CEP")
cCGCPict  := PesqPict("SA2","A2_CGC")
cFonePict := PesqPict("SA2","A2_TEL")
cTelPict  := PesqPict("SY1","Y1_TEL")

oFont1 := TFont():New( "Arial",,16,,.t.,,,,,.f. )
oFont2 := TFont():New( "Arial",,16,,.f.,,,,,.f. )
oFont3 := TFont():New( "Arial",,10,,.t.,,,,,.f. )
oFont4 := TFont():New( "Arial",,10,,.f.,,,,,.f. )
oFont5 := TFont():New( "Arial",,08,,.t.,,,,,.f. )  
oFont6 := TFont():New( "Arial",,08,,.f.,,,,,.f. )
oFont7 := TFont():New( "Arial",,14,,.t.,,,,,.f. )  
oFont8 := TFont():New( "Arial",,14,,.f.,,,,,.f. )
oFont9 := TFont():New( "Arial",,12,,.t.,,,,,.f. )  
oFont10:= TFont():New( "Arial",,12,,.f.,,,,,.f. ) 
oFont11:= TFont():New( "Arial",,07,,.t.,,,,,.f. )  
oFont12:= TFont():New( "Arial",,07,,.f.,,,,,.f. )

oFont1c := TFont():New( "Courier New",,16,,.t.,,,,,.f. )
oFont2c := TFont():New( "Courier New",,16,,.f.,,,,,.f. )
oFont3c := TFont():New( "Courier New",,10,,.t.,,,,,.f. )
oFont4c := TFont():New( "Courier New",,10,,.f.,,,,,.f. )
oFont5c := TFont():New( "Courier New",,09,,.t.,,,,,.f. )  
oFont6c := TFont():New( "Courier New",,09,,.T.,,,,,.f. )
oFont7c := TFont():New( "Courier New",,14,,.t.,,,,,.f. )  
oFont8c := TFont():New( "Courier New",,14,,.f.,,,,,.f. )
oFont9c := TFont():New( "Courier New",,12,,.t.,,,,,.f. )  
oFont10c:= TFont():New( "Courier New",,12,,.f.,,,,,.f. ) 

nDescProd  := 0
nTotal     := 0
nTotMerc   := 0
cCondBus   := cParam1
nOrder	   := 1
nPagD      := 1   
cObsPed    := ""      
cPedEntr   := "" 
nValFrete2 := 0   
cCodIni    := cParam1
cCodFim    := cParam2 

If Empty(cCodIni)
	cCodIni  := SC7->C7_NUM
	cCodFim  := SC7->C7_NUM 
	cCondBus := SC7->C7_NUM	
EndIf 
	
	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	SetRegua(nPagD)
	dbSeek(xFilial("SC7")+cCondBus,.T.) 
	
	// Contagem de paginas
	
	While !Eof() .And. C7_FILIAL == xFilial("SC7") .And. C7_NUM >= cCodIni .And. C7_NUM <= cCodFim 
			           
		nTotPag++			           	    
		dbSkip()
	
	EndDo      
	
	nTotPag := nTotPag/15	
	
	If nTotPag > Int(nTotPag)
		nTotPag :=Int(nTotPag)+1			
	Else
		nTotPag	:= Int(nTotPag)
	EndIf
	
	If Empty(nTotPag)
		nTotPag :=1
	EndIf
	
	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	SetRegua(nPagD)
	dbSeek(xFilial("SC7") + cCondBus,.T.) 	                           
	
	// Executar manualmente pois nao chama a funcao Cabec()
	
	While !Eof() .And. C7_FILIAL == xFilial("SC7") .And. C7_NUM >= cCodIni .And. C7_NUM <= cCodFim
		
		// Variaveis para armazenar valores do pedido
		
		nOrdem   := 1
		nReem    := 0
		nPag     := 1 

		If (C7_EMISSAO < dParam3) .Or. (C7_EMISSAO > dParam4)
			dbSkip()
			Loop
		Endif     
		
		If ! Empty(SC7->C7_FILENT) .And. SC7->C7_FILIAL <> SC7->C7_FILENT
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt+SC7->C7_FILENT))
			If SM0->(! Eof())
				aDadEmp := {	SM0->M0_NOMECOM,SM0->M0_TEL,SM0->M0_FAX,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_ENDENT,SM0->M0_BAIRENT,SM0->M0_CIDENT,;
								SM0->M0_ESTENT,SM0->M0_CEPENT,SM0->M0_ENDCOB,SM0->M0_BAIRCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,SM0->M0_CEPCOB}
			Else
				SM0->(dbGoTo(nRegSM0))
				aDadEmp := {	SM0->M0_NOMECOM,SM0->M0_TEL,SM0->M0_FAX,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_ENDENT,SM0->M0_BAIRENT,SM0->M0_CIDENT,;
								SM0->M0_ESTENT,SM0->M0_CEPENT,SM0->M0_ENDCOB,SM0->M0_BAIRCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,SM0->M0_CEPCOB}
			EndIf
		Else
			SM0->(dbGoTo(nRegSM0))
			aDadEmp := {	SM0->M0_NOMECOM,SM0->M0_TEL,SM0->M0_FAX,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_ENDENT,SM0->M0_BAIRENT,SM0->M0_CIDENT,;
							SM0->M0_ESTENT,SM0->M0_CEPENT,SM0->M0_ENDCOB,SM0->M0_BAIRCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,SM0->M0_CEPCOB}
		EndIf
		
		MaFisEnd()
		//R110FIniPC(SC7->C7_NUM,,,)

		For ncw := 1 To nParam6		// Imprime o numero de vias informadas
				
			nTotal    := 0
			nTotMerc  := 0
			nDescProd := 0
   		    nReem     := 1
			nSavRec   := SC7->(Recno())
			NumPed    := SC7->C7_NUM
	        li        := 465        
	        nTotDesc  := 0
	        cFornece  := SC7->(C7_FORNECE+C7_LOJA)
	
			ImpCabec(aDadEmp)
			
			While !Eof() .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == NumPed 
			                                             
				dbSelectArea("SC7")
				If AScan(aSavRec,Recno()) == 0	// Guardar R_E_C_N_O para gravacao
					AAdd(aSavRec,Recno())
				Endif
				
				IncRegua()
				
			// Verifica se havera salto de formulario
	
				If li > 1550
					nOrdem++
//					nPag++
					ImpRodape()			// Imprime rodape do formulario e salta para a proxima folha
					ImpCabec(aDadEmp)
					li  := 465
				Endif
			
				If !Empty(SC7->C7_RESIDUO) .And. SC7->C7_QUJE == 0
				   dbSkip()
				   Loop 
				EndIf 
				
				If !Empty(SC7->C7_RESIDUO) .And. SC7->C7_QUJE <> 0
				   lAux := .T. 
				EndIf 
				
		        li:=li+60
				
				oPrn:Say( li, 0040, StrZero(Val(SC7->C7_ITEM),4),oFont6,100 )
	            oPrn:Say( li, 0160, UPPER(SC7->C7_PRODUTO),oFont6,100 )
	
				// Pesquisa Descricao do Produto

				ImpProd()
	
				If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif            
	
				dbSkip()
			EndDo
			
			dbGoto(nSavRec)
	
			If li>1550
				nOrdem++
				ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec(aDadEmp)
				li  := 465
			Endif
	
			FinalPed(aDadEmp)  // Imprime os dados complementares do PC
	
		Next
	
		MaFisEnd()  
      
      	dbSelectArea("SC7")
		If Len(aSavRec)>0
			For i:= 1 to Len(aSavRec)
				dbGoto(aSavRec[i])
   //			RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
	//			MsUnLock()
			Next
			dbGoto(aSavRec[Len(aSavRec)])		// Posiciona no ultimo elemento e limpa array
		Endif              	 
				
		dbGoto(aSavRec[Len(aSavRec)])		// Posiciona no ultimo elemento e limpa array
	
		aSavRec := {}
		
		dbSkip()
	EndDo

dbSelectArea("SC7")
Set Filter To
dbSetOrder(1)

dbSelectArea("SX3")
dbSetOrder(1)

If lEnc
   oPrn:Preview()
   MS_FLUSH()
EndIf

SM0->(dbGoTo(nRegSM0))
   
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o Cabecalho do Pedido de Compra                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpCabec(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function ImpCabec(aDadEmp)

Local nOrden, cCGC
Local cMoeda
LOcal cAlter	:=	""
Local cCompr	:=	"" 
Local cAprov    :=	""
Local cTipoSC7  :=	""

Public cAprovador := ""   

Private cSubject

cMoeda := IIf(nParam7<10,Str(nParam7,1),Str(nParam7,2))

If !lPrimPag
   oPrn:EndPage()
   oPrn:StartPage() 
Else
   lPrimPag := .F.
   lEnc     := .T.
   oPrn     := TMSPrinter():New()
   oPrn:Setup()
EndIf

oPrn:Say( 0020, 0020, " ",oFont,100 )
cCompr   := Left(FWGetUserName(SC7->C7_USER),20)           
cTipoSC7 := IIf(SC7->C7_TIPO == 1,"PC","AE")	

dbSelectArea("SCR")
dbSetOrder(1)
dbSeek(xFilial("SC7")+"PC"+SC7->C7_NUM)
cAprov := "A G U A R D A N D O   L I B E R A C A O"
While !Eof() .And. SCR->CR_FILIAL+AllTrim(SCR->CR_NUM) == xFilial("SC7")+SC7->C7_NUM .And. SCR->CR_TIPO == cTipoSC7
	cAprovador := AllTrim(FWGetUserName(SCR->CR_USER))
	Do Case
		Case SCR->CR_STATUS=="03" //Liberado
			cAprov := "L I B E R A D O"
		Case SCR->CR_STATUS=="04" //Bloqueado
			cAprov := "B L O Q U E A D O"
		Case SCR->CR_STATUS=="05" //Nivel Liberado
			cAprov := "N I V E L   L I B E R A D O"
		OtherWise                 //Aguardando Liberacao
			cAprov := "A G U A R D A N D O   L I B E R A C A O"
	EndCase
	dbSelectArea("SCR")
	dbSkip()
Enddo

//Cabecalho (Logomarca e Titulo)
oPrn:Box( 0020, 0020, 0175,3180)
//oPrn:SayBitmap( 0030,0050,"logopc.jpg",0140,0135 ) 

//Cabecalho (Enderecos da Empresa e Fornecedor)
oPrn:Box( 0175, 0020, 0420,1000)    
oPrn:Box( 0175, 1000, 0420,2500)
oPrn:Box( 0175, 2500, 0420,3180)

//Cabecalho Produto do Pedido
oPrn:Box( 0420, 0020, 0480,0145)//Item
oPrn:Box( 0420, 0145, 0480,0380)//Codigo  
oPrn:Box( 0420, 0380, 0480,1300)//Desc  

oPrn:Box( 0420, 1300, 0480,1690)//Obs
          // Esq       Direita
oPrn:Box( 0420, 1690, 0480,1800)//Un     
oPrn:Box( 0420, 1800, 0480,1950)//Qtde
oPrn:Box( 0420, 1950, 0480,2230)//Valor Total
oPrn:Box( 0420, 2230, 0480,2355)//ICM
oPrn:Box( 0420, 2355, 0480,2500)//IPI
oPrn:Box( 0420, 2500, 0480,2715)//Valor Uni
oPrn:Box( 0420, 2715, 0480,2855)//Dt Entr 
oPrn:Box( 0420, 2855, 0480,3050)//Centro Custo
oPrn:Box( 0420, 3050, 0480,3180)//Solic.

//Espaco dos Itens do Pedido
oPrn:Box( 0480, 0020, nLinMaxIte,0145)  //Item 
oPrn:Box( 0480, 0145, nLinMaxIte,0380)  //Codigo
oPrn:Box( 0480, 0380, nLinMaxIte,1300)  //Descri
oPrn:Box( 0480, 1300, nLinMaxIte,1690)  //Obs
oPrn:Box( 0480, 1690, nLinMaxIte,1800) //UN
oPrn:Box( 0480, 1800, nLinMaxIte,1950) //Qtde
oPrn:Box( 0480, 1950, nLinMaxIte,2230) //Valor Total
oPrn:Box( 0480, 2230, nLinMaxIte,2355) //ICM
oPrn:Box( 0480, 2355, nLinMaxIte,2500) //IPI
oPrn:Box( 0480, 2500, nLinMaxIte,2715) //Valor Uni
oPrn:Box( 0480, 2715, nLinMaxIte,2855) //Dt Entr
oPrn:Box( 0480, 2855, nLinMaxIte,3050) //Centro Custo
oPrn:Box( 0480, 3050, nLinMaxIte,3180) //Solic.
                    
dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)

// Titulo

If SC7->C7_TIPO==1
	oPrn:Say( 0080, 1040, "P E D I D O   D E   C O M P R A S", oFont1, 100 )
Else
	oPrn:Say( 0080, 1040, "A U T O R I Z A Ç Ã O   D E   E N T R E G A",oFont1,100 )
EndIf

oPrn:Say( 0080, 2880, "FOLHA:" ,oFont3,100 )
oPrn:Say( 0080, 3032, AllTrim(StrZero(nPag,2))+"/"+Alltrim(StrZero(nTotPag,2)),oFont3,100 )

// Itens das Empresas
oPrn:Say( 0185, 2570, "Nº "+SC7->C7_NUM,oFont7,100 )
oPrn:Say( 0185, 2710, Str(nReem) + "ª Via",oFont5,100 )

oPrn:Say( 0195, 0050, "EMPRESA: "+aDadEmp[01],oFont6,100 )
oPrn:Say( 0195, 1040, "FORNECEDOR: "+AllTrim(Substr(SA2->A2_NOME,1,40))+" ("+SA2->A2_COD+"/"+SA2->A2_LOJA +")",oFont6,100 )
//oPrn:Say( 0370, 1950, "VENDEDOR: " + Upper(Substr(SC7->C7_CONTATO,1,25)),oFont6,100 )
oPrn:Say( 0335, 1950, "VENDEDOR: " + Upper(Substr(SC7->C7_CONTATO,1,25)),oFont6,100 )

oPrn:Say( 0265, 2570, "DATA EMISSÃO: " + DTOC(SC7->C7_EMISSAO),oFont6,100 )

oPrn:Say( 0265, 0050, "ENDEREÇO: " + SubStr(UPPER(aDadEmp[06]),1,25) ,oFont6,100 )
oPrn:Say( 0265, 0610, "BAIRRO: "   + UPPER(Substr(aDadEmp[07],1,25)) ,oFont6,100 )
oPrn:Say( 0265, 1040, "ENDEREÇO: " + UPPER(Substr(SA2->A2_END,1,40)) ,oFont6,100 )
oPrn:Say( 0265, 1950, "BAIRRO: "   + Substr(SA2->A2_BAIRRO,1,25) ,oFont6,100 )
oPrn:Say( 0300, 0050, Upper("CEP: "+ Trans(aDadEmp[10],cCepPict)),oFont6,100 )
oPrn:Say( 0300, 0610, Upper(Trim(aDadEmp[08])+" - "+aDadEmp[09]) ,oFont6,100 )
	
oPrn:Say( 0300, 1040, Upper("CEP: "+ Trans(SA2->A2_CEP,cCepPict)),oFont6,100 )
oPrn:Say( 0300, 1950, Upper(Trim(SA2->A2_MUN)+" - "+SA2->A2_EST),oFont6,100 )     

oPrn:Say( 0320, 2570, "SITUAÇÃO: ",oFont6,100 )
oPrn:Say( 0320, 2720, cAprov      ,oFont5,100 )

oPrn:Say( 0375, 2570, "APROVADOR: ",oFont6,100 )
oPrn:Say( 0375, 2720, cAprovador   ,oFont5,100 )

oPrn:Say( 0335, 0050, "FONE: " + aDadEmp[02] ,oFont6,100 )
//oPrn:Say( 0335, 0610, "FAX: " + aDadEmp[03] ,oFont6,100 )

oPrn:Say( 0335, 1040, "FONE: " + "("+Substr(SA2->A2_DDD,1,2)+") "+Trans(SA2->A2_TEL,cFonePict),oFont6,100 )
//oPrn:Say( 0335, 1950, "FAX: " + "("+Substr(SA2->A2_DDD,1,3)+") "+SA2->A2_FAX ,oFont6,100 )

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("A2_CGC")
cCGC := Alltrim(X3TITULO())
nOrden = IndexOrd()

oPrn:Say( 0235, 0050, (cCGC) + " " + Transform(aDadEmp[04],cCgcPict) ,oFont6,100 ) 
oPrn:Say( 0235, 0610, "IE: "  + aDadEmp[05] ,oFont6,100 )

dbSelectArea("SA2")
dbSetOrder(nOrden)
oPrn:Say( 0235, 1040, "CNPJ: " + Transform(SA2->A2_CGC,cCgcPict) ,oFont6,100 )
oPrn:Say( 0235, 1950, "IE: "   + SA2->A2_INSCR ,oFont6,100 )

oPrn:Say( 0435, 0035, "Item"  ,oFont3,100 )
oPrn:Say( 0435, 0165, "Código",oFont3,100 )
oPrn:Say( 0435, 0400, "Descrição do Material e/ou Serviço" ,oFont3,100 )
oPrn:Say( 0435, 1360, "Observações",oFont3,100 )

oPrn:Say( 0435, 1700, "UN"          ,oFont3,100 )
oPrn:Say( 0435, 1820, "Qtd"         ,oFont3,100 )
oPrn:Say( 0435, 2000, "Valor Unit." ,oFont3,100 )
oPrn:Say( 0435, 2250, "ICMS%"       ,oFont3,100 )
oPrn:Say( 0435, 2370, "IPI%"        ,oFont3,100 )
oPrn:Say( 0435, 2515, "Valor Total" ,oFont3,100 )
oPrn:Say( 0435, 2720, "Dt Entr"     ,oFont3,100 )
oPrn:Say( 0435, 2870, "C. Custo"    ,oFont3,100 )
oPrn:Say( 0435, 3060, "SC"          ,oFont3,100 )

cSubject := "Pedido de Compras Nº " + SC7->C7_NUM + " / " + AllTrim(Left(SA2->A2_NOME,30))

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpProd  ³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisar e imprimir  dados Cadastrais do Produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProd(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function ImpProd()

LOCAL cDesc, nLinRef := 1, nBegin := 0, cDescri := "", nLinha:=0, nTamDesc := 50 , aColuna := Array(8)

// Impressao da descricao generica do Produto

cObs    := AllTrim(Trim(SC7->C7_OBS))         
cDescri := AllTrim(SC7->C7_DESCRI) // + " " + Alltrim(SC7->C7_DESCRIC) +" - "+Alltrim(SC7->C7_ZOBSUS1)+" "+Alltrim(SC7->C7_ZOBSUS2)
		
dbSelectArea("SC7")
nLinhaD := MLCount(cDescri,nTamDesc)
nLinhaO := MLCount(cObs,20)
nLinha  := If(nLinhaD>nLInhaO,nLinhaD,nLinhaO)
oPrn:Say(li, 0400, MemoLine(cDescri,nTamDesc,1) ,oFont6,100)
oPrn:Say(li, 1340, If(nLinhaO>0,MemoLine(cObs,20,1),""),oFont6,100)

ImpCampos()

For nBegin := 2 To nLinha
	li+=35              
	If nLinhaD >= nBegin
		oPrn:Say( li, 0430, MemoLine(cDescri,nTamDesc,nBegin) ,oFont6,100 )
	EndIf
	If nLinhaO >= nBegin
		oPrn:Say( li, 1340, MemoLine(cObs,20,nBegin),oFont6,100 )
	EndIf
Next nBegin

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o    ³ ImpCampos³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir dados Complementares do Produto no Pedido.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpCampos(Void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function ImpCampos()

dbSelectArea("SC7")   
     
//	Primeira/Segunda Unidade Medida

If nParam5 == 2 .And. !Empty(SC7->C7_SEGUM)
   oPrn:Say( li, 1700, SC7->C7_SEGUM ,oFont6,100 )
Else
   oPrn:Say( li, 1700, SC7->C7_UM ,oFont6,100 )
EndIf             

// Quantidade
If nParam5 == 2 .And. !Empty(SC7->C7_QTSEGUM) 
   If !lAux
      oPrn:Say( li,1810, Transform(SC7->C7_QTSEGUM,"@E 999,999.99") ,oFont6,100 )
   Else
      oPrn:Say( li,1810, Transform(SC7->C7_QUJE,"@E 999,999.99") ,oFont6,100 )   
   EndIf 
Else
   If !lAux 
      oPrn:Say( li,1810, Transform(SC7->C7_QUANT,"@E 999,999.99") ,oFont6,100 )
   Else 
      oPrn:Say( li,1810, Transform(SC7->C7_QUJE,"@E 999,999.9") ,oFont6,100 )   
   EndIf 
EndIf                                       

// Valor Unitario
If nParam5 == 2 .And. !Empty(SC7->C7_QTSEGUM)  
   If !lAux
      oPrn:Say( li, 1990, Transform(xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),PesqPict("SC7","C7_PRECO",14, nParam7)) ,oFont6,100 )
   Else 
      oPrn:Say( li, 1990, Transform(xMoeda((SC7->C7_PRECO),SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),PesqPict("SC7","C7_PRECO",14, nParam7)) ,oFont6,100 )   
   EndIf    
Else
   oPrn:Say( li, 1990, Transform(SC7->C7_PRECO,"@E 9,999,999.99") ,oFont6,100 )
EndIf

// ICMS
// oPrn:Say( li, 2250, Transform(SC7->C7_PICM,"@E 99.9") ,oFont6,100 ) Excluido solicitado pelo Chamado 15666

// IPI
oPrn:Say( li, 2380, Transform(SC7->C7_IPI,"@E 99.99") ,oFont6,100 ) 

// Valor Total
If !lAux 
   oPrn:Say( li, 2510, Transform(SC7->C7_TOTAL,"@E 9,999,999.99") ,oFont6,100 )
Else
   oPrn:Say( li, 2510, Transform(SC7->C7_PRECO * SC7->C7_QUJE,"@E 9,999,999.99") ,oFont6,100 )
EndIf

 oPrn:Say( li, 2720, DTOC(SC7->C7_DATPRF) ,oFont6,100 )

// Centro de Custo
oPrn:Say( li, 2870, Transform(SC7->C7_CC,"@E 9999999999") ,oFont6,100 )

// Solicitacao de Compra
oPrn:Say( li, 3060, SC7->C7_NUMSC ,oFont6,100 )

//nTotal  :=nTotal+IIF(!lAux,SC7->C7_TOTAL,SC7->C7_PRECO * SC7->C7_QUJE)
nTotal := nTotal + SC7->C7_TOTAL

nTotMerc := nTotal // MaFisRet(,"NF_TOTAL") -> antes
nTotDesc+=SC7->C7_VLDESC

If lAux 
   nValIPI  += (SC7->C7_VALIPI /SC7->C7_QUANT)*SC7->C7_QUJE
Else
   nValIpi  += SC7->C7_VALIPI
EndIf  

lAux := .F. 
Return .T.  

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o    ³ ImpRodape³ Autor ³ Leandro Eber Ribeiro  ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o rodape do formulario e salta para a proxima folha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRodape(Void)   			         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                     				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function ImpRodape()

oPrn:Say( 1650, 1810, "***************  CONTINUA  ***************" ,oFont3,100 )
nPag++

Return .T. 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o    ³ FinalPed ³ Autor ³ Leandro Eber Ribeiro  ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados complementares do Pedido de Compra        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinalPed(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function FinalPed(aDadEmp)

Local nk 		 := 1,nG
Local nQuebra	 := 0
Local lNewAlc	 := .F.
Local lLiber 	 := .F.
Local lImpLeg	 := .T.
Local cComprador :=	""
LOcal cAlter	 :=	""
Local cAprova	 :=	""
Local cCompr	 :=	""
Local cEmail	 :=	""
Local cTele		 :=	""
Local cObsPe	 :=	""
Local aColuna    := Array(8), nTotLinhas 
Local nTotIpi	 := nValIPI
Local nTotIcms	 := 0
Local nTotDesp	 := MaFisRet(,'NF_DESPESA')
Local nTotFrete  := 0 //MaFisRet(,'NF_FRETE')
Local nTotalNF	 := MaFisRet(,'NF_TOTAL')
Local nTotSeguro := MaFisRet(,'NF_SEGURO')
Local aValIVA    := MaFisRet(,"NF_VALIMP")
Local cTPFrete

//Rodape
oPrn:Box( nLinMaxIte, 0020, nLinMaxIte + 220,2550) // Sub Total
oPrn:Box( nLinMaxIte + 110, 0020, nLinMaxIte + 220,2550) // Total s/ Imp
oPrn:Box( nLinMaxIte, 2550, nLinMaxIte + 220,3180) // Desconto  

oPrn:Box( nLinMaxIte + 110, 0020, nLinMaxIte + 220,0900) //Impostos
oPrn:Box( nLinMaxIte + 110, 0900, nLinMaxIte + 220,1700) //Impostos
oPrn:Box( nLinMaxIte + 110, 1700, nLinMaxIte + 220,3180) //Impostos

oPrn:Box( nLinMaxIte + 220, 0020, nLinMaxIte + 380,2550) // Endereco
oPrn:Box( nLinMaxIte + 220, 1700, nLinMaxIte + 380,3180) //2100 Observações
oPrn:Box( nLinMaxIte + 220, 2550, nLinMaxIte + 380,3180) // Total

oPrn:Box( nLinMaxIte + 380, 0020, nLinMaxIte + 680,3180) //2130 Obs Finais   

If cPaisLoc <> "BRA" .And. !Empty(aValIVA)
   For nG:=1 To Len(aValIVA)
       nValIVA+=aValIVA[nG]
   Next
EndIf   
   
    // Seleciona o Aprovador caso exista

	dbSelectArea("SCR")
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+"PC"+SC7->C7_NUM)
	
	While !Eof() .And. SCR->CR_FILIAL+AllTrim(SCR->CR_NUM)==xFilial("SC7")+SC7->C7_NUM .And. SCR->CR_TIPO == "PC"
		IF SCR->CR_STATUS=="03"
			cAprova += AllTrim(FWGetUserName(SCR->CR_USER))
		EndIF
		dbSelectArea("SCR")
		dbSkip()
	Enddo  
	
	cAprova := "Não Aprovado"     
	
	// Seleciona o Comprador

	cCompr  := Left(FWGetUserName(SC7->C7_USER),20)
	cObsPe  := SC7->C7_OBS                                         
	cEmail	:= Posicione("SY1", 3, xFilial("SY1")+SC7->C7_USER, "Y1_EMAIL")
	cTele	:= Posicione("SY1", 3, xFilial("SY1")+SC7->C7_USER, "Y1_TEL")
	
//nTotIpi	 := SC7->C7_VALIPI
//nTotIcms	 := SC7->C7_VALICM
//nTotDesp	 := SC7->C7_DESPESA
//nTotalNF	 := SC7->C7_TOTAL
//nTotSeguro := SC7->C7_SEGURO
//aValIVA    := SC7->C7_VALIMP

// Impressso de Descontos abaixo da linha dos itens

oPrn:Say( nLinMaxIte + 20, 0420, "D E S C O N T O -->" ,oFont3,100 ) 
oPrn:Say( nLinMaxIte + 20, 0850, Transform(SC7->C7_DESC1,"@E999.99")+" %" ,oFont4,100 )
oPrn:Say( nLinMaxIte + 20, 0950, Transform(SC7->C7_DESC2,"@E999.99")+" %" ,oFont4,100 )
oPrn:Say( nLinMaxIte + 20, 1050, Transform(SC7->C7_DESC3,"@E999.99")+" %" ,oFont4,100 ) 
                                                      
// Aglutina os descontos de itens com o pedido
// nTotDesc += SC7->C7_DESC1+SC7->C7_DESC1+SC7->C7_DESC1 

oPrn:Say( nLinMaxIte + 20, 1300, Transform(xMoeda(nTotDesc,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),PesqPict("SC7","C7_VLDESC",14, nParam7)) ,oFont4,100 )

dbSelectArea("SM4")
dbSetOrder(1)
dbSelectArea("SC7")

// Impressao do Frete                                    

If SC7->C7_TPFRETE == 'C'
   cTPFrete   := "CIF"
   nTotFrete2 := MaFisRet(,'NF_FRETE')
   nTotFrete  := MaFisRet(,'NF_FRETE')
Else
   cTPFrete   := "FOB"        
   nTotFrete2 := MaFisRet(,'NF_FRETE')
   nTotFrete  := 0
EndIf

// Primeira Caixa de Impostos

oPrn:Say( nLinMaxIte + 120, 0040, "IPI :" ,oFont3,100 )
oPrn:Say( nLinMaxIte + 120, 0200, Transform(xMoeda(nTotIPI,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm(nTotIpi,14,MsDecimais(nParam7))) ,oFont4c,100 )
oPrn:Say( nLinMaxIte + 170, 0040, "ICMS :" ,oFont3,100 )
oPrn:Say( nLinMaxIte + 170, 0200, Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm(nTotIcms,14,MsDecimais(nParam7))) ,oFont4c,100 )

// Segunda Caixa de Impostos

oPrn:Say( nLinMaxIte + 120, 0950, "Frete + Despesas:" ,oFont3,100 )
oPrn:Say( nLinMaxIte + 120, 1150, Transform(xMoeda(nTotFrete2+nTotDesp,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm(nTotFrete,14,MsDecimais(nParam7))) ,oFont4c,100 )
oPrn:Say( nLinMaxIte + 170, 0950, "Obs. Frete:" ,oFont3,100 )
oPrn:Say( nLinMaxIte + 170, 1150, Alltrim(cTPFrete),oFont4c,100 )

// Terceira Caixa de Impostos

dbSelectArea("SE4")
dbSetOrder(1)
dbSeek("    "+SC7->C7_COND)  //Tabela SE4 - Condição de Pagamentos compartilhada
dbSelectArea("SC7")

oPrn:Say( nLinMaxIte + 120, 1760, "Condição de Pagto:"   ,oFont3,100 )
oPrn:Say( nLinMaxIte + 120, 2100, Alltrim(SE4->E4_DESCRI),oFont6,100 )
oPrn:Say( nLinMaxIte + 170, 1760, "Seguro:"              ,oFont3,100 )
oPrn:Say( nLinMaxIte + 170, 2000, Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm(nTotSeguro,14,MsDecimais(nParam7))),oFont6,100 )
oPrn:Say( nLinMaxIte + 35, 2580, "SUB-TOTAL: "           ,oFont3,100 )
oPrn:Say( nLinMaxIte + 35, 2810, Transform(xMoeda(nTotal,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm(nTotal,14,MsDecimais(nParam7))) ,oFont6,100 )

oPrn:Say( nLinMaxIte + 240 , 0050, "Local de Entrega: "  ,oFont3,100 )

//Verifica se existe local de entrega preenchido

If Empty(Alltrim(cPedEntr))
   oPrn:Say( nLinMaxIte + 240 , 0420, Alltrim(Substr(aDadEmp[06],1,30))+" - "+ Alltrim(Substr(aDadEmp[07],1,10))+" - " +Alltrim(Substr(aDadEmp[08],1,10))+" / "+aDadEmp[09]+ " - " + UPPER("CEP: "+Trans(aDadEmp[10],cCepPict)),oFont6,100 )
Else  
   oPrn:Say( nLinMaxIte + 240 , 0420, Upper(Alltrim(cPedEntr)) ,oFont6,100 )            
EndIf	

oPrn:Say( nLinMaxIte + 300 , 0050, "Local de Cobrança: ",oFont3,100 )
oPrn:Say( nLinMaxIte + 300 , 0420, Alltrim(Substr(aDadEmp[11],1,30))+" - "+ Alltrim(Substr(aDadEmp[12],1,10))+" - " +Alltrim(Substr(aDadEmp[13],1,10))+" / "+aDadEmp[14]+ " - " + UPPER("CEP: "+Trans(aDadEmp[15],cCepPict)),oFont6,100 )

oPrn:Say( nLinMaxIte + 140 , 2580, "TOTAL S/ IMP.: ",oFont3,100 )
oPrn:Say( nLinMaxIte + 140 , 2820, Transform(xMoeda((nTotal+nTotFrete+nTotDesp+nTotSeguro)-(nTotDesc+nTotIcms),SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm((nTotal+nTotFrete+nTotDesp+nTotSeguro)-(nTotDesc+nTotIcms),14,MsDecimais(nParam7))),oFont6,100 )

oPrn:Say( nLinMaxIte + 280 , 2580, "TOTAL GERAL: ",oFont9,100 )
oPrn:Say( nLinMaxIte + 280 , 2818, Transform(xMoeda((nTotal+nTotFrete+nTotDesp+nTotSeguro+nTotIpi)-nTotDesc,SC7->C7_MOEDA,nParam7,SC7->C7_DATPRF),tm((nTotal+nTotFrete+nTotDesp+nTotSeguro+nTotIpi)-nTotDesc,14,MsDecimais(nParam7))),oFont9c,100 )

oPrn:Say( nLinMaxIte + 230 , 1750, "COMPRADOR: ",oFont5,100 )
oPrn:Say( nLinMaxIte + 230 , 2100, UPPER(Alltrim(cCompr)),oFont6,100 )
oPrn:Say( nLinMaxIte + 280 , 1750, "E-MAIL: ",oFont5,100 )
oPrn:Say( nLinMaxIte + 280 , 1850, UPPER(Alltrim(cEmail)),oFont6,100 ) 
oPrn:Say( nLinMaxIte + 330 , 1750, "TEL: ",oFont5,100 )
oPrn:Say( nLinMaxIte + 330 , 1850, Trans(SY1->Y1_TEL,cTelPict),oFont6,100 ) 
                                                     
oPrn:Say( nLinMaxIte + 470 , 0040,  " ATENÇÃO: ",oFont7,100 )
oPrn:Say( nLinMaxIte + 470 , 0265,  "1) É obrigatório constar o Nº deste Pedido na NOTA FISCAL ELETRONICA, caso contrário não será aceita a mercadoria e/ou serviço",oFont4, 100 )
oPrn:Say( nLinMaxIte + 520 , 0265,  "2) Não serão aceitas entregas em desconformidade com todas as condições descritas neste Pedido de Compra",oFont4, 100 )
oPrn:Say( nLinMaxIte + 570 , 0265,  "3) Horário de recebimento de segunda a sexta das 8h às 16h",oFont4,100)
//oPrn:Say( nLinMaxIte + 470 , 0265,  "2) É obrigatório constar o Nº deste Pedido na NOTA FISCAL, sob pena de não ser aceita a mercadoria e/ou serviço",oFont4,100 ) 
//oPrn:Say( nLinMaxIte + 520 , 0265,  "3) Não serão aceitas entregas em desconformidade com as condições expressas neste Pedido de Compra",oFont4,100 )
//oPrn:Say( nLinMaxIte + 570 , 0265,  "4) Toda NOTA FISCAL emitida entre os dias 25 e 31 do mês atual, o fornecedor OBRIGATORIAMENTE deverá emitir a NF com data do 1º dia do mês subseqüente",oFont4,100 )
//oPrn:Say( nLinMaxIte + 620 , 0265,  "5) Produtos quimicos e reagentes não serão recebidos sem os respectivos CERTIFICADOS DE QUALIDADE",oFont4,100 )

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Funcao   ³VALIDPERG ³ Autor³Adalberto Moreno Batista³ Data ³11.02.2000³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function ValidPerg()

Local _aAlias := Alias(), aRegs
Local i := 0
Local j := 0

dbSelectArea("SX1")
dbSetOrder(1)
aRegs := {}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Do Pedido ?"        ,"¿De Pedido?","From Order ?"                  ,"mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegs,{cPerg,"02","Até o Pedido ?"     ,"¿A  Pedido?","To Order ?"                    ,"mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegs,{cPerg,"03","Da Data ?"          ,"¿De Fecha?","From Date ?"                    ,"mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegs,{cPerg,"04","Até a Data ?"       ,"¿A  Fecha?","To Date ?"                      ,"mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegs,{cPerg,"05","Qual Unid. Medida ?","¿Cual Unidad Medida?","Which Unit of Meas. ?","mv_ch5","N",1,0,1,"C","","mv_par05","Primaria","Primaria","Primary","","","Secundaria","Secundaria","Secondary","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegs,{cPerg,"06","Numero de Vias ?"   ,"¿Numero de Copias?","Number of Copies ?"     ,"mv_ch6","N",2,0,0,"G","","mv_par06","","",""," 1","","","","7","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegs,{cPerg,"07","Qual Moeda ?"       ,"¿Cual Moneda?","Currency ?"                  ,"mv_ch7","N",1,0,1,"C","","mv_par07","Moeda 1","Moneda 1","Currency 1","","","Moeda 2","Moneda 2","Currency 2","","","Moeda 3","Moneda 3","Currency 3","","","Moeda 4","Moneda 4","Currency 4","","","Moeda 5","Moneda 5","Currency 5","","","S","",""})

For i:=1 to Len(aRegs)
   //	If !dbSeek(cPerg+aRegs[i,2])  
    If SX1->( !MsSeek(PadR(cPerg,10)+aRegs[i,2]) )
		RecLock("SX1",.T.)
		For j:=1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_aAlias)   

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

Local aArea    := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local cValid   := ""
Local nPosRef  := 0
Local nItem    := 0
Local cItemDe  := IIf(cItem==Nil,'',cItem)
Local cItemAte := IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols := ''

DEFAULT cSequen  := ""
DEFAULT cFiltro  := ""

dbSelectArea("SC7")
dbSetOrder(1)

If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
                MaFisEnd()
                MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
                While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen);
				             .OR. cSequen == SC7->C7_SEQUEN)

                               // Nao processar os Impostos se o item possuir residuo eliminado  
                               If &cFiltro
                                  dbSelectArea('SC7')
                                  dbSkip()
                                  Loop
                               EndIf
            
                               // Inicia a Carga do item nas funcoes MATXFIS  
                               nItem++
                               MaFisIniLoad(nItem)
                               dbSelectArea("SX3")
                               dbSetOrder(1)
                               dbSeek('SC7')
                               While !EOF() .AND. (X3_ARQUIVO == 'SC7')
                                               cValid    := StrTran(Upper(SX3->X3_VALID)," ","")
                                               cValid    := StrTran(cValid,"'",'"')
                                               If "MAFISREF" $ cValid
                                                               nPosRef  := AT('MAFISREF("',cValid) + 10
                                                               cRefCols := SubStr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
                                                               // Carrega os valores direto da SC7
                                                               MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
                                               EndIf
                                               dbSkip()
                               End
                               MaFisEndLoad(nItem,2)
                               dbSelectArea('SC7')
                               dbSkip()
                End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.
