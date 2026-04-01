-- Procedimiento que anula requisición desde una tabla

-- Creado    : 04/10/2017 - Autor: Amado Perez 

DROP PROCEDURE ap_anular_req;

CREATE PROCEDURE "informix".ap_anular_req()
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
	  
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "ap_anular_req.trc"; 
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
	 where anulado = 0
	 --  and no_requis = '782490'
	 	  
	SELECT origen_cheque,
	       cod_agente,
		   tipo_requis,
		   monto
	  INTO _origen_cheque,
	       _cod_agente,
		   _tipo_requis,
		   _monto
	  FROM chqchmae
	 WHERE no_requis = _no_requis;
	 
	Select max(renglon) 
	  into _renglon
	  From chqchcta
	 Where no_requis = _no_requis;		

   select no_requis, renglon, cuenta, debito, credito, cod_auxiliar, tipo, no_poliza 
     from chqchcta
    where no_requis = _no_requis
 	 into temp prueba;
	 
   foreach
		select renglon, 
		       cuenta, 
			   debito, 
			   credito, 
			   cod_auxiliar, 
			   no_poliza
		  into _reng,
		       _cuenta,
			   _debito,
			   _credito,
			   _cod_auxiliar,
			   _no_poliza
		  from prueba
		  
		select no_requis, renglon, cuenta, cod_auxiliar, debito, credito from chqctaux
		where no_requis = _no_requis
		  and renglon = _reng
		  and cuenta = _cuenta
		  and cod_auxiliar = _cod_auxiliar
		 into temp prueba2;
		 
		let _renglon = _renglon + 1; 
		 
		insert into chqchcta (
		  no_requis,
		  renglon,
		  cuenta, 
		  debito, 
		  credito, 
		  cod_auxiliar, 
		  no_poliza,
		  tipo)
        values (
		  _no_requis,
		  _renglon,
		  _cuenta,
		  _credito,
		  _debito,
		  _cod_auxiliar,
		  _no_poliza,
		  2);
		  
          foreach		
			select cuenta,
			       debito,
				   credito,
				   cod_auxiliar
			  into _cuenta,
			       _debito,
				   _credito,
				   _cod_auxiliar
			  from prueba2
			  
			insert into chqctaux (
			      no_requis,
				  renglon,
				  cuenta,
				  debito,
				  credito,
				  cod_auxiliar)
             values (
			      _no_requis,
				  _renglon,
				  _cuenta,
				  _credito,
				  _debito,
				  _cod_auxiliar);				  
		  
		  end foreach
		  
         drop table prueba2;

   end foreach

   drop table prueba;
      
   foreach
	select transaccion
	  into _transaccion
	  from chqchrec
	 where no_requis = _no_requis
	 
	update rectrmae
	   Set no_requis      = null, 
		   pagado         = 0,
		   fecha_pagado   = null,
		   generar_cheque = 0
	 Where transaccion = _transaccion;
   end foreach
   
   foreach
	select no_poliza,
	       monto
	  into _no_poliza,
	       _monto2
	  from chqchpol
	 where no_requis = _no_requis
	  	 
	update emipomae
	   set saldo = saldo - _monto2
	 where no_poliza = _no_poliza;
   end foreach
   
   if (_origen_cheque = "2" OR _origen_cheque = "7") AND (_tipo_requis = "A" OR _tipo_requis = "C") Then
	   foreach
		select cod_ramo,
			   monto
		  into _cod_ramo,
			   _monto2
		  from chqchagt
		 where no_requis = _no_requis
		 
		 Select count(*) 
		   Into _reg 
			From agtsalra
		  Where cod_agente = _cod_agente
			and cod_ramo = _cod_ramo;
			 
		 If _reg > 0 Then
			 Update agtsalra 
				Set monto = monto + _monto2
			 Where cod_agente = _cod_agente
			   and cod_ramo = _cod_ramo;
		 Else
			 Insert into agtsalra( 
				cod_agente, 
				 cod_ramo, 
				 monto) 
				values( 
				 _cod_agente, 
				 _cod_ramo, 
				 _monto2);
		 End If
		 		
	   end foreach
	   
	   	Update agtagent 
		   set saldo = saldo + _monto
		 Where cod_agente = _cod_agente;

	end if
		 
	let _retorno = sp_sis227(_no_requis);

	update chqchmae
       set hora_anulado = current
     where no_requis    = _no_requis;
	 
    Update chqchmae
	 Set anulado_por  = 'OMYVETT', 
		 fecha_anulado  = TODAY, 
		 hora_anulado = current,
		 anulado   = 1 
   Where no_requis = _no_requis;
   
   update tmp_anula_req
      set anulado = 1
	where no_requis = _no_requis;
   
	return _no_requis WITH RESUME;
	 
END FOREACH     
	
   
COMMIT WORK;

END
END PROCEDURE
