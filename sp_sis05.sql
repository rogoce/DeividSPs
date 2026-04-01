-- Buscar banco y chequera

-- Armando Moreno 23/09/2011


drop procedure sp_sis05;

create procedure sp_sis05(a_usuario char(8))
RETURNING char(3),char(3),char(3);

Define ls_cobrador		char(3);
define ls_cod_bco       char(3);
define ls_cod_chequera  char(3);




set isolation to dirty read;

BEGIN
foreach

	select cod_cobrador,
	       cod_banco,
	       cod_chequera
	  into ls_cobrador,
	       ls_cod_bco,
	       ls_cod_chequera
	  from cobcobra 
	 where usuario = a_usuario
	   and activo  = 1

	RETURN ls_cobrador, ls_cod_bco,ls_cod_chequera   WITH RESUME;

	exit foreach;

end foreach


END
end procedure