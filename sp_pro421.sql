-- Renovación Emisiones Electrónicas
-- Creado    : 15/06/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_pro421;
CREATE PROCEDURE sp_pro421(a_poliza char(10), a_vigencia_inic date, a_vigencia_final date, a_suma dec(16,2), a_usuario char(8)) 
RETURNING  INTEGER as Error,
           VARCHAR(100) as Descripcion;		   

DEFINE _pool			   char(1);  
DEFINE _cod_ramo           char(3);
DEFINE _vigencia_final     date;
DEFINE _vigencia_fin_pol   date;
DEFINE _rtn                smallint;
DEFINE _no_unidad          char(10);
DEFINE _ls_descrip         varchar(50);
DEFINE _porc_partic_agt    dec(5,2);
DEFINE _no_poliza2         char(10);  
DEFINE _valor_nuevo        char(10);  
DEFINE _return             integer;
DEFINE _no_documento       char(20);
DEFINE _cnt                smallint;
DEFINE li_error            smallint;
DEFINE li_tiene_imp        smallint;
DEFINE ll_row              integer;
DEFINE ls_no_doc           char(20);
DEFINE ls_cod_ramo         char(3);
DEFINE ldt_vig_f           date;
DEFINE ls_factura          char(10); 
DEFINE ls_mes              char(2);
DEFINE ls_ano              char(4);
DEFINE ls_periodo          char(7);
DEFINE ls_periodo_contable char(7);
DEFINE ldt_vigen_inic      date;
DEFINE _return_2           integer;
DEFINE _aprob              smallint;

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_pro421.trc";	
--  trace on;

	let _cnt = 0;

	select count(*)
	  into _cnt
	  from emirepol
	 where no_poliza = a_poliza;
	 
    if _cnt > 0 then
		let _pool = "M";
	else
		select count(*)
		  into _cnt
		  from emirepo
		 where no_poliza = a_poliza
		   and estatus = 1;
		
		if _cnt > 0 then
			let _pool = "A";
		else
			let _pool = "";
		end if   
	end if
	
	if _pool = "" then
		return 1, "No se Encuentra la Póliza en el Set de Renovación." || " Póliza: " || trim(_no_documento);
	end if

	select cod_ramo,
		   vigencia_final,
		   vigencia_fin_pol,
           no_documento		   
	  into _cod_ramo,
		   _vigencia_final,
		   _vigencia_fin_pol,
           _no_documento		   
	  from emipomae 
	 where no_poliza = a_poliza;
	 
	if _cod_ramo = "008" then
		-- Verifica si el el asegurado en las unidades tenga cedula y telefono de casa Amado 23/10/2007
		-- excepto las polizas de colectivo de vida que son renovaciones segun Memorando	006-2007
		CALL sp_proe40a(a_poliza) returning _rtn, _no_unidad, _ls_descrip;
		If _rtn = 1 Then
			Return _rtn, "El Asegurado de la Unidad No. " || Trim(_no_unidad) || " No tiene los valores de " || _ls_descrip || "Que son obligatorios" || " Póliza: " || trim(_no_documento);
		End If
	end if

	let _porc_partic_agt = 0.00;
	select sum(porc_partic_agt)
	  into _porc_partic_agt
	  from emiagtre
	 where no_poliza = a_poliza;
	 
	if _porc_partic_agt <> 100 then
		return 1, "Verifique sumatoria de % de participacion del corredor." || " Póliza: " || trim(_no_documento);
	end if
	
    let _valor_nuevo =  sp_sis13 ("001", 'PRO', '02', 'par_no_poliza');	
			
	if _pool = 'M' then

		--Procedure que carga la Distribución de Reaseguro Global e Individual de la Póliza
		let _return = sp_pro222 (a_poliza,'00001',a_suma,'001',0);   --?? 
		
		CALL sp_pro421b(a_poliza, _valor_nuevo, a_vigencia_inic, a_vigencia_final, a_usuario) RETURNING li_error, _ls_descrip; --f_emision_renovar		
		
		if li_error = 0 then  --**********A C T U A L I Z A C I O N**********
	
			select tiene_impuesto 
			  into li_tiene_imp
			  from emipomae
			 where no_poliza = _valor_nuevo;
			
			let _return = sp_sis17(_valor_nuevo);
				 			
			If _return = 0 Then
				-- Cesion Facultativa
				Select Count(*) 
				  Into ll_row
				  From emifafac
				 Where no_poliza = _valor_nuevo
				   And no_endoso = '00000';
	
				If ll_row > 0 Then
					CALL sp_pro421c(_valor_nuevo, '00000') RETURNING li_error, _ls_descrip; --f_emision_cesion_fac
					if li_error <> 0 then
						return li_error, "Error en la cesión facultativo " || _ls_descrip || " Póliza: " || trim(_no_documento);
					end if
				End If
				
				--** BORRAR TABLAS TEMPORALES********
				LET _return = sp_sis61d(a_poliza);
									
				If _return = 0 Then
					DELETE FROM emirepol WHERE no_documento = _no_documento;
					
					Update hemirepo
					   Set estatus_final = 2
					 Where no_poliza = a_poliza;
				
					select no_documento,
					       cod_ramo,
						   vigencia_final 
					  into ls_no_doc,
					       ls_cod_ramo,
						   ldt_vig_f 
					  from emipomae 
					 where no_poliza = _valor_nuevo;

					--Commit Using Sqlca;
					
					LET _return = sp_pro326(a_poliza, a_usuario);
						
							
					--Commit Using Sqlca;
					
					--Therefore					
					--select no_factura
					 -- into ls_factura
					 -- from emipomae
					 --where no_poliza = _valor_nuevo;	
					
					-- _return = f_inserta_therefore(_valor_nuevo,'00000',ls_poliza,ls_factura) llamar al ws 
				Else
					return 1, "Error eliminando tablas temporales" || " Póliza: " || trim(_no_documento);
				end if
			else	--Error Sis17
--				rollback using sqlca;
					
				if _return = 2 then
					let _ls_descrip = "Numero de Factura Duplicado, Por Favor Actualice Nuevamente ..." || " Póliza: " || trim(_no_documento);
				elif _return = 3 then
					if li_tiene_imp = 1 then
						let _ls_descrip = 'Esta Renovación NO debe tener Impuesto, Por Favor Verifique...' || " Póliza: " || trim(_no_documento);
					else
						let _ls_descrip = 'Esta Renovación DEBE tener Impuesto, Por Favor Verifique...' || " Póliza: " || trim(_no_documento);
					end if
				elif _return =4 then
					let _ls_descrip = 'La Sumatoria de porcentajes de Prima/Suma diferente de 100%, por favor verifique ...' || " Póliza: " || trim(_no_documento);
				elif _return =5 then
					let _ls_descrip = 'El Numero de Recibo de Pago es Obligatorio, por favor verifique ...' || " Póliza: " || trim(_no_documento);
				elif _return =6 then
					let _ls_descrip = 'El porcentaje de comision para agente tipo Oficina debe ser cero...' || " Póliza: " || trim(_no_documento);
				elif _return =7 then
					let _ls_descrip = 'El porcentaje de participacion de los agentes debe sumar 100.00' || " Póliza: " || trim(_no_documento);
				elif _return =8 then
					let _ls_descrip = "Las Polizas de Salud No Pueden Tener Vigencia Despues del 28" || " Póliza: " || trim(_no_documento);
				elif _return =9 then
					let _ls_descrip = "El vehículo ha sido bloqueado, No se puede Emitir." || " Póliza: " || trim(_no_documento);
				elif _return =10 then
					let _ls_descrip = "El cliente esta marcado con mala referencia, por favor verifique...." || " Póliza: " || trim(_no_documento);
				else
					if _return =327 then
						CALL sp_emi02(_valor_nuevo) RETURNING _return_2, _ls_descrip;
					else
						let _ls_descrip = "Error al actualizar sp_sis17" || " Póliza: " || trim(_no_documento);
					end if
				end if
				return _return, _ls_descrip;
			end if
		else
			--	rollback using sqlca;
			return li_error, _ls_descrip || " Tipo M";
		end if
	elif _pool = 'A' then
        CALL sp_pro320c(a_usuario, a_poliza, _valor_nuevo) RETURNING li_error, _ls_descrip;
		
		if li_error = 0 then  --**********A C T U A L I Z A C I O N**********		
			Select emi_periodo
			  Into ls_periodo_contable
			  From parparam
			 Where cod_compania = '001'; 

			Select vigencia_inic
			  Into ldt_vigen_inic
			  From emipomae
			 Where no_poliza = a_valor_nuevo; 
	
			let ls_mes = Month(ldt_vigen_inic);
			let ls_mes = Trim(ls_mes);
			let ls_ano = Year(ldt_vigen_inic);
			
			IF ls_mes IN ('10', '11', '12') THEN
				let ls_mes = ls_mes;
			ELSE
				let ls_mes = "0" || Trim(ls_mes);
			END IF
			
			let ls_periodo = ls_ano || "-" || ls_mes;
			
			If ls_periodo > ls_periodo_contable Then
				let ls_periodo_contable = ls_periodo;
			End If
			
			Update emipomae
				Set periodo = ls_periodo_contable
			  Where no_poliza = _valor_nuevo;
			  
			let _return = sp_sis17(_valor_nuevo);  
			
			if _return = 0 Then
				-- Cesion Facultativa
				Select Count(*) 
				  Into ll_row
				  From emifafac
				 Where no_poliza = _valor_nuevo
				   And no_endoso = '00000';
	
				If ll_row > 0 Then
					CALL sp_pro421c(_valor_nuevo, '00000') RETURNING li_error, _ls_descrip; --f_emision_cesion_fac
					if li_error <> 0 then
						return li_error, "Error en la cesión facultativo " || _ls_descrip;
					end if
				End If
			else
			--	rollback using sqlca;
				
				if _return = 2 then
					let _ls_descrip = 'Información', 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...' || " Póliza: " || trim(_no_documento);
				elif _return = 3 then
					if li_tiene_imp = 1 then
						let _ls_descrip = 'Esta Renovación NO debe tener Impuesto, Por Favor Verifique...' || " Póliza: " || trim(_no_documento);
					else
						let _ls_descrip = 'Esta Renovación DEBE tener Impuesto, Por Favor Verifique...' || " Póliza: " || trim(_no_documento);
					end if							
				elif _return =4 then
					let _ls_descrip = 'La Sumatoria de porcentajes de Prima/Suma diferente de 100%, por favor verifique ...' || " Póliza: " || trim(_no_documento);
				elif _return =5 then
					let _ls_descrip = 'El Numero de Recibo de Pago es Obligatorio, por favor verifique ...' || " Póliza: " || trim(_no_documento);
				elif _return =6 then
					let _ls_descrip = 'El porcentaje de comision para agente tipo Oficina debe ser cero...' || " Póliza: " || trim(_no_documento);
				elif _return =7 then
					let _ls_descrip = 'El porcentaje de participacion de los agentes debe sumar 100.00' || " Póliza: " || trim(_no_documento);
				elif _return =8 then
					let _ls_descrip = "Las Polizas de Salud No Pueden Tener Vigencia Despues del 28" || " Póliza: " || trim(_no_documento);
				elif _return =9 then
					let _ls_descrip = "El vehículo ha sido bloqueado, No se puede Emitir." || " Póliza: " || trim(_no_documento);
				elif _return =10 then
					let _ls_descrip = "El cliente esta marcado con mala referencia, por favor verifique...." || " Póliza: " || trim(_no_documento);
				else
					let _ls_descrip = "Error al actualizar sp_sis17" || " Póliza: " || trim(_no_documento);
				end if
				return _return, _ls_descrip;
			end if

			Update emirepo
			   Set estatus   = 5,
				   renovar   = 1
			 Where no_poliza = a_poliza;

			Update hemirepo
				Set estatus_final = 3
			 Where no_poliza = a_poliza;
			 
			Update emipomae
				Set renovada  = 1
			 Where no_poliza = a_poliza;
			 
			let _return = sp_sis157(_valor_nuevo,a_poliza,_no_documento,a_usuario); --insertar nota si tiene obs la ren anterior
			
	--		Commit Using Sqlca;
			--Therefore					
			--select no_factura &
			--	into :ls_factura &
			--	from emipomae &
			--where no_poliza = :_valor_nuevo using sqlca;	
			
			--_return = f_inserta_therefore(_valor_nuevo,'00000',ls_poliza,ls_factura) llamar al ws therefore
		else
			return li_error, _ls_descrip || " Tipo A";
		end if
	end if

	return 0, "Actualizacion Exitosa";
END PROCEDURE	  