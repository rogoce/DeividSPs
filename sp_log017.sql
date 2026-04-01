-- Verificacion de polizas segun referencia a ser colocadas fechas
-- PRogramado para liberar la secuencia del informe
-- Creado    : 24/05/2016 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_log017;
create procedure sp_log017(a_user_proceso CHAR(15), a_numero char(10), a_aviso char(10))
returning integer,
          char(100);

define _no_documento	char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);  
define _cobra_poliza	char(1);
define _estatus_poliza	char(1);
define _cod_tipoprod	char(3);

define _cantidad		smallint;
define _fecha_emision	date;
define _fecha_actual	date;

define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _nombre_formapag	char(50);
define _dias			smallint;
define _return			smallint;
define _error			integer;

define _cancelada		smallint;
define _fecha_canc		date;
define _fecha_proceso	date;

define _saldo			dec(16,2);
define _saldo_act		dec(16,2);
define _saldo_canc		dec(16,2);
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _corriente		dec(16,2);
define _dias_30  		dec(16,2);
define _dias_60  		dec(16,2);
define _dias_90  		dec(16,2);
define _dias_120 		dec(16,2);
define _dias_150 		dec(16,2);
define _dias_180		dec(16,2);
define _no_aviso 		char(10);
define _a_aviso         char(10);
define _user_added		char(8);
define _renglon         integer;
define _descripcion     char(100);

define _correo_certif     char(50);
define _tipo              char(1);
define _cnt               integer;

define _tm_ultima_gestion integer;
define _tm_fecha_efectiva integer;
define _realizado         integer;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

drop table if exists tmp_codigos;

let _saldo_canc	 = 0; 
let _renglon = 0; 
let _cnt = 0; 
let _fecha_actual = sp_sis26(); 
let _tm_ultima_gestion = 0; 
let _tm_fecha_efectiva = 0; 

select count(*)  
  into _realizado
  from cobccert0 
 where numero = a_numero 
   and activo = 5;  -- 5 al ser completado 
   
 if _realizado <> 0  then  
	return 1, "Reporte de Correo Certificado completado ...";  
end if 

select count(*)  
  into _realizado
  from cobccert0 
 where numero = a_numero 
   and activo = 4;  -- 5 al ser completado 
   
 if _realizado = 0  then  
	return 1, "Reporte de Correo Certificado no existe con esta numeracion ...";  
end if 

select correo_certif  
  into _correo_certif 
  from cobccert0 
 where numero = a_numero 
   and activo = 4;  -- 4 al generar el informe C.C.
   
 if _correo_certif = "" or _correo_certif is null then  
	return 1, "Reporte de Correo Certificado Sin Descipcion Valida ...";  
end if    
let _tipo = sp_sis04(_correo_certif); -- Separa los valores del string  

--SET DEBUG FILE TO "sp_log017.trc";
--TRACE ON; 

SELECT count(*)   
  INTO _cnt   
  FROM tmp_codigos    
 WHERE codigo = a_aviso; 
 
 if _cnt = 0 then   
	return 1, "Reporte de Correo Certificado no pertenece al aviso ...";   
end if  
  
 update cobccert0
    set no_aviso = a_aviso, usuario_entrega = a_user_proceso
  where numero = a_numero
    and activo = 5;
	
update cobccert1 
   set error  = 0
   where numero = a_numero 
	 and error <> 3 ;	
	 
foreach
	 SELECT trim(codigo) 
	   INTO _a_aviso     
	   FROM tmp_codigos  
	
		foreach
			select distinct b.no_aviso, a.no_documento
			  into _no_aviso, _no_documento
			  from cobccert1 a, avisocanc b
			 where a.numero = a_numero 
			   and a.no_documento = b.no_documento
			   and b.no_aviso = _a_aviso						   

			update avisocanc  
--			   set marcar_entrega = 0, impreso = 0
               set marcar_certifica = 0, reporte_certifica = '', fecha_certifica = null, user_certifica = '' 
			 where no_aviso     = _no_aviso 
			   and no_documento = _no_documento ;
			    -- and estatus in ('I') ;  

		end foreach
end foreach		

end 

-- return 0, "Se desvinculo avisos al informe correctamente ..."||trim(_correo_certif) ;
return 0, "Actualizacion Exitosa ..."||trim(_correo_certif);
drop table tmp_codigos;

--drop table if exists tmp_ccertcc;
end procedure	 
