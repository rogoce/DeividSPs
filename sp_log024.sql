-- Proceso que envia si es sucursal  0:va al pool y no se imprime 1:se imprime y va al pool
-- Creado    : 12/04/2017 - Autor: Henry Girón

drop procedure sp_log024;
create procedure sp_log024(a_no_poliza char(10),a_no_endoso char(5),a_usuario char(8))
returning integer, CHAR(100);

define _no_documento		char(20);
define _cod_contratante 	char(10);	 
define _cantidad			smallint;
define _interna		    	smallint;
define _cod_endomov     	char(3);
define _cod_tipocan     	char(3);
define _no_poliza       	char(10);
define _sucursal        	char(3);
define _cod_agente			char(5);
define _cod_acreedor		char(5);
define _cod_vendedor		char(3);
define _leasing				smallint;
define _estado_pro			smallint;
define _estado_log			smallint;
define _desc_suc		    char(100);
define _mensaje             char(100);
define _error          smallint; 
-- Actualiza el Periodo del Endoso de acuerdo a la vigencia 
-- Requerimientos NIFF
let _leasing = 0;
let _estado_pro = 0;
let _estado_log= 0;
let _error  = 0;

select interna,no_documento
  into _interna,_no_documento
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _interna <> 0 then   -- Internos no aplican
	LET _mensaje = 'Endoso Internos no Aplican.';
	return 1,_mensaje;
end if

LET _no_poliza = sp_sis21(_no_documento);

 SELECT sucursal_origen 
  INTO _sucursal
  FROM emipomae
 WHERE no_poliza = _no_poliza; 
 
  select count(*)
  into _cantidad  
    from insuser u, insagen a
   where u.usuario in(a_usuario)
   and u.codigo_agencia = a.codigo_agencia
   and a.sucursal_promotoria <> '001'
   and a.codigo_agencia = _sucursal; 	
   
   if _cantidad is null then
   let _cantidad = 0;
   end if

if _cantidad <> 0 then
	LET _mensaje = 'Se imprime y va al pool de endoso.';
	return 1,_mensaje;
end if

--if _cantidad <> 0 then
--	LET _mensaje = 'Se imprime y NO va al pool de endoso.';
--	return 2,_mensaje;
--end if
	  
  
CALL sp_log023(a_no_poliza,a_no_endoso,a_usuario,1) returning _error, _mensaje;
if _error <> 0 then
	return _error, _mensaje;
end if  

   	LET _mensaje = 'Va al Pool y no se imprime.';
	return 0,_mensaje;
   
end procedure