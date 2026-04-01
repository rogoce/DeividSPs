-- POLIZAS VIGENTES 
--
   DROP procedure sp_jean01;
   CREATE procedure sp_jean01()
   RETURNING char(10) as no_poliza,
             char(20) as poliza,
			 char(10) as cod_contratante,
			 CHAR(50) as nombre_contratante,
			 char(30) as cedula,
			 date     as vigencia_inicial;
   
    DEFINE _no_poliza,_cod_contratante	CHAR(10);
    DEFINE _no_documento                CHAR(20);
	define _cedula                      char(30);
    DEFINE _n_contratante   	        CHAR(50);
	define _vi	    					date;

--    CALL sp_pro03("001","001",a_fecha,"002;") RETURNING v_filtros;

foreach
	select distinct e.no_documento
	  into _no_documento
	  from emipomae e
	 where e.actualizado = 1
	   and e.estatus_poliza = 1
	   and e.tiene_impuesto = 0
	
	let _no_poliza = sp_sis21(_no_documento);
	
	select e.cod_contratante,
		   e.vigencia_inic
	  into _cod_contratante,
		   _vi
	  from emipomae e
	 where e.no_poliza = _no_poliza;

	select nombre,
	       cedula
	  into _n_contratante,
	       _cedula
	  from cliclien
	 where cod_cliente = _cod_contratante;
		 
	return _no_poliza,_no_documento,_cod_contratante,_n_contratante,_cedula,_vi with resume;

end foreach
END PROCEDURE;
