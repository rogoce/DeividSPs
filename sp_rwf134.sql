-- Procedimiento que disminuye la reserva y crea una reserva inicial -- Cambio de Evento

-- Creado    : 02/05/2014 - Autor: Amado Perez M. 

--drop procedure sp_rwf120;
drop procedure sp_rwf134;

create procedure sp_rwf134(a_no_reclamo char(10), a_cod_evento char(3), a_user_name_ajust CHAR(20), a_cod_cobertura CHAR(5)) 
  returning integer,
            char(50),
            char(10);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);
define _variacion           dec(16,2);
define _cod_tipotran        char(3);
define _cod_cobertura_rec   char(5);
define _user_added          char(8);
define _cerrar_rec          smallint;

define _cod_evento          char(3);
define _suma_asegurada   	decimal(16,2);
define _tipo                smallint;
define a_monto     			decimal(16,2);
define a_opcion      		smallint;
define _cant_cob          	smallint;
define _tipo_dano           smallint;
define _cnt                 smallint;

set isolation to dirty read;

if a_no_reclamo = '677028' then
  set debug file to "sp_rwf134.trc";
  trace on;
end if

begin work;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, null;
end exception

let _reserva_actual = 0; 
let _cerrar_rec = 0; 
let _cod_cobertura = a_cod_cobertura;
let a_user_name_ajust = UPPER(a_user_name_ajust);
let _cant_cob = 0;
let _cnt = 0;
let a_monto = 0;

 select usuario
   into _user_added
   from insuser
  where windows_user = trim(a_user_name_ajust);

select cod_compania,
       cod_sucursal,
	   numrecla,
	   cod_asegurado,
	   no_poliza,
	   reserva_actual,
	   cod_evento,
	   suma_asegurada,
	   tipo_dano
  into _cod_compania,
       _cod_sucursal,
	   _numrecla,
	   _cod_cliente,
	   _no_poliza,
	   _reserva_actual,
	   _cod_evento,
	   _suma_asegurada,
	   _tipo_dano
  from recrcmae
 where no_reclamo = a_no_reclamo;
 
SELECT COUNT(*)
  INTO _cant_cob
  FROM recrccob
 WHERE no_reclamo = a_no_reclamo
   AND cod_cobertura = _cod_cobertura;

if a_cod_evento = _cod_evento and _cant_cob > 0 then
	return 0, "No hubo cambios", null;
end if

-- Dismunir la reserva a 0

call sp_rwf120(a_no_reclamo, _user_added) returning _error, _error_desc;  

if _error <> 0 then
    rollback work;
	return _error, _error_desc, null;
end if

select count(*)
  into _cnt
  from recreeve
 where cod_ramo = '002'
   and cod_evento = a_cod_evento
   and tipo_dano = _tipo_dano;

if _cnt > 0 then
	select reserva_inicial, tipo
	  into a_monto, _tipo
	  from recreeve
	 where cod_ramo = '002'
	   and cod_evento = a_cod_evento
	   and tipo_dano = _tipo_dano;
else
	select reserva_inicial, tipo
	  into a_monto, _tipo
	  from recreeve
	 where cod_ramo = '002'
	   and cod_evento = a_cod_evento
	   and tipo_dano = 0;
end if

if a_monto is null then
	let a_monto = 0;
end if
   
if _tipo = 2 then
	let a_monto = _suma_asegurada;
end if 

LET _cant_cob = 0;

SELECT COUNT(*)
  INTO _cant_cob
  FROM recrccob
 WHERE no_reclamo = a_no_reclamo
   AND cod_cobertura = _cod_cobertura;

if _cant_cob = 0 then
	INSERT INTO recrccob (
	            no_reclamo,
				cod_cobertura)
	     VALUES	(
	            a_no_reclamo,
		        _cod_cobertura
		        );
end if

{foreach
	select cod_cobertura, reserva_actual
	  into _cod_cobertura, _reserva_cob
	  from recrccob
	 where no_reclamo = a_no_reclamo

	 exit foreach;
end foreach
}
-- Nueva reserva inicial  

LET _cod_tipotran = '001';
LET _variacion = a_monto;

let _aplicacion = "REC";

SELECT version
  INTO _version
  FROM insapli
 WHERE aplicacion = _aplicacion;

SELECT valor_parametro
  INTO _valor_parametro
  FROM inspaag
 WHERE codigo_compania  = _cod_compania
   AND aplicacion       = _aplicacion
   AND version          = _version
   AND codigo_parametro	= 'fecha_recl_default';

IF TRIM(_valor_parametro) = '1' THEN   --Toma la fecha del servidor

	LET _fecha_no_server = CURRENT;				

ELSE								   --Toma la fecha de un parametro establecido por computo.

	SELECT valor_parametro			  
      INTO _valor_parametro2
	  FROM inspaag
	 WHERE codigo_compania  = _cod_compania
	   AND aplicacion       = _aplicacion
	   AND version          = _version
	   AND codigo_parametro	= 'fecha_recl_valor';

	LET _fecha_no_server = DATE(_valor_parametro2);				

END IF

IF MONTH(_fecha_no_server) < 10 THEN
	LET _periodo_rec = YEAR(_fecha_no_server) || "-0" || MONTH(_fecha_no_server);
ELSE
	LET _periodo_rec = YEAR(_fecha_no_server) || "-" || MONTH(_fecha_no_server);
END IF

-- Asignacion del Numero Interno y Externo de Transacciones

--LET _no_tran_char = null;
LET _no_tran_char    = sp_sis12(_cod_compania, _cod_sucursal, a_no_reclamo);
LET _no_tranrec_char = sp_sis13(_cod_compania, _aplicacion, _version, 'par_tran_genera');

INSERT INTO rectrmae(
no_tranrec,
cod_compania,
cod_sucursal,
no_reclamo,
cod_cliente,
cod_tipotran,
cod_tipopago,
no_requis,
no_remesa,
renglon,
numrecla,
fecha,
impreso,
transaccion,
perd_total,
cerrar_rec,
no_impresion,
periodo,
pagado,
monto,
variacion,
generar_cheque,
actualizado,
user_added
)
VALUES(
_no_tranrec_char,
_cod_compania,
_cod_sucursal,
a_no_reclamo,
_cod_cliente,
_cod_tipotran,
null,
null,
null,
null,
_numrecla,
_fecha_no_server,
0,
_no_tran_char,
0,
_cerrar_rec,
0,
_periodo_rec,
0,
a_monto,
_variacion,
0,
1,
_user_added
);

-- Insercion de las Coberturas (Transacciones)

INSERT INTO rectrcob(
no_tranrec,
cod_cobertura,
monto,
variacion
)
VALUES(
_no_tranrec_char,
_cod_cobertura,
a_monto,
_variacion
);

-- Actualizando reclamo

update recrcmae
   set cod_evento      = a_cod_evento
 where no_reclamo      = a_no_reclamo;

update recrccob
   set reserva_inicial = 0
 where no_reclamo      = a_no_reclamo
   and cod_cobertura   <> _cod_cobertura;
  
update recrccob
   set reserva_inicial = _variacion,
       reserva_actual  = _variacion 
 where no_reclamo      = a_no_reclamo
   and cod_cobertura   = _cod_cobertura;
        
-- Reaseguro a Nivel de Transaccion

call sp_sis58(_no_tranrec_char) returning _error, _error_desc;

if _error <> 0 then
	rollback work;
	return _error, _error_desc, null;
end if



end
commit work;

return 0, "Actualizacion Exitosa", _no_tranrec_char;

end procedure