-- Procedure que verifica que cuadre SAC Vs Cheques

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac117;

create procedure sp_sac117()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(7),
		  char(3);
		  
define _monto1		dec(16,2);
define _monto2		dec(16,2);

define _mes			smallint;
define _ano			smallint;
define _periodo		char(7);
define _fecha		date;

define _periodo2	char(7);
define _cuenta		char(25);
define _fechatrx	date;
define _auxiliar	char(1);
define _notrx		integer;
define _notrx_2		integer;
define _ccosto		char(3);
define _no_requis	char(10);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc

	drop table tmp_asientos;

	return _error,
		   _error_desc,
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

if _periodo < "2009-08" then

	let _periodo = "2009-08";
	let _fecha   = "01/08/2009";

end if

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
  where res_origen  in("CHE","PLA")
	and res_fechatrx  >= _fecha
  group by 1, 2, 3, 4

	let _periodo2 = sp_sis39(_fechatrx);

--	let _ccosto = "001";

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _ccosto, _monto1, 0.00);

end foreach

foreach
 select sac_notrx,
		cuenta,
		fecha,
		centro_costo,
        sum(debito - credito)
   into _notrx,
		_cuenta,
		_fechatrx,
		_ccosto,
        _monto2
   from chqchcta 
  where fecha  >= _fecha
  group by 1, 2, 3, 4

	let _periodo2 = sp_sis39(_fechatrx);
--	let _ccosto = "001";

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _ccosto, 0.00, _monto2);

end foreach

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

{
		update chqchcta
		   set centro_costo = _ccosto
		 where sac_notrx    = _notrx
		   and cuenta       = _cuenta;	
}
{
		call sp_sac115(_notrx) returning _error, _error_desc;

		if _error <> 0 then

			return _error,
				   _error_desc,
				   0.00,
				   0.00,
				   0.00,
				   "",
				   "",
				   _ccosto
				   with resume;

		end if
--}

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
			   _periodo2,
			   _ccosto	
			   with resume;

	end if

end foreach

drop table tmp_asientos;

foreach 
 select no_requis,
        periodo
   into _no_requis,
        _periodo2
   from chqchmae
  where fecha_impresion >= _fecha
    and origen_cheque    = 6
    and pagado           = 1  
	and anulado          = 0
  order by fecha_impresion	
	
	select sum(prima_neta)
	  into _monto1
	  from chqchpol
	 where no_requis = _no_requis;

	if _monto1 is null then
		let _monto1 = 0;
	end if
	
	select sum(debito - credito)
	  into _monto2
	  from chqchcta 
	 where no_requis   =  _no_requis
	   and cuenta[1,3] in ("131", "144")
	   and tipo        =  1;

	if _monto2 is null then
		let _monto2 = 0;
	end if

    if _monto1 <> _monto2 then
   
		return _no_requis,
			   "131",
			   _monto1,
			   _monto2,
			   (_monto2 - _monto1),
			   "",
			   _periodo2,
			   "PAG"	
			   with resume;
  
	end if
	
end foreach

foreach 
 select no_requis,
        fecha_anulado
   into _no_requis,
        _fechatrx
   from chqchmae
  where fecha_anulado >= _fecha
    and origen_cheque    = 6
    and pagado           = 1  
	and anulado          = 1
  order by fecha_anulado
	
	select sum(prima_neta)
	  into _monto1
	  from chqchpol
	 where no_requis = _no_requis;

	if _monto1 is null then
		let _monto1 = 0;
	end if
	
	select sum(debito - credito)
	  into _monto2
	  from chqchcta 
	 where no_requis   =  _no_requis
	   and cuenta[1,3] in ("131", "144")
	   and tipo        =  2;

	if _monto2 is null then
		let _monto2 = 0;
	end if

	let _monto2 = _monto2 * -1;

    if _monto1 <> _monto2 then
	
		let _periodo2 = sp_sis39(_fechatrx);
   
		return _no_requis,
			   "131",
			   _monto1,
			   _monto2,
			   (_monto2 - _monto1),
			   "",
			   _periodo2,
			   "ANU"	
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
	   "",
	   ""	
	   with resume;

end procedure