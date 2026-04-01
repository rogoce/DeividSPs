--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245b('2024-09') 

drop procedure sp_end17;

create procedure sp_end17(a_no_poliza char(10), a_no_endoso char(5))
returning	integer			as err,
			integer			as error_isam;

define _desc_error				varchar(100);       
define _error_desc 				varchar(100);       
define _no_documento			char(20);           
define _cod_contratante			char(10);           
define _no_poliza 				char(10);           
define _cod_producto			char(5);            
define _no_unidad 				char(5);            
define _cod_descuen	 			char(3);            
define _cod_ramo		 		char(3);            
define _error_isam				integer;
define _error					integer;
define _existe					integer;
define _vigencia_final			date;
define _fecha_aniversario		date;
DEFINE _ld_prima_neta_t, _prima_resultado    DEC(16,2);
DEFINE _prima_neta_sin, _suma_asegurada      DEC(16,2);
DEFINE _calculo         		DEC(5,2);
define _cod_cliente				char(10);
define _tar_salud               smallint;  
define _tarifa_dep_tot          dec(16,2);   
define _fecha_nac				date;  
define _edad					smallint;   
define _prima_plan				dec(16,2);
define _prima_vida				dec(16,2);  
define _prima_nueva             dec(16,2);
define _cod_depend				char(10);
define _prima_plan_dep			dec(16,2);
define _prima_vida_dep			dec(16,2);
define _tarifa_dep          	dec(16,2);
define _cod_parentesco  		char(3);
define _tipo_pariente,_tipo_par_prod	smallint;


set debug file to "sp_end17.trc";
trace on;

begin
on exception set _error,_error_isam,_error_desc
	
	return	_error,
			_error_isam;
end exception
	
foreach
	select cod_producto,
	       no_unidad,
		   cod_cliente
	  into _cod_producto,
	       _no_unidad,
		   _cod_cliente
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   
	select no_documento,
	       vigencia_final
      into _no_documento,
	       _vigencia_final
      from emipomae
     where no_poliza = a_no_poliza;

    select tar_salud
	  into _tar_salud
	  from prdprod
	 where cod_producto = _cod_producto;
	 	
    let _tarifa_dep_tot	= 0;  
	   
	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;
 
	let _edad = sp_sis78(_fecha_nac, _vigencia_final);	   
	   
	select prima,
           prima_vida
	  into _prima_plan,
           _prima_vida
	  from prdtaeda
	 where cod_producto = _cod_producto
	   and edad_desde   <= _edad
	   and edad_hasta   >= _edad;	

    select prima_nueva
      into _prima_nueva
      from deivid_tmp:carta84
     where poliza = _no_documento
	   and codasegurado = _cod_cliente;
	   
	LET _calculo = 0; 
	LET _calculo = ((_prima_nueva - _prima_plan) / _prima_plan ) * 100; 	
	   
    if _tar_salud = 5 then	--> Tarifas por edad (Aseg + Dep)
		FOREACH with hold
			SELECT cod_cliente
			  INTO _cod_depend
			  FROM emidepen
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND activo = 1

			SELECT fecha_aniversario
			  INTO _fecha_aniversario
			  FROM cliclien
			 WHERE cod_cliente = _cod_depend;

			LET _edad = sp_sis78(_fecha_aniversario, _vigencia_final);

			let _tarifa_dep     = 0;
			let _prima_plan_dep = 0;
			let _prima_vida_dep = 0;
			 
			select prima,
				   prima_vida
			  into _prima_plan_dep,
				   _prima_vida_dep
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad
			   and edad_hasta   >= _edad;

			if _prima_plan_dep is null then
				let _prima_plan_dep = 0;
			end if

			if _prima_vida_dep is null then
				let _prima_vida_dep = 0;
			end if

			let _tarifa_dep = _prima_plan_dep + _prima_vida_dep;
			
			select prima_nueva
			  into _prima_nueva
			  from deivid_tmp:carta84
			 where poliza = _no_documento
			   and codasegurado = _cod_depend;
			   
			LET _calculo = 0;    
			   
			LET _calculo = ((_prima_nueva - _tarifa_dep) / _tarifa_dep ) * 100; 
			
			let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;
		END FOREACH
	  
		let _prima_plan = _prima_plan + _tarifa_dep_tot;

	elif _tar_salud = 6 then	--> Tarifas por dependiente
		select prima
		  into _prima_plan
		  from prdtadep
		 where cod_producto = _cod_producto
		   and tipo         = 1; -- 1 = Aseurado Principal

		let _cod_parentesco = null;

		FOREACH with hold
			SELECT cod_parentesco,cod_cliente
			  INTO _cod_parentesco,_cod_depend
			  FROM emidepen
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND activo = 1
			
			-- 1 = CONYUGUE, 2 = HIJO, HIJA ETC, 99 = OTRA COSA
			select tipo_pariente
			  into _tipo_pariente
			  from emiparen
			 where cod_parentesco = _cod_parentesco; 

			let _tarifa_dep     = 0;
			let _prima_plan_dep = 0;

			if _tipo_pariente = 1 then
				let _tipo_par_prod = 2;	 -- CONYUGUE EN PRODUCTO
			elif _tipo_pariente = 2 then 
				let _tipo_par_prod = 3;	 -- HIJO, HIJA EN PRODCUTO
			else
				let _tarifa_dep     = 0;
				let _prima_plan_dep = 0;
			end  if
			 
			select prima
			  into _prima_plan_dep
			  from prdtadep
			 where cod_producto = _cod_producto
			   and tipo         = _tipo_par_prod;

			if _prima_plan_dep is null then
				let _prima_plan_dep = 0;
			end if

			let _tarifa_dep = _prima_plan_dep;
			
			select prima_nueva
			  into _prima_nueva
			  from deivid_tmp:carta84
			 where poliza = _no_documento
			   and codasegurado = _cod_depend;
			   
			LET _calculo = 0; 
	
			LET _calculo = ((_prima_nueva - _tarifa_dep) / _tarifa_dep ) * 100; 			


			let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;
		END FOREACH
		let _prima_plan = _prima_plan + _tarifa_dep_tot;		   
    end if
	
	-- Porcentaje de Descuento

{	LET _porc_descuento = 0;

	SELECT SUM(porc_descuento)
	  INTO _porc_descuento
	  FROM emiunide
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_descuento IS NULL THEN
		LET _porc_descuento = 0;
	END IF

	-- Porcentaje de Recargo

	LET _porc_recargo   = 0;

	SELECT SUM(porc_recargo)
	  INTO _porc_recargo
	  FROM emiunire
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_recargo IS NULL THEN
		LET _porc_recargo = 0;
	END IF

			   
			if _cnt_descu is null then
				let _cnt_descu = 0;
			end if	
			   
			if _cnt_descu > 0 then   
				update emiunide
				   set porc_descuento = porc_descuento + (_calculo * (-1))
				 where no_poliza = _no_poliza_n
				   and no_unidad = _no_unidad
				   and cod_descuen = '001';
			else	
				insert into emiunide
				values (_no_poliza_n,
						_no_unidad,
					   '001',
					   _calculo * (-1),
					   1);
			end if	

}			
		return _error,0 with resume;
			   
end foreach
end
end procedure;