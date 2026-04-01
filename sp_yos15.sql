-- Procedimiento para generacion una nota del reclamo
-- 
-- creado: 18/02/2011 - Autor: Amado Perez.

DROP PROCEDURE sp_yos15;
CREATE PROCEDURE "informix".sp_yos15(a_codigo_eliminado varchar(10), a_codigo_correcto varchar(10))
                  RETURNING integer, varchar(50);  
DEFINE _error               integer;
DEFINE _cnt                 integer;
DEFINE _cnt_acu				INTEGER;
--SET DEBUG FILE TO "sp_yos15.trc";
--TRACE ON;

BEGIN
ON EXCEPTION SET _error 
 	RETURN _error, "Error al insertar en cliyoseguro";         
END EXCEPTION 


SET LOCK MODE TO WAIT 60;

let _cnt = 0;
let _cnt_acu = 0;

select count(*)
  into _cnt
  from recrcmae
 where cod_asegurado = a_codigo_eliminado
   and yoseguro = 1;

IF _cnt > 0 then
	let _cnt_acu = 1;
end if
   
select count(*)
  into _cnt
  from recrcmae
 where cod_conductor = a_codigo_eliminado
   and yoseguro = 1;

IF _cnt > 0 then
	let _cnt_acu = 1;
end if   
   
select count(*)
  into _cnt
  from recrcmae
 where cod_doctor = a_codigo_eliminado
   and yoseguro = 1;
   
IF _cnt > 0 then
	let _cnt_acu = 1;
end if
 
select count(*)
  into _cnt
  from recrcmae
 where cod_hospital = a_codigo_eliminado
   and yoseguro = 1;  

IF _cnt > 0 then
	let _cnt_acu = 1;
end if   
   
select count(*)
  into _cnt
  from recrcmae
 where cod_reclamante = a_codigo_eliminado
   and yoseguro = 1;    

IF _cnt > 0 then
	let _cnt_acu = 1;
end if   
   
select count(*)
  into _cnt
  from recrcmae
 where cod_taller = a_codigo_eliminado
   and yoseguro = 1;
   
IF _cnt > 0 then
	let _cnt_acu = 1;
end if 

select count(*)
  into _cnt
  from rectrmae
 where cod_cliente = a_codigo_eliminado
   and yoseguro = 1;

IF _cnt > 0 then
	let _cnt_acu = 1;
end if 

select count(*)
  into _cnt
  from rectrmae
 where cod_proveedor = a_codigo_eliminado
   and yoseguro = 1;

IF _cnt > 0 then
	let _cnt_acu = 1;
end if 
  
if _cnt_acu > 0 then 
	Insert into cliyoseguro (codigo_correcto, codigo_eliminado)
				  values (a_codigo_correcto, a_codigo_eliminado); 
end if

SET ISOLATION TO DIRTY READ;
END

return 0, "Se inserto en RECNOTAS";

END PROCEDURE
