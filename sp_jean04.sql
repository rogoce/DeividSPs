-- POLIZAS VIGENTES 
--

   DROP procedure sp_jean04;
   CREATE procedure sp_jean04()
   RETURNING char(20),char(5),char(10),CHAR(50),char(30),char(10),CHAR(50),char(30),smallint,date,date;
   
     
    DEFINE _no_poliza,_cod_asegurado	 	CHAR(10);
    DEFINE _no_documento    CHAR(20);
    DEFINE _no_unidad      CHAR(5);
	define _cod_contratante char(10);
    DEFINE _n_contratante,_n_asegurado   	CHAR(50);
	define _vi,_vf		    date;
	define _cedula_c,_cedula_u char(30);
	define _leasing smallint;

--    CALL sp_pro03("001","001",a_fecha,"002;") RETURNING v_filtros;

foreach

	select e.no_documento,
	       e.cod_contratante,
		   c.nombre,
		   c.cedula,
		   e.leasing,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.no_poliza,
		   u.no_unidad,
		   u.cod_asegurado
	  into _no_documento,
           _cod_contratante,
		   _n_contratante,
		   _cedula_c,
		   _leasing,
		   _vi,
		   _vf,
		   _no_poliza,
		   _no_unidad,
		   _cod_asegurado
	  from emipomae e, cliclien c, emipouni u
	 where e.cod_contratante = c.cod_cliente
	   and e.no_poliza = u.no_poliza
	   and e.actualizado = 1
	   and e.estatus_poliza = 1
	   and u.cod_asegurado in(
	select cod_cliente from cliclien
	 where nombre like 'FINANZAS%GENERA%')
	
	select nombre,
		   cedula
	  into _n_asegurado,
		   _cedula_u
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	 
	return _no_documento,_no_unidad,_cod_contratante,_n_contratante,_cedula_c,_cod_asegurado,_n_asegurado,_cedula_u,_leasing,_vi,_vf with resume;

end foreach	
END PROCEDURE;