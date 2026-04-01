-- Procedimiento que Realiza la insercion de la nva. requisicion a partir de la que se anulo

-- Creado    : 10/05/2006 - Autor: Armando Moreno M.
-- mod		 : 01/08/2006
-- mod       : 08/07/2009   Amado Perez -- Se agrego codigo para cuando son auto y soda
-- mod       : 16/11/2010	Amado Perez -- Se agrego codigo para cuando son requisiciones de origen "S" Devolucion de Primas

drop procedure sp_che208;

create procedure "informix".sp_che208(
a_valor_ant       char(10),
a_valor_nvo		  char(10),
a_user			  char(10),
a_tipo_requis     char(1)
) RETURNING   	  INTEGER;

define _error 		   	  integer;
define _error_desc		  char(100);
define _no_cheque	   	  integer;
define _transaccion	   	  char(10);
define _fecha_actual   	  date;
define v_periodo	   	  char(7);
define _origen_cheque  	  char(1);
define _renglon		   	  smallint;
define _firma_electronica smallint;
define _autorizado		  smallint;
define _cod_banco	   	  char(3);
define _cod_chequera   	  char(3);
define _numrecla	   	  char(18);
define _cod_cte_chq       char(10);
define _cod_cte_rec		  char(10);
define _en_firma          smallint;
define _autorizado_por    char(8);

define _doc_remesa		  char(20);
define _cod_auxiliar	  char(5);
define _centro_costo	  char(3);
define _debito			  dec(16,2);
define _credito			  dec(16,2);
define _monto			  dec(16,2);

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;

let _fecha_actual = CURRENT;
let _numrecla     = "";

IF MONTH(_fecha_actual) < 10 THEN
	LET v_periodo = YEAR(_fecha_actual) || '-0' || MONTH(_fecha_actual);
ELSE
	LET v_periodo = YEAR(_fecha_actual) || '-' || MONTH(_fecha_actual);
END IF

let _autorizado = 0;

select * 
  from chqchmae
 where no_requis = a_valor_ant
  into temp prueba;

select origen_cheque,
	   no_cheque,
	   cod_banco,
	   cod_chequera,
	   en_firma,
	   autorizado_por,
	   monto
  into _origen_cheque,
	   _no_cheque,
	   _cod_banco,
	   _cod_chequera,
	   _en_firma,
	   _autorizado_por,
	   _monto
  from chqchmae
 where no_requis = a_valor_ant;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

foreach

	select numrecla
	  into _numrecla
	  from chqchrec
	 where no_requis = a_valor_ant

	 exit foreach;
end foreach

if _numrecla[1,2] = "18" and _origen_cheque = "3" then

  foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '018'
	   and cod_banco = _cod_banco

	 exit foreach;
  end foreach

  let _autorizado = 1;
  let _en_firma = 0;
end if

if _numrecla[1,2] = "16" and _origen_cheque = "3" then

  foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '016'
	   and cod_banco = _cod_banco

	 exit foreach;
  end foreach

  let _autorizado = 1;
  let _en_firma = 0;
end if

if _numrecla[1,2] = "19" and _origen_cheque = "3" then

  foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '019'
	   and cod_banco = _cod_banco

	 exit foreach;
  end foreach

  let _autorizado = 1;
  let _en_firma = 0;
end if

if _numrecla[1,2] = "02" and _origen_cheque = "3" and _en_firma = 2 then -- Automovil  -- Amado

  foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '002'
	   and cod_banco = _cod_banco

	 exit foreach;
  end foreach

  let _autorizado = 1;
  let _en_firma = 4;
end if

if _numrecla[1,2] = "20" and _origen_cheque = "3" and _en_firma = 2 then -- Soda   -- Amado

  foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '020'
	   and cod_banco = _cod_banco

	 exit foreach;
  end foreach

  let _autorizado = 1;
  let _en_firma = 4;
end if

if _numrecla[1,2] = "23" and _origen_cheque = "3" and _en_firma = 2 then -- Flota   -- Amado

  foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '023'
	   and cod_banco = _cod_banco

	 exit foreach;
  end foreach

  let _autorizado = 1;
  let _en_firma = 4;
end if

if _origen_cheque = "S" then --Devolucion de Primas
  let _autorizado = 1;
  let _en_firma   = 4;
  let _cod_auxiliar = "0127";
  let _doc_remesa   = sp_sis15('CPDEVSUS');
  --Centro de costo
  call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;
  if _error <> 0 then  
 	RETURN _error;  
  end if       
end if

insert into chqchmae
select * 
  from prueba
 where no_requis = a_valor_nvo;


update chqchmae
   set no_cheque       = 0,
       autorizado      = _autorizado,
	   cod_banco       = _cod_banco,
	   cod_chequera    = _cod_chequera,
	   pagado          = 0,
	   anulado         = 0,
	   fecha_anulado   = null,
	   anulado_por     = null,
	   autorizado_por  = null,
	   fecha_captura   = _fecha_actual,
	   fecha_impresion = _fecha_actual, 
	   user_added      = a_user,
	   periodo         = v_periodo,
	   firma1		   = null,
	   firma2		   = null,
	   fecha_firma1    = null,
	   fecha_firma2    = null,
	   autorizado_por  = null,
	   en_firma        = _en_firma,
	   no_cheque_ant   = _no_cheque,
	   sac_asientos    = 0,
	   incidente	   = null,
	   wf_firmado	   = null,
	   tipo_requis     = a_tipo_requis,
	   hora_captura    = current,
	   hora_anulado    = null,
	   aut_workflow_hora = null,
	   hora_impresion    = null
 where no_requis       = a_valor_nvo;

select cod_banco,
	   cod_chequera,
	   cod_cliente
  into _cod_banco,
	   _cod_chequera,
	   _cod_cte_chq
  from chqchmae
 where no_requis = a_valor_nvo;

SELECT firma_electronica
  INTO _firma_electronica
  FROM chqchequ
 WHERE cod_banco    = _cod_banco
   AND cod_chequera = _cod_chequera;

if _firma_electronica = 1 then
	if _cod_banco = '001' and _cod_chequera = '006' then
		update chqchmae
		   set autorizado       = 1,
		       autorizado_por   = _autorizado_por,
			   incidente	    = null,
			   wf_firmado	    = null,
			   wf_entregado	    = null,
			   aut_workflow	    = null,
			   fecha_paso_firma = null,
			   periodo_pago     = 0,
			   wf_nombre        = null,
			   wf_cedula        = null,
			   wf_fecha         = null,
			   wf_hora          = null
		 where no_requis        = a_valor_nvo;
	end if
	if _cod_banco = '001' and _cod_chequera = '001' and _en_firma = 4 then	-- Solo autos
		update chqchmae
		   set autorizado       = 1,
		       autorizado_por   = _autorizado_por,
			   incidente	    = null,
			   wf_firmado	    = null,
			   wf_entregado	    = null,
			   aut_workflow	    = null,
			   fecha_paso_firma = null,
			   periodo_pago     = 0,
			   wf_nombre        = null,
			   wf_cedula        = null,
			   wf_fecha         = null,
			   wf_hora          = null
		 where no_requis        = a_valor_nvo;
	 end if
	if _cod_banco = '295' and _cod_chequera = '045' and _en_firma = 4 then	-- Solo autos
		update chqchmae
		   set autorizado       = 1,
		       autorizado_por   = _autorizado_por,
			   incidente	    = null,
			   wf_firmado	    = null,
			   wf_entregado	    = null,
			   aut_workflow	    = null,
			   fecha_paso_firma = null,
			   periodo_pago     = 0,
			   wf_nombre        = null,
			   wf_cedula        = null,
			   wf_fecha         = null,
			   wf_hora          = null
		 where no_requis        = a_valor_nvo;
	 end if
end if

drop table prueba;
------------------
select * 
  from chqchdes
 where no_requis = a_valor_ant
  into temp prueba;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

insert into chqchdes
select * 
  from prueba
 where no_requis = a_valor_nvo;

drop table prueba;
------------------
{if _origen_cheque = "1" then	--contabilidad

	select max(renglon)
	  into _renglon
	  from chqchcta
	 where no_requis = a_valor_nvo;

	delete from chqchcta
	 where no_requis = a_valor_nvo
	   and renglon   = _renglon;

end if}
------------------

if _origen_cheque = "S" then --Devolucion de Primas	-- Amado 16-11-2010 se incluye porque llegaba en blanco al momento de imprimir.
	-- Cuentas del Cheque

	if _monto > 0 then
		let _debito  = _monto;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = _monto * - 1;
	end if

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito,
	cod_auxiliar,
	tipo,
	centro_costo
	)
	VALUES(
	a_valor_nvo,
	1,
	_doc_remesa,
	_debito,
	_credito,
	_cod_auxiliar,
	1,
	_centro_costo
	);

	INSERT INTO chqctaux(
	no_requis,
	renglon,
	cuenta,
	cod_auxiliar,
	debito,
	credito,
	tipo,
	centro_costo
	)
	VALUES(
	a_valor_nvo,
	1,
	_doc_remesa,
	_cod_auxiliar,
	_debito,
	_credito,
	1,
	_centro_costo
	);
end if

select * 
  from chqchrec
 where no_requis = a_valor_ant
  into temp prueba;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

insert into chqchrec
select * 
  from prueba
 where no_requis = a_valor_nvo;

drop table prueba;

if _numrecla[1,2] = "18" and _origen_cheque = "3" then
	foreach
	  select transaccion
	    into _transaccion
		from chqchrec
	   where no_requis = a_valor_nvo
	 
	 let _cod_cte_rec = "";
	
	 foreach
	   select cod_cliente
	     into _cod_cte_rec
		 from rectrmae
		where transaccion = _transaccion

	   exit foreach;
	 end foreach

     if _cod_cte_rec is null then
		let _cod_cte_rec = "";
	 end if

	 if _cod_cte_rec = _cod_cte_chq then

		 update rectrmae
		    set no_requis      = a_valor_nvo,
		        generar_cheque = 1
		  where transaccion = _transaccion;

	 else
		delete from chqchrec
		 where no_requis = a_valor_nvo
		   and transaccion = _transaccion
		   and monto       = 0;
	 end if 

	end foreach
else
	foreach
	  select transaccion
	    into _transaccion
		from chqchrec
	   where no_requis = a_valor_nvo

	  update rectrmae
	     set no_requis      = a_valor_nvo,
		     generar_cheque = 1
	   where transaccion = _transaccion;
	  
	end foreach

end if
------------------
select * 
  from chqchpol
 where no_requis = a_valor_ant
  into temp prueba;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

insert into chqchpol
select * 
  from prueba
 where no_requis = a_valor_nvo;

drop table prueba;
------------------
select * 
  from chqchagt
 where no_requis = a_valor_ant
  into temp prueba;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

insert into chqchagt
select * 
  from prueba
 where no_requis = a_valor_nvo;

drop table prueba;
------------------
select * 
  from recunino
 where no_requis = a_valor_ant
  into temp prueba;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

insert into recunino
select * 
  from prueba
 where no_requis = a_valor_nvo;

drop table prueba;
------------------
select * 
  from chqchpoa
 where no_requis = a_valor_ant
  into temp prueba;

update prueba 
   set no_requis = a_valor_nvo
 where no_requis = a_valor_ant;

insert into chqchpoa
select * 
  from prueba
 where no_requis = a_valor_nvo;

drop table prueba;

return 0;
END
end procedure