-- Procedure que actualiza endpool0 al imprimir las facturas. 
-- Creado    : 07/04/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A. 
Drop procedure sp_log023;
Create procedure sp_log023(a_no_poliza char(10), a_no_endoso char(10), a_user char(10), a_tipo smallint)
RETURNING integer, 
          varchar(50);

define _cantidad	   smallint;
define _estado_log     smallint;
define _estado_pro     smallint;
define _error          integer;
define _user_imprimio  char(10);
define _user_elimino   char(10);
define _fecha_imprimio date;
define _fecha_elimino  date;
define _fecha_actual   date;
define _no_factura     char(10);
define _cant_fact      smallint;
define _orden          smallint;
define _cod_acreedor   char(5);
define _leasing		   smallint;
define _interna		    	smallint;
define _interna_char   char(2);

let _cantidad = 0;
let _no_factura = '';
let _fecha_actual = sp_sis26();
let _estado_log = 0;
let _estado_pro = 0;

set isolation to dirty read;
set debug file to "sp_log023.trc";
trace on;
     --elimina temporal 
drop table if exists endpool0_tmp;
select * from endpool0	where no_poliza = a_no_poliza and no_endoso = a_no_endoso into temp endpool0_tmp;  	
set lock mode to wait;

-- Tipo: 1- Impresion Cliente 2- Impresion Acredor, 3- Sin Acreedor, 4- Elimino, 5- ReImpresion, 6- Pool salir
-- Tipo: 1- Produccion(Cliente)   2-Logistica(Cliente) 5- Impresion/Produccion, 3- Sin Acreedor, 4- Elimino, 8- Acreedor
	
BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al actualizar pools"; 
	END EXCEPTION 
	
	-- manejo de estatus  
  select estado_log, 
		 estado_pro, 
         no_factura,
         cod_acreedor,
		 leasing
	into _estado_log, 
		 _estado_pro, 
		 _no_factura,
         _cod_acreedor,
		 _leasing
	from endpool0_tmp 
   where no_poliza = a_no_poliza 
	 and no_endoso = a_no_endoso;	 
	
	let _cant_fact = 0; 
	let _orden = 0;
	select count(*) 
	into _cant_fact 
	from logcaja1 
	where numero = _no_factura; 
	
	if _cant_fact is null then 
		let _cant_fact = 0; 
	end if 	  	
	if _leasing is null then 
		let _leasing = 0; 
	end if 	  	
		if _cod_acreedor is null then 
		let _cod_acreedor = ''; 
	end if 	  	
	
	   let _orden = _cant_fact + 1;
	
	 INSERT INTO logcaja1  
			 ( numero,   
			   no_documento,   
			   no_aviso,   
			   renglon,   
			   error )  
	  VALUES ( _no_factura,   
			   a_no_poliza,   
			   a_no_endoso,   
			   a_tipo,   
			   _orden )  ;				   
			   
		if a_tipo in (1,2,5) then 
			let _cant_fact = 0; 
			let _orden = 0;			
			select interna       
			  into _interna
			  from endedmae
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso;
			   
			   let _interna_char = _interna;   
			
			select count(*) 
			into _cant_fact 
			from logcaja0
			where numero = _no_factura; 
			
			if _cant_fact is null then 
				let _cant_fact = 0; 
			end if 	  		

			if _cant_fact = 0 then
				INSERT INTO logcaja0
						 (numero,
						 descripcion,
						 fecha_adicion,
						 usuario_captura,
						 fecha_recibe,
						 usuario_recibe,
						 activo
						 )
				VALUES (
						_no_factura,
						a_no_poliza||','||a_no_endoso||','||_interna_char,
						null,
						null,
						null,
						null,
						a_tipo
						);					
			end if
		end if			   			   			   	
			   
			   
	 if _leasing <> 1 and _cod_acreedor = '' and a_tipo = 2 then 
		let a_tipo = 3;    -- Requerimiento para el pool de acreedor
	end if 	
	
--1--0-0
--5--1-2 o NOACR 2-3
--2--2-2 o 2-3
--3--2-3
--4--4-2
--8--2-3  [5-3] * REIMPRESION

	if a_tipo = 1 then 
		if _estado_log <> 0 or _estado_pro <> 0 then
			return 0, "Actualizaciion Exitosa";
		end if		
		let _estado_pro = 0;    -- insertar Row desde PRO 
		let _estado_log = 0;	-- nada 
	end if
	if a_tipo = 2 then 
		if _estado_log = 3 then 
			return 0, "Actualizaciion Exitosa"; 
		end if	
		let _estado_pro = 2;    -- impresion del pool logistica  
		let _estado_log = 2;	-- impresion Clientes. 
		
		Update  logcaja0
		   set  fecha_adicion = _fecha_actual,
				usuario_captura = a_user,
				activo = a_tipo
		Where numero = _no_factura;
		  
	end if	
	if a_tipo = 3 then 
		if _estado_log = 3 then
			return 0, "Actualizaciion Exitosa"; 
		end if				
		if _estado_pro = 0 then
			let _estado_pro = 2;    -- impresion de Produccion  se corrige que se colocaba en 1
			let _estado_log = 3;	-- impresion finalizada 
		else
			let _estado_pro = 2;    -- impresion pool logistica
			let _estado_log = 3;	-- impresion finalizada  	
		end if
		Update  logcaja0
		   set  fecha_adicion = _fecha_actual,
				usuario_captura = a_user,
				activo = a_tipo
		Where numero = _no_factura;		
	end if		
	if a_tipo = 4 then 
		if _estado_pro = 2  and _estado_log = 3 then
			return 0, "Actualizaciion Exitosa";
		end if				
		let _estado_pro = 4;    -- impresion sin acreedor del pool logistica
		let _estado_log = 2;	-- impresion sin acreedor Log.  
		Update  logcaja0
		   set  activo = a_tipo
		Where numero = _no_factura;			
	end if			
	if a_tipo = 5 then 
		if _estado_pro <> 0 and _estado_log <> 0 then
			return 0, "Actualizaciion Exitosa";
		end if					
		if _estado_pro = 0 then
			let _estado_pro = 2; --1;    -- impresion pool logistica
			let _estado_log = 2;	-- impresion Acreedor.  				
		else
			let _estado_pro = 2;    -- impresion pool logistica
			let _estado_log = 2;	-- impresion Acreedor.  				
		end if				
		Update  logcaja0
		   set  activo = a_tipo
		Where numero = _no_factura;		
	end if			
	if a_tipo = 8 then 
		if _estado_log = 5 then
			return 0, "Actualizaciion Exitosa";
		end if				
		if _estado_log in (1) then
			return 0, "Actualizaciion Exitosa";
		end if						
		let _estado_pro = 5;        -- impresion sin acreedor del pool logistica.
		let _estado_log = 2;	    -- impresion finalizada desde logistica.  
		
		Update  logcaja0
		   set  fecha_recibe = _fecha_actual,
				usuario_recibe = a_user,
				activo = a_tipo
		Where numero = _no_factura;
						
	end if		
	
	if a_tipo = 4  then -- eliminar
		select user_imprimio,
               fecha_imprimio 		
		into _user_imprimio,
		     _fecha_imprimio
		from endpool0_tmp
		where no_poliza = a_no_poliza
		  and no_endoso = a_no_endoso;
		  
		 let _user_elimino = a_user;
		 let _fecha_elimino = _fecha_actual;		 				 		 	 
		  
	 else              -- imprimir o Reimpresion
		select user_elimino,
               fecha_elimino 		
		into _user_elimino,
		     _fecha_elimino
		from endpool0_tmp
		where no_poliza = a_no_poliza
		and no_endoso = a_no_endoso;	 
		
		 let _user_imprimio = a_user; 
		 let _fecha_imprimio = _fecha_actual; 
	 end if
	
	Update endpool0
	Set estado_pro     = _estado_pro,   -- impreso desde logistica : 0-Adicion, 1-Produccion, 2-Logistica, 3-ReimpresionLog, 4-ReimpresionPro, 5-EliminoLog
		estado_log     = _estado_log,   -- cambia el estado de imrpesion de endosos de la polizas : 0-Ninguno, 1-Cliente, 2-Acreedor y 3-Ambos		
		user_imprimio  = _user_imprimio,
        fecha_imprimio = _fecha_imprimio,
        user_elimino   = _user_elimino,
        fecha_elimino  =_fecha_elimino
	Where no_poliza    = a_no_poliza
	  and no_endoso    = a_no_endoso;					
end



return 0, "Actualizaciion Exitosa";
end procedure  