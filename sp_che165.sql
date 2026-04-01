--***********************************************************************************
-- Procedimiento que genera CHQBONO019 - Polizas Nuevas Vidad Individual
--***********************************************************************************
-- execute procedure sp_che165("001","001","2017-01","HGIRON")
-- Creado    : 23/01/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che165;
CREATE PROCEDURE sp_che165(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo           CHAR(7),  -- 2017-01
a_usuario           CHAR(8)
) RETURNING SMALLINT,
            char(50),
	        char(7);

--Poner esta linea en comentario cuando se vaya a utilizar.
--return 0, 'Actualizacion Exitosa...',a_periodo;
define _error            smallint;
define _error_isam	     integer;
define _error_desc	     char(50);
define _error_desc2	     char(50);
define _cod_agente   	 char(5);
define _estatus_licencia char(1);
define _ult_per_bono19	 char(7);
define _ultmes			 char(2);

--SET DEBUG FILE TO "sp_che165.trc";
--TRACE ON;

let _error          = 0; 
select ult_per_bono19
  into _ult_per_bono19
  from parparam;

let _ultmes = _ult_per_bono19[6,7];

if _ultmes = '12' then
	return 1,'',_ult_per_bono19;
end if

delete from chqbono019 where periodo  = a_periodo;	
delete from chqbono019e where periodo = a_periodo;

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

-- Realiza el Pase de CHQBONO019
call sp_che164(a_compania,a_sucursal,a_periodo,a_usuario) returning _error,_error_desc,_error_desc2;

if _error <> 0 then
	return _error,'Error de pase a tablas de Bono Vida Individual.'||_error_desc,_error_desc2;
end if 

foreach
	SELECT distinct cod_agente
	  INTO _cod_agente
	  FROM chqbono019e
     WHERE no_requis is null   --periodo = a_periodo
	   AND aplica = 1
	 ORDER BY cod_agente
	 
	select estatus_licencia
	  into _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;
	
	--se elimina exclusion segun caso 9912
	{if _cod_agente = '02825' then  --se excluye 02825 caso 3631
		continue foreach;
	end if}
	--se excluye segun caso 11579
	if _cod_agente = '02442' then
		continue foreach;
	end if
	if _estatus_licencia = 'A' then
		 call sp_che166(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;
	end if	

	if _error <> 0 then
		return _error,'Actualizacion Exitosa...Error.',a_periodo;
	end if

end foreach	

-- Actualiza parametros
update parparam
   set ult_per_bono19 = a_periodo
 where cod_compania  = a_compania;
 
end  
--TRACE Off;
return 0, 'Actualizacion Exitosa...',a_periodo;

END PROCEDURE;	