-- Ingreso a parmailsend para ser enviado por correo --> CON ANCON SIEMPRE GANAS

-- Amado Perez 25/10/2012


drop procedure sp_super13;
create procedure sp_super13()
RETURNING integer;

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

DEFINE v_nombre     		varchar(100);
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

let _estatus_poliza = 0;

CREATE TEMP TABLE tmp_atcacbdd
     (no_documento       CHAR(20),
      cod_cliente        CHAR(10),
      status             CHAR(1),
	  carta_aviso_canc   SMALLINT default 0,
	  canc_falta_pago    SMALLINT default 0,
	  usuario            CHAR(8),
	  cod_sucursal  	 CHAR(3),
	  fecha_act          DATE,
	  no_boleto          CHAR(5),
      PRIMARY KEY (no_documento, cod_cliente))
      WITH NO LOG;


IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;

BEGIN

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_atc21.trc"; 
--trace on;
FOREACH
	select no_boleto,
	       cod_cliente,
	       cod_sucursal,
	       user_changed,
	       date_changed	  
	  into v_no_boleto,
		   _cod_cliente,
		   v_cod_sucursal,
		   v_user_changed,
		   v_date_changed	
	  from atcacbdd

    foreach with hold
		select distinct no_documento
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
			    usuario,         
		        cod_sucursal,  	
		        fecha_act,       
		        no_boleto)
		values (v_no_documento,
		        _cod_cliente,
				v_user_changed,
		        v_cod_sucursal,
				v_date_changed,
				v_no_boleto);

	   end	               
    end foreach
end foreach	

return 0; 

END
end procedure