-- Actualizacion de Deuda de Agentes en Actualizacion de la remesa
 													   
drop procedure rv_agtsalra;

create procedure rv_agtsalra(a_fecha_genera date)
returning integer,
          char(100);

define _cod_agente	char(10);
define _renglon		integer;
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _cod_ramo    char(3);
define _fecha_hasta date;
define _cant, _cant_reg		integer;
define _no_poliza   char(10);
define v_comision   dec(16,2);

define _error		integer;

CREATE TEMP TABLE tmp_ramo(
	cod_agente		CHAR(5),
	cod_ramo		CHAR(3),
	comision		DEC(16,2),
	PRIMARY KEY (cod_agente, cod_ramo)
	) WITH NO LOG;


begin
on exception set _error
  	return _error, "Error Actualizando Deuda de Agentes";
end exception

foreach
  SELECT chqcomis.cod_agente,   
         chqcomis.comision,   
         chqcomis.fecha_hasta,
		 no_poliza
    INTO _cod_agente,
         _monto,     
         _fecha_hasta,
         _no_poliza 
    FROM chqcomis   
   WHERE chqcomis.fecha_genera = a_fecha_genera  
     AND chqcomis.no_requis is null  
     AND chqcomis.comision <> 0
     and chqcomis.no_poliza <> '00000'  

   select cod_ramo
     into _cod_ramo
	 from emipomae
	where no_poliza = _no_poliza;

	BEGIN

		ON EXCEPTION IN(-239)

			UPDATE tmp_ramo
			   SET comision   = comision + _monto
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo   = _cod_ramo;

		END EXCEPTION

		INSERT INTO tmp_ramo(
		cod_agente,
		cod_ramo,
		comision
		)
		VALUES(
		_cod_agente,
		_cod_ramo,
		_monto
		);

	END
end foreach

foreach
  SELECT chqcomis.cod_agente,   
         chqcomis.comision,   
         chqcomis.fecha_hasta,
		 no_poliza
    INTO _cod_agente,
         _monto,     
         _fecha_hasta,
         _no_poliza 
    FROM chqcomis   
   WHERE chqcomis.fecha_genera = a_fecha_genera  
     AND chqcomis.no_requis is null  
     AND chqcomis.comision <> 0
     and chqcomis.no_poliza = '00000'  

	LET _monto = _monto * -1;
	LET _cant_reg = 0;

   SELECT COUNT(*)
     INTO _cant_reg
	 FROM tmp_ramo
	WHERE cod_agente = _cod_agente;

   IF _cant_reg IS NULL THEN
   	LET _cant_reg = 0;
   END IF

   IF _cant_reg > 0 THEN
	   FOREACH		
		SELECT comision,
			   cod_ramo	
		  INTO v_comision,
		       _cod_ramo   
		  FROM tmp_ramo
		 WHERE cod_agente = _cod_agente
		 ORDER BY cod_ramo

			IF _monto = 0 THEN
				EXIT FOREACH;
			ELSE
				IF _monto >= v_comision THEN
					UPDATE tmp_ramo
					   SET comision   = 0
					 WHERE cod_agente = _cod_agente
					   AND cod_ramo   = _cod_ramo;
					LET _monto   = _monto - v_comision;
				ELSE
					UPDATE tmp_ramo
					   SET comision   = comision - _monto
					 WHERE cod_agente = _cod_agente
					   AND cod_ramo   = _cod_ramo;
					LET _monto   = 0;
				END IF
			END IF

		END FOREACH

        SELECT SUM(comision)
		  INTO v_comision
		  FROM tmp_ramo
		 WHERE cod_agente = _cod_agente;

        IF v_comision = 0 AND _monto > 0 THEN
			FOREACH
				SELECT cod_ramo
				  INTO _cod_ramo
				  FROM tmp_ramo
				 WHERE cod_agente = _cod_agente
				   AND comision   = 0
				 EXIT FOREACH;
			END FOREACH

			UPDATE tmp_ramo
			   SET comision   = _monto * -1
			 WHERE cod_agente = _cod_agente
			   AND cod_ramo   = _cod_ramo;
        END IF 

	ELSE
		INSERT INTO tmp_ramo(
		cod_agente,
		cod_ramo,
		comision
		)
		VALUES(
		_cod_agente,
		'002',
		_monto * -1
		);
	END IF

end foreach

FOREACH
 SELECT cod_agente, cod_ramo, SUM(comision)
   INTO _cod_agente, _cod_ramo, _monto
   FROM tmp_ramo
  GROUP BY cod_agente, cod_ramo

 IF _monto <> 0 THEN
   select count(*)
     into _cant
	 from agtsalra
	where cod_agente = _cod_agente
	  and cod_ramo = _cod_ramo;       
   
   if _cant > 0 then 
    update agtsalra
       set monto = monto - _monto
     where cod_agente = _cod_agente
       and cod_ramo = _cod_ramo;
   else
    insert into agtsalra (
	  	cod_agente, 
	  	cod_ramo, 
	  	monto
	  	)
	values (
	    _cod_agente,
        _cod_ramo,
		_monto * -1
		);
   end if       
 
	update agtagent
	   set saldo      = saldo - _monto
	 where cod_agente = _cod_agente;

 END IF
 

END FOREACH

--delete from chqcomis
-- where chqcomis.fecha_genera = a_fecha_genera
--   and chqcomis.no_requis is null;

end

return 0, "Actualizacion Exitosa";
DROP TABLE tmp_ramo;

end procedure