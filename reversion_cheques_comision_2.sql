-- Actualizacion de Deuda de Agentes en Actualizacion de la remesa
 													   
drop procedure rv_agtagent;

create procedure rv_agtagent()
returning integer,
          char(100);

define _cod_agente	char(10);
define _renglon		integer;
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _cod_ramo    char(3);
define _no_poliza   char(10);
define _fecha_hasta date;
define _no_requis   char(10);
define _desc_cheque varchar(100);
define _fecha_desde date;
define _dia         char(2);
define _mes         char(2);
define _ano2         char(4);
define _origen_cheque char(1);

define _error		integer;

begin work;
begin
on exception set _error
    rollback work;
	return _error, "Error Actualizando Deuda de Agentes";
end exception

--SET DEBUG FILE TO "rv_agtagent.trc"; 
--trace on;

foreach
  SELECT cod_agente
    INTO _cod_agente   
    FROM agtbitacora  
   WHERE date(fecha_modif) = '07/01/2009' 
     AND saldo <> 0 
     AND fecha_ult_comis = '31/12/2008'

	SELECT no_requis,
	       origen_cheque
	  INTO _no_requis,
		   _origen_cheque
	  FROM chqchmae
	 WHERE cod_agente = _cod_agente
	   AND fecha_captura = '07/01/2009'
	   AND origen_cheque in('2','7'); 

    select desc_cheque
	  into _desc_cheque
	  from chqchdes
	 where no_requis = _no_requis
	   and renglon = 1;

    if _origen_cheque = "2" then
     LET _dia = substring(_desc_cheque from 22 for 23);
     LET _mes = substring(_desc_cheque from 25 for 26);
     LET _ano2 = substring(_desc_cheque from 28 for 31);
	else
     LET _dia = substring(_desc_cheque from 37 for 38);
     LET _mes = substring(_desc_cheque from 40 for 41);
     LET _ano2 = substring(_desc_cheque from 43 for 46);
	end if

     LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);

          
  	FOREACH 
	  SELECT cod_agente,   
	         comision,   
	         no_poliza,
	         fecha_hasta
	    INTO _cod_agente,
	         _monto,     
	         _no_poliza,
	         _fecha_hasta
	    FROM chqcomis  
	   WHERE fecha_genera <> '07/01/2009'
	     AND no_requis = _no_requis
	     AND comision <> 0
		 AND cod_agente = _cod_agente
		 AND fecha_desde >= _fecha_desde

	    IF _no_poliza <> "00000" THEN
		   	SELECT cod_ramo
			  INTO _cod_ramo
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;
		ELSE
		    LET _cod_ramo = "002";
	   	END IF

        select count(*) 
          into _renglon
          from agtsalra
	     where cod_agente = _cod_agente
	       and cod_ramo = _cod_ramo; 
	       
	    if _renglon > 0 Then         
		    update agtsalra
		       set monto = monto + _monto
		     where cod_agente = _cod_agente
		       and cod_ramo = _cod_ramo; 
		else
		    insert into agtsalra(
			   cod_agente,
			   cod_ramo,
			   monto)
			values(
			   _cod_agente,
			   _cod_ramo,
			   _monto
			   );

		end if      

		update agtagent
		   set saldo           = saldo + _monto,
		       fecha_ult_comis = _fecha_desde
		 where cod_agente = _cod_agente;

	   delete from agtsalhi
	    where cod_agente = _cod_agente
		  and cod_ramo =  _cod_ramo
		  and fecha_hasta = _fecha_hasta;

	END FOREACH


    update chqcomis
       set no_requis = "RV"
     where cod_agente = _cod_agente
	   and fecha_genera <> '07/01/2009'
	   and no_requis = _no_requis;

	delete from chqcomis
	 where fecha_genera = '07/01/2009'
	   and cod_agente   = _cod_agente;

end foreach


end
commit work;
return 0, "Actualizacion Exitosa";

end procedure