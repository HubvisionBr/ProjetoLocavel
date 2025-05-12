#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function MT103AFN()

	Local cBase      := "" // Codigo personalizado
	Local cItem      := "" // Numero item personalizado
	Local aRet       := {}

	// Local aTeste     := Paramixb[1] //Dados do projeto
	Local cAtuaATF   := Paramixb[2] //Atualiza ativo:  "S"-Sim / "N"-Nao
	// Local cDesItATF  := Paramixb[3] //Desmembra itens ativo:  "1"-Sim / "2"-Nao
	// Local lTipoDes   := Paramixb[4] //".F." Desmembra itens / ".T." Desmembra codigo base

	// MsgAlert("Execu??o do ponto de entrada MT103AFN")

	// If !Empty(aTeste)
	// 	MsgAlert("Projeto (Integra??o PMS):" + aTeste[1][2][1][1])
	// EndIf

	// MsgAlert("Atualiza Ativo?(S-Sim /N-Nao): " + cAtuaATF)
	// MsgAlert("Desmembra itens ativo?(1-Sim /2-Nao): " + cDesItATF)
	// MsgAlert("F-Desmembra itens / T-Desmembra codigo base: " + (iif(lTipoDes,"T","F")))
    IF cAtuaATF == "S" 
        cBase := Right(Alltrim(SD1->D1_CHASSI),10)
        cItem := "0001"
    Endif

    aRet := {cBase, cItem}

	// MsgAlert("Codigo - Item personalizados: " + aRet[1] + " - " + aRet[2])

Return(aRet)
