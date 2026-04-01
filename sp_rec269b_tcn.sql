-- Reporte Comparativo de Reservas y Siniestros Pagados
-- Creado    : 09/05/2016 - Autor: Román Gordón
-- Modificado: 31/05/2018 - Hgiron adicion campo de diagnostico
--    Modificado: adicion movimiento del mes    HGIORN   18/02/2020
--execute procedure sp_rec269b('001','001','2016-11','*')

drop procedure sp_rec269b_tcn;
create procedure 'informix'.sp_rec269b_tcn(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_cod_ramo	varchar(255)	default '*')
returning	char(20)        as poliza,
			char(5)        	as cod_contratante,
			varchar(100)	as contratante,
			char(3)        	as cod_ramo,
			varchar(100)	as ramo,
			char(3)        	as cod_subramo,
			varchar(100)	as subramo,
            date			as vigencia_inic,
            date			as vigencia_final,
			char(5)        	as cod_grupo,
			varchar(100)	as grupo,
			dec(16,2)		as prim_cob_dev2021,
			dec(16,2)		as reserva_2021,
			dec(16,2)		as pagado_2021,
			dec(16,2)       as prim_cob_dev2022,
			dec(16,2)       as reserva_2022,
			dec(16,2)       as pagado_2022,
			dec(16,2)       as prim_cob_bruta,
			dec(16,2)       as res_mes_act,
			dec(16,2)       as pagado_bruto;


define v_filtros			varchar(255);
define _nom_reclamante		varchar(100);  
define _nom_asegurado		varchar(100);  
define _nom_compania		varchar(50);
define _n_ajustador			varchar(50);
define _subramo				varchar(50);
define _grupo				varchar(50);
define _ramo				varchar(50);
define _desc_paso			varchar(50);
define _error_desc			varchar(50);
define _mensaje				varchar(50);
define _numrecla			char(18);
define _cod_contratante		char(10);     
define _cod_asegurado		char(10);    
define _no_reclamo			char(10);  
define _cod_grupo			char(10);  
define _no_poliza			char(10);  
define _periodo_anio1		char(7);
define _periodo_anio2		char(7);
define _periodo_desde		char(7);
define _cod_subramo			char(3);
define _ajust_interno		char(3);
define _cod_ramo			char(3);
define _siniestralidad		dec(16,2);
define _prim_cob_dev2021	dec(16,2);
define _prim_cob_dev2022	dec(16,2);
define _incurrido_reclamo   dec(16,2);
define _deducible_pagado	dec(16,2);
define _deducible_devuel	dec(16,2);
define _incurrido_bruto     dec(16,2);
define _reserva_inicial     dec(16,2);
define _pago_deducible		dec(16,2);
define _reserva_actual      dec(16,2);
define _incurrido_neto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _variacion    		dec(16,2);
define _var_pos    			dec(16,2);
define _var_neg    			dec(16,2);
define _pagado_2021			dec(16,2);
define _pagado_2022			dec(16,2);
define _reserva_2021		dec(16,2);
define _reserva_2022		dec(16,2);
define _res_mes_act			dec(16,2);
define _prim_cob_bruta		dec(16,2);
define v_porc_reas			dec(16,2);
define v_porc_coas			dec(16,2);
define _deducible			dec(16,2);
define _estimado			dec(16,2);
define _recupero			dec(16,2);
define _pagos				dec(16,2);
define _error_isam			smallint;
define _cnt_dev				smallint;
define _error				smallint;
define _anio				smallint;
define _mes					smallint;
define _fecha_periodo2021	date;
define _fecha_periodo2022	date;
define _fecha_vigencia		date;
define _fecha_documento		date;
define _fecha_suspension	date;
define _fecha_desde			date;
define _cubierto_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_periodo		date;
define _fecha_reclamo		date;
define _no_documento        char(20);
define _cod_icd			    char(10);
define _nombre_icd		    char(100);
define _contratante		    char(100);


--set debug file to "sp_rec269b_tcn.trc";
--trace on;

set isolation to dirty read;

begin


on exception set _error,_error_isam,_error_desc
	return _no_documento,'','','',_error_desc,'',_error,_vigencia_inic,_vigencia_final,'',_desc_paso,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00;
end exception

let _nom_compania = '';
let _nom_compania = sp_sis01(a_compania);

drop table if exists tmp_sinis_pag_act;
drop table if exists tmp_res_mes_act;
drop table if exists tmp_res_mes_ant;
drop table if exists tmp_sinis;

-- carga de siniestros pagados

begin
	on exception in(-535)

	end exception 	
	begin work;
end

let _periodo_desde = '2021-01';
let _fecha_desde = mdy(_periodo_desde[6,7],1,_periodo_desde[1,4]);


let _desc_paso = 'Siniestros Pagados';
let _variacion = 0;
Call sp_rec704(
a_compania,
a_agencia, 
'2020-01',
a_periodo,
'*', --a_sucursal,
'*', 
a_cod_ramo,'*','*','*','*',
'*') returning v_filtros; 

select emi.no_documento,
	   tmp.*
  from tmp_sinis tmp
 inner join emipomae emi on emi.no_poliza = tmp.no_poliza
 where seleccionado = 1
  into temp tmp_sinis_pag_act;

drop table if exists tmp_sinis;

commit work;


begin
	on exception in(-535)

	end exception 	
	begin work;
end

-- cargar la reserva del periodo a evaluar

let _desc_paso = 'Siniestros Pendientes Act';
call sp_rec02(a_compania, a_agencia, a_periodo,'*','*','*',a_cod_ramo,'*') returning v_filtros; 

select no_documento,
	   sum(reserva_bruto) as reserva_bruto
  from tmp_sinis
 where seleccionado = 1
 group by no_documento
  into temp tmp_res_mes_act;

drop table if exists tmp_sinis;

commit work;


--Comparativo

let _desc_paso = 'Comparativo';
begin
	on exception in(-535)

	end exception 	
	begin work;
end


--set debug file to "sp_rec269b_tcn.trc";
--trace on;

foreach
	select emi.no_documento,emi.cod_ramo,ram.nombre,emi.cod_subramo,sub.nombre,emi.vigencia_inic,emi.vigencia_final,grp.cod_grupo,grp.nombre,cli.cod_cliente,cli.nombre,emi.no_poliza
	  into _no_documento,_cod_ramo,_ramo,_cod_subramo,_subramo,_vigencia_inic,_vigencia_final,_cod_grupo,_grupo,_cod_contratante,_contratante,_no_poliza
	  from emipomae emi
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 where emi.cod_ramo in ('023','016','018','004')
	   and emi.vigencia_final >= _fecha_desde
	   and emi.actualizado = 1
	   and emi.no_documento = '0209-00875-01'
	 order by emi.no_documento


	if _cod_ramo in ('018') and _cod_subramo not in ('010','012') then -- Salud Colectivo
		continue foreach;
	elif _cod_ramo in ('004') and _cod_subramo not in ('006','007','008','009') then -- Colectivos AP
		continue foreach;
	end if

/*	Detalle de Reclamos

	select no_poliza,
		   numrecla,
		   cod_reclamante,cod_asegurado,
		   fecha_documento,
		   fecha_reclamo,
		   fecha_siniestro,
		   ajust_interno,
		   no_documento,
		   cod_icd
	  into _no_poliza,
		   _numrecla,
		   _cod_reclamante,_cod_asegurado,
		   _fecha_documento,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _ajust_interno,
		   _no_documento,
		   _cod_icd		   
	  from recrcmae
	 where no_reclamo = _no_reclamo;

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

	 
	let _n_ajustador = "";

	select nombre 
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
	
    select sum(variacion)
      into _variacion
      from rectrmae
     where numrecla = _numrecla
       and periodo  = a_periodo
       and cod_tipotran in ('001','002','003','010','011','012','013','014')
	   and actualizado = 1;
	   
	select sum(variacion)
      into _var_pos
      from rectrmae
     where numrecla = _numrecla
       and periodo  = a_periodo
       and cod_tipotran in ('001','002','003','010','011','012','013','014')
	   and actualizado = 1
	   and variacion > 0;

	select sum(variacion)
      into _var_neg
      from rectrmae
     where numrecla = _numrecla
       and periodo  = a_periodo
       and cod_tipotran in ('001','002','003','010','011','012','013','014')
	   and actualizado = 1
	   and variacion < 0;	   
	  
	if _variacion is null then_
		let _variacion = 0;
	end if
	
	if _var_neg is null then
		let _var_neg = 0;
	end if
	
	if _var_pos is null then
		let _var_pos = 0;
	end if		
*/
	
	if month(_vigencia_inic) <> month(_vigencia_final) and _cod_ramo <> '018' then		
		if month(_vigencia_final) in (1,3,5,7,8,10,12) and day(_vigencia_final) >= 29 then
			let _fecha_periodo = _vigencia_final -32 units day;
		else
			let _fecha_periodo = _vigencia_final -1 units month;
		end if
	
		let _fecha_vigencia = _vigencia_final;
	else
		if month(_vigencia_inic) in (1,3,5,7,8,10,12) and day(_vigencia_inic) >= 29 then
			let _fecha_periodo = _vigencia_inic -32 units day;
		else
			let _fecha_periodo = _vigencia_inic -1 units month;
		end if
		let _fecha_vigencia = _vigencia_inic;
	end if	
	
	--Determinar el Periodo Anterior de la Vigencia en 2021
	if year(_fecha_periodo) = 2020 then	
		let _fecha_periodo2021 = mdy(1,day(_fecha_periodo),2021);	
		let _periodo_anio1 = sp_sis39(_fecha_periodo2021);
	else
		let _fecha_periodo2021 = mdy(month(_fecha_periodo),day(_fecha_periodo),2021);	
		let _periodo_anio1 = sp_sis39(_fecha_periodo2021);
	end if
	
	--Determinar el Periodo Anterior de la Vigencia en 2022
	let _fecha_periodo2022 = _fecha_periodo2021 + 1 units year;
	let _periodo_anio2 = sp_sis39(_fecha_periodo2022);
	
	--Determinar las fechas de vigencia
	let _fecha_periodo2021 = mdy(month(_fecha_vigencia),day(_fecha_vigencia),2022);	
	let _fecha_periodo2022 = _fecha_periodo2021 + 1 units year;
	
	
/*Prima Cobrada Devengada*/
	select count(*)
	  into _cnt_dev
	  from deivid_tmp:consumo_prima
	 where no_documento = _no_documento;

	if _cnt_dev is null then
		let _cnt_dev = 0;
	end if
	
	if _cnt_dev = 0 then
		call sp_dev06(_no_documento,today) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;
		
		insert into deivid_tmp:consumo_prima
		select * from tmp_consumo_prima;
	end if
	
	let _prim_cob_dev2021 = 0.00;
	let _prim_cob_dev2022 = 0.00;
	
	if _cod_ramo = '018' then
		select sum(prima_cobrada)
		  into _prim_cob_dev2021
		  from deivid_tmp:consumo_prima
		 where no_documento = _no_documento
		   and fecha >= _fecha_periodo2021
		   and fecha <= _fecha_periodo2022;

		select sum(prima_cobrada)
		  into _prim_cob_dev2022
		  from deivid_tmp:consumo_prima
		 where no_documento = _no_documento
		   and fecha > _fecha_periodo2022;

		select sum(prima_cobrada)
		  into _prim_cob_bruta
		  from deivid_tmp:consumo_prima
		 where no_documento = _no_documento
		   and fecha >= _fecha_periodo2021;
		   
	else
		select sum(prima_cobrada)
		  into _prim_cob_bruta
		  from deivid_tmp:consumo_prima
		 where no_documento = _no_documento
		   and fecha >= _vigencia_inic
		   and fecha <= _vigencia_final;
	end if
	
	
	select sum(reserva_bruto)
	  into _res_mes_act
	  from tmp_res_mes_act
	 where no_documento = _no_documento;
	

	select sum(reserva_bruta)
	  into _reserva_2021
	  from deivid_bo:recrespe rec
	 inner join recrcmae mae on mae.no_reclamo = rec.no_reclamo
	 inner join emipomae emi on emi.no_poliza = mae.no_poliza
	 where emi.no_documento = _no_documento
	   and rec.periodo = _periodo_anio1;

	select sum(reserva_bruta)
	  into _reserva_2022
	  from deivid_bo:recrespe rec
	 inner join recrcmae mae on mae.no_reclamo = rec.no_reclamo
	 inner join emipomae emi on emi.no_poliza = mae.no_poliza
	 where emi.no_documento = _no_documento
	   and rec.periodo = _periodo_anio2;

	

	select sum(pagado_bruto)
	  into _pagado_2021
	  from tmp_sinis_pag_act
	 where no_documento = _no_documento
	   and periodo > _periodo_anio1
	   and periodo <= _periodo_anio2;

	select sum(pagado_bruto)
	  into _pagado_2022
	  from tmp_sinis_pag_act
	 where no_documento = _no_documento
	   	   and periodo >= _periodo_anio2;
	
	select sum(pagado_bruto)
	  into _pagado_bruto
	  from tmp_sinis_pag_act
	 where no_documento = _no_documento
	   and periodo >= '2021-01';

	if _res_mes_act is null then
		let _res_mes_act = 0.00;
	end if

	if _pagado_2021 is null then
		let _pagado_2021 = 0.00;
	end if

	if _reserva_2021 is null then
		let _reserva_2021 = 0.00;
	end if

	if _pagado_2022 is null then
		let _pagado_2022 = 0.00;
	end if

	if _reserva_2022 is null then
		let _reserva_2022 = 0.00;
	end if

	if _pagado_bruto is null then
		let _pagado_bruto = 0.00;
	end if

	if _prim_cob_bruta is null then
		let _prim_cob_bruta = 0.00;
	end if

	if _prim_cob_dev2021 is null then
		let _prim_cob_dev2021 = 0.00;
	end if

	if _prim_cob_dev2022 is null then
		let _prim_cob_dev2022 = 0.00;
	end if

	let _incurrido_bruto = _res_mes_act + _pagado_bruto;
	--let _siniestralidad = _incurrido_bruto/_prim_cob_bruta;
  
	
	 
	return	_no_documento,
			_cod_contratante,
			_contratante,
			_cod_ramo,
			_ramo,
			_cod_subramo,
			_subramo,
			_vigencia_inic,
			_vigencia_final,
			_cod_grupo,
			_grupo,
			_prim_cob_dev2021,
			_reserva_2021,
			_pagado_2021,			
			_prim_cob_dev2022,			
			_reserva_2022,
			_pagado_2022,			
			_prim_cob_bruta,
			_res_mes_act,
			_pagado_bruto with resume;			
end foreach

{drop table if exists tmp_sinis;
drop table if exists tmp_res_mes_act;
drop table if exists tmp_sinis_pag_act;
drop table if exists tmp_res_mes_ant;}

commit work;

end
end procedure;                                               