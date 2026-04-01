-- Marcar Reclamo y Poliza como Perdida Total
-- 
-- Creado    : 17/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 17/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_rwf123;

create procedure "informix".sp_rwf123(a_numrecla char(20), a_tiporeclamo varchar(10), a_inicidente integer) 
    returning char(10), 
              char(5), 
              char(10), 
			  char(20),
              char(3), 
              varchar(50), 
              char(10), 
              varchar(100), 
              date, 
              datetime hour to second, 
              date, 
              char(3), 
              varchar(50), 
              dec(16,2), 
              dec(16,2), 
              dec(16,2), 
              dec(16,2), 
              dec(16,2), 
              dec(16,2), 
              dec(16,2), 
              dec(16,2),
              char(10),
              char(5),
              varchar(50),
              dec(16,2);

define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_reclamo  	char(10);
define _no_documento    char(20);
define _cod_evento		char(3);
define _cod_asegurado 	char(10);
define _fecha_siniestro	date;
define _hora_sisniestro	datetime hour to second;
define _fecha_documento	date;
define _reserva			dec(16,2);
define _evento			varchar(50);
define _asegurado		varchar(100);
define _cod_ramo		char(3);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _ramo			varchar(50);
define _por_vencer		dec(16,2);
define _exigible  		dec(16,2);
define _corriente 		dec(16,2);
define _monto_30  		dec(16,2);
define _monto_60  		dec(16,2);
define _monto_90  		dec(16,2);
define _saldo			dec(16,2);
define _cod_cobertura   char(5);
define _cobertura       varchar(50);
 
define _mes_char		char(2);
define _ano_char		char(4);
define _periodo			char(7);
define _no_tramite      char(10);

define _error		integer;

define _reserva_cob		dec(16,2);
define _cant_cob        smallint;

set isolation to dirty read;

if a_numrecla = '02-0418-00082-11' then
	SET DEBUG FILE TO "sp_rwf123.trc";
	TRACE ON;
end if

begin
on exception set _error 
 	return _error, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null;         
end exception

IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;


select no_poliza,
       no_unidad,
	   no_reclamo,
	   no_documento,
	   cod_evento,
	   cod_asegurado,
	   fecha_siniestro,
	   hora_siniestro,
	   fecha_documento,
	   no_tramite
  into _no_poliza,
       _no_unidad,
	   _no_reclamo,
	   _no_documento,
	   _cod_evento,
	   _cod_asegurado,
	   _fecha_siniestro,
	   _hora_sisniestro,
	   _fecha_documento,
	   _no_tramite
  from recrcmae
 where numrecla = a_numrecla and actualizado = 1;

select sum(variacion)
  into _reserva
  from rectrmae
 where no_reclamo   = _no_reclamo
   and actualizado  = 1;

 select nombre
   into _evento
   from recevent
  where cod_evento = _cod_evento;

let _cod_cobertura = null;
let _cobertura = null;

if trim(a_tiporeclamo) = "Tercero" then
	select cod_tercero
	  into _cod_asegurado
	  from recterce
	 where no_reclamo = _no_reclamo
	   and no_incidente = a_inicidente;

    foreach
		select a.cod_cobertura, a.reserva_actual, b.nombre
		  into _cod_cobertura, _reserva_cob, _cobertura
		  from recrccob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and no_reclamo = _no_reclamo
		   and b.nombre like '%AJENA%'   
	end foreach
else
	select count(*) 
	  into _cant_cob
	  from recrccob
	 where no_reclamo = _no_reclamo;
	  
	if _cant_cob > 1 then
		foreach
			select a.cod_cobertura, a.reserva_actual, b.nombre
			  into _cod_cobertura, _reserva_cob, _cobertura
			  from recrccob a, prdcober b
			 where a.cod_cobertura = b.cod_cobertura
			   and no_reclamo = _no_reclamo
			   and reserva_inicial > 0
			exit foreach;
		end foreach
		if _cod_cobertura is null then
			foreach
				select a.cod_cobertura, a.reserva_actual, b.nombre
				  into _cod_cobertura, _reserva_cob, _cobertura
				  from recrccob a, prdcober b
				 where a.cod_cobertura = b.cod_cobertura
				   and no_reclamo = _no_reclamo
				exit foreach;
			end foreach
		end if
	else
		select a.cod_cobertura, a.reserva_actual, b.nombre
		  into _cod_cobertura, _reserva_cob, _cobertura
		  from recrccob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and no_reclamo = _no_reclamo;
	end if
end if

 select nombre
   into _asegurado
   from cliclien
  where cod_cliente = _cod_asegurado;

 select cod_ramo,
        cod_compania,
		sucursal_origen
   into _cod_ramo,
        _cod_compania,
		_cod_sucursal
   from emipomae
  where no_poliza = _no_poliza;
  
 select nombre 
   into _ramo
   from prdramo
  where cod_ramo = _cod_ramo;
  
	CALL sp_cob33(
	_cod_compania,
	_cod_sucursal,
	_no_documento,
	_periodo,
	current
	) RETURNING _por_vencer,
			    _exigible,  
			    _corriente, 
			    _monto_30,  
			    _monto_60,  
			    _monto_90,  
				_saldo;


end 


return _no_poliza,	
	   _no_unidad,	
	   _no_reclamo,
	   _no_documento,
	   _cod_evento,
	   _evento,
	   _cod_asegurado,
	   _asegurado,
	   _fecha_siniestro,
	   _hora_sisniestro,
	   _fecha_documento,
	   _cod_ramo,
	   _ramo,
	   _reserva,
	   _por_vencer,
	   _exigible,  
	   _corriente, 
	   _monto_30,  
	   _monto_60,  
	   _monto_90,  
	   _saldo,
	   _no_tramite,
	   _cod_cobertura,
	   _cobertura,
	   _reserva_cob;

end procedure
