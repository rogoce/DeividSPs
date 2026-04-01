-- Procedimiento que Realiza la Reversion de la facturacion mensual

-- Creado    : 06/10/2010 - Autor: Amado Perez  

--{
drop procedure ap_vigencia2;

create procedure "informix".ap_vigencia2() RETURNING INTEGER,	CHAR(100), integer;
--}

--- Actualizacion de Polizas

define _error           	smallint;
define _error_desc      	char(100);
define v_poliza             char(10);
define v_endoso             char(5);
define v_factura            char(10);
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
define _fecha1              date;
define _fecha2              date;
define _cod_perpago         char(3);
define _meses               smallint;
define _no_unidad           char(5);


let _contador = 0;
				
SET DEBUG FILE TO "ap_vigencia2.trc"; 
trace on;

--BEGIN

SET ISOLATION TO DIRTY READ;

begin work;

BEGIN
ON EXCEPTION SET _error 
    rollback work;
	RETURN _error, _error_desc, _contador;
END EXCEPTION           


foreach	with hold
select no_poliza, no_endoso, no_factura 
  into v_poliza, v_endoso, v_factura 
  from tmpfacm
 where paso = 0 

let _contador = _contador + 1;

{select no_poliza
  into v_poliza
  from emipomae
 where no_documento = '1809-00884-01';}

select vigencia_inic, cod_perpago
  into _fecha1, _cod_perpago 
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

-- Se determina la nueva vigencia final de la poliza

SELECT meses
  INTO _meses
  FROM cobperpa
 WHERE cod_perpago = _cod_perpago;

if _meses = 0 then
	if _cod_perpago = '008' then
		let _meses = 12; 	   	
	else
		let _meses = 1;
	end if
end if

LET _fecha2 = _fecha1 + _meses UNITS MONTH;


{update endedmae
   set vigencia_final    = _fecha2
 where no_poliza         = v_poliza
   and no_endoso         = v_endoso;

UPDATE emipomae
   SET vigencia_final    = _fecha2
 where no_poliza         = v_poliza;

foreach 
	SELECT no_unidad
	  INTO _no_unidad
	  FROM endeduni
	 WHERE no_poliza = v_poliza
	   AND no_endoso = v_endoso
	  
	update endeduni
	   set vigencia_final    = _fecha2
	 where no_poliza         = v_poliza
	   and no_endoso         = v_endoso
	   and no_unidad         = _no_unidad;

	UPDATE emipouni
	   SET vigencia_final = _fecha2
	 WHERE no_poliza      = v_poliza
	   and no_unidad      = _no_unidad;

	UPDATE emireama
	   SET vigencia_final = _fecha2
	 WHERE no_poliza      = v_poliza
	   and no_unidad      = _no_unidad;
end foreach
}
update endedhis
   set vigencia_final = _fecha2
 where no_poliza         = v_poliza
   and no_endoso         = v_endoso;

update tmpfacm set paso = 1 
 where no_poliza         = v_poliza
   and no_endoso         = v_endoso;

end foreach
commit work;

END

RETURN 0, 'Actualizacion Exitosa ...', _contador;

end procedure;