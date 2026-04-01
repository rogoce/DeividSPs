-- Busqueda de los clientes validos para la rifa --> CON ANCON SIEMPRE GANAS

-- Amado Perez 25/10/2012


drop procedure sp_atc22;

create procedure sp_atc22(a_opcion smallint)
RETURNING INT, char(5), VARCHAR(100);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
DEFINE _cod_cliente     char(10);
DEFINE v_no_boleto      char(5);
DEFINE v_cod_sucursal   char(3);
DEFINE v_user_changed   char(8);
DEFINE v_date_changed   DATE;
DEFINE v_no_documento	char(20);
DEFINE _no_poliza       char(10);
DEFINE _cod_agente      char(5);
DEFINE _cod_vendedor	char(3);
DEFINE _casam           SMALLINT;

DEFINE v_nombre     	varchar(100);
define _mes_char			char(2);
define _ano_char			char(4);
define _periodo			    char(7);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
define _estatus_poliza      SMALLINT;
DEFINE _carta_aviso_canc   	SMALLINT;
define _cant                SMALLINT;
define v_saldo_tot, v_por_vencer, _exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo dec(16,2);
DEFINE _corriente     		SMALLINT;
DEFINE _falta_pago          SMALLINT;
DEFINE v_agencia            CHAR(30);
DEFINE v_secuencia          INT;

CREATE TEMP TABLE tmp_atcacbdd
     (no_documento       CHAR(20),
      cod_cliente        CHAR(10),
	  no_boleto          CHAR(5),
      PRIMARY KEY (no_documento))
      WITH NO LOG;

CREATE TEMP TABLE tmp_cliente
     (cod_cliente        CHAR(10),
	  no_boleto          CHAR(5),
	  corriente          SMALLINT DEFAULT 1,
	  falta_pago         SMALLINT DEFAULT 0, 
	  opcion             SMALLINT DEFAULT 0,
      PRIMARY KEY (cod_cliente))
      WITH NO LOG;


IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;


BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion, null;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_atc22.trc"; 
--trace on;
FOREACH
	select no_boleto,
	       cod_cliente
	  into v_no_boleto,
		   _cod_cliente
	  from atcacbdd
	 where ganador = 0
  order by no_boleto

    foreach
		select no_documento
		  into v_no_documento
		  from emipomae
		 where (cod_contratante = _cod_cliente
		    or cod_pagador     = _cod_cliente)
		   and actualizado = 1

       begin
		ON EXCEPTION IN(-239)
		END EXCEPTION
		insert into tmp_atcacbdd (
		        no_documento,    
			    cod_cliente,     
		        no_boleto)
		values (v_no_documento,
		        _cod_cliente,
				v_no_boleto);

	   end	               
    end foreach 
    
    foreach
		select no_poliza
		  into _no_poliza
		  from emipouni
		 where cod_asegurado = _cod_cliente

		select no_documento
		  into v_no_documento
		  from emipomae
		 where no_poliza = _no_poliza 
		   and actualizado = 1;

       If v_no_documento is not null  Then
	       begin
			ON EXCEPTION IN(-239)
			END EXCEPTION
			insert into tmp_atcacbdd (
			        no_documento,    
				    cod_cliente,     
			        no_boleto)
			values (v_no_documento,
			        _cod_cliente,
					v_no_boleto);

		   end
		End If	               
    end foreach 


END FOREACH


FOREACH	
	SELECT no_documento,
		   cod_cliente, 
		   no_boleto
	  INTO v_no_documento,
		   _cod_cliente,
		   v_no_boleto
	  FROM tmp_atcacbdd

	LET _corriente = 1; 
	LET _falta_pago = 0;

	FOREACH   
	    SELECT cod_compania,
			   sucursal_origen,
			   no_poliza,
			   estatus_poliza,
			   carta_aviso_canc
		  INTO _cod_compania,
			   _cod_sucursal,
			   _no_poliza,
			   _estatus_poliza,
			   _carta_aviso_canc
		  FROM emipomae
		 WHERE no_documento = v_no_documento
		   AND actualizado = 1
  	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH

	CALL sp_cob33(
	_cod_compania,
	_cod_sucursal,
	v_no_documento,
	_periodo,
	current
	) RETURNING v_por_vencer,
			    _exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90,  
				v_saldo;
	If (v_monto_30 + v_monto_60 + v_monto_90) > 0 Then
		LET _corriente = 0;
	end if 

    IF _estatus_poliza = 2 THEN
		select count(*) 
		  into _cant
		  from endedmae 
		 where no_poliza = _no_poliza
		   and cod_endomov = '002'
		   and cod_tipocan = '001';
		IF _cant > 0 THEN
			LET _falta_pago = 1;
		END IF
	END IF

    FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

        EXIT FOREACH;
    END FOREACH

    SELECT cod_vendedor
	  INTO _cod_vendedor
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT nombre
	  INTO v_agencia    
	  FROM agtvende
	 WHERE cod_vendedor = _cod_vendedor; 
	   
	let _casam = 0;

    if v_agencia like "%ZONA%" then
		let _casam = 1;
    end if 

    if v_agencia like "%EDISON%" then
		let _casam = 1;
    end if 

    if v_agencia like "%PUEBLOS%" then
		let _casam = 1;
    end if 

 {   IF a_opcion = 1 THEN  --> Solo Casa Matriz
		IF _casam = 0 THEN
		   --	CONTINUE FOREACH;
		END IF
	ELSE
		IF _casam = 1 THEN	--> Solo Sucursales
		   --	CONTINUE FOREACH;
		END IF
	END IF
  }

	begin
		ON EXCEPTION IN(-239)
		END EXCEPTION
		insert into tmp_cliente (
			    cod_cliente,     
		        no_boleto)
		values (_cod_cliente,
				v_no_boleto
			   );

	end

   IF a_opcion = 1 THEN  --> Solo Casa Matriz
		IF _casam = 1 THEN
			UPDATE tmp_cliente 
			   SET opcion = 1
			 WHERE cod_cliente = _cod_cliente;
		END IF
   ELSE
		IF _casam = 0 THEN	--> Solo Sucursales
			UPDATE tmp_cliente 
			   SET opcion = 1
			 WHERE cod_cliente = _cod_cliente;
		END IF
   END IF

   IF _corriente = 0 THEN
	UPDATE tmp_cliente 
	   SET corriente = 0
	 WHERE cod_cliente = _cod_cliente;
   END IF

   IF _falta_pago = 1 THEN
	UPDATE tmp_cliente 
	   SET falta_pago = 1
	 WHERE cod_cliente = _cod_cliente;
   END IF

END FOREACH

let v_secuencia = 0;

FOREACH WITH HOLD
	SELECT cod_cliente, 
		   no_boleto
	  INTO _cod_cliente,
		   v_no_boleto
	  FROM tmp_cliente
 	 WHERE opcion =  1
 	   AND corriente = 1
       AND falta_pago = 0

    let v_secuencia = v_secuencia + 1;

    select nombre 
	  into v_nombre
	  from cliclien
	 where cod_cliente = _cod_cliente;

    RETURN v_secuencia,
           v_no_boleto,
           v_nombre  WITH RESUME;

END FOREACH

drop table tmp_atcacbdd;
drop table tmp_cliente;

END
end procedure