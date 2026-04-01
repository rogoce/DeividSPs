-- Reporte Comparativo de Reservas y Siniestros Pagados
-- Creado    : 09/05/2016 - Autor: Román Gordón
-- Modificado: 31/05/2018 - Hgiron adicion campo de diagnostico
--execute procedure sp_rec269('001','001','2016-11','*')

drop procedure sp_rec269;
create procedure 'informix'.sp_rec269(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_cod_ramo	varchar(255)	default '*',
a_cod_asegurado	char(255)    default "*",
a_numrecla char(20)
)
returning	char(18)		as Reclamo,
            date			as fecha_doc,
            date			as fecha_rec,
			date			as fecha_sin,
			varchar(100)	as Cliente,
			dec(16,2)		as mes_ant,
			dec(16,2)		as pag_act,
			dec(16,2)		as mes_act,
			varchar(50)		as nom_compania,
			char(50)        as ajustador,
			dec(16,2)       as Incurrido,
			char(20)        as poliza,
			varchar(100)    as nom_asegurado,
			char(10)        as cod_icd,
			char(100)       as nom_icd,
			CHAR(30)  as cedula,
			CHAR(1)   as sexo ,
			char(50)  as nom_producto,
			dec(16,2) as pagado_bruto_ant,
			char(20) as estado,
			dec(16,2) as _Pagado_Banco_act;		

define v_filtros,_mess			varchar(255);
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
define _Pagado_Banco_act		dec(16,2);

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
	return '','01/01/1900','01/01/1900','01/01/1900',_error_desc,_error,0.00,0.00,_nom_compania,_desc_paso,0.00,'','','','','','','',0,'',0.00;
end exception

let _nom_compania = '';
let _nom_compania = sp_sis01(a_compania);

drop table if exists tmp_sinis_pag_act;
drop table if exists tmp_res_mes_act;
drop table if exists tmp_res_mes_ant;
drop table if exists tmp_sinis;
drop table if exists tmp_sinis_pag_ant;
drop table if exists tmp_sinis_pag_banco;

-- carga de siniestros pagados

begin
	on exception in(-535)

	end exception 	
	begin work;
end
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
commit work;

--*********************************************
begin
	on exception in(-535)

	end exception 	
	begin work;
end

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
commit work;

--***PAGADO BANCO ******************************************
begin
	on exception in(-535)

	end exception 	
	begin work;
end

Call sp_rec291(a_periodo) returning _mess; 

select numrecla,
	   no_reclamo,
	   pagado_banco
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_sinis_pag_banco;

drop table if exists tmp_sinis;
commit work;
--***PAGADO BANCO ******************************************
--*****************************************
begin
	on exception in(-535)

	end exception 	
	begin work;
end

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

commit work;

-- cargar la reserva del periodo anterior

let _desc_paso = 'Siniestros Pendientes Ant';
begin
	on exception in(-535)

	end exception 	
	begin work;
end

call sp_rec02(a_compania,a_agencia,_periodo_desde,'*','*','*',a_cod_ramo,'*') returning v_filtros; 

select numrecla,
	   no_reclamo,
	   reserva_bruto
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_res_mes_ant;

commit work;

--Comparativo

let _desc_paso = 'Comparativo';
begin
	on exception in(-535)

	end exception 	
	begin work;
end

foreach
	select caso,
		   sum(reserva_mes_ant),
		   sum(reserva_mes_act),
		   sum(pagado_bruto),
		   sum(pagado_bruto_ant),
		   sum(Pagado_Banco_act)		   
	  into _no_reclamo,
		   _res_mes_ant,
		   _res_mes_act,
		   _pagado_bruto,
		   _pagado_bruto_ant,
		   _Pagado_Banco_act
	  from (select no_reclamo as caso, reserva_bruto as reserva_mes_ant, 0 as reserva_mes_act, 0 as pagado_bruto, 0 as pagado_bruto_ant, 0 as Pagado_Banco_act  from tmp_res_mes_ant
	 union select no_reclamo as caso, 0 as reserva_mes_ant, reserva_bruto as reserva_mes_act, 0 as pagado_bruto, 0 as pagado_bruto_ant, 0 as Pagado_Banco_act  from tmp_res_mes_act
	 union select no_reclamo as caso, 0 as reserva_mes_ant, 0 as reserva_mes_act, pagado_bruto as pagado_bruto, 0 as pagado_bruto_ant, 0 as Pagado_Banco_act  from tmp_sinis_pag_act
	 union select no_reclamo as caso, 0 as reserva_mes_ant, 0 as reserva_mes_act, 0 as pagado_bruto, pagado_bruto as pagado_bruto_ant, 0 as Pagado_Banco_act  from tmp_sinis_pag_ant  
	 union select no_reclamo as caso, 0 as reserva_mes_ant, 0 as reserva_mes_act, 0 as pagado_bruto, 0 as pagado_bruto_ant, pagado_banco as Pagado_Banco_act  from tmp_sinis_pag_banco )
	 group by caso
	 
	select no_poliza,
		   numrecla,
		   cod_reclamante,cod_asegurado,
		   fecha_documento,
		   fecha_reclamo,
		   fecha_siniestro,
		   ajust_interno,
		   no_documento,
		   cod_icd,
		   no_unidad
	  into _no_poliza,
		   _numrecla,
		   _cod_reclamante,_cod_asegurado,
		   _fecha_documento,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _ajust_interno,
		   _no_documento,
		   _cod_icd,
            _no_unidad		   
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	if a_cod_asegurado <> "*" then 
		if a_cod_asegurado <> _cod_asegurado then
			continue foreach;
		end if
	end if		 
	
	if a_numrecla <> "*" then 
		if a_numrecla <> _numrecla then
			continue foreach;
		end if
	end if	

	let _incurrido_reclamo = 0;
	
	call sp_rec33(_no_reclamo) returning 
	   _estimado,   
	   _deducible,  
	   _reserva_inicial,  
	   _reserva_actual,  
	   _pagos,      
	   _recupero,
	   _salvamento, 
	   _deducible_pagado,
	   _deducible_devuel,
	   v_porc_reas,
	   v_porc_coas,
	   _pago_deducible,
	   _incurrido_reclamo,
	   _incurrido_bruto,
	   _incurrido_neto;
	   
		   

	select nombre 
	  into _nom_reclamante	 
	  from cliclien 
	 where cod_cliente = _cod_reclamante;
	 
	 let _cedula = "";
	 let _sexo = "";
	 
	select nombre,
           cedula,sexo	
	  into _nom_asegurado,_cedula,_sexo
	  from cliclien 
	 where cod_cliente = _cod_asegurado;	  
	 
	 
	let _n_ajustador = "";

	select usuario  --nombre 
	  into _n_ajustador
	  from recajust
	 where cod_ajustador = _ajust_interno;
	 
	select nombre
	  into _nombre_icd
	  from recicd
	 where cod_icd = _cod_icd;

	if _cod_icd is null then
		let _cod_icd    = "";
		let _nombre_icd = "";
	end if	 
	 let _cod_producto = "";
	 let _nom_producto = "";	
	
SELECT cod_producto
  INTO _cod_producto
  FROM emipouni
 WHERE no_poliza = _no_poliza
   AND no_unidad = _no_unidad;

	if _cod_producto is not null then	
	  SELECT trim(cod_producto)||'- '||trim(nombre)
		INTO _nom_producto
		FROM prdprod  
	   WHERE cod_producto = _cod_producto;   	 
	end if				
	
	let _cnt_dependiente = 0;
	let _estado = '';
	
	SELECT count(*)
  INTO _cnt_dependiente
  FROM emidepen
 WHERE no_poliza = _no_poliza
   AND no_unidad = _no_unidad
   and cod_cliente = _cod_asegurado;
   
   if _cnt_dependiente > 0 then	
       let _estado = 'DEP';
	else
	   let _estado = 'ASE';
   end if
	 
	return	_numrecla,
			_fecha_documento,
			_fecha_reclamo,
			_fecha_siniestro,
			_nom_reclamante,
			_res_mes_ant,
			_pagado_bruto,
			_res_mes_act,
			_nom_compania,
			_n_ajustador,
			_incurrido_reclamo,
		    _no_documento,
			_nom_asegurado,
            _cod_icd,
            _nombre_icd,
			_cedula,
			_sexo,
			_nom_producto,
			_pagado_bruto_ant,
            _estado,
            _Pagado_Banco_act			

			with resume;	
end foreach

drop table if exists tmp_sinis;
drop table if exists tmp_res_mes_act;
drop table if exists tmp_sinis_pag_act;
drop table if exists tmp_res_mes_ant;
drop table if exists tmp_sinis_pag_ant;
drop table if exists tmp_sinis_pag_banco;

commit work;

end
end procedure;                                               