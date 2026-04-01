

create procedure sp_sac132()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(7);
		  
define _error_desc2		varchar(50);
define _error_desc		varchar(50);
define _cuenta			char(25);
define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _anular_nt		char(10);
define _no_poliza		char(10);
define _periodo2		char(7);
define _periodo			char(7);
define _cod_cobertura	char(5);
define _cod_cober_reas	char(3);
define _cod_tipoprod	char(3);
define _auxiliar		char(1);
define _var_cob_total	dec(16,2);
define _var_cob_bruto	dec(16,2);
define _var_cob_neto	dec(16,2);
define _monto_bruto		dec(16,2);
define _monto_neto		dec(16,2);
define _porc_reas		dec(16,6);
define _porc_coas		dec(16,2);
define _monto2			dec(16,2);
define _monto1			dec(16,2);
define _mes				smallint;
define _ano				smallint;
define _error_isam		integer;
define _notrx_2			integer;
define _error2			integer;
define _notrx			integer;
define _error			integer;
define _fecha			date;
define _fechatrx		date;

--set debug file to "sp_sac132.trc";
--trace on; 

begin 
on exception set _error, _error_isam, _error_desc

	drop table tmp_asientos;

	return _error,
		   _error_desc,
		   0.00,
		   0.00,
		   0.00,
		   "",
		   ""	
		   with resume;
end exception

create temp table tmp_asientos(
no_trx		integer,
periodo		char(7),
cuenta		char(25),
monto1		dec(16,2),
monto2		dec(16,2)) with no log;

set isolation to dirty read;

call sp_sac104() returning _ano, _periodo, _fecha;

if _periodo < "2009-04" then

	let _periodo = "2009-04";
	let _fecha   = "01/04/2009";

end if

foreach
	select res_fechatrx,
		   res_cuenta,
		   res_notrx,
		   sum(res_debito - res_credito)
	  into _fechatrx,
		   _cuenta,
		   _notrx,
		   _monto1
	  from cglresumen
	 where res_comprobante[1,3] = "REC"
	   and res_fechatrx >= _fecha
	 group by 1, 2, 3

	let _periodo2 = sp_sis39(_fechatrx);

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _monto1, 0.00);

end foreach

foreach
	select sac_notrx,
		   cuenta,
		   periodo,
		   sum(debito + credito)
	  into _notrx,
		   _cuenta,
		   _periodo2,
		   _monto2
	  from recasien
	 where periodo >= _periodo
	 group by 1, 2, 3

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, 0.00, _monto2);
end foreach

let _notrx_2 = "00000";
 
foreach	with hold
	select no_trx,
		   periodo,
		   cuenta,
		   sum(monto1),
		   sum(monto2)
	  into _notrx,
		   _periodo2,
		   _cuenta,
		   _monto1,
		   _monto2
	  from tmp_asientos
	 --where no_trx = 426460
	 group by 1, 2, 3
	 order by 2, 1, 3

	if _monto1 <> _monto2 then

		select cta_auxiliar
		  into _auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _auxiliar = "N" then
			let _auxiliar = "";
		end if

		{
		if _notrx <> _notrx_2 then

			call sp_sac77(_notrx) returning _error, _error_desc;
			
			let _notrx_2 = _notrx;

		end if
		--}

		return _notrx,
			   _cuenta,
			   _monto1,
			   _monto2,
			   (_monto2 - _monto1),
			   _auxiliar,
			   _periodo2	
			   with resume;
	end if
end foreach

drop table tmp_asientos;

-- Pagos

let _monto2 = 0;

foreach
	select no_tranrec,
		   monto,
		   periodo,
		   no_reclamo,
		   anular_nt
	  into _no_tranrec,
		   _monto1,
		   _periodo2,
		   _no_reclamo,
		   _anular_nt
	  from rectrmae
	 where periodo >= _periodo
	   and actualizado  = 1
	   and sac_asientos = 2
	   and cod_tipotran in ("004")
	   and monto <> 0

	select count(*)
	  into _notrx
      from reccoas
     where no_reclamo   = _no_reclamo;

	if _notrx = 0 then

			return 3,
				   _no_tranrec,
				   _monto1,
				   _monto2,
				   (_monto2 - _monto1),
				   "",
				   _periodo2	
				   with resume;

	end if

	select porc_partic_coas
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = "036";

	if _porc_coas is null then
		let _porc_coas = 0;
	end if

	let _monto1 = _monto1 * _porc_coas / 100;

	select sum(debito + credito)
	  into _monto2
	  from recasien
	 where no_tranrec  = _no_tranrec
	   and cuenta[1,3] = "541";

	if _monto2 is null then
		let _monto2 = 0;
	end if
	   
	if abs(_monto1 - _monto2) > 0.01 then

			return 1,
				   _no_tranrec,
				   _monto1,
				   _monto2,
				   (_monto2 - _monto1),
				   "",
				   _periodo2	
				   with resume;

	end if
	
	if _anular_nt is null then
		let _anular_nt = '';
	end if
	
	select no_poliza
	  into _no_poliza	
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _anular_nt <> '' and _cod_tipoprod = '002' and _no_tranrec not in ('1793039','1870633','1867074','1834299','1910448','1910399') then
		select sum(debito + credito)
		  into _monto2
		  from rectrmae t, recasien a
		 where t.no_tranrec = a.no_tranrec
		   and t.transaccion = _anular_nt
		   and a.cuenta = '26612';

		if _monto2 is null then
			let _monto2 = 0.00;
		end if

		select sum(debito + credito)
		  into _monto1
		  from recasien
		 where no_tranrec  = _no_tranrec
		   and cuenta = '26612';

		if _monto1 is null then
			let _monto1 = 0.00;
		end if

		if abs(_monto1 + _monto2) > 0.01 then

			return 10,
				   _no_tranrec,
				   _monto1,
				   _monto2,
				   (_monto2 - _monto1),
				   "",
				   _periodo2	
				   with resume;

		end if
	end if
end foreach

-- Variacion

--trace on;

let _monto2 = 0;

if _periodo < "2015-09" then
	let _periodo = "2015-09";
end if

foreach
 select no_tranrec,
		variacion,
		periodo,
		no_reclamo
   into _no_tranrec,
        _monto1,
		_periodo2,
		_no_reclamo
   from rectrmae
  where periodo     >= _periodo
    and actualizado  = 1 
	and sac_asientos = 2
	and variacion    <> 0
--	and no_tranrec   = "1376185"

	select count(*)
	  into _notrx
	  from tranpen
	 where no_tranrec = _no_tranrec;

 	if _notrx is null then
		let _notrx = 0;
	end if

	if _notrx <> 0 then
		continue foreach;
	end if

	select count(*)
	  into _notrx
	  from recasien
	 where no_tranrec = _no_tranrec;

 	if _notrx is null then
		let _notrx = 0;
	end if

	if _notrx = 0 then

			return 4,
				   _no_tranrec,
				   _monto1,
				   0,
				   (0 - _monto1),
				   "",
				   _periodo2	
				   with resume;

	end if

	select porc_partic_coas
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = "036";

	if _porc_coas is null then
	
		let _porc_coas = 0;

		return 8,
			   _no_tranrec,
			   0,
			   0,
			   0,
			   "",
			   _periodo2	
			   with resume;
			   
	end if

	-- Variacion Neta (553)

	let _monto_bruto = _monto1 / 100 * _porc_coas;
	let _monto_neto  = 0;

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
		  into _notrx
		  from rectrrea
		 where no_tranrec     = _no_tranrec
		   and cod_cober_reas = _cod_cober_reas;

		if _notrx = 0 then

			return 5,
				   _no_tranrec,
				   _monto1,
				   _monto2,
				   (_monto2 - _monto1),
				   "",
				   _periodo2	
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
		let _monto_neto    = _monto_neto    + _var_cob_neto;

	end foreach

	-- Validacion 553
	
	select sum(debito + credito)
	  into _monto2
	  from recasien
	 where no_tranrec  = _no_tranrec
	   and cuenta[1,3] = "553";

	if _monto2 is null then
		let _monto2 = 0;
	end if

	if _monto2 <> _monto_neto then
	
		if _no_tranrec not in ('1873244','1847897') then

			return 6,
				   _no_tranrec,
				   _monto_neto,
				   _monto2,
				   (_monto2 - _monto_neto),
				   "",
				   _periodo2	
				   with resume;
		end if
	end if

	-- Validacion 221
	
	select sum(debito + credito)
	  into _monto2
	  from recasien
	 where no_tranrec  = _no_tranrec
	   and cuenta[1,3] = "221";

	if _monto2 is null then
		let _monto2 = 0;
	end if

	let _monto2 = _monto2 * -1;
	
	if _monto2 <> _monto_bruto then

		return 7,
			   _no_tranrec,
			   _monto_bruto,
			   _monto2,
			   (_monto2 - _monto_bruto),
			   "",
			   _periodo2	
			   with resume;

	end if

end foreach

if _periodo < "2015-01" then
	let _periodo = "2015-01";
end if

foreach
 select no_tranrec,
		variacion,
		periodo,
		no_reclamo,
		monto
   into _no_tranrec,
        _monto1,
		_periodo2,
		_no_reclamo,
		_monto2
   from rectrmae
  where periodo     >= _periodo
    and actualizado  = 0
--	and sac_asientos = 2

	select count(*)
	  into _notrx
	  from recasien
	 where no_tranrec = _no_tranrec;

 	if _notrx is null then
		let _notrx = 0;
	end if

	if _notrx <> 0 then

			{
			update rectrmae
			   set sac_asientos = 0
			 where no_tranrec   = _no_tranrec;   

			delete from recasien
			 where no_tranrec = _no_tranrec;
			--}
			
			return 9,
				   _no_tranrec,
				   _monto1,
				   _monto2,
				   0,
				   "",
				   _periodo2	
				   with resume;

	end if
	
end foreach

let _periodo = "2015-07";

{
foreach
 select no_tranrec,
		variacion,
		periodo,
		no_reclamo,
		monto
   into _no_tranrec,
        _monto1,
		_periodo2,
		_no_reclamo,
		_monto2
   from rectrmae
  where periodo     >= _periodo
    and actualizado  = 1
--	and sac_asientos = 2
	and cod_tipotran not in ("005", "006", "007")

	if _monto1 = 0 and
	   _monto2 = 0 then
		continue foreach;
	end if
	
	select count(*)
	  into _notrx
	  from recasien
	 where no_tranrec = _no_tranrec;

 	if _notrx is null then
		let _notrx = 0;
	end if

	if _notrx = 0 then

			return 10,
				   _no_tranrec,
				   _monto1,
				   _monto2,
				   0,
				   "",
				   _periodo2	
				   with resume;

	end if
	
end foreach
--}


end

return "0",
	   "",
	   0.00,
	   0.00,
	   0.00,
	   "",
	   "";

end procedure
                                                                                                                                                                                                                                                     
