-- Consulta de la web de SEMM
-- Creado    : 28/02/2023 - Autor: FEDERICO CORONADO.

DROP PROCEDURE sp_web72;

CREATE PROCEDURE sp_web72(a_opcion smallint, a_entrada varchar(50))
RETURNING smallint;

DEFINE v_cnt0  				smallint;
DEFINE v_cnt1		  		smallint;
DEFINE v_cnt2		  		smallint;
DEFINE v_cnt3  				smallint;
DEFINE v_cnt4		  		smallint;
DEFINE v_cnt5		  		smallint;
DEFINE v_cnt6  				smallint;
DEFINE v_cnt7		  		smallint;
DEFINE v_no_poliza			varchar(10);


--SET DEBUG FILE TO "sp_pro67.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

let v_cnt0=0;
let v_cnt1=0;
let v_cnt2=0;
let v_cnt3=0;
let v_cnt4=0;
let v_cnt5=0;
let v_cnt6=0;
let v_cnt7=0;


	if a_opcion = 0 then    -- busqueda por número de documento
		let v_no_poliza = sp_sis21(a_entrada);
		--MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS'
			SELECT count(*)
			  into v_cnt0
			  FROM prdramo, cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND prdramo.nombre  IN  ('MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND emipouni.activo = 1
			   AND emipomae.estatus_poliza = 1
			   AND emipomae.no_poliza = v_no_poliza;
			   
		--SALUD ASEGURADO PRINCIPAL
			SELECT count(*)
			  into v_cnt1
			  FROM prdramo, cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND prdramo.nombre  IN  ('SALUD')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND emipouni.activo = 1
			   AND emipomae.estatus_poliza = 1
			   AND emipomae.no_poliza = v_no_poliza;
			   
		--SALUD DEPENDIENTES
			   SELECT count(*)
				 into v_cnt2
				 FROM prdramo, cliclien, emipomae, emidepen, cliclien  BO_Deivid_dbo_cliclien6, emipouni
				WHERE ( cliclien.cod_cliente=emipomae.cod_contratante  )
				  AND  ( emipomae.cod_ramo=prdramo.cod_ramo  )
				  AND  ( emidepen.cod_cliente=BO_Deivid_dbo_cliclien6.cod_cliente  )
				  AND  ( emipomae.no_poliza=emipouni.no_poliza  )
				  AND  ( emipouni.no_poliza=emidepen.no_poliza and emipouni.no_unidad=emidepen.no_unidad  )
				  AND  prdramo.nombre  =  'SALUD' AND  case emipomae.estatus_poliza	when 1 then '1 - Vigentes' when 2 then '2 - Canceladas'	when 3 then '3 - Vencidas'
				 when 4 then '4 - Anuladas' else '5 - Otros estatus'	end  =  '1 - Vigentes'	AND emipomae.no_poliza = v_no_poliza AND emipouni.activo = 1 AND emipomae.estatus_poliza = 1;

	else -- busqueda por cedula
			SELECT count(*)
			  into v_cnt3
			  FROM prdramo, cliclien, emipomae, emipouni 
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND prdramo.nombre  IN  ('MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND  cliclien.cedula = a_entrada AND emipouni.activo = 1 AND emipomae.estatus_poliza = 1;

		 --contratante
			SELECT count(*)
			  into v_cnt4
			  FROM prdramo, cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante) 
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza) 
			   AND (emipomae.cod_ramo = prdramo.cod_ramo) 
			   AND prdramo.nombre  IN  ('SALUD')  
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes' 
			   AND  cliclien.cedula = a_entrada AND emipouni.activo = 1 AND emipomae.estatus_poliza = 1;
			   

		 --Asegurado
			SELECT count(*)
			  into v_cnt5
			  FROM prdramo, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza)
			   AND (emipomae.cod_ramo = prdramo.cod_ramo)
			   AND prdramo.nombre  IN  ('SALUD')
			   AND  case emipomae.estatus_poliza when 1 then '1 - Vigentes' when 2 then '2 - Canceladas' when 3 then '3 - Vencidas' when 4 then '4 - Anuladas' else '5 - Otros estatus' end  =  '1 - Vigentes'
			   AND  BO_Deivid_dbo_cliclien6.cedula = a_entrada AND emipouni.activo = 1 AND emipomae.estatus_poliza = 1;

		
		--Dependientes 
		   SELECT count(*)
			 into v_cnt6
			 FROM prdramo, cliclien, emipomae, emidepen, cliclien  BO_Deivid_dbo_cliclien6, emipouni
			WHERE ( cliclien.cod_cliente=emipomae.cod_contratante  )
			  AND  ( emipomae.cod_ramo=prdramo.cod_ramo  )
			  AND  ( emidepen.cod_cliente=BO_Deivid_dbo_cliclien6.cod_cliente  )
			  AND  ( emipomae.no_poliza=emipouni.no_poliza  )
			  AND  ( emipouni.no_poliza=emidepen.no_poliza and emipouni.no_unidad=emidepen.no_unidad  )
			  AND  prdramo.nombre  =  'SALUD' AND  case emipomae.estatus_poliza	when 1 then '1 - Vigentes' when 2 then '2 - Canceladas'	when 3 then '3 - Vencidas'
			 when 4 then '4 - Anuladas' else '5 - Otros estatus'	end  =  '1 - Vigentes'	AND  cliclien.cedula = a_entrada AND emipouni.activo = 1 AND emipomae.estatus_poliza = 1;
	end if

	let v_cnt7	= v_cnt0 + v_cnt1 + v_cnt2 + v_cnt3 + v_cnt4 + v_cnt5 + v_cnt6;
	if v_cnt7 > 0 then
		let v_cnt7 = 1;
	else
		let v_cnt7 = 0;
	end if
	return v_cnt7;
END PROCEDURE;