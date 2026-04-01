--**************************************************************
-- R E P O R T E para consurso a Milan 2008 Corredores
--**************************************************************

-- Creado    : 11/06/2008 - Autor: Armando Moreno M.
-- Modificado: 17/06/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che86a;

CREATE PROCEDURE sp_che86a(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
RETURNING char(5),char(50),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),INT,INT,DEC(16,2),smallint,smallint;

define _cod_agente   		 char(5);
define _nombre_agente   	 char(50);
define _sini_inc			 dec(16,2);
define _siniestralidad  	 dec(16,2);
define _pri_sus_pag     	 dec(16,2);
define _crecimiento     	 dec(16,2);
define _crecimiento2    	 dec(16,2);
define _pri_sus_pag_ap  	 dec(16,2);
define _vigente_aa           int;
define _vigente_ap           int;
define _aplica               smallint;
define _cre_prima_aplica     smallint;
define _min_prima_pag_aplica smallint;
define _cre_pol_vig_aplica   smallint;
define _sini_aplica          smallint;
define _tiene				 smallint;

--SET DEBUG FILE TO "sp_che86a.trc";   
--TRACE ON;

let _crecimiento  		  = 0;
let _crecimiento2 		  = 0;
let _aplica       	      = 0;
let _sini_aplica          = 0;
let _cre_prima_aplica     = 0;
let _min_prima_pag_aplica = 0;
let _cre_pol_vig_aplica   = 0;
let _tiene                = 0;

foreach

	 select cod_agente,
	        sum(pri_sus_pag),
			sum(sini_inc),
			sum(siniestra),
			sum(vigente)
	   into _cod_agente,
	        _pri_sus_pag,
			_sini_inc,
   		    _siniestralidad,
			_vigente_aa
	   from concurso
	  group by cod_agente
	  order by cod_agente

	 select sum(pri_sus_pag),
	        sum(vigente)
	   into _pri_sus_pag_ap,
	        _vigente_ap
	   from concurso2
	  where cod_agente = _cod_agente;

	 if _pri_sus_pag_ap is null then
		let _pri_sus_pag_ap = 0;
	 end if

	 let _crecimiento = 0;

	 if _pri_sus_pag_ap <> 0 then
		 let _crecimiento = ((_pri_sus_pag - _pri_sus_pag_ap) / _pri_sus_pag_ap) * 100;
	 end if

	 if _crecimiento = 0 then
		let _crecimiento = 100;
	 end if

	 if _vigente_ap is null then
		let _vigente_ap = 0;
	 end if

	 let _crecimiento2 = 0;

	 if _vigente_ap <> 0 then
		 let _crecimiento2 = ((_vigente_aa - _vigente_ap) / _vigente_ap) * 100;
	 end if

	 if _crecimiento2 = 0 then
		let _crecimiento2 = 100;
	 end if

	SELECT nombre
	  INTO _nombre_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	--Calculos para saber si aplica el corredor
	--*****************************************
	let _siniestralidad = 0;
	if _pri_sus_pag <> 0 then
		let _siniestralidad = (_sini_inc / _pri_sus_pag) * 100;
	end if

	if _siniestralidad <= 40 then
		let _sini_aplica = 1;
	else
		let _sini_aplica = 0;
	end if

	if _crecimiento >= 40 then
		let _cre_prima_aplica = 1;
	else
		let _cre_prima_aplica = 0;
	end if

	if _pri_sus_pag >= 75000 then
		let _min_prima_pag_aplica = 1;
	else
		let _min_prima_pag_aplica = 0;
	end if

	if _crecimiento2 >= 20 then
		let _cre_pol_vig_aplica = 1;
	else
		let _cre_pol_vig_aplica = 0;
	end if

	if _sini_aplica = 1 and _cre_prima_aplica = 1 and _min_prima_pag_aplica = 1 and _cre_pol_vig_aplica = 1 then
		let _aplica = 1;
	else
		let _aplica = 0;
	end if

    let _tiene = _sini_aplica + _cre_prima_aplica + _min_prima_pag_aplica + _cre_pol_vig_aplica;

						 
	RETURN _cod_agente,
		   _nombre_agente,
		   _pri_sus_pag,
		   _sini_inc,
		   _siniestralidad,
		   _pri_sus_pag_ap,
		   _crecimiento,
		   _vigente_aa,
		   _vigente_ap,
		   _crecimiento2,
		   _aplica,
		   _tiene
		   WITH RESUME;

end foreach

END PROCEDURE;