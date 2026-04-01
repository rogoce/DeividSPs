-- Deterioro de Cartera NIIF , identificar las fianzas de propuesta, fianza de corredor. y excluir el ramo transporte.
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

--drop procedure sp_niif03;
create procedure "informix".sp_niif03()
returning   char(20);

define _no_documento    char(20);
define _no_poliza       char(10);
define _cod_subramo     char(3);

begin

set isolation to dirty read;

--006 = fianza corredor
--002 = propuesta
--Excluir ramo de transporte

foreach

	select no_documento
	  into _no_documento
	  from tmp_cobmo
	 where estatus = '*'
       and no_documento[1,2] in('08','80')

	select max(no_poliza)
	  into _no_poliza
      from deivid_cob:cobmoros2
	 where no_documento = _no_documento;

	select cod_subramo
	  into _cod_subramo
	  from deivid:emipomae
	 where no_poliza = _no_poliza;

    if _cod_subramo = '006' then

       update tmp_cobmo
	      set corredor  = '*'
		where no_documento = _no_documento;

    elif _cod_subramo = '002' then

       update tmp_cobmo
	      set propuesta  = '*'
		where no_documento = _no_documento;

	end if

end foreach

return "Actualizacion Terminada";

end
end procedure