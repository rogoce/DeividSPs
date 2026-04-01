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


--set debug file to "sp_end17.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	
	return	_error,
			_error_isam;
end exception

let _error = 0;
	
foreach
	select prima_neta,
	       no_unidad,
		   cod_asegurado
	  into _prima_plan,
	       _no_unidad,
		   _cod_cliente
	  from emipouni
	 where no_poliza = a_no_poliza
	   and activo = 1
	   
	select no_documento,
	       vigencia_final
      into _no_documento,
	       _vigencia_final
      from emipomae
     where no_poliza = a_no_poliza;
	 	
    let _tarifa_dep_tot	= 0;  
	
	let _prima_nueva = 0;
	   
    select prima_nueva
      into _prima_nueva
      from deivid_tmp:salud_ren_rec
     where poliza = _no_documento
	   and codasegurado = _cod_cliente
	   and excluir = 0;
	   
	if  _prima_nueva is null then
		let _prima_nueva = 0;
	end if
	   
	LET _calculo = 0; 
	
	if _prima_nueva <> 0 then
		LET _calculo = ((_prima_nueva - _prima_plan) / _prima_plan ) * 100; 	
	
		IF _calculo <> 0 THEN
			delete from emiunire 
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_recargo = '002';
			   
			insert into emiunire
			values (a_no_poliza,
					_no_unidad,
				   '002',
				   _calculo);		
		END IF
	
	end if
	   
	FOREACH with hold
		SELECT cod_cliente,
			   prima
		  INTO _cod_depend,
			   _prima_plan_dep
		  FROM emidepen
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1

		let _tarifa_dep = 0;

		let _tarifa_dep = _prima_plan_dep;
		
		let _prima_nueva = 0;
				
		select prima_nueva
		  into _prima_nueva
		  from deivid_tmp:salud_ren_rec
		 where poliza = _no_documento
		   and codasegurado = _cod_depend
		   and excluir = 0;
		   
		if  _prima_nueva is null then
			let _prima_nueva = 0;
		end if
		   
		LET _calculo = 0;    

		if _prima_nueva <> 0 then
		   
			LET _calculo = ((_prima_nueva - _tarifa_dep) / _tarifa_dep ) * 100; 
			
			IF _calculo <> 0 THEN		   
				delete from emiderec 
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad
				   and cod_cliente = _cod_depend
				   and cod_recargo = '002';
				   
				insert into emiderec
				values (a_no_poliza,
						_no_unidad,
						_cod_depend,
					   '002',
					   _calculo);		
			END IF
		
		end if
--		let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;
	END FOREACH
  
--	let _prima_plan = _prima_plan + _tarifa_dep_tot;

end foreach
	return _error,0;	
end
end procedure;