-- Procedure que retorna el porcentaje de comision del corredor dependiendo del ramo

drop procedure sp_pro305b;

create procedure sp_pro305b(a_cod_agente char(5)) 
returning char(5), varchar(50), char(3), varchar(50), char(3), varchar(50), dec(5,2);

define _porc_comision	dec(5,2);
define _porc_comis_sub  dec(5,2);
define _tipo_agente		char(1);
define _nombre          varchar(50);
define _cod_ramo        char(3);
define _ramo            varchar(50);
define _cod_subramo     char(3);
define _subramo         varchar(50);

set isolation to dirty read;

select tipo_agente,
       nombre
  into _tipo_agente,
       _nombre
  from agtagent
 where cod_agente = a_cod_agente;

if _tipo_agente = "O" then
	return null,null,null,null,null,null,0.00;
end if

let _porc_comis_sub = 0;

foreach with hold
	select cod_ramo,
		   nombre,
	       porc_comision
	  into _cod_ramo,
	       _ramo,
		   _porc_comision
	  from prdramo
	 order by 2

	let _porc_comis_sub = 0;
	
	foreach with hold  
		select cod_subramo,
			   nombre,
			   porc_comision
		  into _cod_subramo,
			   _subramo,
			   _porc_comis_sub
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and activo = 1
		 order by 2
		 
		if _porc_comis_sub > 0 and _porc_comis_sub <= 100 then
			let _porc_comision = _porc_comis_sub;
		end if
	 
		foreach 
			select porc_comis_agt
			  into _porc_comision
			  from agtcomra
			 where cod_agente = a_cod_agente
			   and cod_ramo = _cod_ramo
		end foreach
		
		foreach
			select porc_comision
			  into _porc_comision
			  from agtcomsu
			 where cod_agente  = a_cod_agente
			   and cod_ramo = _cod_ramo
			   and cod_subramo = _cod_subramo
		end foreach

		return a_cod_agente,
			   _nombre, 
			   _cod_ramo,
			   _ramo,
			   _cod_subramo,
			   _subramo,
			   _porc_comision with resume;
	end foreach
end foreach



end procedure