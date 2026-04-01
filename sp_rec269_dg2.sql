-- Reporte Comparativo de Reservas y Siniestros Pagados
-- Creado    : 09/05/2016 - Autor: Román Gordón
-- Modificado: 31/05/2018 - Hgiron adicion campo de diagnostico
--execute procedure sp_rec269('001','001','2016-11','*')

drop procedure sp_rec269_dg2;
create procedure 'informix'.sp_rec269_dg2(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_cod_ramo	varchar(255)	default '*',
a_cod_asegurado	char(255)    default "*",
a_numrecla char(20) default "*"
)
returning	dec(16,2)		as mes_ant,
			dec(16,2)		as pag_act,
			dec(16,2)		as mes_act,
			varchar(50)     as nom_compania,
			dec(16,2)       as pagado_bruto_ant;		

define v_filtros			varchar(255);
define _nom_reclamante		varchar(100);  
define _nom_asegurado		varchar(100);  
define _nom_compania		varchar(50);
define _n_ajustador			varchar(50);
define _desc_paso			varchar(50);
define _error_desc			varchar(50);
define _numrecla			char(18);
define _cod_reclamante		char(10);     
define _cod_asegurado		char(10);    
define _no_reclamo			char(10);  
define _no_poliza			char(10);  
define _periodo_desde		char(7);
define _ajust_interno		char(3);
define _cod_ramo			char(3);
define _incurrido_reclamo   dec(16,2);
define _deducible_pagado	dec(16,2);
define _deducible_devuel	dec(16,2);
define _incurrido_bruto     dec(16,2);
define _reserva_inicial     dec(16,2);
define _pago_deducible		dec(16,2);
define _reserva_actual      dec(16,2);
define _incurrido_neto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _pagado_bruto_ant		dec(16,2);
define _res_mes_ant			dec(16,2);
define _res_mes_act			dec(16,2);
define _salvamento			dec(16,2);
define v_porc_reas			dec(16,2);
define v_porc_coas			dec(16,2);
define _deducible			dec(16,2);
define _estimado			dec(16,2);
define _recupero			dec(16,2);
define _pagos				dec(16,2);
define _error_isam			smallint;
define _error				smallint;
define _anio				smallint;
define _mes					smallint;
define _fecha_siniestro		date;
define _fecha_documento		date;
define _fecha_periodo		date;
define _fecha_reclamo		date;
define _no_documento        char(20);
define _cod_icd			    char(10);
define _nombre_icd		    char(100);

DEFINE _cedula           CHAR(30); 
DEFINE _sexo          CHAR(1); 
define _no_unidad			char(5);
define _cod_producto			char(5);
define _nom_producto			char(50);
define _cnt_dependiente					smallint;
define _estado        char(20);
	

set isolation to dirty read;

begin	

on exception set _error,_error_isam,_error_desc
	return _error,0.00,0.00,null,0.00;
end exception

let _nom_compania = '';
let _nom_compania = sp_sis01(a_compania);

drop table if exists tmp_sinis_pag_act;
drop table if exists tmp_res_mes_act;
drop table if exists tmp_res_mes_ant;
drop table if exists tmp_sinis;
drop table if exists tmp_sinis_pag_ant;

-- carga de siniestros pagados

{begin
	on exception in(-535)

	end exception 	
	--begin work;
end
}
let _desc_paso = 'Siniestros Pagados';
--Sacar el periodo anterior
let _mes = a_periodo[6,7];
let _anio = a_periodo[1,4];
let _fecha_periodo = mdy(_mes,1,_anio);
let _fecha_periodo = _fecha_periodo - 1 units day;
let _periodo_desde = sp_sis39(_fecha_periodo);

--******************************************
Call sp_rec704(
a_compania,
a_agencia, 
'2019-04',
_periodo_desde,
'*', --a_sucursal,
'*', 
a_cod_ramo,'*','*','*','*',
'*') returning v_filtros; 

select numrecla,
	   no_reclamo,
	   pagado_bruto
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_sinis_pag_ant;

drop table if exists tmp_sinis;
--commit work;

--*********************************************
{begin
	on exception in(-535)

	end exception 	
	--begin work;
end}

Call sp_rec704(
a_compania,
a_agencia, 
a_periodo,
a_periodo,
'*', --a_sucursal,
'*', 
a_cod_ramo,'*','*','*','*',
'*') returning v_filtros; 

select numrecla,
	   no_reclamo,
	   pagado_bruto
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_sinis_pag_act;

drop table if exists tmp_sinis;
--commit work;
--*****************************************
{begin
	on exception in(-535)

	end exception 	
--	begin work;
end}

-- cargar la reserva del periodo a evaluar

let _desc_paso = 'Siniestros Pendientes Act';
call sp_rec02(a_compania, a_agencia, a_periodo,'*','*','*',a_cod_ramo,'*') returning v_filtros; 

select numrecla,
	   no_reclamo,
	   reserva_bruto
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_res_mes_act;

drop table if exists tmp_sinis;

--commit work;

-- cargar la reserva del periodo anterior

let _desc_paso = 'Siniestros Pendientes Ant';
{begin
	on exception in(-535)

	end exception 	
--	begin work;
end}

call sp_rec02(a_compania,a_agencia,_periodo_desde,'*','*','*',a_cod_ramo,'*') returning v_filtros; 

select numrecla,
	   no_reclamo,
	   reserva_bruto
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_res_mes_ant;

--commit work;

--Comparativo

let _desc_paso = 'Comparativo';
{begin
	on exception in(-535)

	end exception 	
--	begin work;
end}

foreach
	select sum(reserva_mes_ant),
		   sum(reserva_mes_act),
		   sum(pagado_bruto),
		   sum(pagado_bruto_ant)
	  into _res_mes_ant,
		   _res_mes_act,
		   _pagado_bruto,
		   _pagado_bruto_ant
	  from (select no_reclamo as caso, reserva_bruto as reserva_mes_ant, 0 as reserva_mes_act, 0 as pagado_bruto, 0 as pagado_bruto_ant  from tmp_res_mes_ant
	 union select no_reclamo as caso, 0 as reserva_mes_ant, reserva_bruto as reserva_mes_act, 0 as pagado_bruto, 0 as pagado_bruto_ant  from tmp_res_mes_act
	 union select no_reclamo as caso, 0 as reserva_mes_ant, 0 as reserva_mes_act, pagado_bruto as pagado_bruto, 0 as pagado_bruto_ant  from tmp_sinis_pag_act
	 union select no_reclamo as caso, 0 as reserva_mes_ant, 0 as reserva_mes_act, 0 as pagado_bruto, pagado_bruto as pagado_bruto_ant  from tmp_sinis_pag_ant  )
	 
	 
	return	_res_mes_ant,
			_pagado_bruto,
			_res_mes_act,
			_nom_compania,
			_pagado_bruto_ant
			with resume;	
end foreach

drop table if exists tmp_sinis;
drop table if exists tmp_res_mes_act;
drop table if exists tmp_sinis_pag_act;
drop table if exists tmp_res_mes_ant;
drop table if exists tmp_sinis_pag_ant;

--commit work;

end
end procedure;                                               