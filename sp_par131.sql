-- Procedimiento que muestra la provision de comision por pagar
-- 
-- Creado     : 28/12/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par131;

create procedure "informix".sp_par131(a_periodo char(7))
returning char(20),
	      dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(3),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_impuesto	char(3);
define _factor_impuesto	dec(5,2);
define _suma_impuesto   dec(16,2);

define _saldo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_calc		dec(16,2);
define _porc_partic		dec(7,4);

define _porc_comision	dec(16,2);
define _porc_comis_par	dec(16,2);
define _comision_sus 	dec(16,2);
define _comision_monto	dec(16,2);

define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _cod_tipoprod	char(3);
define _nombre_tipoprod	char(50);

--set debug file to "sp_par131.trc";
--trace on;

set isolation to dirty read;

foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
--    and cod_tipoprod in ("002")
--  and cod_tipoprod in ("001", "002", "005")
--	and no_documento = "0203-00428-23"
  group by no_documento

	let _no_poliza   = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_ramo
	  into _cod_tipoprod,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then -- Reaseguro Asumido
		continue foreach;
	end if

	let _saldo = sp_cob175(_no_documento, a_periodo);

	if _saldo = 0.00 then
		continue foreach;
	end if

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_tipoprod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	Let _suma_impuesto = 1;

	Foreach	
	 Select cod_impuesto
	   Into _cod_impuesto
	   From emipolim
	  Where no_poliza = _no_poliza

		Select factor_impuesto
		  Into _factor_impuesto
		  From prdimpue
		 Where cod_impuesto = _cod_impuesto;
			    
		Let _suma_impuesto = _suma_impuesto + _factor_impuesto / 100;

	End Foreach
	
	let _prima_neta = _saldo / _suma_impuesto;
	let _impuesto   = _saldo - _prima_neta;
	let _prima_calc = _prima_neta;

	if _cod_tipoprod = "001" then -- Coaseguro Mayoritario
	
		select sum(porc_partic_coas)
		  into _porc_partic
		  from emicoama
	     where no_poliza    = _no_poliza
	       and cod_coasegur = "036";

		IF _porc_partic IS NULL THEN
			LET _porc_partic = 0;
		END IF
		
		let _prima_calc = _prima_calc * _porc_partic / 100;

	end if

	LET _comision_sus = 0.00;

	FOREACH
	 SELECT porc_comis_agt,
		    porc_partic_agt
	   INTO _porc_comision,
	        _porc_comis_par
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza

		IF _porc_comision IS NULL THEN
			LET _porc_comision = 0.00;
		END IF

		LET _comision_monto = (_prima_calc * (_porc_comision/100) * (_porc_comis_par/100));
		LET _comision_sus   = _comision_sus + _comision_monto;

	END FOREACH;

	return _no_documento,
	       _saldo,
		   _prima_neta,
		   _impuesto,
		   _prima_calc,
		   _comision_sus,
		   0.00,
		   0.00,
		   _cod_ramo,
		   _nombre_ramo,
		   _cod_tipoprod,
		   _nombre_tipoprod
		   with resume;

end foreach

end procedure