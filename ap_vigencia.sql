-- Procedimiento que Realiza la Reversion de la facturacion mensual

-- Creado    : 06/10/2010 - Autor: Amado Perez  

--{
drop procedure ap_vigencia;

create procedure "informix".ap_vigencia() RETURNING INTEGER, CHAR(100), integer, char(10), char(5), date, date;
--}

--- Actualizacion de Polizas

define _error           	smallint;
define _error_desc      	char(100);
define v_poliza             char(10);
define _no_endoso_ori		char(5);
define _no_endoso_int       integer;
define _no_endoso_char      char(5);
define _no_endoso           char(5);
define _no_factura   		char(10);
define _no_endoso_ext		char(5);
define _cantidad           	integer;
define _cantidad2           integer;
define _prima_neta          dec(16,2);
define _impuesto            dec(16,2);
define _contador           	integer;
define _vigencia_final      date;
define _vigencia_final_er   date;
define _vigencia_inic       date;

let _contador = 0;
				
SET DEBUG FILE TO "ap_vigencia.trc"; 
trace on;

--BEGIN

SET ISOLATION TO DIRTY READ;

begin work;

BEGIN
ON EXCEPTION SET _error 
    rollback work;
	RETURN _error, _error_desc, _contador, v_poliza, _no_endoso, _vigencia_inic, _vigencia_final;
END EXCEPTION           


foreach	with hold
select no_poliza 
  into v_poliza
  from exepsal


select vigencia_final
  into _vigencia_final_er
  from emipomae
 where no_poliza = v_poliza;

If month(_vigencia_final_er) <> 12 Then
	continue foreach;
end if

let _contador = _contador + 1;
let _no_endoso = "";

select no_endoso, vigencia_inic, vigencia_final
  into _no_endoso, _vigencia_inic, _vigencia_final 
  from endedmae
 where no_poliza = v_poliza
   and cod_endomov = '014'
   and periodo = '2010-10'
   and vigencia_final = _vigencia_final_er;

	LET _vigencia_inic = _vigencia_inic - 1 UNITS MONTH;
	LET _vigencia_final = _vigencia_final - 1 UNITS MONTH;

update endedmae
   set vigencia_inic = _vigencia_inic,
	   vigencia_final = _vigencia_final,
	   fecha_primer_pago = _vigencia_inic
 where no_poliza = v_poliza
   and no_endoso = _no_endoso;

update endeduni
   set vigencia_inic = _vigencia_inic,
	   vigencia_final = _vigencia_final
 where no_poliza = v_poliza
   and no_endoso = _no_endoso;

update emipouni
   set vigencia_final = _vigencia_final
 where no_poliza = v_poliza;

update emireama
   set vigencia_final = _vigencia_final
 where no_poliza = v_poliza
   and vigencia_final = _vigencia_final_er;

update emipomae
   set vigencia_final = _vigencia_final
 where no_poliza      = v_poliza;

--  into temp prueba;

--RETURN 0, 'Actualizacion Exitosa ...', _contador, v_poliza, _no_endoso, _vigencia_inic, _vigencia_final with resume;

end foreach
commit work;

END

RETURN 0, 'Actualizacion Exitosa ...', _contador, v_poliza, _no_endoso, _vigencia_inic, _vigencia_final;

end procedure;