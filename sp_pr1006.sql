--Reporte para ver los registros de las tablas de estados de cuenta.REAESTCT1 Y REAESTCT2

drop procedure sp_pr1006;

create procedure "informix".sp_pr1006(
a_compania	char(03),
a_bx		varchar(255) default "*",
a_reas		varchar(255) default "*",
a_periodo1	char(7),
a_periodo2	char(7),
a_trim		smallint default 0)
returning	char(7),
			char(7),
			smallint,
			varchar(50),
			char(3),
			varchar(50),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			varchar(50),
			varchar(50),
			varchar(255),
			dec(16,2);

-- Procedimiento para ver los registros de los Estados de Cuenta de Reaseguro
-- Creado    : 08/11/2012 - Armando Moreno
-- execute procedure sp_pr1006("001","2012-04","2012-06","063;","01")

begin
define  m_concepto1			char(255);
define  m_concepto2			char(255);
define v_filtros			char(255);
define  t_reasegurador		char(50);
define t_descripcion		char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
define  m_contrato			char(50);
define  t_tipo    			char(10);
define _anio_reas			char(9);
define _periodo1			char(7);
define _periodo3			char(7);
define  s_cod_contrato		char(5);
define _ramo_reas			char(3);
define  s_cod_coasegur		char(3);
define  s_cod_clase			char(3);
define  v_clase				char(3);
define _contrato			char(2);
define a_tipo				char(2);
define _tipo				char(1);
define _saldo_inicial		dec(16,2);
define _saldo_final			dec(16,2);
define _saldo_trim			dec(16,2);
define _remesa_env			dec(16,2);
define _remesa_rec			dec(16,2);
define _remesa_otr			dec(16,2); 
define _cta_tec				dec(16,2);
define _valor				dec(16,2);
define _trim_reas			smallint;
define  _renglon			smallint;
define _tipo2				smallint;
define _cnt					integer;

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_compania);

create temp table tmp_estado
(periodo1		char(7),
periodo2		char(7),
trimestre		smallint,
ano				char(9),
reasegurador	char(3),
contrato		char(10),
saldo_ant		dec(16,2),
remesa_rec		dec(16,2),
remesa_env		dec(16,2),
remesa_otr		dec(16,2),
cta_tec			dec(16,2),
saldo_trim		dec(16,2), 
renglon			smallint,
seleccionado	smallint default 1);

--CREATE INDEX id1_tmp_estado ON tmp_estado(periodo1,periodo2,cod_ramo,cod_clase,reasegurador,contrato,p_partic,renglon);

--set debug file to "sp_pr1006.trc";	
--trace on;

let _remesa_otr = 0;

foreach
	select cod_contrato,
	       tipo
	  into a_tipo,
	  	   _tipo2
	  from reacontr
	 where activo = 1

	foreach
		select ano,
		       trimestre,
			   reasegurador,
		       saldo_inicial,
			   saldo_final,
			   saldo_trim
		  into _anio_reas,
		       _trim_reas,
		  	   s_cod_coasegur,
		       _saldo_inicial,
			   _saldo_final,
			   _saldo_trim
		  from reaestct1 
		 where contrato = a_tipo
	     order by ano,trimestre

	    select periodo1,
			   periodo3
		  into _periodo1,
			   _periodo3
		  from reatrim
		 where ano       = _anio_reas
		   and trimestre = _trim_reas;

		select sum(monto)
		  into _remesa_env
		  from reatrx1
		 where cod_contrato = a_tipo
		   and periodo between _periodo1 and _periodo3
		   and cod_coasegur = s_cod_coasegur
		   and tipo = '01';	   --remesa enviada
		    --and actualizado  = 1
		
		select sum(monto)
		  into _remesa_rec
		  from reatrx1
		 where cod_contrato = a_tipo
		   and periodo between _periodo1 and _periodo3
		   and cod_coasegur = s_cod_coasegur
		   and tipo = '02';	   --remesa recibida
		   -- and actualizado  = 1

		select sum(monto)
		  into _remesa_otr
		  from reatrx1
		 where cod_contrato = a_tipo
		   and periodo between _periodo1 and _periodo3
		   and cod_coasegur = s_cod_coasegur
		   and tipo not in('01','02');	   --remesa enviada
		    --and actualizado  = 1


		 --este select debo cambiarlo para sacar de reaestct2
		select sum(participar)
		  into _cta_tec
		  from reacoest
		 where anio         = _anio_reas
		   and trimestre    = _trim_reas
		   and borderaux    = a_tipo
		   and cod_coasegur = s_cod_coasegur;

		insert into tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
		values(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,a_tipo,_saldo_inicial,_remesa_rec,_remesa_env,_cta_tec,_saldo_final,0,1,_remesa_otr);
	end foreach

	foreach
		select distinct trimestre,
			   ano,
			   contrato
		  into _trim_reas,
			   _anio_reas,
			   _contrato
		  from tmp_estado
		 where seleccionado = 1

        foreach
	   		select cod_coasegur,
	   		       sum(participar)
			  into s_cod_coasegur,
			       _cta_tec
			  from reacoest
			 where anio         = _anio_reas
			   and trimestre    = _trim_reas
			   and borderaux    = _contrato
	           and cod_coasegur <> '036'
	         group by 1

			select count(*)
			  into _cnt
			  from tmp_estado
			 where seleccionado = 1
			   and ano          = _anio_reas
			   and trimestre    = _trim_reas
			   and reasegurador = s_cod_coasegur;

		    select periodo1,
				   periodo3
			  into _periodo1,
				   _periodo3
			  from reatrim
			 where ano       = _anio_reas
			   and trimestre = _trim_reas;

			if _cnt = 0 then
				insert into tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
				values(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,_contrato,0,0,0,_cta_tec,0,0,1,0);
			end if        
        end foreach 
	end foreach

	if a_trim = 0 then
		call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas;
		
		select periodo1,
			   periodo3
		  into _periodo1,
			   _periodo3
		  from reatrim
		 where ano       = _anio_reas
		   and trimestre = _trim_reas;

		foreach
	   		select cod_coasegur,
	   		       sum(participar)
			  into s_cod_coasegur,
			       _cta_tec
			  from reacoest
			 where anio         = _anio_reas
			   and trimestre    = _trim_reas
			   and borderaux    = a_tipo
	           and cod_coasegur <> '036'
	         group by 1

			select count(*)
			  into _cnt
			  from tmp_estado
			 where trimestre  = _trim_reas
			   and ano        = _anio_reas
			   and contrato   = a_tipo;

			if _cnt = 0 then
				insert into tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
	           	values(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,a_tipo,0,0,0,_cta_tec,0,0,1,0);
			end if
        end foreach        
    else
		foreach
			select distinct anio,
				   trimestre
			  into _anio_reas,
				   _trim_reas
			  from reacoest
			 where borderaux = a_tipo

			select count(*)
			  into _cnt
			  from tmp_estado
			 where trimestre  = _trim_reas
			   and ano        = _anio_reas
			   and contrato   = a_tipo;

			if _cnt = 0 then
				select periodo1,
					   periodo3
				  into _periodo1,
					   _periodo3
				  from reatrim
				 where ano       = _anio_reas
				   and trimestre = _trim_reas;

				foreach
					select cod_coasegur,
						   sum(participar)
					  into s_cod_coasegur,
						   _cta_tec
					  from reacoest
					 where anio         = _anio_reas
					   and trimestre    = _trim_reas
					   and borderaux    = a_tipo
					   and cod_coasegur <> '036'
					 group by 1

					insert into tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
					values(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,a_tipo,0,0,0,_cta_tec,0,0,1,0);
				end foreach
			end if
	   end foreach
	end if
end foreach


--Filtros
let v_filtros = "";

if a_bx <> "*" then
	let v_filtros = trim(v_filtros) || "Borderaux "||trim(a_bx);
	let _tipo = sp_sis04(a_bx); -- Separa los valores del String

	if _tipo <> "E" then -- incluir los registros

		update tmp_estado
	       set seleccionado = 0
	     where seleccionado = 1
	       and contrato not in (select codigo from tmp_codigos);
	else
		update tmp_estado
	       set seleccionado = 0
	     where seleccionado = 1
	       and contrato in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_reas <> "*" then
	let v_filtros = trim(v_filtros) ||"Reasegurador "||trim(a_reas);
	let _tipo = sp_sis04(a_reas); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_estado
	       set seleccionado = 0
	     where seleccionado = 1
	       and reasegurador not in (select codigo from tmp_codigos);
	else
		update tmp_estado
	       set seleccionado = 0
	     where seleccionado = 1
	       and reasegurador in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_trim = 1 then --todos
else
	update tmp_estado
       set seleccionado = 0
     where seleccionado = 1
       and (periodo1  <> a_periodo1
       and periodo2   <> a_periodo2);
end if

let _valor = 0;
foreach
	select periodo1,
	       periodo2,
		   trimestre,
		   ano,
		   reasegurador,
		   contrato,
		   saldo_ant,
		   remesa_rec,
		   remesa_env,
		   cta_tec,
		   saldo_trim,
		   remesa_otr
	  into _periodo1,
		   _periodo3,
		   _trim_reas,
		   _anio_reas,
		   s_cod_coasegur,
		   a_tipo,
		   _saldo_inicial,
		   _remesa_rec,
		   _remesa_env,
		   _cta_tec,
		   _saldo_final,
		   _remesa_otr
	  from tmp_estado
	 where seleccionado = 1

	if _remesa_rec is null then
		let _remesa_rec = 0;
	end if
	if _cta_tec is null then
		let _cta_tec = 0;
	end if
    if _saldo_final is null then
		let _saldo_final = 0;
	end if
	if _saldo_inicial is null then
		let _saldo_inicial = 0;
	end if
	if _remesa_env is null then
		let _remesa_env = 0;
	end if
	if _remesa_otr is null then
		let _remesa_otr = 0;
	end if
	
	let _valor = _saldo_inicial + _cta_tec + (_remesa_rec + _remesa_env + _remesa_otr);

	if _valor > 0 then
		let _valor = _valor * -1;
	else
		let _valor = _valor * -1;
	end if

	let _saldo_final = _valor;

	if _saldo_inicial > 0 then
		let _saldo_inicial = _saldo_inicial * -1;
	else
		let _saldo_inicial = _saldo_inicial * -1;
	end if
	if _remesa_rec < 0 then
		let _remesa_rec = _remesa_rec * -1;
	else
		let _remesa_rec = _remesa_rec * -1;
	end if
	if _remesa_env < 0 then
		let _remesa_env = _remesa_env * -1;
	else
		let _remesa_env = _remesa_env * -1;
	end if

	if _cta_tec > 0 then
		let _cta_tec = _cta_tec * -1;
	else
		let _cta_tec = _cta_tec * -1;
	end if

	select nombre
	  into t_reasegurador
	  from emicoase
	 where cod_coasegur = s_cod_coasegur;

	select descripcion
	  into t_descripcion
	  from reatrim
	 where ano       = _anio_reas
	   and trimestre = _trim_reas;

	select nombre
	  into m_contrato
	  from reacontr
	 where activo = 1
	   and cod_contrato = a_tipo;

    return _periodo1,		--1
		   _periodo3,		--2
		   _trim_reas,		--3
		   t_reasegurador,	--4
		   s_cod_coasegur,	--5
		   m_contrato,		--6
		   _saldo_inicial,	--7
		   _remesa_rec,		--8
		   _remesa_env,		--9
		   _cta_tec,		--10
		   _saldo_final,	--11
		   v_descr_cia,		--12
		   t_descripcion,	--13
		   v_filtros,		--14
		   _remesa_otr		--15
    	   with resume;
end foreach

drop table tmp_estado;
end
end procedure;	 