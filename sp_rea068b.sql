-- Procedimiento que disminuye la reserva del reclamo y la aumenta

-- Creado    : 22/09/2015 - Autor: Armando Moreno

drop procedure sp_rea068b;

create procedure sp_rea068b(a_serie smallint)
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _valor_parametro2	char(20);
define _valor_parametro		char(20);
define _numrecla			char(18);
define _no_tranrec_char		char(10);
define _transaccion2		char(10);
define _no_tran_char		char(10);
define _no_tranrec2			char(10);
define _transaccion			char(10);
define _cod_cliente			char(10);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _cod_ruta			char(5);
define _periodo_rec			char(7);  
define _periodo2			char(7);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _aplicacion			char(3);
define _cod_ramo			char(3);
define _version				char(2);
define _cod_cober_reas		char(3);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6);
define _variacion_acum2		dec(16,2);
define _variacion_acum		dec(16,2);
define _reserva_cob			dec(16,2);
define _variacion			dec(16,2);
define _reserva2			dec(16,2);
define _reserva				dec(16,2);
define _tipo_contrato		smallint;
define _orden               smallint;
define _cnt3     			smallint;
define _cnt2				smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_no_server		date;
define _vigencia_inic		date;

set isolation to dirty read;

begin

foreach with hold
	select first 2 numrecla
	  into _numrecla
	  from deivid_tmp:recpentra
	 where serie  = a_serie
	   and procesado = 0
	 order by 1

	begin work;

	--Procedure que genera las transacciones de Aumento y Disminución de Reserva.
	call sp_rea064a(_numrecla,'DEIVID') returning _error, _error_desc;
	
	if _error <> 0 then
		rollback work;
		return _error,_error_desc with resume;
		continue foreach;
	end if
	
	update deivid_tmp:recpentra
	   set procesado = 1
	 where numrecla = _numrecla;

	commit work;
end foreach

return 0,'Exito';
end
end procedure;