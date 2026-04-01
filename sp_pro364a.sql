-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- Modificado: 24/09/2012 - Autor: Roman Gordon --No eliminar de la tabla de errores para poder quitar el flag cuando encuentra la equivalencia. 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro364a;

create procedure "informix".sp_pro364a(a_cod_agente char(5),a_num_carga char(5),a_opcion char(1))
returning integer,
		  smallint,
		  char(100),
          char(100);

define _error_desc			char(100);
define _no_motor			char(30);
define _campo				char(30);
define _no_documento		char(20);
define _cod_ocupacion		char(10);
define _telefono1		char(10);
define _telefono2		char(10);
define _cod_acreedor		char(10);
define _cod_producto		char(10);
define _cod_subramo			char(10);
define _cod_perpago			char(10);
define _cod_modelo			char(10);
define _cod_agente			char(10);
define _cod_marca			char(10);
define _cod_color			char(10);
define _no_poliza			char(10);
define _cod_ramo			char(10);
define _cod_producto_ancon	char(5);
define _cod_acreedor_ancon	char(5);
define _cod_modelo_ancon	char(5);
define _cod_marca_ancon		char(5);
define _no_unidad			char(5);
define _num_carga			char(5);
define _cod_ocupacion_ancon	char(3);
define _cod_subramo_ancon	char(3);
define _cod_perpago_ancon	char(3);
define _cod_color_ancon		char(3);
define _cod_ramo_ancon		char(3);
define _cod_formapag		char(3);
define _error_excep			smallint;
define _error_isam			smallint;
define _cnt_existe			smallint;
define _cnt_error			smallint;
define _cnt_ren				smallint;
define _tot_reg				smallint;
define _return				smallint;
define _existe				smallint;
define _error				smallint;
define _renglon				integer;
define _vigencia_inic		date;
define _vig_final			date;

--set debug file to "sp_pro364a.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error_excep,_error_isam,_error_desc

	return _error_excep,_error_isam, trim(_campo) || ": " || trim(_cod_modelo) || " Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
end exception

select count(*)
  into _tot_reg
  from prdemielctdet
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga
   and proceso		= a_opcion;

let _cod_subramo = '';
foreach
	select renglon,
		   campo
	  into _renglon,
	  	   _campo
	  from equierror
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and (importancia	= 3 or campo in ('cod_ocupacion'))

	if _campo = 'cod_ramo' then
		select cod_ramo
		  into _cod_ramo
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		let _cod_ramo = trim(_cod_ramo);

		select cod_ramo_ancon
		  into _cod_ramo_ancon
		  from equiramo
		 where cod_agente = a_cod_agente
		   and cod_ramo_agt = _cod_ramo;
		
		if _cod_ramo_ancon is not null and _cod_ramo_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_ramo'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_ramo		= _cod_ramo_ancon,
			   	   error		= _error
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_ramo';

		end if		
		continue foreach;
	end if

	if _campo = 'cod_subramo' then
		select cod_ramo,
			   cod_subramo
		  into _cod_ramo_ancon,
		  	   _cod_subramo
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		let _cod_subramo = trim(_cod_subramo);
		let _cod_ramo_ancon = trim(_cod_ramo_ancon);

		select cod_subramo_ancon
		  into _cod_subramo_ancon
		  from equisubra
		 where cod_agente		= a_cod_agente
		   and cod_ramo_ancon	= _cod_ramo_ancon
		   and cod_subramo_agt	= _cod_subramo;
	
		if (_cod_subramo_ancon is null or _cod_subramo_ancon = '') then   
			
			select cod_producto
			  into _cod_producto
			  from prdemielctdet
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			select cod_subramo_ancon
			  into _cod_subramo_ancon
			  from equiprod
			 where cod_agente 		= a_cod_agente
			   and cod_producto_agt = _cod_producto;
		end if

		if _cod_subramo_ancon is not null and _cod_subramo_ancon <> '' then
			
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_subramo'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_subramo	= _cod_subramo_ancon,
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_subramo';
		end if
				
		continue foreach;
	end if

	if _campo = 'cod_producto' then 
		select cod_producto
		  into _cod_producto
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
		
		select cod_producto_ancon
		  into _cod_producto_ancon
		  from equiprod
		 where cod_agente 		= a_cod_agente
		   and cod_producto_agt = _cod_producto;

		if _cod_producto_ancon is not null and _cod_producto_ancon <> '' then

			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_producto'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_producto	= _cod_producto_ancon,
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_producto';
		end if
				
		continue foreach;
	end if
	
	if _campo = 'cod_acreedor' then 
		select cod_acreedor
		  into _cod_acreedor
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		let _cod_acreedor = trim(_cod_acreedor);

		select cod_acreedor_ancon
		  into _cod_acreedor_ancon
		  from equiacre
		 where cod_agente		= a_cod_agente
		   and cod_acreedor_agt = _cod_acreedor;

		if _cod_acreedor_ancon is not null and _cod_acreedor_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_acreedor'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_acreedor	= _cod_acreedor_ancon,
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_acreedor';
		end if
				
		continue foreach;
	end if
	
	if _campo = 'cod_color' then 
		select cod_color
		  into _cod_color
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		let _cod_color = trim(_cod_color);

		select cod_color_ancon
		  into _cod_color_ancon
		  from equicolor
		 where cod_agente		= a_cod_agente
		   and cod_color_agt	= _cod_color;

		if _cod_color_ancon is not null and _cod_color_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_color'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_color	= _cod_color_ancon,
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_color';
		end if
	
		continue foreach;
	end if

	if _campo = 'cod_perpago' then

		select cod_perpago
		  into _cod_perpago
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		select cod_perpago_ancon
		  into _cod_perpago_ancon
		  from equiperpa
		 where cod_agente		= a_cod_agente
		   and cod_perpago_agt	= _cod_perpago;

		if _cod_perpago_ancon is not null and _cod_perpago_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_perpago'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_perpago	= _cod_perpago_ancon,
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_perpago';
		end if
	end if

	if _campo = 'cod_marca' then 
		select cod_marca
		  into _cod_marca
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		select cod_marca_ancon
		  into _cod_marca_ancon
		  from equimarca
		 where cod_agente		= a_cod_agente
		   and cod_marca_agt	= _cod_marca;

		if _cod_marca_ancon is null or _cod_marca_ancon = '' then 
			select cod_modelo
			  into _cod_modelo_ancon
			  from prdemielctdet
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;
			
			foreach
				select cod_marca_ancon	
				  into _cod_marca_ancon	
				  from equimodel
				 where cod_agente		= a_cod_agente
				   and cod_modelo_ancon	= _cod_modelo_ancon
				exit foreach;
			end foreach
		end if
		
		if _cod_marca_ancon is not null and _cod_marca_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_marca'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_marca	= _cod_marca_ancon,
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;
			   
			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_marca';
		end if
				
		continue foreach;
	end if
	
	if _campo = 'cod_modelo' then 
		select cod_modelo
		  into _cod_modelo
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		select cod_modelo_ancon,
			   cod_marca_ancon		
		  into _cod_modelo_ancon,
			   _cod_marca_ancon	
		  from equimodel
		 where cod_agente		= a_cod_agente
		   and cod_modelo_agt	= _cod_modelo;

		if _cod_modelo_ancon is not null and _cod_modelo_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		not in ('cod_marca','cod_modelo')
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_modelo	= _cod_modelo_ancon,
				   cod_marca	= _cod_marca_ancon,	
			   	   error		= _error		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		in ('cod_marca','cod_modelo');
		end if
				
		continue foreach;
	end if

	if _campo = 'cod_ocupacion' then 
		select cod_ocupacion
		  into _cod_ocupacion
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;

		let _cod_ocupacion = trim(_cod_ocupacion);

		if _cod_ocupacion is null then
			select cod_ocupacion_ancon
			  into _cod_ocupacion_ancon
			  from equiocupa
			 where cod_agente			= a_cod_agente
			   and cod_ocupacion_agt	is null;
		else
	
			select cod_ocupacion_ancon
			  into _cod_ocupacion_ancon
			  from equiocupa
			 where cod_agente			= a_cod_agente
			   and cod_ocupacion_agt	= _cod_ocupacion;
		end if

		if _cod_ocupacion_ancon is not null and _cod_ocupacion_ancon <> '' then
			select count(*)
			  into _cnt_existe
			  from equierror
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		<> 'cod_ocupacion'
			   and importancia	= 3;
			
			let _error = 1;
			if _cnt_existe = 0 then
				let _error = 0;
			end if

			update prdemielctdet
			   set cod_ocupacion	= _cod_ocupacion_ancon,
				   error			= _error	
			 where cod_agente		= a_cod_agente
			   and num_carga		= a_num_carga
			   and proceso			= a_opcion
			   and renglon			= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'cod_ocupacion';
		end if				
		continue foreach;
	end if 

	if _campo = 'no_motor' then
		select no_motor,
			   vigencia_inic
		  into _no_motor,
			   _vigencia_inic
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
		
		call sp_proe23('00000',_no_motor,_vigencia_inic) returning _error_excep,_no_documento,_vig_final,_no_unidad;

		if _error_excep = 0 then
			update prdemielctdet
			   set error		= _error_excep		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'no_motor';
		end if
	end if
	
	if _campo = 'telefono1' then
		select telefono1,
			    telefono2
		  into _telefono1,
			   _telefono2
		  from prdemielctdet
		 where cod_agente	= a_cod_agente
		   and num_carga	= a_num_carga
		   and proceso		= a_opcion
		   and renglon		= _renglon;
		
		call sp_cas021(_telefono1) returning _return;
		if _return = 1 and (_telefono2 is null or _telefono2 = '') then
			call sp_cas021a(_telefono1) returning _return;
		end if

		if _return = 0 then
			update prdemielctdet
			   set error		= _return		
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon;

			update equierror
			   set importancia	= 0
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon
			   and campo		= 'telefono1';
		end if
	end if
	
	if a_opcion = 'R' then
		if _campo = 'no_documento' then
			let _cnt_ren = 0;
			
			select no_documento
			  into _no_documento
			  from prdemielctdet
			 where cod_agente	= a_cod_agente
			   and num_carga	= a_num_carga
			   and proceso		= a_opcion
			   and renglon		= _renglon; 
			
			let _cnt_ren = 0;
			
			select count(*)
			  into _cnt_ren
			  from emirepol
			 where no_documento = _no_documento;
			
			call sp_sis21(_no_documento) returning _no_poliza;
			
			if _no_poliza is not null then
				if _cnt_ren = 0 then
					if _no_documento[1,2] = '20' then
						
						call sp_pro318a(_no_poliza) returning _error,_error_desc;
						if _error = 0 then
							update prdemielctdet
							   set error		= _error		
							 where cod_agente	= a_cod_agente
							   and num_carga	= a_num_carga
							   and proceso		= a_opcion
							   and renglon		= _renglon;

							update equierror
							   set importancia	= 0
							 where cod_agente	= a_cod_agente
							   and num_carga	= a_num_carga
							   and proceso		= a_opcion
							   and renglon		= _renglon
							   and campo		= 'no_documento';
						end if
					end if
				else
					let _error = 0;
					update prdemielctdet
					   set error		= _error,
						   no_poliza	= _no_poliza
					 where cod_agente	= a_cod_agente
					   and num_carga	= a_num_carga
					   and proceso		= a_opcion
					   and renglon		= _renglon;

					update equierror
					   set importancia	= 0
					 where cod_agente	= a_cod_agente
					   and num_carga	= a_num_carga
					   and proceso		= a_opcion
					   and renglon		= _renglon
					   and campo		= 'no_documento';
				end if
			end if
		end if
	end if
	return 1,_tot_reg,'','' with resume;		
end foreach

select count(*)
  into _cnt_error
  from equierror
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga
   and proceso		= a_opcion
   and importancia = 3;

if _cnt_error is null or _cnt_error = 0 then
	update prdemielect
	   set error = 0
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion;
end if

return 0,_tot_reg,'Verificacion Exitosa','';
end
end procedure	