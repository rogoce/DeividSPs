-- Procedimiento que genera los registros contables para las remesas de reaseguro
-- 
-- Creado     : 29/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par283;		

create procedure sp_par283(a_no_remesa CHAR(10))
returning integer,
		  char(100);

define _cod_banco		char(3);
define _cod_origen_ban	char(3);
define _cod_origen_rea	char(3);
define _renglon			smallint;
define _tipo			char(2);

define _cuenta_banco	char(25);
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _cod_coasegur	char(3);
define _cod_auxiliar	char(5);
define _periodo			char(7);
define _centro_costo	char(3);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _tipo_comp		smallint;
define _monto           dec(16,2);
define _dif             dec(16,2);
define _renglon_s       varchar(3);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

--SET DEBUG FILE TO "sp_par283.trc"; 
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

delete from sac999:reaasien where no_remesa = a_no_remesa;

select cod_banco,
	   cod_coasegur,
	   tipo,
	   periodo,
	   ccosto	
  into _cod_banco,
       _cod_coasegur,
	   _tipo,
	   _periodo,
	   _centro_costo
  from reatrx1
 where no_remesa = a_no_remesa;

select cod_origen,
       cod_auxiliar
  into _cod_origen_rea,
       _cod_auxiliar
  from emicoase
 where cod_coasegur = _cod_coasegur;

if _cod_auxiliar is null then
	return 1, "Falta el Codigo de Auxiliar del Reasegurador";
end if

-- Lectura del Origen del Banco para el Enlace de Cuentas

select cod_origen
  into _cod_origen_ban
  from chqbanco
 where cod_banco = _cod_banco;

if _cod_origen_ban = '001' then
	let _cuenta_banco = sp_sis15('BACHEBL', '02', _cod_banco); -- Chequera Bancos Locales
else
	let _cuenta_banco = sp_sis15('BACHEBE', '02', _cod_banco); -- Chequera Bancos Extranjeros
end if

foreach
 select	renglon,
        cod_ramo,
		debito,
		credito
   into	_renglon,
        _cod_ramo,
		_debito,
		_credito
   from reatrx2
  where no_remesa = a_no_remesa

	foreach
	 select cod_subramo
	   into _cod_subramo
	   from prdsubra
	  where cod_ramo = _cod_ramo
		exit foreach;
	end foreach

	if _tipo = "01" then -- Pago de Reaseguro

		let _tipo_comp = 1;

		-- Reaseguro por Pagar

		let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_rea, _cod_ramo, _cod_subramo);   

		insert into sac999:reaasien(no_remesa, renglon, cuenta, debito, credito, centro_costo, periodo, sac_notrx, cod_auxiliar, tipo_comp)
		values (a_no_remesa, _renglon, _cuenta, _debito, _credito, _centro_costo, _periodo, null, _cod_auxiliar, _tipo_comp);

		-- Banco

		insert into sac999:reaasien(no_remesa, renglon, cuenta, debito, credito, centro_costo, periodo, sac_notrx, cod_auxiliar, tipo_comp)
		values (a_no_remesa, _renglon, _cuenta_banco, _credito, _debito, _centro_costo, _periodo, null, null, _tipo_comp);

	elif _tipo = "02" then -- Pago de Siniestro

		let _tipo_comp = 2;

		-- Reaseguro por Pagar

		let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_rea, _cod_ramo, _cod_subramo);   

		insert into sac999:reaasien(no_remesa, renglon, cuenta, debito, credito, centro_costo, periodo, sac_notrx, cod_auxiliar, tipo_comp)
		values (a_no_remesa, _renglon, _cuenta, _debito, _credito, _centro_costo, _periodo, null, _cod_auxiliar, _tipo_comp);

		-- Banco

		insert into sac999:reaasien(no_remesa, renglon, cuenta, debito, credito, centro_costo, periodo, sac_notrx, cod_auxiliar, tipo_comp)
		values (a_no_remesa, _renglon, _cuenta_banco, _credito, _debito, _centro_costo, _periodo, null, null, _tipo_comp);

	end if

end foreach

update reatrx1
   set sac_asientos = 1
 where no_remesa    = a_no_remesa;

end

return 0, "Actualizacion Exitosa";

end procedure 
