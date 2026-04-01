-- Reporte de mayor detallado por transaccion en cuentas de bancos para conciliaciones bancarias

-- Creado    : 23/05/2012 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac221;

create procedure sp_sac221(a_cuenta char(30), a_periodo char(7))
returning date,
          char(10),
          char(10),
          char(50),
          dec(16,2),
          dec(16,2),
          char(30),
          char(50);

define _res_origen		char(3);
define _res_notrx   	integer;
define _res_fechatrx	date;
define _res_debito		dec(16,2);
define _res_credito		dec(16,2);

define _no_requis		char(10);
define _tipo_requis		char(1);
define _no_cheque		char(10);
define _descripcion		char(50);

define _no_remesa		char(10);
define _renglon			smallint;

define _tipo			char(10);
define _transaccion		char(10);
define _cta_nombre		char(50);

create temp table tmp_concilia(
fecha		date,
tipo		char(10),
transaccion	char(10),
descripcion	char(50),
debito		dec(16,2),
credito		dec(16,2)
) with no log;

set isolation to dirty read;

foreach
 select res_origen,
        res_notrx,
		res_fechatrx,
		res_debito,
		res_credito,
		res_descripcion
   into	_res_origen,
        _res_notrx,
		_res_fechatrx,
		_res_debito,
		_res_credito,
		_descripcion
   from cglresumen
  where	year(res_fechatrx)  = a_periodo[1,4]
    and month(res_fechatrx) = a_periodo[6,7]
	and res_cuenta          = a_cuenta
--    and res_notrx           in (254229, 254241)

	if _res_origen = "CHE" then

		--{ 
		foreach
		 select	no_requis,
		        debito,
				credito,
				tipo_requis
		   into _no_requis,
				_res_debito,
				_res_credito,
				_tipo_requis
		   from chqchcta
		  where sac_notrx = _res_notrx
            and cuenta    = a_cuenta

			select no_cheque,
			       a_nombre_de
			  into _no_cheque,
			       _descripcion
			  from chqchmae
			 where no_requis = _no_requis;
				
			if _tipo_requis = "C" then
				let _tipo = "CHEQUE";
			else
				let _tipo = "ACH";
			end if
			 
			insert into tmp_concilia
			values (_res_fechatrx, _tipo, _no_cheque, _descripcion, _res_debito, _res_credito);			

		end foreach
		--}

	elif _res_origen = "COB" then

		--{
		let _tipo = "REMESA";

		foreach
		 select	no_remesa,
		        renglon,
		        debito,
				credito
		   into _no_remesa,
		        _renglon,
				_res_debito,
				_res_credito
		   from cobasien
		  where sac_notrx = _res_notrx
            and cuenta    = a_cuenta

			select desc_remesa
			  into _descripcion
			  from cobredet
			 where no_remesa = _no_remesa
			   and renglon   = _renglon;
				
			insert into tmp_concilia
			values (_res_fechatrx, _tipo, _no_remesa, _descripcion, _res_debito, _res_credito);			

		end foreach
		--}

	else

		let _tipo = "COMPROBANTE";

		insert into tmp_concilia
		values (_res_fechatrx, _tipo, _res_notrx, _descripcion, _res_debito, _res_credito);			

	end if

end foreach

select cta_nombre
  into _cta_nombre
  from cglcuentas
 where cta_cuenta = a_cuenta;

foreach
 select fecha,
		tipo,
		transaccion,
		descripcion,
		sum(debito),
		sum(credito)
   into	_res_fechatrx,
        _tipo,
		_transaccion,
		_descripcion,
		_res_debito,
		_res_credito
   from tmp_concilia
  group by fecha, tipo, transaccion, descripcion
  order by fecha, tipo, transaccion, descripcion

	return _res_fechatrx,
		   _tipo,
		   _transaccion,
		   _descripcion,
		   _res_debito,
		   _res_credito,
		   a_cuenta,
		   _cta_nombre
		   with resume;

end foreach

drop table tmp_concilia;

end procedure
