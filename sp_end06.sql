-- Procedimento que carga los dependientes de una poliza al la tabla enddepen de endoso
-- Creado    : 19/03/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_end06;
CREATE PROCEDURE "informix".sp_end06(a_poliza char(10),a_unidad char(5),a_endoso CHAR(5))
RETURNING SMALLINT; 
 
 --SET DEBUG FILE TO "sp_end06.trc";      
 --TRACE ON;   

	Delete From endedcob
	 Where no_poliza = a_poliza
	   And no_unidad = a_unidad
	   and no_endoso = a_endoso;
								
	Delete From emifacon
	 Where no_poliza = a_poliza
	   And no_unidad = a_unidad
	   and no_endoso = a_endoso;
									  
/*	Delete From enddepen
	 Where no_poliza = a_poliza
	   And no_unidad = a_unidad
	   and no_endoso = a_endoso;
	   
	insert into enddepen(no_poliza,
						 no_unidad,
						 no_endoso,
						 cod_cliente,
						 cod_parentesco,
						 activo,
						 prima,
						 user_added,
						 date_added,
						 no_activo_desde,
						 user_no_activo,
						 doble_cob,
						 doble_cob_cia,
						 doble_cob_fecha,
		                 cont_beneficios,
		                 calcula_prima,
		                 fecha_efectiva,
		                 flag_web_corr)
				select 	no_poliza,
						no_unidad, 
						a_endoso, 
						cod_cliente,	
						cod_parentesco,	
						activo,	
						prima, 
						user_added, 
						date_added, 
						no_activo_desde, 
						user_no_activo, 
						doble_cob, 
						doble_cob_cia, 
						doble_cob_fecha,
						cont_beneficios, 
						calcula_prima, 
						fecha_efectiva,	
						flag_web_corr
				  from  emidepen
				 where  no_poliza = a_poliza
				   and  no_unidad = a_unidad; */
RETURN 0;

END PROCEDURE