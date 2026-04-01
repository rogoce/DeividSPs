-- Consulta de la web de SEMM
-- Creado    : 28/02/2023 - Autor: FEDERICO CORONADO.

DROP PROCEDURE sp_web73;

CREATE PROCEDURE sp_web73(a_opcion smallint, a_entrada varchar(50))
RETURNING varchar(20),
		  varchar(5),
		  varchar(50),
		  varchar(50),
		  varchar(10),
		  varchar(5),
		  date,
		  varchar(10);

DEFINE v_cnt0  				smallint;
DEFINE v_cnt1		  		smallint;
DEFINE v_cnt2		  		smallint;
DEFINE v_no_poliza			varchar(10);
DEFINE v_no_documento		varchar(20);
DEFINE v_no_unidad			varchar(5);
DEFINE v_nombre				varchar(50);
DEFINE v_cod_cliente		varchar(10);
DEFINE v_cod_producto		char(5);
DEFINE v_vigencia_inic      date;
DEFINE v_nombre_producto    varchar(50); 
DEFINE v_cod_asegurado      varchar(10);  


create temp table tmp_polaseg(
       no_documento    varchar(20),
       no_unidad       varchar(5),
	   nombre          varchar(50),
	   nombre_producto varchar(50), 
	   cod_cliente	   varchar(10),
	   cod_producto	   varchar(5),
	   vigencia_inic   date,
	   cod_asegurado   varchar(10)
	   ) WITH NO LOG;
--SET DEBUG FILE TO "sp_pro67.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

	if a_opcion = 0 then    -- busqueda por número de documento
		let v_no_poliza = sp_sis21(a_entrada);
		foreach  --MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS'
			SELECT emipouni.no_unidad, BO_Deivid_dbo_cliclien6.nombre, cliclien.cod_cliente, emipouni.cod_producto, emipouni.vigencia_inic, cliclien.cod_cliente
			  into v_no_unidad, v_nombre,  v_cod_cliente, v_cod_producto, v_vigencia_inic, v_cod_asegurado
			  FROM prdramo, cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND prdramo.nombre  IN  ('MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND emipouni.activo = 1
			   AND emipomae.no_poliza = v_no_poliza
			   
			   select nombre
			     into v_nombre_producto
				 from prdprod
				where cod_producto = v_cod_producto;
			   
			  insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic,cod_asegurado) 
			                   values("", v_no_unidad, v_nombre, v_nombre_producto, v_cod_cliente, v_cod_producto, v_vigencia_inic,v_cod_asegurado);
			   --return "", v_no_unidad, v_nombre, v_nombre_producto, v_cod_cliente, v_cod_producto, v_vigencia_inic WITH RESUME;
		end foreach
		foreach --SALUD ASEGURADO PRINCIPAL
			SELECT emipouni.no_unidad, BO_Deivid_dbo_cliclien6.nombre, BO_Deivid_dbo_cliclien6.cod_cliente, emipouni.cod_producto, emipouni.vigencia_inic, BO_Deivid_dbo_cliclien6.cod_cliente
			  into v_no_unidad, v_nombre,  v_cod_cliente, v_cod_producto, v_vigencia_inic, v_cod_asegurado
			  FROM prdramo, cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND prdramo.nombre  IN  ('SALUD')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND emipouni.activo = 1
			   AND emipomae.no_poliza = v_no_poliza
			   
			   select nombre
			     into v_nombre_producto
				 from prdprod
				where cod_producto = v_cod_producto;
				
			    insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic, cod_asegurado) 
			                   values("Asegurado", v_no_unidad, v_nombre, v_nombre_producto, v_cod_cliente, v_cod_producto, v_vigencia_inic, v_cod_asegurado);
			   --return "Asegurado", v_no_unidad, v_nombre, v_nombre_producto, v_cod_cliente, v_cod_producto, v_vigencia_inic WITH RESUME;
		end foreach
		foreach 	   --SALUD DEPENDIENTES
			   SELECT emipouni.no_unidad, BO_Deivid_dbo_cliclien6.nombre, BO_Deivid_dbo_cliclien6.cod_cliente, emipouni.cod_producto, emipouni.vigencia_inic, emipouni.cod_asegurado
				 into v_no_unidad, v_nombre, v_cod_cliente, v_cod_producto, v_vigencia_inic, v_cod_asegurado
				 FROM prdramo, cliclien, emipomae, emidepen, cliclien  BO_Deivid_dbo_cliclien6, emipouni
				WHERE ( cliclien.cod_cliente=emipomae.cod_contratante  )
				  AND  ( emipomae.cod_ramo=prdramo.cod_ramo  )
				  AND  ( emidepen.cod_cliente=BO_Deivid_dbo_cliclien6.cod_cliente  )
				  AND  ( emipomae.no_poliza=emipouni.no_poliza  )
				  AND  ( emipouni.no_poliza=emidepen.no_poliza and emipouni.no_unidad=emidepen.no_unidad  )
				  AND  prdramo.nombre  =  'SALUD' AND  case emipomae.estatus_poliza	when 1 then '1 - Vigentes' when 2 then '2 - Canceladas'	when 3 then '3 - Vencidas'
				 when 4 then '4 - Anuladas' else '5 - Otros estatus'	end  =  '1 - Vigentes'	AND emipomae.no_poliza = v_no_poliza AND emipouni.activo = 1  AND emidepen.activo = 1
				 
				select nombre
			     into v_nombre_producto
				 from prdprod
				where cod_producto = v_cod_producto;
				
				insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic, cod_asegurado) 
			                     values("Dependiente", v_no_unidad, v_nombre, v_nombre_producto, v_cod_cliente, v_cod_producto, v_vigencia_inic, v_cod_asegurado);
				 --return "Dependiente", v_no_unidad, v_nombre, v_nombre_producto, v_cod_cliente, v_cod_producto, v_vigencia_inic WITH RESUME;
		end foreach
	else -- busqueda por cedula
		foreach
			SELECT emipomae.no_documento, emipouni.no_unidad, cliclien.nombre --, emipomae.vigencia_inic,emipomae.vigencia_final,emipomae.prima_neta, emipomae.impuesto, emipomae.prima_bruta, emipomae.saldo, estatus_poliza,prdramo.nombre
			  into v_no_documento, v_no_unidad, v_nombre
			  FROM prdramo, cliclien, emipomae, emipouni 
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND prdramo.nombre  IN  ('MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND  cliclien.cedula = a_entrada AND emipouni.activo = 1
			   --return v_no_documento, v_no_unidad, v_nombre,  "", "", "", "" WITH RESUME;
			   
			   insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic, cod_asegurado) 
			                    values(v_no_documento, v_no_unidad, v_nombre,  "", "", "", "", "");
		end foreach
		foreach --contratante
			SELECT emipomae.no_documento, emipouni.no_unidad, cliclien.nombre
			  into v_no_documento, v_no_unidad, v_nombre
			  FROM prdramo, cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND prdramo.nombre  IN  ('SALUD')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND  cliclien.cedula = a_entrada AND emipouni.activo = 1
			   
			   --return v_no_documento, v_no_unidad, v_nombre,  "", "", "", "" WITH RESUME;
			   insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic, cod_asegurado) 
					values(v_no_documento, v_no_unidad, v_nombre,  "", "", "", "","");
		end foreach
		foreach --Asegurado
			SELECT emipomae.no_documento, emipouni.no_unidad, BO_Deivid_dbo_cliclien6.nombre
			  into v_no_documento, v_no_unidad, v_nombre
			  FROM prdramo, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza)
			   AND (emipomae.cod_ramo = prdramo.cod_ramo)
			   AND prdramo.nombre  IN  ('SALUD')
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes'
			   AND  BO_Deivid_dbo_cliclien6.cedula = a_entrada AND emipouni.activo = 1
			   
			  --return v_no_documento, v_no_unidad, v_nombre,  "", "", "", "" WITH RESUME;
			  
			  insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic, cod_asegurado) 
			                   values(v_no_documento, v_no_unidad, v_nombre,  "", "", "", "", "");
		end foreach
		
		foreach --Dependientes 
			   SELECT emipomae.no_documento, emipouni.no_unidad, cliclien.nombre --, emipomae.vigencia_inic,emipomae.vigencia_final,emipomae.prima_neta, emipomae.impuesto, emipomae.prima_bruta, emipomae.saldo, estatus_poliza,prdramo.nombre
				 into v_no_documento, v_no_unidad, v_nombre
				 FROM prdramo, cliclien, emipomae, emidepen, cliclien  BO_Deivid_dbo_cliclien6, emipouni
				WHERE ( cliclien.cod_cliente=emipomae.cod_contratante  )
				  AND  ( emipomae.cod_ramo=prdramo.cod_ramo  )
				  AND  ( emidepen.cod_cliente=BO_Deivid_dbo_cliclien6.cod_cliente  )
				  AND  ( emipomae.no_poliza=emipouni.no_poliza  )
				  AND  ( emipouni.no_poliza=emidepen.no_poliza and emipouni.no_unidad=emidepen.no_unidad  )
				  AND  prdramo.nombre  =  'SALUD' AND  case emipomae.estatus_poliza	when 1 then '1 - Vigentes' when 2 then '2 - Canceladas'	when 3 then '3 - Vencidas'
				 when 4 then '4 - Anuladas' else '5 - Otros estatus'	end  =  '1 - Vigentes'	AND  cliclien.cedula = a_entrada AND emipouni.activo = 1  AND emidepen.activo = 1
				 
			  -- return v_no_documento, v_no_unidad, v_nombre,  "", "", "", "" WITH RESUME;
			  
			   insert into tmp_polaseg(no_documento, no_unidad, nombre, nombre_producto, cod_cliente, cod_producto, vigencia_inic,cod_asegurado) 
					values(v_no_documento, v_no_unidad, v_nombre,  "", "", "", "","");
			  
		end foreach
	end if
	foreach	
		select no_documento, 
			   no_unidad, 
			   nombre, 
			   nombre_producto, 
			   cod_cliente, 
			   cod_producto, 
			   vigencia_inic,
			   cod_asegurado
		  into v_no_documento, 
			   v_no_unidad, 
			   v_nombre, 
			   v_nombre_producto, 
			   v_cod_cliente, 
			   v_cod_producto, 
			   v_vigencia_inic,
			   v_cod_asegurado
		from tmp_polaseg 
		group by 1,2,3,4,5,6,7,8
		
		return v_no_documento, 
			   v_no_unidad, 
			   v_nombre, 
			   v_nombre_producto, 
			   v_cod_cliente, 
			   v_cod_producto, 
			   v_vigencia_inic,
			   v_cod_asegurado
			   WITH RESUME;
	end foreach

DROP TABLE tmp_polaseg;
END PROCEDURE;