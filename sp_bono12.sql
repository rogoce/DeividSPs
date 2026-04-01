--************************************************************************************************************
-- Procedimiento que genera la tabla con la información para el Bono de Productividad para Comercializacion
--************************************************************************************************************
--execute procedure sp_bono12('001','001')

drop procedure sp_bono12;
create procedure sp_bono12(a_compania char(3), a_sucursal char(3))
returning	smallint		as code_error,
			varchar(255)	as error_desc;--,datetime year to fraction(5);

define _filtros				varchar(255);
define _n_cliente			varchar(100);
define _nombre_vendedor		varchar(50);
define _nombre_ramo			varchar(50);
define _error_desc			varchar(50);
define _cedula_agt			varchar(30);
define _reemplaza_poliza	char(20); 
define _no_documento		char(20); 
define _cod_contratante		char(10);
define _no_reclamo			char(10);
define _no_poliza_r			char(10);
define _no_poliza			char(10);
define _emi_periodo			char(7);
define _per_fin_dic			char(7);
define _per_ini_ap			char(7);
define _per_fin_ap			char(7);
define _per_fin_aa			char(7);
define _per_ini				char(7);
define _periodo				char(7);
define _cod_agente			char(5);
define _no_endoso			char(5);
define _cod_grupo			char(5);
define _cod_coasegur		char(3);
define _cod_tipoprod		char(3);
define _cod_vendedor		char(3);
define _cod_agencia			char(3);
define _cod_ramo			char(3);
define _estatus_licencia	char(1);
define _tipo_agente			char(1);
define _nueva_renov			char(1);
define _porc_coas_ancon		dec(5,2);
define _prima_suscrita_ap	dec(16,2);
define _siniestralidad		dec(16,2);
define _porc_coaseguro		dec(16,4);
define _prima_suscrita		dec(16,2);
define _prima_sus_pag		dec(16,2);
define _sin_pen_dic			dec(16,2);
define _pri_pag_ap			dec(16,2);
define _sin_pag_aa			dec(16,2);
define _sin_pen_aa			dec(16,2);
define _sini_incu			dec(16,2);
define _pri_pag				dec(16,2);
define _monto				dec(16,2);
define _cnt_somos			smallint;  
define _fronting			smallint;  
define _trimestre			smallint;  
define _dias				smallint;
define _flag				smallint;
define _anio				smallint;
define _mes					smallint;
define _ano					smallint;
define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;
define _no_pol_ren_ap		integer;
define _no_pol_nue_aa		integer;
define _no_pol_nue_ap		integer;
define _no_pol_ren_aa		integer;
define my_sessionid			integer;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _fecha_aa_ini		date;
define _fecha_ap_ini		date;
define _fecha_cierre		date;
define _fecha_fin_ap		date;
define _fecha_cobro			date;
define _fecha_aa			date;
define _fecha_ap			date;
define _fecha				date;
define _fecha_proceso		datetime year to fraction(5);

--return 0,'Proceso Inactivo'; 

--SET DEBUG FILE TO 'sp_che86.trc';
--TRACE ON;

begin 
on exception set _error, _error_isam, _error_desc
	return _error,_error_desc;--,current;
end exception

let _error          = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;

-- Periodo Actual
select par_ase_lider,
       par_periodo_act,
	   par_periodo_ant,
	   fecha_cierre
  into _cod_coasegur,
	   _per_fin_aa,
	   _emi_periodo,
	   _fecha_cierre
  from parparam;

--Para que tome en cuenta el periodo anterior mientras no se haya cerrado.
if (today - _fecha_cierre) > 1 then
	let _per_fin_aa = _per_fin_aa;
else
	let _per_fin_aa = _emi_periodo;
end if

--ESTO ES EN CASO DE PRUEBA
--let _per_fin_aa = '2017-05';

--*****************************
-- Periodo Inicial del Bono
--*****************************

--let _per_ini      = '2018-07';	--PONER EN COMENTARIO CUANDO SE PONGA AUTOMATICO

-- Periodo Final del Concurso
if _per_fin_aa > '2019-12' then
	let _per_fin_aa = '2019-12';
end if

select ano,
	   trimestre
  into _anio,
	   _trimestre
  from tribono 
 where _per_fin_aa in (periodo1,periodo2,periodo3);

select periodo1
  into _per_ini
  from tribono
 where ano       = _anio
   and trimestre = _trimestre;

let _fecha_fin_ap = sp_sis36(_per_ini);

--let _per_fin_aa = '2018-09';	--PONER EN COMENTARIO CUANDO SE PONGA AUTOMATICO

-- Periodo Pasado
let _ano            = _per_ini[1,4];		  --2019
let _ano            = _ano - 1;				  --2018
let _per_ini_ap     = _ano || _per_ini[5,7];  --2018-04

let _ano            = _per_fin_aa[1,4];		     --2019
let _ano            = _ano - 1;				     --2018
let _per_fin_ap     = _ano || _per_fin_aa[5,7];  --2018-04

-- Diciembre
let _per_fin_dic    = _per_fin_ap[1,4] || '-12'; --2018-12

-- Fechas de los Periodos
let _fecha_aa_ini = mdy(_per_ini[6,7], 1, _per_ini[1,4]);        --01/04/2019
let _fecha_ap_ini = mdy(_per_ini_ap[6,7], 1, _per_ini_ap[1,4]);  --01/04/2018

let _fecha_aa     = sp_sis36(_per_fin_aa);  -- último día del periodo actual               --30/04/2019
let _fecha_ap     = sp_sis36(_per_fin_ap);  --último día del periodo final del año pasado  --30/04/2018

--return 0,'Proceso Inactivo'; 

set isolation to dirty read;

{drop table if exists t_bono_comerc;
select *
  from bono_comerc
  into temp t_bono_comerc;}

delete from bono_comerc
 where periodo between _per_ini and _per_fin_aa;
 
delete from fisc_bono;

let my_sessionid = DBINFO('sessionid');

--**********************************************************************************************
-- Prima Pagada Este Anno META I
--**********************************************************************************************
foreach
	select d.doc_remesa,
		   d.prima_neta,
		   d.fecha,
		   d.periodo,
		   e.nueva_renov,
		   e.cod_ramo,
		   e.vigencia_inic,
		   e.reemplaza_poliza
	  into _no_documento,
		   _monto,
		   _fecha_cobro,
		   _periodo,
		   _nueva_renov,
		   _cod_ramo,
		   _vigencia_inic,
		   _reemplaza_poliza
	  from cobredet d, emipomae e
	 where d.no_poliza = e.no_poliza
	   and d.periodo >= _per_ini
	   and d.periodo <= _per_fin_aa
	   and d.actualizado = 1
	   and d.tipo_mov in ('P', 'N')
	   and e.fronting = 0
	   and e.cod_ramo <> '008'

	--let _no_poliza = sp_sis21(_no_documento);

	if _nueva_renov = 'N' then
		if _reemplaza_poliza is not null and _reemplaza_poliza <> '' then
			let _no_poliza_r = sp_sis21(_reemplaza_poliza);

			if _no_poliza_r is not null then
				select nueva_renov,
					   vigencia_inic,
					   fronting,
					   reemplaza_poliza
				  into _nueva_renov,
					   _vigencia_inic,
					   _fronting,
					   _reemplaza_poliza
				  from emipomae
				 where no_poliza = _no_poliza_r;

				if _fronting = 1 then
					continue foreach;
				end if
			end if
		end if
	end if

	if _cod_ramo = '018' then -- Ramo de Salud	
		let _dias = _fecha_cobro - _vigencia_inic;
		
		if _dias > 365 then
			let _nueva_renov = 'S';
		else
			let _nueva_renov = 'N';
		end if
	end if

	insert into fisc_bono(no_documento, pri_pag_aa,tipo,nueva_renov,periodo)
	values (_no_documento, _monto,1,_nueva_renov,_periodo);
end foreach

--**********************************************************************************************
-- Prima Pagada Anno Pasado	META I
--**********************************************************************************************
foreach
	select d.doc_remesa,
		   d.prima_neta,
		   d.fecha,
		   d.periodo,
		   e.nueva_renov,
		   e.cod_ramo,
		   e.vigencia_inic,
		   e.fronting,
		   e.reemplaza_poliza
	  into _no_documento,
		   _monto,
		   _fecha_cobro,
		   _periodo,
		   _nueva_renov,
		   _cod_ramo,
		   _vigencia_inic,
		   _fronting,
		   _reemplaza_poliza
	  from cobredet d, emipomae e
	 where d.no_poliza = e.no_poliza
	   and d.periodo >= _per_ini_ap
	   and d.periodo <= _per_fin_ap
	   and e.cod_ramo <> '008'
	   and d.actualizado = 1
	   and d.tipo_mov in ('P', 'N')
	   and e.fronting = 0

	--Determinar el periodo equivalente al año actual
	let _ano = _periodo[1,4];
	let _mes = _periodo[5,6];
	let _periodo = _ano || '-' || _mes;

	if _nueva_renov = 'N' then
		if _reemplaza_poliza is not null and _reemplaza_poliza <> '' then
			let _no_poliza_r = sp_sis21(_reemplaza_poliza);

			if _no_poliza_r is not null then
				select nueva_renov,
					   vigencia_inic,
					   fronting,
					   reemplaza_poliza
				  into _nueva_renov,
					   _vigencia_inic,
					   _fronting,
					   _reemplaza_poliza
				  from emipomae
				 where no_poliza = _no_poliza_r;

				if _fronting = 1 then
					continue foreach;
				end if
			end if
		end if
	end if

	if _cod_ramo = '018' then -- Ramo de Salud	
		let _dias = _fecha_cobro - _vigencia_inic;
		
		if _dias > 365 then
			let _nueva_renov = 'R';
		else
			let _nueva_renov = 'N';
		end if
	end if

	insert into fisc_bono(no_documento, pri_pag_ap,tipo,nueva_renov,periodo)
	values (_no_documento, _monto,2,_nueva_renov,_periodo);
end foreach

--**********************************************************************************************
-- Prima Suscrita Actual		META II
--**********************************************************************************************

insert into fisc_bono(no_documento, pri_sus_aa,nueva_renov,periodo)
select p.no_documento,
	   b.pbs_nueva_neto,
	   p.nueva_renov,
	   e.periodo
  from endedmae e, emipomae p, deivid_bo:boendedmae b
 where e.no_poliza = p.no_poliza
   and e.no_poliza = b.no_poliza
   and e.no_endoso = b.no_endoso
   and e.actualizado = 1
   and e.periodo between _per_ini and _per_fin_aa
   and p.fronting = 0
   and p.cod_ramo <> '008';
	   
	   
{foreach
	select no_poliza,
		   no_endoso,
		   periodo
	  into _no_poliza,
		   _no_endoso,
		   _periodo
	  from endedmae
	 where actualizado  = 1
	   and periodo between _per_ini and _per_fin_aa

	select no_documento,
		   fronting
	  into _no_documento,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fronting = 1 then
		continue foreach;
	end if
	
	select pbs_nueva_neto
	  into _prima_suscrita
	  from deivid_bo:boendedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima_suscrita is null then
		let _prima_suscrita = 0.00;
	end if

	insert into fisc_bono(no_documento, pri_sus_aa,nueva_renov,periodo)
	values (_no_documento, _prima_suscrita,_nueva_renov,_periodo);
end foreach}

--**********************************************************************************************
-- Prima Suscrita Anno Pasado	META II
--**********************************************************************************************
insert into fisc_bono(no_documento, pri_sus_ap,nueva_renov,periodo)
select p.no_documento,
	   b.pbs_nueva_neto,
	   p.nueva_renov,
	   e.periodo
  from endedmae e, emipomae p, deivid_bo:boendedmae b
 where e.no_poliza = p.no_poliza
   and e.no_poliza = b.no_poliza
   and e.no_endoso = b.no_endoso
   and e.actualizado = 1
   and e.periodo between _per_ini_ap and _per_fin_ap
   and p.fronting = 0
   and p.cod_ramo <> '008';
--insert into fisc_bono(no_documento, pri_sus_ap,nueva_renov,periodo)
--values (_no_documento, _prima_suscrita,_nueva_renov,_periodo);

{foreach
	select no_poliza,
		   no_endoso,
		   periodo
	  into _no_poliza,
		   _no_endoso,
		   _periodo
	  from endedmae
	 where actualizado  = 1
	   and periodo between _per_ini_ap and _per_fin_ap

	--Determinar el periodo equivalente al año actual
	let _ano = _periodo[1,4];
	let _mes = _periodo[5,6];
	let _periodo = _ano || '-' || _mes;

	select no_documento,
		   fronting
	  into _no_documento,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fronting = 1 then
		continue foreach;
	end if
	
	select pbs_nueva_neto
	  into _prima_suscrita
	  from deivid_bo:boendedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima_suscrita is null then
		let _prima_suscrita = 0.00;
	end if

	insert into fisc_bono(no_documento, pri_sus_ap,nueva_renov,periodo)
	values (_no_documento, _prima_suscrita,_nueva_renov,_periodo);
end foreach}

---**********************************************************************************************
-- Polizas Nuevas y Renovadas Anno Pasado META III
---**********************************************************************************************
call sp_bo077(_fecha_ap_ini, _fecha_ap) returning _error, _error_desc;

foreach
	select no_documento,
		   sum(no_pol_nueva),
		   sum(no_pol_nueva_per),
		   sum(no_pol_renov),
		   sum(no_pol_renov_per)
	  into _no_documento,
		   _no_pol_nue_ap,
		   _no_pol_nue_ap_per,
		   _no_pol_ren_ap,
		   _no_pol_ren_ap_per
	  from tmp_persis
	 group by no_documento

	insert into fisc_bono(
			no_documento, 
			no_pol_nue_ap, 
			no_pol_nue_ap_per,
			no_pol_ren_ap,
			no_pol_ren_ap_per,
			periodo)
	values(	_no_documento, 
			_no_pol_nue_ap,
			_no_pol_nue_ap_per,
			_no_pol_ren_ap,
			_no_pol_ren_ap_per,
			_per_fin_aa);
end foreach

drop table tmp_persis;
----**********************************************************************************************
-- Polizas Nuevas y Renovadas Anno Actual META III
----**********************************************************************************************

call sp_bo077(_fecha_aa_ini, _fecha_aa) returning _error, _error_desc;

foreach
	select no_documento,
		   sum(no_pol_nueva),
		   sum(no_pol_renov),
		   sum(no_pol_renov_per)
	  into _no_documento,
		   _no_pol_nue_aa,
		   _no_pol_ren_aa,
		   _no_pol_ren_aa_per
	  from tmp_persis
	 group by no_documento
  
	insert into fisc_bono(
			no_documento, 
			no_pol_nue_aa, 
			no_pol_ren_aa,
			no_pol_ren_aa_per,
			periodo)
	values(	_no_documento, 
			_no_pol_nue_aa,
			_no_pol_ren_aa,
			_no_pol_ren_aa_per,
			_per_fin_aa);
end foreach

drop table if exists tmp_persis;

--**********************************************************************************************
-- Siniestros Pagados Anno Actual META IV
--**********************************************************************************************
call sp_rec01(a_compania, a_sucursal, _per_ini, _per_fin_aa,'*','*','008;Ex') returning _filtros;

foreach
	select doc_poliza,
		   pagado_bruto,
		   nueva_renov
	  into _no_documento,
		   _sin_pag_aa,
		   _nueva_renov
	  from tmp_sinis t, emipomae e
	 where t.no_poliza = e.no_poliza
	   and fronting = 0
	   and t.seleccionado = 1


	insert into fisc_bono(no_documento, sin_pag_aa,nueva_renov,periodo)
	values (_no_documento, _sin_pag_aa,_nueva_renov,_per_fin_aa);

end foreach
drop table tmp_sinis;

--**********************************************************************************************
-- Siniestros Pendientes Diciembre Anno Pasado META IV
--**********************************************************************************************

foreach 
	select e.no_documento,
		   e.nueva_renov,
		   t.no_reclamo,
		   sum(variacion)
	  into _no_documento,
		   _nueva_renov,
		   _no_reclamo,
		   _sin_pen_dic
	  from rectrmae t, recrcmae r, emipomae e
	 where t.no_reclamo = r.no_reclamo
	   and r.no_poliza = e.no_poliza
	   and t.cod_compania = a_compania
	   and t.periodo      <= _per_fin_dic
	   and t.actualizado  = 1
	   and t.numrecla <> '00-0000-00000-00'
	   and e.fronting = 0
	   and e.cod_ramo not in ('008')
	 group by e.no_documento,e.nueva_renov,t.no_reclamo
	having sum(variacion) > 0 

	{select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	let _fronting = 0;

	select no_documento,
		   nueva_renov,
		   cod_ramo,
		   fronting
	  into _no_documento,
		   _nueva_renov,
		   _cod_ramo,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fronting = 1 then
		continue foreach;
	end if}
	
	select porc_partic_coas 
	  into _porc_coaseguro
	  from reccoas
	 where no_reclamo   = _no_reclamo
	   and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_dic = _sin_pen_dic * (_porc_coaseguro / 100);

	insert into fisc_bono(no_documento, sin_pen_ap,nueva_renov)
	values (_no_documento, _sin_pen_dic,_nueva_renov);
end foreach

--**********************************************************************************************
-- Siniestros Pendientes Anno Actual --META IV
--**********************************************************************************************
foreach 
	select no_reclamo,
		   sum(variacion)
	  into _no_reclamo,
		   _sin_pen_aa
	   from rectrmae
	  where cod_compania = a_compania
		and periodo      <= _per_fin_aa
		and actualizado  = 1
		and numrecla <> '00-0000-00000-00'
	  group by no_reclamo
	 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	let _fronting = 0;

	select no_documento,
		   nueva_renov,
		   fronting,
		   cod_ramo
	  into _no_documento,
		   _nueva_renov,
		   _fronting,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fronting = 1 then
		continue foreach;
	end if

	if _cod_ramo = '008' then 
		continue foreach;
	end if

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_aa = _sin_pen_aa * (_porc_coaseguro / 100);

	insert into fisc_bono(no_documento, sin_pen_aa,nueva_renov)
	values (_no_documento, _sin_pen_aa,_nueva_renov);

end foreach

foreach
	select no_documento,
		   nueva_renov,
		   sum(pri_pag_aa),
		   sum(sin_pag_aa),
		   sum(sin_pen_aa),
		   sum(sin_pen_ap),
		   sum(no_pol_ren_aa),
		   sum(no_pol_ren_ap),
		   sum(no_pol_nue_aa),
		   sum(no_pol_nue_ap),
		   sum(no_pol_nue_ap_per),
		   sum(pri_pag_ap),
		   sum(pri_sus_aa),
		   sum(pri_sus_ap),
		   sum(no_pol_ren_aa_per),
		   sum(no_pol_ren_ap_per)
	  into _no_documento,
		   _nueva_renov,
		   _pri_pag,
		   _sin_pag_aa,
		   _sin_pen_aa,
		   _sin_pen_dic,
		   _no_pol_ren_aa,
		   _no_pol_ren_ap,
		   _no_pol_nue_aa,
		   _no_pol_nue_ap,
		   _no_pol_nue_ap_per,
		   _pri_pag_ap,
		   _prima_suscrita,
		   _prima_suscrita_ap,
		   _no_pol_ren_aa_per,
		   _no_pol_ren_ap_per
	  from fisc_bono
	 group by no_documento,nueva_renov
	 order by no_documento,nueva_renov

	let _no_poliza = sp_sis21(_no_documento);

	select cod_grupo,
		   cod_ramo,
		   cod_contratante,
		   cod_tipoprod
	  into _cod_grupo,
		   _cod_ramo,
		   _cod_contratante,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = '004' then	--Excluir Reaseguro Asumido
		continue foreach;
	elif _cod_tipoprod = '002' then --Coaseguro Minoritario
		let _no_pol_ren_aa_per = 0;
		let _no_pol_ren_ap_per = 0;
		let _no_pol_nue_ap_per = 0;
	end if
	
	if _cod_ramo in ('023','008') then --Excluir Flotas de la Persistencia
		let _no_pol_ren_aa_per = 0;
		let _no_pol_ren_ap_per = 0;
		let _no_pol_nue_ap_per = 0;
	end if

	-- Siniestros Incurridos		
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- Validaciones para Persistencia
	if _no_pol_ren_ap_per > 1 then
		let _no_pol_ren_ap_per = 1;
	end if

	if _no_pol_nue_ap_per > 1 then
		let _no_pol_nue_ap_per = 1;
	end if

	if _no_pol_ren_aa_per > 1 then
		let _no_pol_ren_aa_per = 1;
	end if

	if _no_pol_ren_aa_per = 1 and 
	   _no_pol_ren_ap_per = 0 and 
	   _no_pol_nue_ap_per = 0 then
		let _no_pol_ren_ap_per = 1;
	end if

	if _no_pol_ren_ap_per = 1 and 
	   _no_pol_nue_ap_per = 1 then
		let _no_pol_nue_ap_per = 0;
	end if

	select nombre
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	let _flag = 0;
	let _error = sp_sis101a(_no_documento,_fecha_aa,_fecha_aa,my_sessionid);	--Crea tabla con el corredor con_corr

	foreach
		select cod_agente
		  into _cod_agente
		  from con_corr
		 where sessionid = my_sessionid
		 order by porcentaje desc

		select tipo_agente,
			   estatus_licencia,
			   cod_vendedor
		  into _tipo_agente,
			   _estatus_licencia,
			   _cod_vendedor
		  from agtagent
		 where cod_agente = _cod_agente;

		if _tipo_agente <> 'A' then	-- Solo Corredores
		    let _flag = 1;
			--exit foreach;
		end if

	    select nombre 
		  into _nombre_vendedor 
		  from agtvende 
		 where cod_vendedor = _cod_vendedor;

		insert into bono_comerc( 
				periodo,
				cod_agente,
				no_documento,
				nueva_renov,
				cod_contratante,
				cod_vendedor,
				nombre_vendedor,
				tipo_agente,
				cod_ramo,
				nombre_ramo,
				n_cliente,
				pri_pag_aa,
				pri_pag_ap,
				sinis_inc,
				no_pol_nue_aa,
				no_pol_nue_ap,
				no_pol_ren_aa,
				no_pol_ren_ap,
				prima_suscrita,
				prima_suscrita_ap,
				vigenteap_per,
				renovaa_per,
				renovap_per)
		values(	_per_fin_aa,
				_cod_agente,				
				_no_documento,
				_nueva_renov,
				_cod_contratante,
				_cod_vendedor,
				_nombre_vendedor,
				_tipo_agente,
				_cod_ramo,
				_nombre_ramo,
				_n_cliente,
				_pri_pag,
				_pri_pag_ap,
				_sini_incu,
				_no_pol_nue_aa,    
				_no_pol_nue_ap,
				_no_pol_ren_aa,
				_no_pol_ren_ap,
				_prima_suscrita,
				_prima_suscrita_ap,
				_no_pol_nue_ap_per,
				_no_pol_ren_aa_per,
				_no_pol_ren_ap_per);
		exit foreach;
	end foreach
end foreach
--drop table if exists tmp_concurso;
end
--let _fecha_proceso = sp_sis40();
return 0,'Actualización Exitosa';
end procedure;