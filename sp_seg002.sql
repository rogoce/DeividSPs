-- Lista de Cambios de Usuarios
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.  

DROP PROCEDURE sp_seg002;
create procedure "informix".sp_seg002()
returning CHAR(8),   --_usuario,
		  CHAR(30),  --_descripcion
		  char(100), --_depto_name,												   
		  char(30),	 --_n_agencia
		  char(10);  --motivo solo sale vacaciones

DEFINE _usuario         char(8);  -- 1
DEFINE _descripcion     char(30); -- 2
DEFINE _n_agencia       char(30);
DEFINE _depto_name      char(100);
DEFINE _cia_depto       char(5);
DEFINE _codigo_agencia  char(3);
define _cod_motivo      char(3);
define _n_motivo        char(10);

let _n_agencia = "";
let _n_motivo  = null;

SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach
	 select descripcion,
	 		usuario,	        
			cia_depto,
			codigo_agencia,
			cod_motivo
	   into _descripcion,
		   	_usuario,	        
			_cia_depto,
			_codigo_agencia,
			_cod_motivo
	   from insuser
	  where status = "A"
         or cod_motivo = '001'

	select  nombre
	  into  _depto_name
	  from  insdepto 
	  where cod_depto = _cia_depto;

	select  descripcion
	  into  _n_agencia
	  from  insagen
	  where codigo_agencia = _codigo_agencia;
	  
    if _cod_motivo is null or _cod_motivo = '' then
		let _n_motivo = null;
	else
		let _n_motivo = 'VACACIONES';
	end if
	 return _usuario,
			_descripcion,
			_depto_name,
			_n_agencia,
			_n_motivo
	   with resume;
end foreach
		   
end procedure;
				 