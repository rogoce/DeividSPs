-- Procedimiento que Crea los Registros para los Auditores - Prima Suscrita
-- Auditoria del 29 de agosto del 2007
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud04;

create procedure "informix".sp_aud04(
a_periodo1	char(7),
a_periodo2	char(7)
) returning integer,
            char(50);

define _no_documento	char(20);
define _nombre			char(100);
define _prima_suscrita	dec(16,2);
define _ramo			char(50);
define _porc_coas_aa	dec(16,5);
define _porc_coas_ced	dec(16,5);
define _porc_reas_ret	dec(16,5);
define _porc_reas_ced	dec(16,5);
define _fecha_emision	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _cod_ramo		char(10);
define _nombre_ramo		char(50);
define _cod_cliente		char(10);
define _cod_tipoprod	char(3);

define _no_endoso		char(5);
define _no_unidad		char(5);

define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _porc_partic		dec(16,5);
define _cantidad		smallint;

create temp table tmp_facturas(
	no_documento	char(20),
	nombre			char(50),
	prima_suscrita	dec(16,2),
	ramo			char(50),
	porc_coas_aa	dec(16,5),
	porc_coas_ced	dec(16,5),
	porc_reas_ret	dec(16,5),
	porc_reas_ced	dec(16,5),
	fecha_emision	date,
	vigencia_final	date,
	primary key (no_documento)
	) with no log;

set isolation to dirty read;

foreach
 select no_poliza,
        no_endoso,
        prima_suscrita
   into _no_poliza,
        _no_endoso,
        _prima_suscrita
   from endedmae
  where actualizado = 1
    and periodo     >= a_periodo1
    and periodo     <= a_periodo2

	let _porc_coas_aa  = 0;
	let _porc_coas_ced = 0;

	select cod_ramo,
		   no_documento,
		   cod_contratante,
		   cod_tipoprod,
		   fecha_suscripcion,
		   vigencia_final	
	  into _cod_ramo,
	       _no_documento,
	       _cod_cliente,
	       _cod_tipoprod,	
		   _fecha_emision,
		   _vigencia_final	
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cantidad
	  from tmp_facturas
	 where no_documento = _no_documento;

	if _cantidad = 0 then
	
		if _cod_tipoprod = "001" then

			select porc_partic_coas
			  into _porc_coas_aa
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = "036";

			let _porc_coas_ced = 100 - _porc_coas_aa;

		end if

		foreach
		 select no_unidad
		   into _no_unidad
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			let _porc_reas_ret = 0;
			let _porc_reas_ced = 0;

			foreach
			 select cod_contrato,
			        porc_partic_prima
			   into _cod_contrato,
					_porc_partic
			   from emifacon
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
				and no_unidad = _no_unidad

				select tipo_contrato
				  into _tipo_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if _tipo_contrato = 1 then

					let _porc_reas_ret = _porc_partic;
		
					exit foreach;
				
				end if

			end foreach

			exit foreach;

		end foreach
		
		let _porc_reas_ced = 100 - _porc_reas_ret;

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
		_prima_suscrita,
		_ramo,
		_porc_coas_aa,
		_porc_coas_ced,
		_porc_reas_ret,
		_porc_reas_ced,
	    _fecha_emision,
	    _vigencia_final	
		);

	else


		update tmp_facturas
		   set prima_suscrita = prima_suscrita + _prima_suscrita
		 where no_documento   = _no_documento;

	end if

end foreach

return 0, "Actualizacion Exitosa ...";

--unload to facturas.txt select * from tmp_facturas;

end procedure