#Include 'Totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA1151
Grava campo customizado na ST9 a partir de um Ativo.
@author  NG Informática
@since   24/02/2020
@version P12
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*
+-------------------------------------------------------------------------------------------------------+
¦ Programa responsavel por mudar a categoria do bem para '4' no momento da importação 
¦ Desenvolvido para LOCAVEL
¦ @author  Elivelton Canedo elivelton.canedo@totvs.com.br
| @since 02/12/2024
¦ Ultima atualização
¦ Historico :
|
¦
+-------------------------------------------------------------------------------------------------------+
Obs:
ATUALIZAR NA OFICIAL:

MV_CATBEM parâmetro criado para cadastrar qual categoria irá ser salvo o bem.
/*/
//-------------------------------------------------------------------

User Function MNTA1151()

    Local aAtvNBEM  := PARAMIXB[1]
    Local aAreaST9  := GetArea()
    Local x
    Local cCATBEM   := GetMV("MV_CATBEM")

    If Len(aAtvNBEM) > 0 .and. !Empty(cCATBEM)

        dbSelectArea("ST9")
        dbSetOrder(1)

        For x:= 1 To Len(aAtvNBEM)
            If dbSeek(xFilial("ST9")+aAtvNBem[x][1] )
                RecLock('ST9',.F.)
                ST9->T9_CATBEM   := cCATBEM
                ST9->(MsUnLock())
            EndIf
        Next

    EndIf

    RestArea( aAreaST9 )

Return .T.
