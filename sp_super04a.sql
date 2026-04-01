   --Reporte B - punto 10 Total de Ingresos por Prima de Seguro en el periodo.
   --Estadistico para la superintendencia 
   --  Armando Moreno M. 11/03/2017
   
   DROP procedure sp_super04a;
   CREATE procedure sp_super04a(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7))
   RETURNING smallint,decimal(16,2);

    DEFINE _cod_ramo        CHAR(3);
    DEFINE _no_poliza       CHAR(10);
    DEFINE _prima_suscrita  DECIMAL(16,2);
	DEFINE _cnt_cerra       INTEGER;
	define _cantidad        integer;
	define _tipo 			smallint;
	define _monto  			dec(16,2);
	define _venta_corredor  dec(16,2);
    define _venta_directa   dec(16,2);
	define _venta_canal     dec(16,2);
	define _no_unidad		char(5);
	define _valor           smallint;
	DEFINE _mes2,_mes,_ano2 SMALLINT;
	DEFINE _fecha2     	    DATE;
	DEFINE _cnt_cont        INTEGER;
	DEFINE a_periodo_ini    CHAR(7);
	DEFINE v_filtros        CHAR(255);
	define _tipo_agente     char(1);
	define _licencia        char(3);
	

LET _prima_suscrita  = 0;
let _cnt_cerra       = 0;
let _cnt_cont        = 0;

SET ISOLATION TO DIRTY READ;

--Buscar el impuesto para sacar punto 10 total de ingresos por prima de seguro 
let a_periodo_ini = a_periodo[1,5] || '01';
--call sp_cob38c(a_cia, a_agencia, a_periodo_ini, a_periodo2) returning _valor; se pone comentario 25/01/2018, debido a que no es prima cobrada, sino prima suscrita correo de Amilcar 25/01/2018
LET v_filtros = sp_pr26bk(a_cia,a_agencia,a_periodo_ini,a_periodo2,'*','*','*','*','*','*','*','*');
let _venta_corredor = 0;
let _venta_directa = 0;
let _venta_canal = 0;
foreach
	select sum(e.total_pri_sus),
	       a.tipo_agente,a.no_licencia[1,3]
	  into _prima_suscrita,
	       _tipo_agente,_licencia
	  from tmp_prod e, agtagent a
	 where e.cod_agente   = a.cod_agente
	   and e.seleccionado = 1
	 group by a.tipo_agente,a.no_licencia[1,3]
	 
	 if _licencia = 'OAL' then
		let _venta_canal = _venta_canal + _prima_suscrita;	 
	 else
		if _tipo_agente <> 'O' then
			let _venta_corredor = _venta_corredor + _prima_suscrita;
		else
			let _venta_directa = _venta_directa + _prima_suscrita;
		end if
	end if
	
end foreach	
let _prima_suscrita = 0;
let _prima_suscrita = _venta_corredor + _venta_directa + _venta_canal;
--Buscar punto 10.1 y 10.2 Efectivo y cheques
let _valor = sp_pro562(a_periodo, a_periodo2);

insert into tmp_monto(tipo,monto)
values(10,_prima_suscrita);

insert into tmp_monto(tipo,monto)
values(11,_venta_directa);

insert into tmp_monto(tipo,monto)
values(12,_venta_corredor);

-- ANEXAR COD_AGENTE con NO_LICENCIA Donde las 3 primeras letras indica “OAL”- canal alternativo. AMORENO 06/02/2019
if _venta_canal is null then
	let _venta_canal = 0.00;
end if   

insert into tmp_monto(tipo,monto)
values(13,_venta_canal);
--  02596 --: BAC - CANAL DE COMERCIALIZACION

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
LET _mes = _mes2;
IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

--trae cant. de polizas vig. temp_perfil
CALL sp_pro95a(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex'
) RETURNING v_filtros;

--CONTRANTANTES
select count(distinct cod_contratante)
  into _cnt_cont
  from temp_perfil
 where seleccionado = 1;
 
if _cnt_cont is null then
	let _cnt_cont = 0;
end if

insert into tmp_monto(tipo,monto)
values(14,_cnt_cont);

--POLIZAS
select count(distinct no_documento)
  into _cnt_cont
  from temp_perfil
 where seleccionado = 1;
 
if _cnt_cont is null then
	let _cnt_cont = 0;
end if

insert into tmp_monto(tipo,monto)
values(15,_cnt_cont);

---SALIDA
foreach with hold
	select sum(monto), 
	       tipo
	  into _monto,
	       _tipo
	  from tmp_monto
	 group by tipo
	 
	return _tipo, _monto with resume;
end foreach

drop table tmp_prod;
drop table tmp_monto;
END PROCEDURE;