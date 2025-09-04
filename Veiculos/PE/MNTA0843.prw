/*/{Protheus.doc} MNTA0843
(long_description)
@type user function
@author user
@since 02/06/2025
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function MNTA0843()  
    Local aRotina := PARAMIXB[1]
    aAdd( aRotina, {"Pesquisa BIN API", "U_UGFRE001()", 0, 2, 0} )
Return aRotina
