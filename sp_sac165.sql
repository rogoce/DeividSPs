-- Procedure que verifica que cuadre SAC Vs Deivid en Reaseguro

-- Creado    : 10/02/2010 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac165;

create procedure sp_sac165()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(7);
		  
define _monto1		dec(16,2);
define _monto2		dec(16,2);

define _mes			smallint;
define _ano			smallint;
define _periodo		char(7);
define _fecha		date;

define _periodo2	char(7);
define _periodo3	char(7);
define _cuenta		char(25);
define _fechatrx	date;
define _auxiliar	char(1);
define _notrx		integer;
define _notrx_2		integer;

define _no_registro	char(10);
define _no_factura	char(10);
define _no_poliza	char(10);
define _no_endoso	char(5);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _tipo_registro smallint;
define _cod_ramo      char(2);
define _cnt           smallint;

begin 
on exception set _error, _error_isam, _error_desc

	drop table tmp_asientos;
	drop table tmp_excluir;

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

create temp table tmp_excluir(
no_registro char(10)
) with no log;

set isolation to dirty read;

call sp_sac104() returning _ano, _periodo, _fecha;

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
  where res_comprobante[1,3] = "REA"
	and res_fechatrx         >= _fecha
  group by 1, 2, 3

	let _periodo2 = sp_sis39(_fechatrx);

	insert into tmp_asientos
	values (_notrx, _periodo2, _cuenta, _monto1, 0.00);

end foreach

foreach
 select no_registro,
        tipo_registro,
		no_documento[1,2],
		no_poliza
   into _no_registro,
        _tipo_registro,
		_cod_ramo,
		_no_poliza
   from sac999:reacomp
  where sac_asientos = 0
    and periodo      >= _periodo
	
	if _tipo_registro IN (2,4,5) then
		if _cod_ramo in ('02','20','23','18')  then	
        	insert into tmp_excluir
        	values (_no_registro);
		elif _cod_ramo = '19' then -- Cambio para determinar la cuenta
			select count(*)
			  into _cnt
			  from emifacon e, reacomae r
			 where e.cod_contrato = r.cod_contrato
			   and e.no_poliza = _no_poliza
			   and r.serie >= 2024;
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
            	insert into tmp_excluir
            	values (_no_registro);
			end if
		end if
	end if	   
end foreach

foreach
 select sac_notrx,
		cuenta,
		periodo,
        sum(debito -  credito)
   into _notrx,
		_cuenta,
		_periodo2,
        _monto2
   from sac999:reacompasie
  where periodo >= _periodo
    and no_registro not in (select no_registro from tmp_excluir)
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
		}

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
drop table tmp_excluir;

-- Validacion Periodos

if _periodo < "2014-11" then
	let _periodo = "2014-11";
end if

foreach
 select no_poliza,
		no_endoso,
		periodo,
		no_registro
   into _no_poliza,
		_no_endoso,
		_periodo2,
		_no_registro
   from sac999:reacomp
  where periodo >= _periodo

	select periodo,
	       no_factura
	  into _periodo3,
	       _no_factura
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   
	if _no_factura in ('01-1698976','01-1838275','01-2337684', '1076983','1076985','1076360','1076364','1082122',
                       '1080850','1078287','1078257','1080385','1078728','1080644','1082189') then
		continue foreach;
	end if

	if _periodo2 <> _periodo3 then

		return _no_registro,
			   _no_factura,
			   0,
			   0,
			   0,
			   "periodo",
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

end procedure
