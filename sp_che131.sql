-- Procedimiento para actualizar las requisiciones de ach de reclamos
-- 
-- creado: 09/03/2012 - Autor: Amado Perez.

DROP PROCEDURE sp_che131;
CREATE PROCEDURE "informix".sp_che131(a_no_requis CHAR(10), a_fecha DATE, a_cheque INTEGER, a_periodo CHAR(7), a_nombre CHAR(50), a_cedula CHAR(30), a_user CHAR(8))
                  RETURNING integer, varchar(50);  

DEFINE _error               integer;
define _numrecla            char(20);
define _monto               dec(16,2);
define _cod_banco           char(3);

DEFINE _transaccion         char(10);
DEFINE _cant                smallint;
DEFINE _origen_cheque       char(1);

--SET DEBUG FILE TO "sp_che131.trc";
--TRACE ON;


BEGIN
ON EXCEPTION SET _error 
 	RETURN _error, "Error al actualizar las requisicion # " || a_no_requis;         
END EXCEPTION 

SET LOCK MODE TO WAIT;

update chqchmae 
	set fecha_impresion = a_fecha,
		pagado			= 1,
		no_cheque		= a_cheque,
		periodo         = a_periodo,
		wf_nombre 	    = a_nombre,
		wf_cedula 		= a_cedula,
		fecha_cobrado	= a_fecha,
		user_entrego 	= a_user 
  where no_requis       = a_no_requis; 

SET ISOLATION TO DIRTY READ;

foreach
	select numrecla
	  into _numrecla
	  from chqchrec
	 where no_requis = a_no_requis
 exit foreach;
end foreach

select monto,
       cod_banco,
	   origen_cheque
  into _monto,
       _cod_banco,
	   _origen_cheque
  from chqchmae
 where no_requis = a_no_requis;
 
if _origen_cheque = "1" then 
	update chepresem
	   set saldo_real = saldo_real - _monto,
		   pagado_real = pagado_real + _monto
	 where today between fecha_desde and fecha_hasta
	   and opc = 4
	   and cod_banco = _cod_banco;
else
	-- Buscando pago a subrogaciones
	let _cant = sp_rec315(a_no_requis);
	 
	if _cod_banco = '001' then 
		if _numrecla[1,2] in ('02','20','23') then
			
			update cheprereq
			   set saldo_real = saldo_real - _monto,
				   pagado_real = pagado_real + _monto
			 where anio = year(a_fecha)
			   and mes = month(a_fecha)
			   and opc = 1;
			   
			if _cant = 0 then   
				update chepresem
				   set saldo_real = saldo_real - _monto,
					   pagado_real = pagado_real + _monto
				 where today between fecha_desde and fecha_hasta
				   and opc = 1
				   and cod_banco = _cod_banco;
			else
				update chepresem
				   set saldo_real = saldo_real - _monto,
					   pagado_real = pagado_real + _monto
				 where today between fecha_desde and fecha_hasta
				   and opc = 3			   
				   and cod_banco = _cod_banco;
			end if
		elif _numrecla[1,2] in ('04','16','18','19') then
			update cheprereq
			   set saldo_real = saldo_real - _monto,
				   pagado_real = pagado_real + _monto
			 where anio = year(a_fecha)
			   and mes = month(a_fecha)
			   and opc = 2;
			   
			update chepresem
			   set saldo_real = saldo_real - _monto,
				   pagado_real = pagado_real + _monto
			 where today between fecha_desde and fecha_hasta
			   and opc = 2			   
			   and cod_banco = _cod_banco;
			   
		end if
	elif _cod_banco = '295' then 
		if _numrecla[1,2] in ('02','23') then				   
			if _cant = 0 then   
				update chepresem
				   set saldo_real = saldo_real - _monto,
					   pagado_real = pagado_real + _monto
				 where today between fecha_desde and fecha_hasta
				   and opc = 1			   
				   and cod_banco = _cod_banco;
			else
				update chepresem
				   set saldo_real = saldo_real - _monto,
					   pagado_real = pagado_real + _monto
				 where today between fecha_desde and fecha_hasta
				   and opc = 3			   
				   and cod_banco = _cod_banco;
			end if
		elif _numrecla[1,2] in ('16','19') then  
			update chepresem
			   set saldo_real = saldo_real - _monto,
				   pagado_real = pagado_real + _monto
			 where today between fecha_desde and fecha_hasta
			   and opc = 2			   
			   and cod_banco = _cod_banco;		   
		end if
	end if	
end if

END

return 0, "Actualizacion exitosa chqchmae";

END PROCEDURE
