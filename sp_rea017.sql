
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rea017;
create procedure sp_rea017()
returning char(20),smallint,dec(16,2),char(10),char(5),char(5);

						
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_unidad			char(5);
define _cod_ramo			char(3);
define _nombre_ramo			char(50);

define _cod_contrato		char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur 		char(3);
define _cod_lider	 		char(3);
define _bouquet				smallint;
define _nombre				char(50);
define _nombre_contrato		char(50);

define _prima				dec(16,2);
define _prima_neta			dec(16,2);
define _prima_suscrita		dec(16,2);
define _factor_impuesto	 	dec(5,2);
define _porc_comis_agt   	dec(5,2);
define _tiene_comis_rea	 	smallint;
define _porc_cont_partic 	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _monto_reas		 	dec(16,2);
define _cobros			 	dec(16,2);
define _por_pagar		 	dec(16,2);
define _comision		 	dec(16,2);
define _impuesto		 	dec(16,2);
define _es_terremoto		smallint;
define _cantidad			smallint;

define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _cod_cobertura		char(5);
define _monto				dec(16,2);
define _diferencia			dec(16,2);
define _porc_partic_prima	dec(9,6);
define _porc_partic_coas    dec(7,4);
define _no_cambio	       	smallint;

define _por_vencer      	dec(16,2);
define _exigible	    	dec(16,2);
define _corriente	    	dec(16,2);
define _monto_30	    	dec(16,2);
define _monto_60	    	dec(16,2);
define _monto_90	    	dec(16,2);
define _saldo           	dec(16,2);
define _prima_orig      	dec(16,2);
define _ret					smallint;
define _fac					smallint;
define _exc					smallint;
define _otr                 smallint;
define _tipo_contrato       smallint;
define _estatus             smallint;


set isolation to dirty read;

foreach

	 SELECT no_poliza,
	        no_documento,
			estatus_poliza
	   INTO	_no_poliza,
	        _no_documento,
			_estatus
	   FROM emipomae
	  WHERE cod_compania     = '001'
	    AND fecha_suscripcion between '01/01/2010' and '21/04/2010'
	    AND actualizado = 1
		AND cod_ramo in("001","003")


	let _ret = 0;
	let _fac = 0;
	let _exc = 0;
	let _otr = 0;

	foreach

		 select f.cod_contrato,f.no_endoso,f.no_unidad,sum(f.prima)
		   into	_cod_contrato,_no_endoso,_no_unidad,_monto
		   from emifacon f, endeduni u
		  where u.no_poliza = _no_poliza
			and f.no_poliza = u.no_poliza
			and f.no_endoso = u.no_endoso
			and f.no_unidad = u.no_unidad
			and f.prima     <> 0.00
	   group by f.cod_contrato,f.no_endoso,f.no_unidad

	        select tipo_contrato
	          into _tipo_contrato
	          from reacomae
	         where cod_contrato = _cod_contrato;

			if _tipo_contrato <> 3 then
				continue foreach;
			else

			   return 
			   _no_documento,
			   _estatus,
			   _monto,
			   _no_poliza,
			   _no_endoso,
			   _no_unidad
			   with resume;

			end if

	end foreach

end foreach
end procedure
