--***********************************************************************************
-- Procedimiento que genera la Bonificacion de Rentabilidad por corredores
--***********************************************************************************
-- Este es el procedimiento real NEGOCIO 2011 - Realizado: 23/01/2012 Henry Giron
-- execute procedure sp_che94("001","001","2011-12","HGIRON")
-- Creado    : 28/01/2009 - Autor: Henry Giron
-- Ultima Modificacion: 23/01/2012 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che222;
CREATE PROCEDURE sp_che222(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
v_periodo_aa        CHAR(7),  -- 2016-02
a_usuario           CHAR(8)
) RETURNING SMALLINT,
            char(50),
	        char(3);

--Poner esta linea en comentario cuando se vaya a utilizar.
--return 0, 'Actualizacion Exitosa...',a_periodo;
define _error            smallint;
define _error_isam	     integer;
define _error_desc	     char(50);
define a_periodo         char(7);
define v_periodo_ap      char(7);
define a_periodo_anio    integer;
define v_periodo_ap_anio integer;
define _anio_procesar	 char(4);
define _cod_agente   	 char(5);
define _estatus_licencia char(1);

--SET DEBUG FILE TO "sp_che222.trc";
--TRACE ON;
let _error          = 0;

select par_periodo_act,
	   ult_per_renta_ii 
  into a_periodo,
	   v_periodo_ap	   
  from parparam
 where cod_compania = a_compania;

let a_periodo_anio    = a_periodo[1,4] - 1;
let v_periodo_ap_anio = v_periodo_ap[1,4];

--if a_periodo_anio <= v_periodo_ap_anio then
   --return 1,'Bonificacion de Rentabilidad ya fue Generado.',v_periodo_ap;
--end if

let a_periodo_anio = v_periodo_ap[1,4] + 1;
let _anio_procesar = a_periodo_anio;
let a_periodo      = _anio_procesar||v_periodo_ap[5,7];

delete from chqrentaii where periodo = a_periodo;	--2016-12

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

-- Realiza el Pase de CHQRENTAII
call sp_che221(a_compania,a_sucursal,a_periodo,a_usuario) returning _error,_error_isam,_error_desc;

if _error <> 0 then
	return _error,'Error de pase de tablas de renta 2.'||_error_desc,a_periodo;
end if 

foreach
	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqrentaii
     WHERE periodo = a_periodo
	 GROUP BY cod_agente
	 ORDER BY cod_agente
	 
	select estatus_licencia
	  into _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _estatus_licencia = 'A' then
		call sp_che223(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;
	end if	

	if _error <> 0 then
		return _error,'Actualizacion Exitosa...Error.',a_periodo;
	end if

end foreach	

-- Actualiza parametros
update parparam
   set ult_per_renta_ii = a_periodo
 where cod_compania  = a_compania;
 
end  
--TRACE Off;
return 0, 'Actualizacion Exitosa...',a_periodo;

END PROCEDURE;	