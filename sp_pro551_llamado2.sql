-- Genera Endosos de modificacion para corregir facturas de salud
-- Creado    : 13/09/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pro551_llamado2;
CREATE PROCEDURE sp_pro551_llamado2()
RETURNING  smallint,				--Salud
		   char(50);

DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(200);
define _cnt_origen          smallint;
define _no_endoso           char(5);
define _prima,_p_bruta   	dec(16,2);
define _no_poliza           char(10);
define _vig_ini,_fecha_hoy  date;

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_pro551_llamado2.trc";	
--  trace on;

let _fecha_hoy = current;

begin
on exception set _error
	return _error, "Error...";
end exception

foreach
	select no_poliza
	  into _no_poliza
	  from deivid_tmp:registros_sal1
	 where procesado = 0
	 
	select vigencia_inic
	  into _vig_ini
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _prima = 0;
	let _p_bruta = 0;

	--Se debe crear el recargo para todas las polizas.
	let _error = sp_jean16a(_no_poliza);	--Crea los recargos en las tablas emiunire y emiderec
	
	if _vig_ini > _fecha_hoy then
	
		foreach
			select prima_bruta
			  into _p_bruta
			  from endedmae
			 where actualizado = 1
			   and no_poliza = _no_poliza
			   and periodo = '2024-09'
			   and cod_endomov = '014'
			exit foreach;
		end foreach
		
		let _prima = _p_bruta * 31.5/100;

		call sp_pro551cc(_no_poliza,'DEIVID',_prima,'001') returning _error, _error_desc,_no_endoso;
		return _no_poliza||_no_endoso,0 with resume;
	end if	
	
	if _error = 0 then
		update deivid_tmp:registros_sal1
		   set procesado = 1
		 where no_poliza = _no_poliza;
	end if
	
end foreach
end
return 0, 'Actualizacion exitosa';
END PROCEDURE	  