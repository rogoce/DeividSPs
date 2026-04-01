-- Procedimiento que Realiza la Reversion de la facturacion mensual

-- Creado    : 06/10/2010 - Autor: Amado Perez  

--{
drop procedure ap_reversa3;

create procedure "informix".ap_reversa3() RETURNING INTEGER,	CHAR(100), integer;
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

let _contador = 0;
				
SET DEBUG FILE TO "ap_reversa2.trc"; 
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

let _contador = _contador + 1;

{select no_poliza
  into v_poliza
  from emipomae
 where no_documento = '1809-00884-01';}

select * 
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso
  into temp prueba;

select no_endoso
  into _no_endoso_ori
  from prueba
 where no_poliza = v_poliza;

	-- Asignacion del Numero de Endoso

	SELECT MAX(no_endoso)
	  INTO _no_endoso_int
	  FROM endedmae
	 WHERE no_poliza = v_poliza;

	IF _no_endoso_int IS NULL THEN
		LET _no_endoso_int  = 0;
	END IF

	LET _no_endoso_int  = _no_endoso_int + 1;
	LET _no_endoso_char = '00000';
	 
	IF _no_endoso_int > 9999  THEN	
		LET _no_endoso_char[1,5] = _no_endoso_int;
	ELIF _no_endoso_int > 999 THEN
		LET _no_endoso_char[2,5] = _no_endoso_int;
	ELIF _no_endoso_int > 99  THEN
		LET _no_endoso_char[3,5] = _no_endoso_int;
	ELIF _no_endoso_int > 9   THEN
		LET _no_endoso_char[4,5] = _no_endoso_int;
	ELSE
		LET _no_endoso_char[5,5] = _no_endoso_int;
	END IF

	LET _no_endoso = _no_endoso_char;


LET _no_factura    = sp_sis14('001', '001', v_poliza);
LET _no_endoso_ext = sp_sis30(v_poliza, _no_endoso);

select count(*)
  into _cantidad
  from endedmae
 where no_factura = _no_factura;

if _cantidad >= 1 then
    rollback work;
	LET _error_desc = 'Numero de Factura Duplicado ';
	RETURN _error, _error_desc, _contador;

end if


update prueba
   set no_endoso         = _no_endoso,
       prima             = prima * (-1),
       descuento   		 = descuento * (-1),
       recargo   		 = recargo * (-1),
       prima_neta   	 = prima_neta * (-1),
       impuesto   		 = impuesto * (-1),
       prima_bruta   	 = prima_bruta * (-1),
       prima_suscrita    = prima_suscrita * (-1),
       prima_retenida    = prima_retenida * (-1),
       fecha_emision     = current,   
       fecha_impresion   = current,   
       no_factura        = _no_factura,   
       date_added        = current,   
       date_changed   	 = current,
       suma_asegurada    = suma_asegurada * (-1),   
       no_endoso_ext     = _no_endoso_ext,   
       subir_bo   		 = 0,
       sac_notrx         = null,   
       flag_web_corr     = 0,
	   fact_reversar     = v_factura
 where no_poliza         = v_poliza;

insert into endedmae
select * from prueba
 where no_poliza = v_poliza;

select prima_neta,
       impuesto
  into _prima_neta,
       _impuesto
  from prueba
 where no_poliza = v_poliza;

UPDATE emipomae
   SET saldo          = saldo + (_prima_neta + _impuesto),
       estatus_poliza = 1
 WHERE no_poliza      = v_poliza;


drop table prueba;

select * 
  from endedimp
 where no_poliza = v_poliza
   and no_endoso = _no_endoso_ori
  into temp prueba;

update prueba 
   set no_endoso = _no_endoso,
       monto     = monto * (-1)
 where no_poliza = v_poliza;

insert into endedimp
select * 
  from prueba
 where no_poliza = v_poliza;

drop table prueba;

select * 
  from endeduni
 where no_poliza = v_poliza
   and no_endoso = _no_endoso_ori
  into temp prueba;

update prueba 
   set no_endoso         = _no_endoso,
       prima             = prima * (-1),
       descuento   		 = descuento * (-1),
       recargo   		 = recargo * (-1),
       prima_neta   	 = prima_neta * (-1),
       impuesto   		 = impuesto * (-1),
       prima_bruta   	 = prima_bruta * (-1),
       prima_suscrita    = prima_suscrita * (-1),
       prima_retenida    = prima_retenida * (-1),
	   subir_bo          = 0
 where no_poliza = v_poliza;

insert into endeduni
select * 
  from prueba
 where no_poliza = v_poliza;

drop table prueba;


select * 
  from endunide
 where no_poliza = v_poliza
   and no_endoso = _no_endoso_ori
  into temp prueba;

update prueba 
   set no_endoso = _no_endoso
 where no_poliza = v_poliza;

insert into endunide
select * 
  from prueba
 where no_poliza = v_poliza;

drop table prueba;

select * 
  from endunire
 where no_poliza = v_poliza
   and no_endoso = _no_endoso_ori
  into temp prueba;

update prueba 
   set no_endoso = _no_endoso
 where no_poliza = v_poliza;

insert into endunire
select * 
  from prueba
 where no_poliza = v_poliza;

drop table prueba;

select * 
  from endedcob
 where no_poliza = v_poliza
   and no_endoso = _no_endoso_ori
  into temp prueba;

update prueba 
   set no_endoso         = _no_endoso,
       prima_anual       = prima_anual * (-1),
       prima             = prima * (-1),
       descuento   		 = descuento * (-1),
       recargo   		 = recargo * (-1),
       prima_neta   	 = prima_neta * (-1),
	   date_added        = TODAY,
	   date_changed      = TODAY,
	   subir_bo          = 0
 where no_poliza = v_poliza;

insert into endedcob
select * 
  from prueba
 where no_poliza = v_poliza;

drop table prueba;


select * 
  from emifacon
 where no_poliza = v_poliza
   and no_endoso = _no_endoso_ori
  into temp prueba;

update prueba 
   set no_endoso         = _no_endoso,
       prima             = prima * (-1),
	   subir_bo          = 0
 where no_poliza = v_poliza;

insert into emifacon
select * 
  from prueba
 where no_poliza = v_poliza;

drop table prueba;

let v_poliza = v_poliza;
let _no_endoso = _no_endoso;

call sp_pro100(v_poliza, _no_endoso);	 -- Historico de endedmae (endedhis)
call sp_sis70(v_poliza, _no_endoso);	 -- Historico de emipoagt (endmoage)


-- Registros para el Comprobante de Reaseguro

call sp_rea008(1, v_poliza, _no_endoso) returning _error, _error_desc;

if _error <> 0 then
    rollback work;
	return _error, _error_desc, _contador;
end if 

update tmpfacm set paso = 1;

end foreach
commit work;

END

RETURN 0, 'Actualizacion Exitosa ...', _contador;

end procedure;