-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud06;

create procedure "informix".sp_aud06(
a_periodo1	char(7),
a_periodo2	char(7)
) returning integer,
            char(50);

define _no_documento	char(20);
define _nombre			char(100);
define _monto			dec(16,2);
define _ramo			char(50);
define _fecha_emision	date;
define _vigencia_final	date;

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_ramo		char(10);
define _nombre_ramo		char(50);
define _cod_cliente		char(10);

define _cantidad		smallint;
define v_filtros		char(255);
define _cod_tipotran	char(3);
define _fecha			date;
define _porc_coas_otras	dec(16,2);
define _monto2			dec(16,2);

create temp table tmp_facturas(
	no_documento	char(20),
	nombre			char(50),
	monto			dec(16,2),
	ramo			char(50),
	fecha_ult_pago	date,
	vigencia_final	date,
	primary key (no_documento)
	) with no log;

set isolation to dirty read;

foreach
 select no_reclamo,
        monto,
		fecha,
		cod_tipotran
   into _no_reclamo,
        _monto,
		_fecha_emision,
		_cod_tipotran
   from rectrmae
  where periodo    >= a_periodo1
    and periodo    <= a_periodo2
	and actualizado = 1
	and cod_tipotran in ("004", "005", "006", "007")
  order by no_reclamo, fecha

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo,
		   no_documento,
		   cod_contratante,
		   vigencia_final	
	  into _cod_ramo,
	       _no_documento,
	       _cod_cliente,
		   _vigencia_final	
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cantidad
	  from tmp_facturas
	 where no_documento = _no_documento;

	if _cod_tipotran = "004" then

		if _cantidad = 0 then
		
			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente;

			select nombre
			  into _ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			insert into tmp_facturas
			values (
			_no_documento,
			_nombre,
			_monto,
			_ramo,
		    _fecha_emision,
		    _vigencia_final	
			);

		else

			select fecha_ult_pago
			  into _fecha
			  from tmp_facturas
			 where no_documento = _no_documento;

			if _fecha_emision > _fecha then
				let _fecha = _fecha_emision;
			end if

			update tmp_facturas
			   set monto          = monto + _monto,
			       fecha_ult_pago = _fecha 
			 where no_documento   = _no_documento;

		end if


	end if

   foreach
	select porc_partic_coas
	  into _porc_coas_otras
	  from reccoas
	 where no_reclamo   =  _no_reclamo
	   and cod_coasegur <> "036"

		let _monto2  = _monto / 100 * _porc_coas_otras;
		let _monto2  = _monto2 * -1;

		select count(*)
		  into _cantidad
		  from tmp_facturas
		 where no_documento = _no_documento;

		if _cantidad = 0 then
		
			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente;

			select nombre
			  into _ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			insert into tmp_facturas
			values (
			_no_documento,
			_nombre,
			_monto,
			_ramo,
		    "",
		    _vigencia_final	
			);

		else

			update tmp_facturas
			   set monto          = monto + _monto2
			 where no_documento   = _no_documento;

		end if

	end foreach

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure