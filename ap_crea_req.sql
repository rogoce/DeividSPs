-- Procedimiento que anula requisición desde una tabla

-- Creado    : 04/10/2017 - Autor: Amado Perez 

DROP PROCEDURE ap_crea_req;

CREATE PROCEDURE "informix".ap_crea_req()
returning char(10) as Requisicion;

define _fecha_actual  date;
define v_periodo      char(7);
define _no_requis     char(10);
define _origen_cheque char(1);
define _cod_agente    char(5);
define _tipo_requis   char(1);
define _monto         dec(16,2);
define _reng          smallint; 
define _cuenta        char(25);
define _debito        dec(16,2);
define _credito       dec(16,2);
define _cod_auxiliar  char(5);
define _no_poliza     char(10);
define _transaccion   char(10);
define _monto2        dec(16,2);
define _cod_ramo      char(3);
define _reg           smallint;
define _retorno       smallint;
define _renglon       smallint;
define _no_requis_n   char(10);
define _firma1        char(20);
define _firma2        char(20);
define _user_pre_aut  char(8);
define _numrecla      char(20);
	  
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "ap_crea_req.trc"; 
--trace on;

BEGIN WORK;

BEGIN

ON EXCEPTION
	ROLLBACK WORK;
	RETURN null;
END EXCEPTION

let _fecha_actual = TODAY;

IF MONTH(_fecha_actual) < 10 THEN
	LET v_periodo = YEAR(_fecha_actual) || '-0' || MONTH(_fecha_actual);
ELSE
	LET v_periodo = YEAR(_fecha_actual) || '-' || MONTH(_fecha_actual);
END IF

FOREACH
	SELECT no_requis
	  INTO _no_requis
	  FROM tmp_anula_req
	 where anulado = 1
	   and creado = 0
	--   and no_requis = '780090'
	 	  
    LET _no_requis_n = sp_sis71('001');
   
    LET _retorno = sp_che50(_no_requis, _no_requis_n, 'OMYVETT');
	
	if _retorno <> 0 THEN
		ROLLBACK WORK;
		return _retorno;
	end if
	
   select origen_cheque,
          firma1,
          firma2,
		  user_pre_aut,
		  monto
	 into _origen_cheque,
	      _firma1,
          _firma2,
		  _user_pre_aut,
		  _monto
     from chqchmae
    where no_requis = _no_requis;	 
   
   update chqchmae
      set firma1 = _firma1,
	      firma2 = _firma2,
		  fecha_paso_firma = current,
		  fecha_firma1 = current,
		  fecha_firma2 = current,
		  en_firma = 2,
		  pre_autorizado = 1,
		  user_pre_aut = _user_pre_aut,
		  date_pre_aut = current
	where no_requis = _no_requis_n;
   
   update tmp_anula_req
      set creado = 1,
	      en_firma = 2,
		  no_requis_n = _no_requis_n
	where no_requis = _no_requis;
	
   if _origen_cheque = '3' then
	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = _no_requis
	 exit foreach;
	end foreach
	
	if _numrecla[1,2] in ('02','20','23') then
		update cheprereq
		   set saldo = saldo - _monto,
			   preautorizado = preautorizado + _monto
		 where anio = year(today)
		   and mes = month(today)
		   and opc = 1;
	elif _numrecla[1,2] in ('04','16','18','19') then
		update cheprereq
		   set saldo = saldo - _monto,
			   preautorizado = preautorizado + _monto
		 where anio = year(today)
		   and mes = month(today)
		   and opc = 2;
	end if
   end if
   
	return _no_requis WITH RESUME;
	 
END FOREACH     
	
   
COMMIT WORK;

END
END PROCEDURE
