drop procedure sp_par343;

create procedure "informix".sp_par343()
returning char(20),
          char(10),
          char(7),
          char(50),
		  dec(16,2),
		  dec(16,2),
		  date;

define v_filtros    	char(255);

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _no_tranrec		char(10);
define _transaccion		char(10);
define _fecha			date;
define _cantidad		smallint;

define v_reserva_neto	decimal(16,2);
define v_doc_reclamo    char(18);
define _monto_asiento	dec(16,2);

define _monto_total     decimal(16,2);
define _monto_bruto     decimal(16,2);
define _monto_neto      decimal(16,2);

define _var_cob_total	decimal(16,2);
define _var_cob_bruto   decimal(16,2);
define _var_cob_neto    decimal(16,2);

define _cod_cobertura	char(5);
define _cod_cober_reas	char(3);

define _porc_coas       decimal(16,2);
define _porc_reas       decimal(16,6);

define a_periodo		char(7);
define _periodo			char(7);

define _cod_ramo		char(3);
define _nom_ramo		char(50);

--set debug file to "sp_par343.trc";
--trace on;

let a_periodo = "2014-05";

foreach
 select no_tranrec,
        variacion,
		transaccion,
		no_reclamo,
		periodo,
		fecha
   into _no_tranrec,
		_monto_total,
		_transaccion,
		_no_reclamo,
		_periodo,
		_fecha
   from rectrmae
  where periodo      >= a_periodo
    and actualizado  = 1
	and sac_asientos = 2
--	and variacion    <> 0
--	and no_reclamo  = "317125"
--  and transaccion = "10-187378"
  order by periodo

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

--	if _cod_ramo not in ("002", "020") then
--		continue foreach;
--	end if

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- Informacion de Coaseguro

	select porc_partic_coas
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = "036";

	if _porc_coas is null then
		let _porc_coas = 0;
	end if

	-- Variacion Neta

	LET _monto_neto  = 0;

	foreach
	 select	cod_cobertura,
	        variacion
	   into	_cod_cobertura,
	        _var_cob_total
	   from rectrcob
	  where no_tranrec = _no_tranrec
		and variacion  <> 0

		select cod_cober_reas
		  into _cod_cober_reas
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

		-- Informacion de Reaseguro

		select count(*)
		  into _cantidad
		  from rectrrea
		 where no_tranrec     = _no_tranrec
		   and cod_cober_reas = _cod_cober_reas;

		if _cantidad = 0 then

			return _transaccion,
				   _no_tranrec,
				   _periodo,
				   "Error",
				   _var_cob_total,
				   0,
				   _fecha
				   with resume;

		end if

		let _porc_reas = 0;

		select porc_partic_suma
		  into _porc_reas
		  from rectrrea
		 where no_tranrec     = _no_tranrec
		   and cod_cober_reas = _cod_cober_reas
		   and tipo_contrato  = 1;

		if _porc_reas is null then
		
			let _porc_reas = 0;

		end if;
	
		let _var_cob_bruto = _var_cob_total / 100 * _porc_coas;
		let _var_cob_neto  = _var_cob_bruto / 100 * _porc_reas;
		LET _monto_neto    = _monto_neto    + _var_cob_neto;

	end foreach

	select sum(debito + credito)
	  into _monto_asiento
	  from rectrmae	t, recasien a
	 where t.no_tranrec  = a.no_tranrec
	   and t.no_tranrec  = _no_tranrec
	   and a.cuenta[1,3] = "553";

	if _monto_asiento is null then
		let _monto_asiento = 0;
	end if

	if _monto_asiento <> _monto_neto then

--		update rectrmae
--		   set sac_asientos = 0
--		 where transaccion  = _transaccion;

		return _transaccion,
			   _no_tranrec,
			   _periodo,
			   _nom_ramo,
			   _monto_neto,
			   _monto_asiento,
			   _fecha
			   with resume;

	end if

end foreach

--drop table tmp_sinis;
			
return "0",
       "0",
	   "",
	   "",
	   0,
	   0,
	   null;

end procedure