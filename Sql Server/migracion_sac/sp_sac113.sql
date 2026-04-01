-- Procedure que verifica que cuadre SAC Vs Cobros

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac113;

create procedure sp_sac113()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(7),
		  char(3);
		  
define _error_desc		char(50);
define _cuenta			char(25);
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _periodo_verif	char(7);
define _periodo2		char(7);
define _periodo			char(7);
define _ccosto			char(3);
define _auxiliar		char(1);
define _impuesto		dec(16,2);
define _monto1			dec(16,2);
define _monto2			dec(16,2);
define _tiene_impuesto	smallint;
define _sac_asientos	smallint;
define _cantidad		smallint;
define _mes				smallint;
define _ano				smallint;
define _error_isam		integer;
define _notrx_2			integer;
define _renglon			integer;
define _notrx			integer;
define _error			integer;
define _fechatrx		date;
define _fecha			date;

let _notrx = "";

begin 
on exception set _error, _error_isam, _error_desc

	drop table tmp_asientos;

	return _error,
		   trim(_error_desc) || _notrx,
		   0.00,
		   0.00,
		   0.00,
		   "",
		   "",
		   ""	
		   with resume;

end exception

create temp table tmp_asientos(
no_trx		integer,
periodo		char(7),
cuenta		char(25),
ccosto		char(3),
monto1		dec(16,2),
monto2		dec(16,2)
) with no log;

set isolation to dirty read;

call sp_sac104() returning _ano, _periodo, _fecha;

-- cglresumen

--{

select periodo_verifica
  into _periodo_verif
  from emirepar;

foreach
 select res_fechatrx,
		res_cuenta,
		res_notrx,
		res_ccosto,
		sum(res_debito - res_credito)
   into _fechatrx,
		_cuenta,
		_notrx,
		_ccosto,
		_monto1
   from cglresumen
  where res_origen    = "COB"
	and res_fechatrx  >= _fecha
	--and (res_cuenta like '131%' or res_cuenta like '141%')
  group by 1, 2, 3, 4

	let _periodo2 = sp_sis39(_fechatrx);

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _ccosto, _monto1, 0.00);

end foreach

-- cobasien

foreach
 select sac_notrx,
		cuenta,
		periodo,
		centro_costo,
        sum(debito - credito)
   into _notrx,
		_cuenta,
		_periodo2,
		_ccosto,
        _monto2
   from cobasien 
  where periodo  >= _periodo
  group by 1, 2, 3, 4

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _ccosto, 0.00, _monto2);

end foreach

-- diferencia

let _notrx_2 = "00000";

foreach	with hold
 select no_trx,
        periodo,
		cuenta,
		ccosto,
        sum(monto1),
        sum(monto2)
   into _notrx,
        _periodo2,
		_cuenta,
		_ccosto,
        _monto1,
        _monto2
   from tmp_asientos
--  where ccosto = "017"
--    and no_trx = 31156
  group by 1, 2, 3, 4
  order by 2, 1, 3, 4

	if _monto1 <> _monto2 then


--		call sp_sac115(_notrx) returning _error, _error_desc;

--		if _error <> 0 then

--			return _error,
--				   _error_desc,
--				   0.00,
--				   0.00,
--				   0.00,
--				   "",
--				   "",
--				   _ccosto
--				   with resume;

--		end if

		select cta_auxiliar
		  into _auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _auxiliar = "N" then
			let _auxiliar = "";
		end if

		if _notrx in (877946,877940,877942,877946,877948) then
			continue foreach;
		end if
		--{
		if _notrx <> _notrx_2 then

			if _periodo2 = _periodo_verif then
				--call sp_sac77(_notrx) returning _error, _error_desc;
			end if
			let _notrx_2 = _notrx;

		end if
		--}
		
		return _notrx,
			   _cuenta,
			   _monto1,
			   _monto2,
			   (_monto2 - _monto1),
			   _auxiliar,
			   _periodo2,
			   _ccosto	
			   with resume;

	end if

end foreach
--}

drop table tmp_asientos;


-- Validacion de periodos

--{

foreach
 select m.no_remesa, 
        a.periodo
   into _no_remesa,
        _periodo2
   from cobremae m, cobredet d, cobasien a
  where m.no_remesa   = d.no_remesa
    and d.no_remesa   = a.no_remesa
    and d.renglon     = a.renglon
    and m.actualizado = 1
    and (m.periodo <> d.periodo or
         d.periodo <> a.periodo)
    and (m.periodo >= _periodo or
         d.periodo >= _periodo or
         a.periodo >= _periodo )
  group by 1, 2

	if _no_remesa = "872951" then
		continue foreach;
	end if

	return "0",
		   _no_remesa,
		   0,
		   0,
		   0,
		   "",
		   _periodo2,
		   "001"	
		   with resume;


end foreach
--}

-- Verificacion de cobasien

foreach
 select no_remesa,
        renglon,
		prima_neta,
		periodo,
		doc_remesa,
		impuesto
   into	_no_remesa,
        _renglon,
		_monto1,
		_periodo2,
		_no_documento,
		_impuesto
   from cobredet
  where periodo     >= _periodo
    and actualizado  = 1
	and sac_asientos = 2
	and tipo_mov     <> "B"

	select count(*)
	  into _cantidad
	  from cobasien
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _cantidad = 0 then

		return 0,
			   trim(_no_remesa) || "-" || _renglon,
			   0,
			   0,
			   _cantidad,
			   "",
			   _periodo2,
			   "002"	
			   with resume;

	end if

end foreach

if _periodo < "2014-10" then
	let _periodo = "2014-10";
end if

foreach
 select no_remesa,
        renglon,
		prima_neta,
		periodo,
		doc_remesa,
		impuesto,
		sac_asientos
   into	_no_remesa,
        _renglon,
		_monto1,
		_periodo2,
		_no_documento,
		_impuesto,
		_sac_asientos
   from cobredet
  where periodo     >= _periodo
    and actualizado  = 1
	and tipo_mov    in ("P", "N", "X")

	-- Validacion Cuenta 131

	if _sac_asientos = 2 then

		select sum(debito - credito),
		       cuenta
		  into _monto2,
		       _cuenta
		  from cobasien
		 where no_remesa   = _no_remesa
		   and renglon     = _renglon
		   and cuenta[1,3] in ("131", "144")
	     group by cuenta;

		if _monto2 is null then
			let _monto2 = 0;
		end if

		let _monto2 = _monto2 * -1;

		if _monto1 <> _monto2 then

			return _no_remesa,
				   _cuenta,
				   _monto1,
				   _monto2,
				   (_monto2 - _monto1),
				   "",
				   _periodo2,
				   "003"	
				   with resume;

		end if

	end if

	-- Validacion de Impuestos

	if _periodo2 >= "2014-12" then
	
		let _no_poliza = sp_sis21(_no_documento);

		select tiene_impuesto
		  into _tiene_impuesto
		  from emipomae
		 where no_poliza = _no_poliza;

		select count(*)
		  into _cantidad
		  from emipolim
		 where no_poliza = _no_poliza;  

		if _tiene_impuesto  = 1 and
		   _impuesto        = 0 and
		   abs(_monto1)     > 0.11 then	-- Montos Menores el impuesto es 0.00
		
			return _tiene_impuesto,
				   trim(_no_remesa) || "-" || _renglon || "(" || _no_documento || ")",
				   _monto1,
				   _impuesto,
				   _cantidad,
				   "",
				   _periodo2,
				   "004"	
				   with resume;

		end if

		if _tiene_impuesto = 0  and
		   _impuesto       <> 0 then

--			update cobredet
--			   set prima_neta   = monto,
--			       impuesto     = 0,
--				   sac_asientos = 0
--			 where no_remesa    = _no_remesa
--			   and renglon      = _renglon;

			if _no_remesa not in ("891279") then
			
				return _tiene_impuesto,
					   trim(_no_remesa) || "-" || _renglon || "(" || _no_documento || ")",
					   _monto1,
					   _impuesto,
					   _cantidad,
					   "",
					   _periodo2,
					   "005"	
					   with resume;
					   
			end if
					   
		end if

		if _tiene_impuesto = 0  and
		   _cantidad       <> 0 then

			return _tiene_impuesto,
				   trim(_no_remesa) || "-" || _renglon || "(" || _no_documento || ")",
				   _monto1,
				   _impuesto,
				   _cantidad,
				   "",
				   _periodo2,
				   "006"	
				   with resume;

		end if

	end if

end foreach

end

return "0",
	   "",
	   0.00,
	   0.00,
	   0.00,
	   "",
	   "",
	   "";

end procedure