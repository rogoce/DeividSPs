-- Procedimiento que Realiza la Renovacion de la Poliza desde programa de opciones de renovacion
-- Es una copia del procedure sp_pro281.

-- Creado    : 07/01/2005 - Autor: Armando Moreno M.
-- mod		 : 03/04/2007 - poner suma aseg decimal y entera cuando es ramo auto.

drop procedure sp_pro283;
create procedure sp_pro283(
v_usuario      char(8),
v_poliza       char(10),
v_poliza_nuevo char(10),
a_opcion	   integer default 0) RETURNING   INTEGER;

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _cod_product1   CHAR(5);
DEFINE _cod_product2   CHAR(5);
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant_unidades  INTEGER; 
DEFINE _suma_asegurada dec(16,2);
define _suma_entera	   integer;
define _suma_acum      dec(16,2);
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);
DEFINE _vigencia_final DATE;
DEFINE li_dia		   SMALLINT;
define _opc_fin,_error integer;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE _no_pagos  		INTEGER;
DEFINE ld_fecha_1_pago DATE;
define _vf,_vi		   date;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE _no_uni		   char(5);
DEFINE li_meses		   SMALLINT;
DEFINE ld_prima		   DECIMAL(16,2);
DEFINE ld_descuento	   DECIMAL(16,2);
DEFINE _prima_bruta    DECIMAL(16,2);
DEFINE ld_recargo	   DECIMAL(16,2);
DEFINE ld_prima_neta   DECIMAL(16,2);
DEFINE ld_prima_anual  DECIMAL(16,2);
DEFINE ld_suscrita     DECIMAL(16,2);
DEFINE ld_retenida	   DECIMAL(16,2);
DEFINE ld_impuesto	   DECIMAL(16,4);
DEFINE ld_prima_bruta  DECIMAL(16,2);
DEFINE _monto_visa	   DECIMAL(16,2);
DEFINE ls_impuesto     CHAR(3);
DEFINE _cod_tipoprod   CHAR(3);
DEFINE ld_impuesto1	   DECIMAL(16,4);
DEFINE _fecha_actual   date;
define _ano_auto       smallint;
define _ano_actual     smallint;
define _resultado      smallint;
define _nuevo		   smallint;
DEFINE _cod_asegurado  CHAR(10);
DEFINE _cod_ruta	   CHAR(5);
define _v_f,_v_i	   date;
define _saber		   integer;
define _cod_ramo       char(3);
define _cod_formapag   char(3);
DEFINE _tipo_forma     SMALLINT;
DEFINE _cod_perpago    CHAR(3);
define _fecha_primer_pago date;
DEFINE _tipo_tarjeta    CHAR(1);
DEFINE _no_tarjeta      CHAR(19);
DEFINE _fecha_exp       CHAR(7);
define _cod_banco       char(3);
define _cobra_poliza    char(1);
define _no_cuenta       char(17);
DEFINE _tipo_cuenta   	CHAR(1);
define _cod_pagador     char(10);
DEFINE _dia_cobros1,_dia_cobros2     SMALLINT;
define _anos_pagador    integer;
define _cod_agt         char(5);
define _porc_com      	DECIMAL(5,2);
define _cod_rammo       char(3);
define _nounidad char(5);
define _cod_manzana     char(15);
define _cnt             integer;
define _r_anos          smallint;
define _cod_prod        char(5);
define _cod_subramo     char(3);
define _tipo_agente     char(1);
define _canti           smallint;
define _aplica_imp      smallint;
define _cod_impuesto    char(3);
define _cod_origen      char(3); 
define _no_documento    char(20);

--SET DEBUG FILE TO "sp_pro283.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

let _fecha_actual = CURRENT;
let _ano_actual   = year(_fecha_actual);

update emipomae
   set renovada    = 1,
       fecha_renov = _fecha_actual
 where no_poliza   = v_poliza;

select * 
  from emipomae
 where no_poliza = v_poliza
  into temp prueba;

Let r_anos = 0;
let _r_anos = 0;
let _resultado = 0;

select anos_pagador,
       vigencia_final,
	   cod_ramo
  Into r_anos,
       _vigencia_final,
	   _cod_rammo
  from emiporen
 where no_poliza = v_poliza;

let li_mes = month(_vigencia_final);
let li_dia = day(_vigencia_final);
let li_ano = year(_vigencia_final);
let _prima_bruta = 0;

If li_mes = 2 Then
	If li_dia > 28 Then
		let li_dia = 28;
	    let _vigencia_final = MDY(li_mes, li_dia, li_ano);
	End If
End If

if _cod_rammo <> "019" then
	If r_anos > 0 Then
	   LET r_anos = r_anos - 1;
	Else
	   LET r_anos = 0;
	End If
else
	let r_anos = r_anos + 1;
end if

update prueba
   set no_poliza         = v_poliza_nuevo,
       serie             = Year(vigencia_final),
       no_factura        = NULL,
       fecha_suscripcion = Current,
       fecha_impresion   = Current,
       fecha_cancelacion = NULL,
       impreso           = 0,
       nueva_renov       = "R",
       estatus_poliza    = 1,
       actualizado       = 0,
	   posteado          = '0',
       fecha_primer_pago = vigencia_final,
       date_changed      = CURRENT,
       date_added        = CURRENT,
       carta_aviso_canc  = 0,
       carta_prima_gan   = 0,
       carta_vencida_sal = 0,
       carta_recorderis  = 0,
       fecha_aviso_canc  = NULL,
       fecha_prima_gan   = NULL,
       fecha_vencida_sal = NULL,
       fecha_recorderis  = NULL,
       user_added        = v_usuario,
       ult_no_endoso     = 0,
       renovada          = 0,
       fecha_renov       = NULL,
       fecha_no_renov    = NULL,
       no_renovar        = 0,
       perd_total        = 0,
       anos_pagador      = r_anos,
       incobrable        = 0,
       fecha_ult_pago    = NULL,
       vigencia_inic     = vigencia_final,
       vigencia_final    = _vigencia_final + 1 UNITS YEAR,
       saldo             = 0,
	   cod_banco         = cod_banco,
	   no_cuenta         = no_cuenta,
	   tiene_gastos      = 0,
	   gastos			 = 0.00
 where no_poliza         = v_poliza;

FOREACH
	select vigencia_final,
	       cod_tipoprod,
		   vigencia_inic
	  into _vf,
	       _cod_tipoprod,
		   _vi
  	  from emireaut
	 where no_poliza = v_poliza
	exit foreach;
end foreach

update emiporen
   set vigencia_final    = _vf,
	   fecha_primer_pago = _vi,
       cod_tipoprod      = _cod_tipoprod
where no_poliza = v_poliza;

update prueba
   set  (fecha_primer_pago,
   		 cod_banco,
   		 no_cuenta,
   		 cod_formapag,
   		 cod_perpago,
   		 no_pagos,
         dia_cobros1,
         dia_cobros2,
         tipo_tarjeta,
         no_tarjeta,
         fecha_exp,
         cobra_poliza,
         tipo_cuenta,
         factor_vigencia,
		 saldo_por_unidad,
		 vigencia_final,
		 direc_cobros,
		 cod_tipoprod) =
	    ((select fecha_primer_pago,
		  		 cod_banco,
		  		 no_cuenta,
		  		 cod_formapag,
		  		 cod_perpago,
		  		 no_pagos,
			     dia_cobros1,
			     dia_cobros2,
			     tipo_tarjeta,
			     no_tarjeta,
			     fecha_exp,
			     cobra_poliza,
			     tipo_cuenta,
			     factor_vigencia,
				 saldo_por_unidad,
				 vigencia_final,
				 direc_cobros,
				 cod_tipoprod
		  from emiporen
		 where no_poliza = v_poliza))
 where no_poliza = v_poliza_nuevo;

insert into emipomae
select * from prueba
 where no_poliza = v_poliza_nuevo;

SELECT fecha_primer_pago,
       no_pagos,
	   cod_formapag,
	   cod_perpago,
	   cod_ramo,
	   cod_subramo,
	   cod_origen,
	   no_documento
  INTO ld_fecha_1_pago,
       li_no_pagos,
	   _cod_formapag,
	   ls_cod_perpago,
	   _cod_ramo,
	   _cod_subramo,
	   _cod_origen,
       _no_documento
  FROM emipomae
 where no_poliza = v_poliza_nuevo;

SELECT tipo_forma
  INTO _tipo_forma
  FROM cobforpa
 WHERE cod_formapag = _cod_formapag;

if li_no_pagos = 1 then

	select meses
	  into li_meses
	  from cobperpa
	 where cod_perpago = ls_cod_perpago;

	let li_mes = month(ld_fecha_1_pago) + li_meses;
	let li_ano = year(ld_fecha_1_pago);
	let li_dia = day(ld_fecha_1_pago);

	If li_mes > 12 Then
		let li_mes = li_mes - 12;
		let li_ano = li_ano + 1;
	End If

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
		End If
	Elif li_mes in (4, 6, 9, 11) Then
		If li_dia > 30 Then
			let li_dia = 30;
		End If
	End If

	let ld_fecha_1_pago = MDY(li_mes, li_dia, li_ano);

	update emipomae
	   set fecha_primer_pago = ld_fecha_1_pago
	 where no_poliza = v_poliza_nuevo;

end if

drop table prueba;

select * 
  from emiporec
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiporec	--recargos
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emidirco
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emidirco	--dir de cobro.
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emiagtre
 where no_poliza = v_poliza
  into temp prueba;

select cod_ramo
  into _cod_rammo
  from emipomae
 where no_poliza = v_poliza;

select anos_pagador,
       cod_subramo
  into _r_anos,
       _cod_subramo
  from emipomae
 where no_poliza = v_poliza_nuevo;

foreach

	select cod_producto
	  into _cod_prod
	  from emipouni
	 where no_poliza = v_poliza

	exit foreach;

end foreach


let _porc_com = 0;

foreach

	select cod_agente,
	       porc_comis_agt
	  into _cod_agt,
		   _porc_com
	  from prueba

	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agt;

	if _cod_rammo <> "019" then
		
		if _porc_com = 0 then

			CALL sp_pro305(_cod_agt,_cod_rammo,_cod_subramo) RETURNING _porc_com;

		end if
	else
		foreach

			select porc_comis_agt
			  into _porc_com
			  from prdcoprd
			 where cod_producto = _cod_prod
			   and _r_anos between ano_desde and ano_hasta

			exit foreach;

 	    end foreach
	end if

	if _porc_com is null then
		let _porc_com = 0;
	end if

	if _tipo_agente = 'O' then
		let _porc_com = 0;
	end if

	update prueba 
	   set porc_comis_agt = _porc_com
	 where cod_agente     = _cod_agt
	   and no_poliza      = v_poliza;

end foreach

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipoagt	--corredores
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emipolim
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolim	--impuestos
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

	select count(*)
	  into _canti 
	  from emipolim
	 where no_poliza = v_poliza_nuevo;

	if _canti = 0 then

		Select aplica_impuesto
		  Into _aplica_imp
		  From parorig
		 Where cod_origen = _cod_origen;

		if _no_documento in ("0225-00382-01","2321-00017-01","0218-00430-01","0210-01288-01",'2315-00106-01','2315-00107-01') then
			let _aplica_imp = 0;
		end if

		if _aplica_imp = 1 then

			foreach
				Select cod_impuesto
				  into _cod_impuesto
				  From prdimsub
				 Where cod_ramo    = _cod_ramo
				   And cod_subramo = _cod_subramo

				Insert Into emipolim (no_poliza, cod_impuesto, monto)
				Values (v_poliza_nuevo,_cod_impuesto, 0.00);

			end foreach
		end if
	end if

select *
  from emicomar
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoama	--coaseguro may
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select *
  from emicomir
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoami	----coaseguro min
select *
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emiciare
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiciara	--
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emipolde
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolde	--descuentos
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emipouni
 where no_poliza = v_poliza
  into temp prueba;

select * from emipouni
 where no_poliza = v_poliza
   and perd_total = 1
  into temp prueba2;

foreach
	select no_unidad,
		   cod_producto,
		   cod_asegurado,
		   vigencia_inic,
		   vigencia_final,
		   cod_formapag,
		   cod_perpago,
		   no_pagos,
		   fecha_primer_pago,
		   tipo_tarjeta,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   cobra_poliza,
		   no_cuenta,
		   tipo_cuenta,
		   cod_pagador,
		   dia_cobros1,
		   dia_cobros2,
		   anos_pagador,
		   monto_visa,
		   cod_manzana
	  into _no_uni,
	       _cod_producto,
		   _cod_asegurado,
		   _v_i,
		   _v_f,
		   _cod_formapag,
		   _cod_perpago,
		   _no_pagos,
		   _fecha_primer_pago,
		   _tipo_tarjeta,
		   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _cobra_poliza,
		   _no_cuenta,
		   _tipo_cuenta,
		   _cod_pagador,
		   _dia_cobros1,
		   _dia_cobros2,
		   _anos_pagador,
		   _monto_visa,
		   _cod_manzana
	  from emireaut
	 where no_poliza = v_poliza

	select count(*)
	  into _saber
	  from emipouni
	 where no_poliza = v_poliza
	   and no_unidad = _no_uni;

	if _saber = 0 then	--es unidad nueva
		foreach
			select cod_ruta
			  into _cod_ruta
			  from emirerea
			 where no_poliza = v_poliza

			exit foreach;
		end foreach

		INSERT INTO prueba(
	    no_poliza,
	    no_unidad,
	    cod_ruta,
	    cod_producto,
	    cod_asegurado,
	    suma_asegurada,
	    prima,
	    descuento,
	    recargo,
	    prima_neta,
	    impuesto,
	    prima_bruta,
	    reasegurada,
	    vigencia_inic,
	    vigencia_final,
	    beneficio_max,
	    desc_unidad,
	    activo,
	    prima_asegurado,
	    prima_total,
	    no_activo_desde,
	    facturado,
	    user_no_activo,
	    perd_total,
	    impreso,
	    fecha_emision,
	    prima_suscrita,
	    prima_retenida,
		suma_aseg_adic,
		tipo_incendio,
		gastos,
		cod_formapag,
		cod_perpago,
		no_pagos,
		fecha_primer_pago,
		tipo_tarjeta,
		no_tarjeta,
		fecha_exp,
		cod_banco,
		cobra_poliza,
		no_cuenta,
		tipo_cuenta,
		cod_pagador,
		dia_cobros1,
		dia_cobros2,
		anos_pagador,
		monto_visa,
		cod_manzana,
		subir_bo
		)
		VALUES(
			   v_poliza,
			   _no_uni,
			   _cod_ruta,
			   _cod_producto,
			   _cod_asegurado,
			   0,
			   0,
			   0,
			   0,
			   0,
			   0,
			   0,
			   0,
			   _v_i,
			   _v_f,
			   0.00,
			   null,
			   1,
			   0,
			   0,
			   null,
			   1,
			   null,
			   0,
			   1,
			   CURRENT,
			   0,
			   0,
			   0,
			   null,
			   0.00,
			   _cod_formapag,
			   _cod_perpago,
			   _no_pagos,
			   _fecha_primer_pago,
			   _tipo_tarjeta,
			   _no_tarjeta,
			   _fecha_exp,
			   _cod_banco,
			   _cobra_poliza,
			   _no_cuenta,
			   _tipo_cuenta,
			   _cod_pagador,
			   _dia_cobros1,
			   _dia_cobros2,
			   _anos_pagador,
			   _monto_visa,
			   _cod_manzana,
			   0
			   );
	end if

	update prueba 
	   set no_poliza = v_poliza_nuevo,
	       cod_manzana = _cod_manzana
	 where no_poliza = v_poliza
	   and no_unidad = _no_uni
	   and perd_total = 0;
end foreach

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

select count(*)
  into _cnt
  from prueba;

if _cnt = 0 then
	return 1;
end if

insert into emipouni	--unidades
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

update emipouni
   set impuesto = 0
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emiredes	--descripcion
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipode2
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emireacr
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipoacr	--acreedores
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select e.* from emiunire e, emireaut i
 where e.no_poliza = i.no_poliza
   and e.no_unidad = i.no_unidad
   and e.no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunire	--recargos
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

if _cod_ramo = '008' then
	select * from emifian1
	 where no_poliza = v_poliza
	  into temp prueba;

	foreach
		select no_unidad
		  into _nounidad
		  from prueba2
		 where perd_total = 1

		delete from prueba
		 where no_unidad = _nounidad;

	end foreach

	{delete from prueba
	 where no_unidad = (select no_unidad from prueba2
						 where prueba.no_unidad = prueba2.no_unidad
						   and prueba2.perd_total = 1);}

	update prueba set no_poliza = v_poliza_nuevo
	 where no_poliza   = v_poliza;

	insert into emifian1		
	select * from prueba
	 where no_poliza = v_poliza_nuevo;

	drop table prueba;
end if

select * from emifigar
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);	}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifigar
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiauto
 where no_poliza = v_poliza
   and no_unidad = (select no_unidad from emipouni where no_poliza = v_poliza_nuevo
   					and emiauto.no_unidad = emipouni.no_unidad)
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba2.perd_total = 1);	 }

insert into prueba
select * from emiautor
 where no_poliza = v_poliza;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiauto
select * from prueba
 where no_poliza = v_poliza_nuevo;

update emiauto
   set ano_tarifa = 1
 where no_poliza  = v_poliza_nuevo
   and ano_tarifa = 0;

update emiauto
   set ano_tarifa = ano_tarifa + 1
 where no_poliza  = v_poliza_nuevo;

drop table prueba;


select * from emirecum
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicupol	--cumulos de incendio
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emireglo
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emigloco	--reaseguro global
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emirerea
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emifacon	--reaseguro individual
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emirefac
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emifafac	--facultativo
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emirenco		--coberturas(opcion Final)
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipocob
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

{select * from emicobde
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicobde
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;}

select * 
  from emibenef
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emibenef
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


let _suma_acum = 0;

	FOREACH
		 SELECT no_unidad,
				suma_aseg,
				opcion_final,
				cod_producto,
				cod_product1,
				cod_product2
		   INTO _no_unidad,
				_suma_asegurada,
				_opc_fin,
				_cod_producto,
				_cod_product1,
				_cod_product2
		   FROM emireaut
		  WHERE no_poliza = v_poliza

		 select cod_ramo
		   into _cod_ramo
		   from emipomae
		  where no_poliza = v_poliza_nuevo;

		if _cod_ramo = "002" or _cod_ramo = "020" then
			let _suma_entera    = _suma_asegurada;
			let _suma_asegurada = _suma_entera;
		end if

		CALL sp_proe02(v_poliza_nuevo, _no_unidad, "001") RETURNING _error;

		LET ld_impuesto = 0.00;
		LET ld_impuesto1 = 0.00;
		FOREACH
			 Select emipolim.cod_impuesto, (prdimpue.factor_impuesto * Sum(emipouni.prima_neta)/100)
			   Into ls_impuesto, ld_impuesto1
			   From emipolim, prdimpue, emipouni
			  Where emipolim.no_poliza    = v_poliza_nuevo
			    And emipouni.no_poliza    = emipolim.no_poliza
				And emipouni.no_unidad    = _no_unidad
			    And prdimpue.cod_impuesto = emipolim.cod_impuesto
			 group by emipolim.cod_impuesto, prdimpue.factor_impuesto

			LET ld_impuesto = ld_impuesto + ld_impuesto1;

			Update emipolim
		       Set monto = monto + ld_impuesto1
			 Where no_poliza    = v_poliza_nuevo
			   And cod_impuesto = ls_impuesto;
			
			LET ld_impuesto1 = 0.00;

		END FOREACH

	    SELECT no_motor
		  INTO _no_motor
		  FROM emiauto
		 WHERE no_poliza = v_poliza
		   AND no_unidad = _no_unidad;

	   	Select SUM(prima_neta)
		  Into ld_prima_neta
		  From emipocob
		 Where no_poliza = v_poliza_nuevo
		   AND no_unidad = _no_unidad;

		LET ld_prima_bruta = ld_prima_neta + ld_impuesto;

		UPDATE emipouni
		   SET suma_asegurada = _suma_asegurada,
		  	   prima_neta 	  = ld_prima_neta,
		  	   impuesto 	  = ld_impuesto,
			   prima_bruta    = ld_prima_bruta
		 WHERE no_poliza      = v_poliza_nuevo
		   AND no_unidad      = _no_unidad;

	   	Select ano_auto
		  Into _ano_auto
		  From emivehic
		 Where no_motor   = _no_motor;

		let _resultado = _ano_actual - _ano_auto;
		if _resultado <= 0 then
			let _nuevo = 1;
		else
			let _nuevo = 0;
		end if

		UPDATE emivehic
		   SET valor_auto = _suma_asegurada,
			   nuevo      = _nuevo
		 WHERE no_motor   = _no_motor;
	
		 let _suma_acum = _suma_acum + _suma_asegurada;

		 if _opc_fin = 0 then
			UPDATE emipouni
			   SET cod_producto = _cod_producto
			 WHERE no_poliza    = v_poliza_nuevo
			   AND no_unidad    = _no_unidad;

			select * from emirede0	--descuento. unidad
			 where no_poliza = v_poliza
			   AND no_unidad = _no_unidad
			  into temp prueba;

			foreach
				select no_unidad
				  into _nounidad
				  from prueba2
				 where perd_total = 1

				delete from prueba
				 where no_unidad = _nounidad;

			end foreach

		   {	delete from prueba
			 where no_unidad = (select no_unidad from prueba2
			   			         where prueba.no_unidad = prueba2.no_unidad
			  					   and prueba2.perd_total = 1);}

			update prueba set no_poliza = v_poliza_nuevo
			 where no_poliza   = v_poliza;

			insert into emiunide
			select * from prueba
			 where no_poliza = v_poliza_nuevo;

			drop table prueba;

		 elif _opc_fin = 1 then
		  if _cod_product1 is null then
			UPDATE emipouni
			   SET cod_producto = _cod_producto
			 WHERE no_poliza    = v_poliza_nuevo
			   AND no_unidad    = _no_unidad;
		  else
			UPDATE emipouni
			   SET cod_producto = _cod_product1
			 WHERE no_poliza    = v_poliza_nuevo
			   AND no_unidad    = _no_unidad;
		  end if
			select * from emirede1	--descuentos. opcion1
			 where no_poliza = v_poliza
			   AND no_unidad = _no_unidad
			  into temp prueba;

			foreach
				select no_unidad
				  into _nounidad
				  from prueba2
				 where perd_total = 1

				delete from prueba
				 where no_unidad = _nounidad;

			end foreach

		  {	delete from prueba
			 where no_unidad = (select no_unidad from prueba2
			   			         where prueba.no_unidad = prueba2.no_unidad
			  					   and prueba2.perd_total = 1);			   }

			update prueba set no_poliza = v_poliza_nuevo
			 where no_poliza   = v_poliza;

			insert into emiunide
			select * from prueba
			 where no_poliza = v_poliza_nuevo;

			drop table prueba;
		 elif _opc_fin = 2 then
		  if _cod_product2 is null then
			UPDATE emipouni
			   SET cod_producto = _cod_producto
			 WHERE no_poliza    = v_poliza_nuevo
			   AND no_unidad    = _no_unidad;
		  else
			UPDATE emipouni
			   SET cod_producto = _cod_product2
			 WHERE no_poliza    = v_poliza_nuevo
			   AND no_unidad    = _no_unidad;
		  end if
			select * from emirede2	--descr. unidad
			 where no_poliza = v_poliza
			   AND no_unidad = _no_unidad
			  into temp prueba;

			foreach
				select no_unidad
				  into _nounidad
				  from prueba2
				 where perd_total = 1

				delete from prueba
				 where no_unidad = _nounidad;

			end foreach

  		  {	delete from prueba
			 where no_unidad = (select no_unidad from prueba2
			   			         where prueba.no_unidad = prueba2.no_unidad
			  					   and prueba2.perd_total = 1);}

			update prueba set no_poliza = v_poliza_nuevo
			 where no_poliza   = v_poliza;

			insert into emiunide
			select * from prueba
			 where no_poliza = v_poliza_nuevo;

			drop table prueba;
		 end if
	END FOREACH

drop table prueba2;

DELETE FROM emirepod
 WHERE no_poliza = v_poliza;

CALL sp_proe03(v_poliza_nuevo, "001") RETURNING _error;

IF _tipo_forma = 2 OR  _tipo_forma = 4 THEN -- Tarjetas de Credito/Ach
	select prima_bruta into _prima_bruta from emipomae where no_poliza = v_poliza_nuevo;
	LET _monto_visa = _prima_bruta / _no_pagos;

	Update emipomae
	   Set monto_visa = _monto_visa
	 Where no_poliza  = v_poliza_nuevo;

END IF

Update emipomae
   Set suma_asegurada = _suma_acum
 Where no_poliza      = v_poliza_nuevo;

return 0;
END
end procedure;