-- Genera Endosos de modificacion para corregir facturas de salud
-- Creado    : 13/09/2024 - Autor: Armando Moreno M.

--DROP PROCEDURE sp_pro551_llamado;
CREATE PROCEDURE sp_pro551_llamado()
RETURNING  smallint,				--Salud
		   char(20);

DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(200);
define _cnt_origen          smallint;
define _no_endoso           char(5);
define _prima 				dec(16,2);
define _no_poliza           char(10);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_pro551_llamado.trc";	
--  trace on;

begin
on exception set _error
	return _error, "Error...";
end exception

foreach
	select no_poliza,
	       prima
	  into _no_poliza,
	       _prima
	  from deivid_tmp:registros_sal
	 where procesado = 0 

	call sp_pro551cc(_no_poliza,'DEIVID',_prima,'001') returning _error, _error_desc,_no_endoso;
	
	if _error = 0 then
		update deivid_tmp:registros_sal
		   set procesado = 1
		 where no_poliza = _no_poliza;
	end if
	
end foreach
end
return 0, 'Actualizacion exitosa';
END PROCEDURE	  