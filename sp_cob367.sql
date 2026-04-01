-- Procedimiento que crear una gestion en Ccobgesti
-- Creado    : 29/05/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cob367;

CREATE PROCEDURE sp_cob367(a_tipo_gestion varchar(3), a_no_cuenta  varchar(30), a_tipo_cuenta char(1), a_cob_banco char(3), a_fecha_expira char(7), a_no_poliza char(10),
								      a_user_proceso char(15))
RETURNING integer,
          char(100); 
		      
DEFINE _no_ultimo_final	 	varchar(4);
DEFINE _tipo_cuenta_char 	varchar(10);
DEFINE _nombre_banco	 	varchar(50);
DEFINE _no_tarjeta_parte1	varchar(5);
DEFINE _no_tarjeta_parte2	varchar(5);
DEFINE _no_cuenta_final		varchar(17);
DEFINE _cod_pagador		 	char(10);
DEFINE _bitacora		 	char(255);
DEFINE _no_poliza		 	char(10);
DEFINE _no_documento	 	char(20);
DEFINE _hay_pago		 	integer;
DEFINE _fecha_ult_pago	 	date;
DEFINE _fecha_actual		date;
DEFINE _no_tarjeta_final	varchar(30);
DEFINE _fecha_gestion    	datetime year to second;
DEFINE _fecha_gestion2	 	datetime year to second;

--set debug file to "sp_pro525.trc";
--trace on;

LET _fecha_actual	= sp_sis26();
LET _tipo_cuenta_char = "";
LET _fecha_gestion2	= _fecha_actual;

LET _fecha_gestion  = current year to second;
LET _fecha_gestion  = _fecha_gestion + 1 units second;		

If _fecha_gestion = _fecha_gestion2 Then
	LET _fecha_gestion  = _fecha_gestion + 1 units second;
End If

LET _fecha_gestion2 = _fecha_gestion;	

--Busca asinga el nombre al tipo de cuenta
If a_tipo_gestion = 'ACH' Then
	If a_tipo_cuenta = 'D' Then
		LET _tipo_cuenta_char = 'CORRIENTE';
	Elif a_tipo_cuenta = 'S' Then
		LET _tipo_cuenta_char = 'AHORRO';
	Else
		LET _tipo_cuenta_char = '';
	End If
	
	LET _no_cuenta_final = 'XXXX' || substr(a_no_cuenta,-4);
Else
	if a_tipo_cuenta = '1' Then
		LET _tipo_cuenta_char = 'VISA';
	Elif a_tipo_cuenta = '2' Then
		LET _tipo_cuenta_char = 'MASTERCARD';
	Elif a_tipo_cuenta = '3' Then
		LET _tipo_cuenta_char = 'DINERS CLUB';
	Elif a_tipo_cuenta = '4' Then
		LET _tipo_cuenta_char = 'AMERICAN EXPRESS';
	Else
		LET _tipo_cuenta_char = '';
	End if
	
	--Solo muestra los ultimos 4 digitos de una tarjeta de credito
	If a_no_cuenta is not null Then
		LET _no_tarjeta_parte1 = a_no_cuenta[1,5];
		LET _no_tarjeta_parte2 = substr(a_no_cuenta,-5);

	 	If a_tipo_cuenta = 4 Then
			LET _no_tarjeta_final =  'xxxx-xxxxxx' || trim(_no_tarjeta_parte2);
	 	Else
			LET _no_tarjeta_final = 'XXXX-XXXX-XXXX' || trim(_no_tarjeta_parte2);
	 	End if
	End If
End If

SELECT nombre 
  INTO _nombre_banco
  FROM chqbanco
 WHERE cod_banco = a_cob_banco;


If a_tipo_gestion = 'ACH' Then
	LET _bitacora = " # DE CUENTA: "||_no_cuenta_final||"  TIPO CUENTA: "||trim(_tipo_cuenta_char)||", BANCO: "||trim(_nombre_banco);
Else
	LET _bitacora = " # DE TARJETA: "||_no_tarjeta_final||"  FECHA EXPIRA: "||trim(a_fecha_expira)||" , TIPO DE TARJETA: "||trim(_tipo_cuenta_char)||", BANCO: "||trim(_nombre_banco);
End If

SELECT cod_pagador,
       no_documento
  INTO _cod_pagador,
       _no_documento
  FROM emipomae
 WHERE trim(no_poliza) = a_no_poliza;

SELECT count(*)
  INTO _hay_pago
  FROM cobgesti
 WHERE no_poliza = a_no_poliza
   AND fecha_gestion = _fecha_gestion;
   
if _hay_pago is null then
	let _hay_pago = 0;
end if

/*If _hay_pago = 0 Then*/
	INSERT INTO cobgesti(
		   no_poliza,
		   fecha_gestion,
		   desc_gestion,
		   user_added,
		   no_documento,
		   fecha_aviso,
		   tipo_aviso,
		   cod_gestion,
		   cod_pagador)
	VALUES(
		   a_no_poliza,
		   _fecha_gestion,
		   _bitacora,
		   a_user_proceso,
		   _no_documento,
		   '',
		   0,
		   null,
		   _cod_pagador);
/*End If*/

return 0, "Actualizacion Exitosa ...";
	  
END PROCEDURE;