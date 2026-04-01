-- Procedimiento para verificar si ya se ejecuto la facturacion mensual de salud automatica
--
-- Creado    : 29/06/2017 - Autor: Amado Perez M.
-- Modificado: 29/06/2017 - Autor: Amado Perez M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis504pru;
CREATE PROCEDURE "informix".sp_sis504pru()
RETURNING smallint,char(7),date,date,char(8);

DEFINE _valor  		 smallint;
DEFINE _periodo_eval char(7);
DEFINE _fecha_inicio date;
DEFINE _fecha_fin    date;
DEFINE _usuario      char(8);
DEFINE _emi_periodo  char(7);
DEFINE _hoy          date;
DEFINE _mes_ant      date;
DEFINE _fecha1       date;
DEFINE _mes_aniv     char(2);
DEFINE _anio_aniv    char(4);

let _periodo_eval = null;
let _fecha_inicio = null;
let _fecha_fin    = null;
let _usuario      = "";

let _hoy = date(current);

if DAY(_hoy) <> 30 THEN
	RETURN 0,_periodo_eval,_fecha_inicio,_fecha_fin,_usuario;	
end if

foreach

	select periodo,
	       user_added
	  into _periodo_eval,
	       _usuario
	  from parcontrol
	 where estatus = 1
  order by periodo desc
  
  exit foreach;
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
	
	if year(_hoy) = year(_fecha_inicio) then
		if month(_hoy) = month(_fecha_inicio) then
			LET _fecha1 = _fecha_inicio - 1;

			LET _anio_aniv = YEAR(_fecha1);

			IF MONTH(_fecha1) < 10 THEN
				LET _mes_aniv = '0' || MONTH(_fecha1);
			ELSE
				LET _mes_aniv = MONTH(_fecha1);
			END IF

			LET _periodo_eval = _anio_aniv || '-' || _mes_aniv;
		else
			let _valor = 1;
		end if
	else
		let _valor = 1;
	end if
    	
end if
	
RETURN _valor,_periodo_eval,_fecha_inicio,_fecha_fin,_usuario;

END PROCEDURE;
