-- f_emision_renovar
-- Creado    : 16/06/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_pro421b;
CREATE PROCEDURE sp_pro421b(a_poliza char(10), a_valor_nuevo char(10), ldt_vigen_inic date, ldt_vig_fin date, a_usuario CHAR(8)) 
RETURNING INTEGER, VARCHAR(50);		   

DEFINE li_reclamos			INTEGER;
DEFINE ld_saldo         	DEC(16,2);   
DEFINE ldt_fecha        	DATE;
DEFINE li_opcfinal         	SMALLINT;
DEFINE li_return           	INTEGER;
DEFINE ls_error_desc       	VARCHAR(50);
DEFINE ls_periodo_contable	CHAR(7);
DEFINE ls_mes               CHAR(2);
DEFINE ls_ano               CHAR(4);
DEFINE _no_tarjeta  		CHAR(19);
DEFINE _fecha_exp   		CHAR(7);
DEFINE _cod_banco   		CHAR(3);
DEFINE li_tipo_forma   		INTEGER;
DEFINE _tipo_tarjeta   		CHAR(1);
DEFINE _dia_cobros1   		SMALLINT;
DEFINE _prima_suscrita   	DEC(16,2);
DEFINE _prima_retenida   	DEC(16,2);
DEFINE _prima_neta   		DEC(16,2);
DEFINE _no_cuenta   		CHAR(17);
DEFINE _tipo_cuenta   		CHAR(1);
DEFINE ls_cod_perpago  		CHAR(3);
DEFINE li_no_pagos 			SMALLINT;
DEFINE li_dia               INTEGER;
DEFINE _cod_pagador         CHAR(10);
DEFINE ls_cedula            VARCHAR(30);
DEFINE li_tot_cta           SMALLINT;
DEFINE ldt_fecha_final      DATE;
DEFINE _no_motor            CHAR(30);
DEFINE ls_documento         CHAR(20);
DEFINE ls_unidad            CHAR(5);
DEFINE i                    SMALLINT;
DEFINE _cta                 CHAR(1);
DEFINE ls_periodo           CHAR(7);
DEFINE li_dias              SMALLINT;
DEFINE li_mes               SMALLINT;

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

Select cant_reclamos,
	   saldo
  Into li_reclamos,
  	   ld_saldo
  From emirepol
 Where no_poliza = a_poliza;
 
If li_reclamos > 0 Or ld_saldo > 0 Then
	let ldt_fecha   = Today;
	Insert Into emirenoh 
	Values (a_poliza, ld_saldo, ldt_fecha, li_reclamos, a_usuario); 
End If

CALL sp_pro283a(a_usuario, a_poliza, a_valor_nuevo) RETURNING li_return, ls_error_desc;

if li_return <> 0 then
	return 1, ls_error_desc;
end if

Update emirepol
	Set no_poliza2 = a_valor_nuevo
 Where no_poliza  = a_poliza;

Select emi_periodo
  Into ls_periodo_contable
  From parparam
 Where cod_compania = '001'; 

--Select vigencia_inic
-- Into ldt_vigen_inic
--  From emipomae
-- Where no_poliza = a_valor_nuevo; 

let ls_mes = Month(ldt_vigen_inic);
let ls_mes = Trim(ls_mes);
let ls_ano = Year(ldt_vigen_inic);

IF ls_mes IN ('10', '11', '12') THEN
	let ls_mes = ls_mes;
ELSE
	let ls_mes = "0" || Trim(ls_mes);
END IF

let ls_periodo = ls_ano || "-" || ls_mes;

If ls_periodo > ls_periodo_contable Then
	let ls_periodo_contable = ls_periodo;
End If

Update emipomae
	Set periodo   = ls_periodo_contable
 Where no_poliza = a_valor_nuevo;

Update emipomae
	Set renovada  = 1
 Where no_poliza = a_poliza;

-- Verificaciones para las Tarjetas de Credito
  SELECT emipomae.no_tarjeta,   
         emipomae.fecha_exp,   
         emipomae.cod_banco,   
         cobforpa.tipo_forma,   
         emipomae.tipo_tarjeta,   
         emipomae.dia_cobros1,   
         emipomae.prima_suscrita,   
         emipomae.prima_retenida,   
         emipomae.prima_neta,   
         emipomae.no_cuenta,   
         emipomae.tipo_cuenta,   
         emipomae.cod_perpago,   
         emipomae.no_pagos,
         emipomae.cod_pagador		 
	INTO _no_tarjeta,   
         _fecha_exp,   
         _cod_banco,   
         li_tipo_forma,   
         _tipo_tarjeta,   
         _dia_cobros1,   
         _prima_suscrita,   
         _prima_retenida,   
         _prima_neta,   
         _no_cuenta,   
         _tipo_cuenta,   
         ls_cod_perpago,   
         li_no_pagos,
         _cod_pagador		 
    FROM emipomae,   
         cobforpa  
   WHERE ( cobforpa.cod_formapag = emipomae.cod_formapag ) and  
         ( ( emipomae.no_poliza = a_valor_nuevo ) );    

--VALIDAR NO PAGOS VS VIGENCIA
--ldt_vig_fin    = a_datawindow.object.vigencia_final[ll_rowm]  --??
--ldt_vigen_inic = a_datawindow.object.vigencia_inic[ll_rowm]   --??
let li_dias        = abs(ldt_vig_fin - ldt_vigen_inic);
let li_mes         = Month(ldt_vigen_inic);

IF ls_cod_perpago = '001' THEN
	LET li_dia = li_no_pagos * 15;
ELIF ls_cod_perpago = '002' THEN
	LET li_dia = li_no_pagos * 30;
ELIF ls_cod_perpago =  '003' THEN
	LET li_dia = li_no_pagos * 60;
ELIF ls_cod_perpago =  '004' THEN
	LET li_dia = li_no_pagos * 90;
ELIF ls_cod_perpago IN ('005','009') THEN
	LET li_dia = li_no_pagos * 120;
ELIF ls_cod_perpago =  '007' THEN
	LET li_dia = li_no_pagos * 180;
ELIF ls_cod_perpago =  '008' THEN
	LET li_dia = li_no_pagos * 365;
END IF

If (li_dias = 28 or li_dias = 29) and li_mes = 2 Then --febrero
	LET li_dias = 30;
End If

If li_dia > li_dias Then
	Return 1, 'El No. de Pagos excede a la vigencia de la poliza, verifique...';
End If	

If li_tipo_forma = 2 Then -- Tarjeta de Credito
	If _no_tarjeta is null Then
		Return 1, 'El Numero de Tarjeta de Credito No Puede Estar en Blanco';
	End If
	If _tipo_tarjeta is null Then
		Return 1, 'El Tipo de Tarjeta de Credito No Puede Estar en Blanco';
	End If
	If _cod_banco is null Then
		Return 1, 'El Banco No Puede Estar en Blanco';
	End If
	If _fecha_exp is null Then 
		Return 1, 'La Fecha de Expiracion No Puede Estar en Blanco';
	End If
	If _dia_cobros1 = 0 Then
		Return 1, 'El Dia de Cobros No Puede Estar en Blanco';
	End If
End If

-- Verificaciones para Ach
If li_tipo_forma = 4 Then -- Ach
	select cedula
	  into ls_cedula
	  from cliclien
	 where cod_cliente = _cod_pagador;
	If trim(ls_cedula) = "" or ls_cedula is Null Then
		Return 1, 'Debe crear la cédula al Pagador de la póliza, Por Favor Verifique ...';
	End If				
	if _no_cuenta[1,1] = " " then
		return 1, 'La primera posicion del No. de cuenta no debe ser un espacio en blanco, verifique...';
	end if
	If _no_cuenta is null Then
		Return 1, 'El Numero de Cuenta No Puede Estar en Blanco';
	End If
	for i = 1 to 17
	    LET _cta = _no_cuenta[1,1];
		LET _no_cuenta = _no_cuenta[2,17];
		if _cta NOT IN ('1','2','3','4','5','6','7','8','9','0') then
			return 1, 'Solo se permiten números en la cuenta, verifique...';
		end if
	end for
	If _tipo_cuenta is null Then
		Return 1, 'El Tipo de Cuenta No Puede Estar en Blanco';
	End If
	If _cod_banco is null Then
		Return 1, 'El Banco No Puede Estar en Blanco';
	End If
	If _dia_cobros1 = 0 Then
		Return 1, 'El Dia de Cobros No Puede Estar en Blanco';
	End If
End If

-- Verificacion de Prima Retenida Vs Prima Suscrita
If _prima_retenida > _prima_suscrita Then
	Return 1, 'Prima Retenida No Puede Ser Mayor que Prima Suscrita, Por Favor Verifique ...';
End If

--Verificacion de primas
CALL sp_sis25(a_valor_nuevo) RETURNING li_return, ls_error_desc;
If li_return <> 0 Then
	Return 1, ls_error_desc;
End If

--Verificacion de Facultativos
CALL sp_sis25b(a_valor_nuevo) RETURNING li_return, ls_error_desc;
If li_return <> 0 Then
	Return 1, ls_error_desc;
End If

--Verificacion del motor
FOREACH
	SELECT no_motor
	  INTO _no_motor
	  FROM emiauto
	 WHERE no_poliza = a_valor_nuevo
	
	CALL sp_proe23(a_valor_nuevo, _no_motor, ldt_vigen_inic) RETURNING li_return, ls_documento, ldt_fecha_final, ls_unidad;
	If li_return = 1 Then
		EXIT FOREACH;
	End If	 
END FOREACH

If li_return = 1 Then
	Return 1, "El No. de Motor " || Trim(_no_motor) || " esta Asegurado en la Poliza " || Trim(ls_documento) || " y con Vigencia Final del " || ldt_fecha_final || ".";
End If

return 0, "Exito";

END PROCEDURE	  