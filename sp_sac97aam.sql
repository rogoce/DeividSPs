-- Consulta de Movimientos de Auxiliar Sac 
-- Creado    : 29/12/2008 -- Autor: Henry Girón
--Modificado: 26/02/2014	-- Autor: Román Gordón	Excluir las cuentas que tienen que ver con Planilla.

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac97aam;
create procedure sp_sac97aam(
			a_tipo		char(2),
			a_cuenta	char(12),
			a_ccosto	char(3),
			a_aux		char(5),
			a_anio		char(4),
			a_mes		char(2),
			a_anio2		char(4),
			a_mes2		char(2)) 
returning	char(12),		--  cuenta
			char(15),		--  comprobante
			date,			--  fechatrx
			char(30),		--  tipcomp
			char(50),		--  descripcion
			dec(15,2),		--  debito
			dec(15,2),		--  credito
			dec(15,2),		--  acumulado
			dec(15,2),		--  total
			char(3),		--  origen
			char(5) ;		--  reaseguro

define v_periodo		char(100);
define v_descrip		char(50);
define v_tipoc			char(30);
define v_comp			char(15);
define a_cuenta2		char(12);
define v_cuenta			char(12);
define v_auxiliar		char(5);
define _cod_tipo		char(4);
define v_origen			char(3);
define v_ccosto			char(3);
define v_tipo			char(3);
define v_speriodo		char(2);
define _mes_inic		char(2);
define v_tipoing		char(2);
define _mes_fin			char(2);
define v_saldo_inicial	dec(15,2);
define v_saldo_acum		dec(15,2);
define v_saldo_ant		dec(15,2);
define v_anterior		dec(15,2);
define v_balance		dec(15,2);
define v_credito		dec(15,2);	
define v_debito			dec(15,2);
define _mes_ant			dec(15,2);
define v_saldo			dec(15,2);
define v_leido			dec(15,2);
define v_total			dec(15,2);  
define psaldo5			dec(15,2);
define _neto			dec(16,2);
define v_anio_ant		smallint;
define v_mes_ant		smallint;
define _orden			smallint;
define _cnt_tab			integer;
define v_notrx			integer;
define v_linea			integer;
define v_norgt			integer;
define _li_cnt			integer;
define _error			integer;
define _fecha_inicial	date;
define _fecha_final		date;
define v_f_inicio		date;
define v_f_final		date;
define v_fecha			date;


--set debug file to "sp_sac97.trc";
--trace on;
SET ISOLATION TO DIRTY READ;


create temp table tmp_saldosac97a(
    no_trx		integer,
	linea		integer,
	no_rgt		integer,
	comp		char(15),
	fecha		date,
	tipocomp	char(30),
	debito		dec(15,2)	default 0,
	credito		dec(15,2)	default 0,
	acumulado	dec(15,2)   default 0,
	total		dec(15,2)   default 0,
	tipo		char(2),
	ccosto		char(3),
	origen		char(3),
	cuenta		char(12),
	auxiliar	char(5),
	descripcion	char(50),
	orden		smallint) with no log;
create index isac1_tmp_saldosac97a on tmp_saldosac97a(cuenta);
create index isac2_tmp_saldosac97a on tmp_saldosac97a(orden);
create index isac3_tmp_saldosac97a on tmp_saldosac97a(fecha);
create index isac4_tmp_saldosac97a on tmp_saldosac97a(comp);
create index isac5_tmp_saldosac97a on tmp_saldosac97a(tipocomp);
create index isac6_tmp_saldosac97a on tmp_saldosac97a(origen);
create index isac7_tmp_saldosac97a on tmp_saldosac97a(auxiliar);
create index isac8_tmp_saldosac97a on tmp_saldosac97a(descripcion);

begin
	on exception set _error
	drop table tmp_saldosac97a;
	return '',
		   '',
		   current,
		   '',
		   '',
		   0,
	       0,
		   0,  
		   0,
		   '',
		   ''
    	 with resume;         
end exception

-- Caso # 17139	Anett (RRHH) No se debe mostrar el detalle de los auxiliares de las cuentas con los siguientes Tipos
--SALARIOS ,VACACIONES,DECIMO TERCER MES Y AGUINALDO,SEGURO SOCIAL,SEGURO EDUCATIVO,RIESGOS PROFESIONALES ,GASTO DE REPRESENTACION ,FONDO DE CESANTIA,SOBRETIEMPO,
--SEGUROS EMPLEADOS,BONO DE PRODUCTIVIDAD,PARTICIPACIÓN UTILIDADES,)

select cod_tipo
  into _cod_tipo
  from cglcuentas
 where cta_cuenta = a_cuenta;

if _cod_tipo in ('0012','0013','0014','0015','0016','0017','0018','0020','0021','0022','0023','0024') then
	drop table tmp_saldosac97a;
	return	'',
			'',
			current,
			'',
			'',
			0,
			0,
			0,  
			0,
			'',
			'';
end if

let v_saldo      = 0;
let psaldo5      = 0;
let v_saldo_ant  = 0;
let v_saldo_acum = 0;
let v_cuenta     = a_cuenta;
let v_auxiliar   = a_aux;
let _orden       = 0;

if a_mes = "*" then	
	let _mes_inic = "01";
	let _mes_fin  = "12";
else
	if a_mes < "10" then
		if length(a_mes) = 1 then
			let  v_speriodo = "0" || a_mes;
		end if
	end if

	let v_speriodo = a_mes;
	let _mes_inic = v_speriodo;
	let _mes_fin  = v_speriodo;
	let a_mes = v_speriodo;
end if

let _fecha_inicial = mdy(_mes_inic, 1, a_anio);

if 	a_mes = "*" then
	let _fecha_final   = sp_sis36(a_anio || "-" || _mes_fin);  -- aun mantengo la busqueda por *
else
	let _fecha_final   = sp_sis36(a_anio2 || "-" || a_mes2);
end if


let v_saldo_inicial = 0;
let v_anio_ant      = a_anio - 1;

select cglsaldoaux.sld_incioano
  into v_saldo_ant
  from cglsaldoaux
 where sld_tipo	like a_tipo
   and sld_cuenta = a_cuenta
   and sld_tercero = a_aux
   and sld_ano = a_anio;

IF v_saldo_ant IS NULL THEN
	LET v_saldo_ant = 0;
END IF

if 	a_mes = "01" or a_mes = "*" then
    let psaldo5    = 0;
else
	let v_anio_ant = a_anio ;
	let v_mes_ant  = a_mes - 1 ;
	let psaldo5    = 0;

	select sum(sld1_debitos + sld1_creditos)
	  into psaldo5
	  from cglsaldoaux1
	 where sld1_tipo    = "01"
	   and sld1_cuenta  = a_cuenta
	   and sld1_tercero = a_aux
	   and sld1_ano     = v_anio_ant
	   and sld1_periodo <= v_mes_ant;

	if psaldo5 is null then
		let psaldo5 = 0;
	end if
end if

let v_saldo_inicial = psaldo5 + v_saldo_ant ;
let v_saldo = v_saldo_inicial;	

foreach
	select m.res_notrx,
		   d.res1_linea,
		   d.res1_noregistro,
		   m.res_comprobante,
		   m.res_fechatrx,
		   m.res_tipcomp,
		   d.res1_debito,   
		   d.res1_credito,
		   d.res1_tipo_resumen,
		   m.res_ccosto,
		   m.res_origen
	  into v_notrx,
		   v_linea,
		   v_norgt,
		   v_comp,
		   v_fecha,
		   v_tipo,
		   v_debito,
		   v_credito,
		   v_tipoing,
		   v_ccosto,
		   v_origen
	  from cglresumen1 d, cglresumen m
	 where m.res_noregistro = d.res1_noregistro
	   and d.res1_cuenta = a_cuenta
	   and d.res1_tipo_resumen like a_tipo
	   and d.res1_auxiliar = a_aux
	   and m.res_ccosto like a_ccosto
	   and m.res_fechatrx >= _fecha_inicial
	   and m.res_fechatrx <= _fecha_final
	 order by res_fechatrx, res_comprobante, res_tipcomp, res_origen

	let v_descrip = " ";

	if v_tipo = "021" then --ASIENTOS DE CIERRES
		let _orden = 1;
	else
		let _orden = 0;
	end if

	foreach
		select res_descripcion
		  into v_descrip
		  from cglresumen
		 where res_cuenta      = a_cuenta
		   and res_fechatrx   >= _fecha_inicial 
		   and res_fechatrx   <= _fecha_final
		   and res_comprobante	= v_comp
		   and res_tipcomp     = v_tipo
		   and res_origen		= v_origen 
		   and res_noregistro = v_norgt
		 order by res_fechatrx, res_comprobante, res_tipcomp, res_origen
		exit foreach;
	end foreach

	if v_descrip is null then
		let v_descrip = "";
	end if

	select con_descrip
	  into v_tipoc
	  from cglconcepto   
	 where con_codigo = v_tipo ;

	--LET v_saldo = v_saldo + v_debito - v_credito;

	insert into tmp_saldosac97a(
			no_trx,
			linea, 
			no_rgt, 
			comp,
			fecha,
			tipocomp,
			debito,
			credito,
			acumulado,
			total,
			tipo,
			ccosto,
			origen,
			cuenta,
			auxiliar,
			descripcion,
			orden)
	values	(v_notrx,
			v_linea,
			v_norgt,
			v_comp,
			v_fecha,
			v_tipoc,
			v_debito,
			v_credito,
			v_saldo,
			0.00,
			v_tipoing,
			v_ccosto,
			v_origen,
			v_cuenta,
			v_auxiliar,
			v_descrip,
			_orden);
end foreach

select count(*) 
  into _li_cnt
  from tmp_saldosac97a;

if _li_cnt = 0 then
	insert into tmp_saldosac97a(
	no_trx,
	linea, 
	no_rgt, 
	comp,
	fecha,
	tipocomp,
	debito,
	credito,
	acumulado,
	total,
	tipo,
	ccosto,
	origen,
	cuenta,
	auxiliar,  
    descripcion,
	orden )
	values(	
	0,
	0,
	0,
	'',
	current,
	'',
	0,
	0,
	0,
	0.00,
	'',
	'',
	'',
	'',
	'',
	'',
	1);
end if

--trace off;

let v_balance = psaldo5 + v_saldo_ant ;

update tmp_saldosac97a
   set total  = v_balance;

foreach	
	select cuenta,
		   comp,
		   fecha,
		   tipocomp,
		   descripcion,
		   auxiliar,
		   sum(debito),
		   sum(credito),
		   sum(acumulado),
		   sum(total),
		   origen,
		   orden
	  into v_cuenta,
		   v_comp,
		   v_fecha,
		   v_tipoc,
		   v_descrip,
		   v_auxiliar,
		   v_debito,
	       v_credito,
		   v_saldo,
		   v_total,
		   v_origen,
		   _orden
      from tmp_saldosac97a
	 group by cuenta,orden, fecha, comp, tipocomp, origen ,auxiliar ,descripcion
	 order by cuenta,orden, fecha, comp, tipocomp, origen ,auxiliar ,descripcion

  	  let v_balance = v_balance + v_debito - v_credito ;

	return	v_cuenta,
			v_comp,
			v_fecha,
			v_tipoc,
			v_descrip,
			v_debito,
			v_credito,
			v_balance,
			v_total,
			v_origen,
			v_auxiliar
			with resume;
end foreach
--drop table tmp_saldosac97a;
end
end procedure					 				 