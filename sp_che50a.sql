-- Procedimiento que Realiza la insercion de la nva. requisicion a partir de la que se anulo

-- Creado    : 10/05/2006 - Autor: Armando Moreno M.
-- mod		 : 01/08/2006

--drop procedure sp_che50a;

create procedure "informix".sp_che50a(
a_valor_ant       char(10),
a_valor_nvo		  char(10),
a_user			  char(10)
) RETURNING   	  INTEGER;

define _error 		   	  integer;
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

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;

let _fecha_actual = CURRENT;

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
	   cod_chequera
  into _origen_cheque,
	   _no_cheque,
	   _cod_banco,
	   _cod_chequera
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

	 exit foreach;
  end foreach

  let _autorizado = 1;
end if

insert into chqchmae
select * 
  from prueba
 where no_requis = a_valor_nvo;

update chqchmae
   set no_cheque       = 0,
       autorizado      = 1,
	   cod_banco       = _cod_banco,
	   cod_chequera    = _cod_chequera,
	   pagado          = 0,
	   anulado         = 0,
	   fecha_anulado   = null,
	   anulado_por     = null,
	   fecha_captura   = _fecha_actual,
	   fecha_impresion = _fecha_actual, 
	   user_added      = a_user,
	   periodo         = v_periodo,
	   no_cheque_ant   = _no_cheque
 where no_requis       = a_valor_nvo;

select cod_banco,
	   cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqchmae
 where no_requis = a_valor_nvo;

SELECT firma_electronica
  INTO _firma_electronica
  FROM chqchequ
 WHERE cod_banco    = _cod_banco
   AND cod_chequera = _cod_chequera;

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

return 0;
END
end procedure