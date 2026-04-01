-- Reaseguro polizas nuevas
-- Genera Reaseguro para pólizas de colectivo ya que son demasiadas unidades para hacerlo manual, se tomará la información de emigloco y no de rearucon 
-- Creado    : 26/04/2021 - Autor: Amado Perez
 

DROP PROCEDURE ap_camp_reaseg;
CREATE PROCEDURE ap_camp_reaseg() 
RETURNING  integer;		   
  
DEFINE _no_poliza 		CHAR(10);
DEFINE _no_unidad 		CHAR(5);
DEFINE _suma_asegurada 	DEC(16,2);
DEFINE _error   		INTEGER;
DEFINE _no_endoso       CHAR(5);
DEFINE _nulo            dec(16,2);
DEFINE _nulo2           smallint; 

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;
let _error = 0;
let _no_endoso = '00145';
let _nulo = null;
let _nulo2 = null;

FOREACH
	select a.no_poliza,
	       a.no_unidad
	  into _no_poliza,
	       _no_unidad	   
	  from emireaco a, reacomae b
	 where a.cod_contrato = b.cod_contrato
	  and a.no_poliza = '2317344' --and no_endoso = '00145'
	  and b.tipo_contrato = 3
	  and no_unidad not in ('00001','00003','00009')

    INSERT INTO endeduni(
	       no_poliza,
		   no_endoso,
		   no_unidad,
		   cod_ruta,
		   cod_producto,
		   cod_cliente,
		   suma_asegurada,
		   prima,
		   descuento,
		   recargo,
		   prima_neta,
		   impuesto,
		   prima_bruta,
		   reasegurada,
		   vigencia_inic,		   
		   vigencia_final,
		   beneficio_max,
		   desc_unidad,
		   prima_suscrita,
		   prima_retenida,
		   suma_aseg_adic,
		   tipo_incendio,
		   gastos,
		   subir_bo)	
        SELECT no_poliza, 
		   _no_endoso,
	       no_unidad,
		   cod_ruta,
		   cod_producto,
		   cod_asegurado,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0,
		   vigencia_inic,
		   vigencia_final,
		   0,
		   desc_unidad,
		   0.00,
		   0.00,
		   _nulo,
		   _nulo2,
		   0,
		   0
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;
	   
	insert into emifacon
    values (_no_poliza,
	        _no_endoso,
            _no_unidad,	
			'004',
			1,
			'00744',
			'00827',
			30,
			30,
			0,
			0,
			0,
			0);
	  
	insert into emifacon
    values (_no_poliza,
	        _no_endoso,
            _no_unidad,	
			'004',
			2,
			'00746',
			'00827',
			70,
			70,
			0,
			0,
			0,
			0);
END FOREACH

return 0; 
END PROCEDURE	  