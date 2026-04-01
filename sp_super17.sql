-- Procedimiento que Realiza la insercion de la nva. requisicion a partir de la que se anulo

-- Creado    : 10/05/2006 - Autor: Armando Moreno M.
-- mod		 : 01/08/2006
-- mod       : 08/07/2009   Amado Perez -- Se agrego codigo para cuando son auto y soda
-- mod       : 16/11/2010	Amado Perez -- Se agrego codigo para cuando son requisiciones de origen "S" Devolucion de Primas
-- Amado en caso que haya algun cambio en este procedure se de replicar a este otro sp_che208

drop procedure sp_super17;
create procedure "informix".sp_super17(
a_valor_ant       char(10),
a_user			  char(10)
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
define a_valor_nvo        char(10);
define _contador          integer;
define _mensaje           char(100);


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

for _contador = 1 to 85

	select * 
	  from chqchmae
	 where no_requis = a_valor_ant
	  into temp prueba;

	let a_valor_nvo = sp_sis13('001', 'CHE', '02', 'par_cheque');

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
	   set no_requis = a_valor_nvo,
		   no_cheque = no_cheque + 1
	 where no_requis = a_valor_ant;

	insert into chqchmae
	select * 
	  from prueba
	 where no_requis = a_valor_nvo;


	update chqchmae
	   set autorizado      = _autorizado,
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
	
	--ANULANDO LA REQUIS
	let _mensaje = "Actualizacion Exitosa ... Requisicion "||trim(a_valor_nvo)||" Anulada.";
	Call sp_che130(a_valor_nvo ,'DEIVID') returning _error, _mensaje;
	let a_valor_ant = a_valor_nvo;
end for

return 0;
END
end procedure