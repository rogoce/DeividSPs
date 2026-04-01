-- Anualizacion de polizas del ramo colectivo de vida y vida individual
--
-- Creado    : 08/06/2009 - Autor: Armando Moreno M.

-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_pro392;

CREATE PROCEDURE "informix".sp_pro392(a_ramo char(3))
RETURNING integer;


DEFINE _no_documento   CHAR(20);
DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _vig_fin        DATE;
DEFINE _no_poliza      CHAR(10); 
DEFINE _ano            INTEGER;
DEFINE v_filtros       CHAR(255);
DEFINE _ramo           CHAR(4);
DEFINE _mes            INTEGER;
define _ano_poliza     integer;
define _mes_poliza     integer;
define _ano_actual     integer;
define _ano_end        integer;
define _mes_actual     integer;
define _valor          integer;
define li_mes          integer;
define li_ano          integer;
define li_dia          integer;
define _vif_fin_endoso date;
define _no_endoso      char(5);

--SET DEBUG FILE TO "sp_pro392.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

let _mes_actual = 8;
let _ano_actual = 2009;
let _valor = 0;
let _ano_end = 0;
let _vif_fin_endoso = null;

{FOREACH

	SELECT no_poliza,
		   vigencia_final
	  INTO _no_poliza,
		   _vigencia_final
	  FROM ramo19


	update emipomae
	   set vigencia_final   = _vigencia_final,
	       vigencia_fin_pol = null
	 where no_poliza        = _no_poliza;

END FOREACH}


FOREACH

	SELECT no_poliza,
		   no_documento,
		   vigencia_inic,
		   vigencia_final
	  INTO _no_poliza,
		   _no_documento,
		   _vigencia_inic, 
		   _vigencia_final
	  FROM emipomae
	 WHERE cod_ramo       = a_ramo
	   and actualizado    = 1

	let _vif_fin_endoso = null;
	let li_mes			= 0;
	let li_dia			= 0;
	let li_ano			= 0;

	foreach

		select t.vigencia_final,
		       t.no_endoso 
		  into _vif_fin_endoso,
		       _no_endoso
          from emipomae e, endedmae t
		 where e.no_poliza    = t.no_poliza
		   and e.cod_ramo     = a_ramo
		   and e.actualizado  = 1
		   and t.actualizado  = 1
		   and t.cod_endomov  = '006'
		   and t.no_documento = _no_documento
		 order by t.no_endoso desc

		exit foreach;

	end foreach



	if _vif_fin_endoso is null then

		let li_mes = month(_vigencia_inic);
		let li_dia = day(_vigencia_inic);
		let li_ano = year(_vigencia_inic);
		let li_ano = li_ano + 1;
	    let _vif_fin_endoso = MDY(li_mes, li_dia, li_ano);

	end if
		
	let _mes_poliza = month(_vigencia_inic);
	let _ano_poliza = year(_vigencia_inic);

	let _valor = 0;
	let _valor = _ano_actual - _ano_poliza;

	if _mes_poliza < _mes_actual then

	   let _ano_end = year(_vif_fin_endoso);

	   if _ano_end = 2010 then

			let _valor = _valor + 1;

	   end if

	end if

	if _ano_poliza = _ano_actual then
		let _valor = 1;
	end if

	update emipomae
	   set vigencia_final   = _vif_fin_endoso,
	       vigencia_fin_pol = _vigencia_final,
		   anos_pagador     = _valor
	 where no_poliza        = _no_poliza;

END FOREACH

return 0;

END PROCEDURE;
