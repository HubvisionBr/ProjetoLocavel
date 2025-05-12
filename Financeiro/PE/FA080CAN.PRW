#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FA080CAN
Cancelamento/Exclusão de baixas do contas a pagar, apos gravar os dados no SE2 e antes de grava-los no SE5
@type function
@author HUBVISION
@since 17/12/2024

@history 
/*/

User Function FA080CAN()

local lRet := .T.
local aAreaSEU := SEU->(getarea())
local aAreaSE5 := SE5->(getarea())
//local cAliasNew := GetNextAlias()

If FWIsInCallStack("FA080Can")
     
     If SE2->(FieldPos("E2_XNUMCX")) > 0 

          If !EMPTY(SE2->E2_XNUMCX)

               lRet := U_F560AUT(5,'00',SE2->E2_XNUMCX)

          Endif     
          
     Endif

Endif

Restarea(aAreaSEU)
Restarea(aAreaSE5)

Return lRet
