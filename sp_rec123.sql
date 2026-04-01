-- Procedimiento que Busca el ajustador a asginar.

-- Creado    : 26/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec123;

CREATE PROCEDURE "informix".sp_rec123(a_cod_entrada	char(10))
returning integer;

define _cod_asignacion	char(10);
define _cod_ajustador   char(3);
define _van			    integer;
define _int			    integer;
define _error 			integer;
define _total           integer;
define _fecha_hora_min	datetime year to minute;

SET ISOLATION TO DIRTY READ;

let _fecha_hora_min = CURRENT;
let _van = 0;
let _int = 0;

begin
on exception set _error
 	return _error;         
end exception

select count(*)
  into _total
  from recajust
 where activo      = 1
   and control_doc = 1;

foreach
	select cod_asignacion
	  into _cod_asignacion
	  from atcdocde
	 where cod_entrada = a_cod_entrada
	   and completado         = 0
	   and imcs_asignar       = 0
	   and ajustador_asignado = 0

	let _van = _van + 1;

	foreach

		select cod_ajustador
		  into _cod_ajustador
		  from recajust
		 where activo      = 1
		   and control_doc = 1
		 order by cod_ajustador

		let _int = _int + 1;

		if _van = _int then
			let _int = 0;
			if _van = _total then
				let _van = 0;
			end if
			exit foreach;
		end if

    end foreach

	update atcdocde
	   set cod_ajustador      = _cod_ajustador,
	       ajustador_asignado = 1,
		   ajustador_fecha    = _fecha_hora_min
	 where cod_asignacion     = _cod_asignacion;

end foreach

foreach
	select cod_asignacion
	  into _cod_asignacion
	  from atcdocde
	 where cod_entrada = a_cod_entrada
	   and completado         = 0
	   and imcs_asignar       = 1
	   and ajustador_asignado = 0

	update atcdocde
	   set cod_ajustador      = null,
		   ajustador_asignar  = 0,
	       ajustador_asignado = 0,
		   ajustador_fecha    = null
	 where cod_asignacion     = _cod_asignacion;

end foreach

end

Return 0;

END PROCEDURE
