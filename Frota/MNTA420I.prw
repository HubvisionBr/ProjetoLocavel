#INCLUDE 'PROTHEUS.CH'
 
User Function MNTA420I()
 
    Local aRot := aClone(ParamIXB[1])
     
    Aadd(aRot,{"Imprime OS", "U_UFATR002()" , 0 , 8,0})
     
Return aRot
