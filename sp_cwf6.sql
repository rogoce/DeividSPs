-- Actualizando la firma en chqchmae

-- Creado    : 16/06/2006 - Autor: Amado Perez M.
-- Modificado: 16/06/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_cwf6;

CREATE PROCEDURE sp_cwf6(a_no_requis CHAR(10) default "%", a_firma char(20), a_opcion smallint, a_cant_f char(1))
RETURNING integer,
          CHAR(50),
          integer;

define _firma_num           char(1);
define _error               integer;
define _usuario             char(8);

define _no_reclamo          char(10);
define _no_poliza			char(10);
define _cod_ramo            char(3);
define _ramo_sis            smallint;
define _existe              smallint;
define _en_firma            smallint;
define _tipo_requis    		char(1);
define _fecha_rec           datetime hour to fraction(5);
define _descripcion         char(50);
define _numrecla            char(20);
define _mes                 smallint;
define _ano                 integer;
define _no_documento        char(20);
define _cod_agente          char(5);
define _cod_grupo           char(5);
define _cod_tipopago        char(3);
define _cod_cliente         char(10);
define _monto               dec(16,2);
define _transaccion         char(10);
define _prioridad           smallint;
define _prioridad_tmp       smallint;
define _pre_autorizado      smallint;
define _cod_area            smallint;
define _saldo               dec(16,2);
DEFINE _busca_prioridad     smallint;
define _no_tranrec          char(10);

let _fecha_rec = current;

let _mes = month(_fecha_rec);
let _ano = year(_fecha_rec);

if a_no_requis = '821550' then
	set debug file to "sp_cwf6.trc";
	trace on;
end if

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 
	RETURN _error, "Error al actualizar la firma #" || _firma_num, 0;
END EXCEPTION           

SELECT en_firma, 
       tipo_requis, 
	   monto
  INTO _en_firma, 
       _tipo_requis,
	   _monto
  FROM chqchmae
 WHERE no_requis = a_no_requis;

IF _en_firma = 2 THEN
   RETURN 0, "Actualizacion Exitosa",0;
 --  RETURN 0, _tipo_requis;
END IF


let _firma_num = "";
let _no_reclamo = "";

IF (a_firma IS NULL OR TRIM(a_firma) = "") AND a_opcion <> 3 THEN
	RETURN 1, "Firma en nulo",0;
  --	LET a_firma = "";
END IF
IF a_cant_f IS NULL THEN
	RETURN 1, "Cantidad de firma en nulo",0;
 --	LET a_cant_f = "";
END IF

SELECT usuario
  INTO _usuario
  FROM insuser
 WHERE windows_user = a_firma
   AND status = "A";


IF a_opcion = 1 THEN
	SET LOCK MODE TO WAIT;
    LET _firma_num = "1";
    IF a_cant_f = "1" THEN
		UPDATE chqchmae
		   SET firma1 = a_firma,   -- _usuario
		       fecha_firma1 = current,
			   en_firma = 2
		 WHERE no_requis = a_no_requis;

        SET ISOLATION TO DIRTY READ;

       	foreach
			select numrecla
			  into _numrecla
			  from chqchrec
		     where no_requis = a_no_requis
		       and numrecla[1,2] in ('02','20','23')

            let _fecha_rec = _fecha_rec + 1 units second;

            select no_reclamo
			  into _no_reclamo
			  from recrcmae 
			 where numrecla = _numrecla;

            CALL sp_rwf104(_no_reclamo,_fecha_rec,"La requisicion # " || trim(a_no_requis) || " fue firmada de forma electronica",_usuario) returning _error, _descripcion;
			IF _error <> 0 THEN
				RETURN  _error, _descripcion, 0;
			END IF
		end foreach

	ELSE
		UPDATE chqchmae
		   SET firma1 = a_firma,   -- _usuario,
		       fecha_firma1 = current
		 WHERE no_requis = a_no_requis;
	END IF
ELIF a_opcion = 2 THEN
		
	--Prioridades
	let _prioridad = 0;
	let _prioridad_tmp = 0;
	let _busca_prioridad = 0;
	
       	foreach    
			select numrecla,
			       transaccion
			  into _numrecla,
			       _transaccion
			  from chqchrec
		     where no_requis = a_no_requis
			 
			if _numrecla[1,2] not in ('02','20','23') then 
				continue foreach;
			else
				let _busca_prioridad = 1;
			end if
			 
			let _prioridad = 0;

            select no_poliza
			  into _no_poliza
			  from recrcmae 
			 where numrecla = _numrecla;
			 
			select cod_ramo,
			       no_documento
			  into _cod_ramo,
			       _no_documento
			  from emipomae
			 where no_poliza = _no_poliza;
			 
			select cod_area
			  into _cod_area
			  from prdramo
			 where cod_ramo = _cod_ramo;
			 
         -- Prioridad por Poliza	
		 
			select a.prioridad
			  into _prioridad_tmp
			  from chepripag a, prdramo b
			 where a.valor_caso = _no_documento
			   and a.cod_ramo = b.cod_ramo
			   and b.cod_area = _cod_area
			   and a.tipo_caso = 1;
			
			if _prioridad_tmp is null then
				let _prioridad_tmp = 0;
			end if
			
			if _prioridad < _prioridad_tmp then
				let _prioridad = _prioridad_tmp;		
			end if
		
         -- Prioridad por Agente		 
		 		 
			foreach		 
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza

				let _prioridad_tmp = 0;  

				select a.prioridad
				  into _prioridad_tmp
				  from chepripag a, prdramo b
				 where a.valor_caso = _cod_agente
				   and a.cod_ramo = b.cod_ramo
				   and b.cod_area = _cod_area
				   and a.tipo_caso = 2;

				if _prioridad_tmp is null then
					let _prioridad_tmp = 0;
				end if

				if _prioridad < _prioridad_tmp then
					let _prioridad = _prioridad_tmp;
				end if	

			end foreach    	
			   
        -- Prioridad por Grupo
		 
			select cod_grupo
			  into _cod_grupo
			  from emipomae
			 where no_poliza = _no_poliza;
		  
			let _prioridad_tmp = 0;  
		  
			select a.prioridad
		      into _prioridad_tmp
		      from chepripag a, prdramo b
		     where a.valor_caso = _cod_grupo
			   and a.cod_ramo = b.cod_ramo
			   and b.cod_area = _cod_area
			   and a.tipo_caso = 3;

			if _prioridad_tmp is null then
				let _prioridad_tmp = 0;
			end if
			
			if _prioridad < _prioridad_tmp then
				let _prioridad = _prioridad_tmp;
			end if			 
			
         -- Prioridad por Proveedor

			select cod_tipopago, 
		           cod_cliente
              into _cod_tipopago,
		           _cod_cliente
			  from rectrmae
			 where transaccion = _transaccion;		   

			let _prioridad_tmp = 0;  
		  
			if _cod_tipopago = '001' then		 
				select a.prioridad
				  into _prioridad_tmp
				  from chepripag a, prdramo b
			     where a.valor_caso = _cod_cliente
				   and a.cod_ramo = b.cod_ramo
				   and b.cod_area = _cod_area
			       and a.tipo_caso = 4;

				if _prioridad_tmp is null then
					let _prioridad_tmp = 0;
				end if				
					
				if _prioridad < _prioridad_tmp then
					let _prioridad = _prioridad_tmp;
				end if			 
			end if
		End Foreach	 
		
   -- Calculo de la prioridad por dia
	
	if _busca_prioridad = 1 then
		let _prioridad_tmp = sp_che158(a_no_requis);
	end if

	if _prioridad < _prioridad_tmp then
		let _prioridad = _prioridad_tmp;
	end if			 
	
	let _pre_autorizado = 0;
	
	if _prioridad > 0 then
		select saldo
		  into _saldo
		  from cheprereq
		 where anio = _ano
		   and mes = _mes
		   and opc = _cod_area;
		
		let _saldo = _saldo - _monto;
	
		if _saldo >= 0 then
	        let _pre_autorizado = 1;
		    
			update cheprereq
			   set saldo = saldo - _monto,
			       preautorizado = preautorizado + _monto
			  where anio = _ano
			   and mes = _mes
			   and opc = _cod_area;
			   
			UPDATE chqchmae
			   SET pre_autorizado = _pre_autorizado,
				   user_pre_aut = 'informix', 
				   date_pre_aut = current			 
			 WHERE no_requis = a_no_requis;
			   
		end if
	end if
	
	SET LOCK MODE TO WAIT;
    LET _firma_num = "2";
	UPDATE chqchmae
	   SET firma2 = a_firma,   -- _usuario,
	       fecha_firma2 = current,
		   en_firma = 2			 
	 WHERE no_requis = a_no_requis;

	SET ISOLATION TO DIRTY READ;

	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = a_no_requis
		   and numrecla[1,2] in ('02','20','23')

		let _fecha_rec = _fecha_rec + 1 units second;

		select no_reclamo
		  into _no_reclamo
		  from recrcmae 
		 where numrecla = _numrecla;

		CALL sp_rwf104(_no_reclamo,_fecha_rec,"La requisicion # " || trim(a_no_requis) || " fue firmada de forma electronica",_usuario) returning _error, _descripcion;
		IF _error <> 0 THEN
			RETURN  _error, _descripcion, 0;
		END IF
	end foreach
	
	-- Crear registro en parmailsend de las requisiciones aprobadas de ramos patrimoniales
	foreach
		select numrecla,
		       transaccion
		  into _numrecla,
		       _transaccion
		  from chqchrec
		 where no_requis = a_no_requis

		select no_poliza
		  into _no_poliza
		  from recrcmae 
		 where numrecla = _numrecla;
		 
		select cod_ramo
          into _cod_ramo
          from emipomae
         where no_poliza = _no_poliza;
 
        select ramo_sis
          into _ramo_sis
          from prdramo
         where cod_ramo = _cod_ramo;
		 
		select no_tranrec
          into _no_tranrec
          from rectrmae
         where transaccion = _transaccion;		  

        if _ramo_sis in (2,8,99,4) then		
			-- Procedimiento que crea los registros para el envío de los finiquitos parmailsend y parmailcomp
			 CALL sp_rec355(_no_tranrec) returning _error, _descripcion;
			 IF _error <> 0 THEN
				rollback work;
				RETURN  _error, _descripcion, 0;
			 END IF
			exit foreach;
		end if
	end foreach
	

ELIF a_opcion = 3 THEN

 {   FOREACH
		SELECT no_reclamo
		  INTO _no_reclamo
		  FROM rectrmae
		 WHERE no_requis = a_no_requis
		EXIT FOREACH;
	END FOREACH

    IF _no_reclamo IS NOT NULL AND TRIM(_no_reclamo) <> "" THEN

	    SELECT no_poliza 
		  INTO _no_poliza
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

	    SELECT cod_ramo
		  INTO _cod_ramo
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

	    SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		select count(*)
		  into _existe
		  from chqbanch
		 where cod_ramo = _cod_ramo;

		if _existe > 0 and _ramo_sis = 1 then
			let _en_firma = 4;
		else
			let _en_firma = 0;
		end if
}
		SET LOCK MODE TO WAIT;

		UPDATE chqchmae
		   SET fecha_paso_firma = null,
		       firma1 = null,
		   	   fecha_firma1 = null,
			   firma2 = null,
			   fecha_firma2 = null,
		       en_firma = 5
		 WHERE no_requis = a_no_requis;
  --	END IF
END IF

END

IF _tipo_requis = "A" THEN
	RETURN 0, "Actualizacion Exitosa", 1; 
ELSE
	RETURN 0, "Actualizacion Exitosa", 0; 
END IF

END PROCEDURE;