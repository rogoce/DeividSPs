-- Procedimiento que valida envio de parmailsend
-- Creado : 12/11/2019 - Autor: Henry Giron 
-- manejo especial para fecha_marcar solo cuando caiga sabado o domingo en avisocanc se le coloca el dia lunes
Drop procedure sp_cob778; 
CREATE PROCEDURE "informix".sp_cob778(  
a_secuencia	INTEGER 
) RETURNING INTEGER; 

define _error			integer; 
define _no_aviso		char(5);
define _renglon			smallint;
define _fecha_quitar    date;
define _fecha_envio		date;
define _cnt             integer;
define _cnt_2           integer;
define _clase			char(1);
define _no_poliza		char(10);

define _no_documento       char(20); 
define _cod_pagador		   char(10);	
define _fecha_gestion	   datetime year to second;	
define _fecha_gestion2	   datetime year to second;
define _msg_gestion 	   char(255);
define _fecha_proceso      date; 		
define _imp_aviso_log      smallint;
define _cod_acreedor 	   CHAR(10);

on exception set _error  
	return _error; 
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob778.trc"; 
--trace on;
	let _imp_aviso_log = 0;		
	let _error = 0;			
	let _cnt = 0;
	let _cnt_2 = 0;
	let _msg_gestion           = '';
	let _fecha_proceso         = sp_sis26();		
	let _fecha_gestion2	       = _fecha_proceso;  
	
 select count(*)
  into _cnt
  from parmailcomp t, parmailsend p
 where t.mail_secuencia = p.secuencia             
   --and t.no_documento[1,2] in ('02','20')
   and p.cod_tipo = '00010'
   and p.enviado = 1
   and p.secuencia = a_secuencia ;
   
   if _cnt is null then
       let _cnt = 0;
   end if
   
   if _cnt > 0  then
    foreach
	select t.no_remesa,
		   t.renglon,
		   p.fecha_envio
	  into _no_aviso,
		   _renglon,
		   _fecha_envio		   
	  from parmailcomp t, parmailsend p
	 where t.mail_secuencia = p.secuencia             
	   --and t.no_documento[1,2] in ('02','20')   --JBRITO 06/01/2020
	   and p.cod_tipo = '00010'
	   and p.enviado = 1
	   and p.secuencia = a_secuencia            -- enviados
	   
	select no_poliza,imp_aviso_log,trim(nvl(cod_acreedor,''))
	  into _no_poliza,_imp_aviso_log,_cod_acreedor
	  from avisocanc
	 where no_aviso = _no_aviso
	   and renglon = _renglon;	   
	   
	   
	   call sp_cob776(_no_poliza,_renglon,_no_aviso) returning _clase;	  
	   call sp_sis388b(_fecha_envio) returning _fecha_quitar;	
	   let _cod_acreedor = _cod_acreedor;
	   let _clase = _clase;
	   
	   if  _clase = 1 and _imp_aviso_log <> 3  then	   	         
	          let _imp_aviso_log = 3;
		   update avisocanc
			   set user_imp_aviso_log = 'DEIVID',
				   date_imp_aviso_log = _fecha_quitar,   -- JEPEREZ 10032021
				   imp_aviso_log = _imp_aviso_log
			 where no_aviso = _no_aviso
			   and renglon = _renglon;		   
	   end if
	   
	   if  _cod_acreedor = '' and _clase = 2 and _imp_aviso_log = 3  then	   	         
		   update avisocanc
			   set user_imp_aviso_log = 'DEIVID',
				   date_imp_aviso_log = _fecha_quitar,   --  JEPEREZ 10032021
				   imp_aviso_log = 3
			 where no_aviso = _no_aviso
			   and renglon = _renglon;		   
	   end if	   

	   if _clase = 1 and _imp_aviso_log = 3 then	   
		update avisocanc
		   set user_marcar = 'DEIVID',
			   fecha_marcar = _fecha_quitar,  -- Se coloca F. Envio solicitur CORREO JBRITO 02/01/2020 y si es Sab o Dom se toma el lunes
			   estatus = 'M'
		 where no_aviso = _no_aviso
		   and renglon = _renglon;	  
		   

			update avisocanc
				   set fecha_imprimir  = 'DEIVID',
					   user_imprimir  = _fecha_quitar  -- Escenario solo correo JEPEREZ 10032021
				 where no_aviso = _no_aviso 				   
				   and renglon = _renglon; 					
		end if
		
     end foreach
	if _error <> 0 then
		return _error;
	end if
	
end if
-- al no ser enviado
select count(*)
  into _cnt_2
  from parmailcomp t, parmailsend p
 where t.mail_secuencia = p.secuencia             
   --and t.no_documento[1,2] in ('02','20')
   and p.cod_tipo = '00010'
   and p.enviado = 2
   and p.secuencia = a_secuencia; 
   
   if _cnt_2 is null then
       let _cnt_2 = 0;
   end if
   
   if _cnt_2 > 0  then
   foreach
   	select t.no_remesa,
		   t.renglon
	  into _no_aviso,
		   _renglon	   
	  from parmailcomp t, parmailsend p
	 where t.mail_secuencia = p.secuencia             
	   --and t.no_documento[1,2] in ('02','20')   --JBRITO 06/01/2020
	   and p.cod_tipo = '00010'
	   and p.enviado = 2
	   and p.secuencia = a_secuencia            -- enviados	   
	   
	select no_poliza,imp_aviso_log,cod_acreedor, no_documento
	  into _no_poliza,_imp_aviso_log,_cod_acreedor, _no_documento
	  from avisocanc
	 where no_aviso = _no_aviso
	   and renglon = _renglon;	   
	   
	   
	   call sp_cob776(_no_poliza,_renglon,_no_aviso) returning _clase;	  
	   call sp_sis388b(_fecha_envio) returning _fecha_quitar;		   
	   
		select cod_pagador			   
		  into _cod_pagador
		  from emipomae 
		 where trim(no_poliza)    = _no_poliza 
		   and trim(no_documento) = _no_documento;		 

   		let _fecha_gestion  = current year to second;
		let _fecha_gestion  = _fecha_gestion + 1 units second; 		 
		
		if _fecha_gestion = _fecha_gestion2 then
			let _fecha_gestion  = _fecha_gestion + 1 units second; 
		end if 

		let _fecha_gestion2 = _fecha_gestion;
		
		let _msg_gestion   = "AVISO ENVIADO A IMPRESIÓN DE LOGISTICA: "||trim(_no_aviso);
		
		if _clase = 1  then
			update avisocanc
				   set fecha_imprimir  =  null,
					   user_imprimir  = null   -- Escenario solo correo JEPEREZ 10032021
				 where no_aviso = _no_aviso 				   
				   and renglon = _renglon; 					
		end if		

			insert into cobgesti(no_poliza,
				 fecha_gestion,
				 desc_gestion,
				 user_added,
				 no_documento,
				 fecha_aviso,
				 tipo_aviso,
				 cod_gestion,
				 cod_pagador)
			values(_no_poliza,
				 _fecha_gestion,
				 _msg_gestion,
				 'DEIVID',
				 _no_documento,
				 _fecha_proceso,
				 0,
				 null,
				 _cod_pagador);	
				 
			update avisocanc
			   set clase = '2'
			 where no_aviso = _no_aviso
			   and renglon = _renglon;				 
	   
      end foreach
   end if




RETURN 0;

--trace off;
END PROCEDURE

