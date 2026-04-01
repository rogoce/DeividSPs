-- Morosidad por Asegurado

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE ap_cobmoro2;

--CREATE PROCEDURE sp_rwf10(a_cod_cliente CHAR(10))
CREATE PROCEDURE ap_cobmoro2(a_periodo CHAR(7))
RETURNING char(20),
          dec(16,2),
		  dec(16,2);

define _fecha			date;
define _no_documento	char(20);
define _saldo_pxc       dec(16,2);

define _por_vencer  	dec(16,2);
define _exigible    	dec(16,2);
define _corriente   	dec(16,2);
define _monto_30    	dec(16,2);
define _monto_60    	dec(16,2);
define _monto_90    	dec(16,2);
define _monto_120    	dec(16,2);
define _monto_150    	dec(16,2);
define _monto_180    	dec(16,2);
define _saldo       	dec(16,2);

SET ISOLATION TO DIRTY READ;


let _fecha = sp_sis36(a_periodo);

foreach
	select a.no_documento, 
		   a.saldo_pxc
	  into _no_documento,
		   _saldo_pxc
	from deivid_cob:cobmoros2 a
	where a.no_documento[1,2] = '20' 
	  and a.periodo = a_periodo 
	  and a.saldo_pxc <> 0

			CALL sp_cob245(
				 "001",
				 "001",	
				 _no_documento,
				 a_periodo,
				 _fecha
				 ) RETURNING _por_vencer,      
							 _exigible,         
							 _corriente,        
							 _monto_30,         
							 _monto_60,         
							 _monto_90,
							 _monto_120,
							 _monto_150,
							 _monto_180,
							 _saldo;         

	RETURN _no_documento, 
		   _saldo_pxc,  
		   _saldo
		   WITH RESUME;
end foreach

--drop table tmp_polizas;

END PROCEDURE;