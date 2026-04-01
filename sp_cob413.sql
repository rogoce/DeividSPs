--*****************************************************************
-- Procedimiento busca grupo Suntracs
--*****************************************************************
-- Execute procedure sp_cob413("001","001","2017-05","HGIRON")
-- Creado    : 26/06/2018      -- Autor: Henry Giron

DROP PROCEDURE sp_cob413;
CREATE PROCEDURE sp_cob413(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7),a_usuario CHAR(8))
returning	char(50) as nombre, 
            char(20) as no_documento,
            date as fecha,
			char(20) as referencia,
			char(20) as documento,
			dec(16,2) as monto,
			dec(16,2) as prima_neta,
			dec(16,2) as saldo,
			char(7) as periodo,
			char(10) as poliza,
			char(30) as tipo_factura,
			char(10) as remesa,
			char(5) as cod_grupo,
			char(50) as nombre_grupo,
			date as vigencia_inic,
			date as vigencia_final,
			char(12) as estatus_poliza;  -- no_remesa										


define _no_documento    char(20); 
define _no_poliza       char(10);
define _cod_contratante	char(10);
define _nombre          char(50);
define _vig_inic        date;      
define _vig_final       date;  
define v_fecha			date;
define  _cod_grupo      char(5); 
define  _nombre_grupo   char(50); 
define _estatus_poliza	char(1);
define v_referencia		char(20);
define v_documento		char(20);
define _tipo_fac		char(30);
define _no_remesa		char(10);
define v_periodo		char(7);
define v_monto			dec(16,2);
define v_prima			dec(16,2);
define v_saldo			dec(16,2);	
define _estatus_desc    char(12);

let _estatus_desc = '';

SET ISOLATION TO DIRTY READ;
--*************************************************
-- Polizas Vigentes Suntracs
--*************************************************

foreach
	select no_poliza
	  into _no_poliza
	  from emipoliza 	  
	 where cod_grupo in ('01016','77778') -- SUNTRACS
	   
	  	select e.no_documento,
			e.cod_contratante,
			e.vigencia_inic,
			e.vigencia_final,
			e.estatus_poliza,
			e.cod_grupo
	   into _no_documento,
			_cod_contratante,
			_vig_inic,
			_vig_final,
			_estatus_poliza,
			_cod_grupo
	   from emipomae e	
	  where e.no_poliza = _no_poliza;
	   
		 select nombre
		   into _nombre				
		   from cliclien 
		  where cod_cliente = _cod_contratante;	  		  
		  
		 select nombre
		   into _nombre_grupo
		   from cligrupo
		  where cod_grupo = _cod_grupo;		 	   		              
		 
		 if _estatus_poliza = 1 then
			let _estatus_desc = "VIGENTE";
		elif _estatus_poliza = 2 then
			let _estatus_desc = "CANCELADA";
		elif _estatus_poliza = 3 then
			let _estatus_desc = "VENCIDA";
		elif _estatus_poliza = 4 then
			let _estatus_desc = "ANULADA";
		end if		  

	    FOREACH EXECUTE PROCEDURE sp_cob25(a_compania,a_sucursal,_no_documento)
			 INTO  v_fecha,
				   v_referencia, 
				   v_documento,
				   v_monto,
				   v_prima,
				   v_saldo,
				   v_periodo,
				   _no_poliza,
				   _tipo_fac,
				   _no_remesa				   	 
	
			return _nombre,
			       _no_documento,
				   v_fecha,
				   v_referencia, 
				   v_documento,  -- documento transaccion
				   v_monto,
				   v_prima,
				   v_saldo,
				   v_periodo,
				   _no_poliza,
				   _tipo_fac,
				   _no_remesa,
				   _cod_grupo,
				   _nombre_grupo,
				   _vig_inic,
				   _vig_final,
				   _estatus_desc
				   with resume;
				   
			   end foreach;
		   
end foreach




END PROCEDURE;