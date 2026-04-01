-- Procedimiento para verificar si hay que ejecutar la facturacion mensual de salud automatica
--
-- Creado    : 11/02/2016 - Autor: Armando Moreno M.
-- Modificado: 11/02/2016 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis222;
CREATE PROCEDURE sp_sis222()
RETURNING smallint,char(7),date,date,char(8);

DEFINE _valor  		 smallint;
DEFINE _periodo_eval char(7);
DEFINE _fecha_inicio date;
DEFINE _fecha_fin    date;
DEFINE _usuario      char(8);
DEFINE _emi_periodo  char(7);

let _periodo_eval = null;
let _fecha_inicio = null;
let _fecha_fin    = null;
let _usuario      = "";

foreach

	select periodo,
	       user_added
	  into _periodo_eval,
	       _usuario
	  from parcontrol
	 where estatus = 0

end foreach

if _periodo_eval is null then
	let _valor = 0;
else
	let _valor = 1;
	select emi_periodo into _emi_periodo from parparam;
	if _emi_periodo = _periodo_eval then
	else
		let _valor = 0;
	end if
	let _fecha_inicio = sp_sis36b(_periodo_eval);
	let _fecha_fin    = sp_sis36(_periodo_eval);	
end if
	
RETURN _valor,_periodo_eval,_fecha_inicio,_fecha_fin,_usuario;

END PROCEDURE;