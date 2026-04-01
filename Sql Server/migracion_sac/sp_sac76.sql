drop procedure sp_sac76;

create procedure sp_sac76()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(7);
		  
define _monto1			dec(16,2);
define _monto2			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _tiene_impuesto	smallint;

define v_comision_sus 	dec(16,2);
define _comision_monto	dec(16,2);
define _porc_comision	dec(16,2);
define _porc_comis_par	dec(16,2);
define _cod_agente		char(10);
define _tipo_agente		char(1);

define _mes				smallint;
define _ano				smallint;
define _periodo			char(7);
define _fecha			date;

define _periodo2		char(7);
define _cuenta			char(25);
define _fechatrx		date;
define _auxiliar		char(1);
define _notrx			integer;
define _notrx_2			integer;

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_poliza2		char(10);
define _no_endoso		char(5);
define _cantidad		integer;

define _vigencia_inic	date;
define _periodo_inic	char(7);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc

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
monto2		dec(16,2)
) with no log;

set isolation to dirty read;

call sp_sac104() returning _ano, _periodo, _fecha;

if _periodo <= "2009-05" then

	let _periodo = "2009-06";
	let _fecha   = "01/06/2009";

end if

--{
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
  where res_comprobante[1,3] = "PRO"
	and res_fechatrx         >= _fecha
  group by 1, 2, 3

	let _periodo2 = sp_sis39(_fechatrx);

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _monto1, 0.00);

end foreach

foreach
 select a.sac_notrx,
		a.cuenta,
		e.periodo,
        sum(a.debito + a.credito)
   into _notrx,
		_cuenta,
		_periodo2,
        _monto2
   from endasien a, endedmae e
  where a.no_poliza    = e.no_poliza
    and a.no_endoso    = e.no_endoso
	and e.periodo      >= _periodo
  group by 1,2,3

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
  where no_trx <> 584899
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
		
		--{
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
--}

drop table tmp_asientos;


if _periodo <= "2010-10" then

	let _periodo = "2010-11";

end if

--let _periodo = "2014-07";

let _auxiliar = "";

foreach
 select no_poliza,
		no_endoso,
		periodo,
        prima_suscrita,
		no_factura,
		prima_neta,
		impuesto,
		vigencia_inic,
		no_documento
   into _no_poliza,
		_no_endoso,
		_periodo2,
        _monto2,
		_cuenta,
		_prima_neta,
		_impuesto,
		_vigencia_inic,
		_no_documento
   from endedmae 
  where periodo     >= _periodo
    and actualizado  = 1
	and sac_asientos = 2

	let _monto1 = 0.00;

	select count(*)
	  into _notrx
	  from endasien
	 where no_poliza = _no_poliza
       and no_endoso = _no_endoso;

	if _notrx   = 0 and
	   _monto2 <> 0 then

		return _notrx,
			   _cuenta,
			   _monto2,
			   _monto1,
			   (_monto2 - _monto1),
			   _auxiliar,
			   _periodo2	
			   with resume;

	end if

	-- Prima Suscrita

	select sum(debito + credito)
	  into _monto1
	  from endasien
	 where no_poliza   = _no_poliza
       and no_endoso   = _no_endoso
       and cuenta[1,3] = "411";

	let _monto1 = _monto1 * -1;

	if _monto1 <> _monto2 then

		return 411,
			   _cuenta,
			   _monto1,
			   _monto2,
			   (_monto2 - _monto1),
			   _auxiliar,
			   _periodo2	
			   with resume;

	end if

	-- Periodo Contable no puede ser menor que vigencia inicial de acuerdo a normas NIFF

	if _periodo2 > "2014-09" then

		let _periodo_inic = sp_sis39(_vigencia_inic);

		if _periodo_inic > _periodo2 and 
		   _monto2      <> 0         then

			update endedmae
			   set periodo      = _periodo_inic,
			       sac_asientos = 0
			 where no_poliza    = _no_poliza
		       and no_endoso    = _no_endoso;

			update endedhis
			   set periodo   = _periodo_inic
			 where no_poliza = _no_poliza
		       and no_endoso = _no_endoso;

			update sac999:reacomp
			   set periodo      = _periodo_inic,
			       sac_asientos = 0
			 where no_poliza    = _no_poliza
		       and no_endoso    = _no_endoso;

			return 411,
				   _cuenta,
				   _monto2,
				   0,
				   (_monto2),
				   _auxiliar,
				   _periodo2	
				   with resume;

		end if

	end if
	

	if _periodo2 <= "2014-04" then
		continue foreach;
	end if

	-- Prima por Cobrar

	select sum(debito + credito)
	  into _monto1
	  from endasien
	 where no_poliza   = _no_poliza
       and no_endoso   = _no_endoso
       and cuenta[1,3] in ("131", "144");
	   
	if _monto1 is null then
		let _monto1 = 0;
	end if

	if abs(_monto1 - _prima_neta) > 0.5 then

		if _cuenta not in ("01-1665905", 
							"01-1660387", 
							"01-1618807", 
							"01-1639114", 
							"07-27693", 
							"01-1649559", 
							"01-1648984", 
							"01-1649220", 
							"01-1649375", 
							"01-1650538", 
							"01-1660062",
							"01-1670612",
							"01-1670882",
							"01-1671127",
							"01-1678489", 
							"01-1764412", 
							"01-1764413", 
							"01-1801991", 
							"01-1764482") then 
		
			return 131,
				   _cuenta,
				   _prima_neta,
				   _monto1,
				   (_prima_neta - _monto1),
				   _auxiliar,
				   _periodo2	
				   with resume;

	   end if

	end if

	-- Comision Corredor

	if _periodo2 <= "2014-06" then
		continue foreach;
	end if

	let v_comision_sus = 0.00;

     foreach
      select porc_comis_agt,
			 porc_partic_agt,
			 cod_agente
        into _porc_comision,
		     _porc_comis_par,
			 _cod_agente
        from endmoage
       where no_poliza = _no_poliza
	     and no_endoso = _no_endoso

		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		-- Solo procesa las comisiones para los Agentes normales, para los especiales y para oficina,
		-- no genera registro de comisiones

		if _tipo_agente = "O"  then
			continue foreach;
		end if

		if _porc_comision is null then
			let _porc_comision = 0.00;
		end if

		let _comision_monto = (_monto2 * (_porc_comision/100) * (_porc_comis_par/100));
		let v_comision_sus  = v_comision_sus + _comision_monto;

	end foreach;

	select sum(debito + credito)
	  into _monto1
	  from endasien
	 where no_poliza   = _no_poliza
       and no_endoso   = _no_endoso
       and cuenta[1,3] in ("521");

	if _monto1 is null then
		let _monto1 = 0;
	end if

	if v_comision_sus is null then
		let v_comision_sus = 0;
	end if

	if _monto1 <> v_comision_sus then

		if _cuenta not in ("01-1579000", "10-11726", "05-24493", "82-00622") then 

			return 521,
				   _cuenta,
				   _monto1,
				   v_comision_sus,
				   (v_comision_sus - _monto1),
				   _auxiliar,
				   _periodo2	
				   with resume;

		end if

	end if

	if _periodo2 <= "2014-07" then
		continue foreach;
	end if

	-- Validacion del Impuesto

	let _no_poliza2 = sp_sis21(_no_documento);

	select tiene_impuesto
	  into _tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza2;

	select count(*)
	  into _cantidad
	  from emipolim
	 where no_poliza = _no_poliza2;  

	if _tiene_impuesto  = 1 and
	   _impuesto        = 0 and
	   abs(_prima_neta) > 0.11 then	-- Montos Menores el impuesto es 0.00
	
		return 26503,
			   _cuenta,
			   _prima_neta,
			   _impuesto,
			   1,
			   _auxiliar,
			   _periodo2	
			   with resume;

	end if

	if _tiene_impuesto = 0  and
	   _impuesto       <> 0 then

		{
		update endedmae
		   set impuesto    = 0,
		       prima_bruta = prima_neta
         where no_poliza   = _no_poliza
	       and no_endoso   = _no_endoso;
      
		update endedhis
		   set impuesto    = 0,
		       prima_bruta = prima_neta
         where no_poliza   = _no_poliza
	       and no_endoso   = _no_endoso;
		}

		if _cuenta not in ("07-24502", "06-49980", "06-49981",'01-1845252') then 
					
			return 26503,
				   _cuenta,
				   _prima_neta,
				   _impuesto,
				   0,
				   _auxiliar,
				   _periodo2	
				   with resume;

		end if

	end if

	if _tiene_impuesto = 0  and
	   _cantidad       <> 0 then

		return _no_poliza2,
			   _cuenta,
			   _prima_neta,
			   _impuesto,
			   0,
			   _auxiliar,
			   _periodo2	
			   with resume;

	end if

end foreach

end

return "0",
	   "",
	   0.00,
	   0.00,
	   0.00,
	   "",
	   "";
end procedure;