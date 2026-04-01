----------------------------------------------------------
--Proceso que genera la prima suscrita en un rango de periodos especifico y la prima cobrada de las mismas pólizas de la prima suscrita
--Creado    : 21/08/2015 - Autor: Román Gordón

--execute procedure sp_sis432('001','001','2014-01','2014-12','01/01/2014','31/12/2015','*','*','*','*','*')
----------------------------------------------------------

drop procedure sp_sis432;
create procedure sp_sis432(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_fecha_desde	date,
a_fecha_hasta	date,
a_codsucursal	char(255)	default '*',
a_codgrupo		char(255)	default '*',
a_codagente		char(255)	default '*',
a_codramo		char(255)	default '*',
a_subramo		char(255)	default '*')
returning	char(7)			as periodo,
			varchar(255)	as tipo_vigencia,
			varchar(50)		as Ramo,
			dec(16,2)		as Prima_Suscrita,
			dec(16,2)		as Prima_Cobrada;

define _error_desc			varchar(255);
define v_filtros2			varchar(255);
define v_filtros			varchar(255);
define _desc_ramo			varchar(50);
define _tipo_vigencia		varchar(20);
define _prima_suscrita		dec(16,2);
define _prima_cobrada		dec(16,2);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo_end			char(7);
define _periodo_cob			char(7);
define _no_endoso			char(5);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _fase				char(1);
define _tipo				char(1);
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _vigencia_inic		date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	rollback work;
	drop table if exists temp_produccion;
	drop table if exists tmp_polizas;
	drop table if exists temp_det;

	let _error_desc = _error_desc || ' ' || _fase || ' no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' ||trim(_no_endoso);
	return _error,_error_desc,'',0.00,0.00;
end exception

drop table if exists temp_produccion;
drop table if exists tmp_polizas;
drop table if exists temp_det;

let _no_poliza = '';
let _no_endoso = '';
let _fase = 'I';

--let v_descr_cia  = sp_sis01(a_compania);
call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,'*',a_codramo,'*')
returning v_filtros;

if a_subramo <> '*' then
	let v_filtros = trim(v_filtros) ||' Sub Ramo '||trim(a_subramo);
	let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

create temp table temp_produccion(
periodo				char(8),
nueva_renov			char(1),
cod_ramo			char(3),
cod_subramo			char(3),
prima_suscrita		dec(16,2),
prima_cobrada		dec(16,2),
seleccionado		smallint default 1,
no_poliza			char(10),
primary key(periodo,cod_ramo, cod_subramo,no_poliza,nueva_renov)) with no log;
create index idx1_temp_produccion on temp_produccion(seleccionado);

create temp table tmp_polizas(
no_poliza	char(10),
primary key(no_poliza)) with no log;

let _fase = 'P';

foreach with hold
	select no_poliza,																	 
		   no_endoso,
		   sum(prima)
	  into _no_poliza,
		   _no_endoso,
		   _prima_suscrita
	  from temp_det 
	 where seleccionado = 1
	 group by 1,2

	begin work;

	select vigencia_inic,
		   nueva_renov,
		   cod_ramo,
		   cod_subramo		   
	  into _vigencia_inic,
		   _nueva_renov,
		   _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _vigencia_inic < a_fecha_desde or _vigencia_inic > a_fecha_hasta then
		commit work;
		continue foreach;
	end if

	select periodo
	  into _periodo_end
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	begin
		on exception in(-239)
			update temp_produccion
			   set prima_suscrita = prima_suscrita + _prima_suscrita
			 where periodo = _periodo_end
			   and cod_ramo = _cod_ramo
			   and cod_subramo = _cod_subramo
			   and no_poliza = _no_poliza
			   and nueva_renov = _nueva_renov;
		end exception

		insert into temp_produccion(
				periodo,
				cod_ramo,
				cod_subramo,
				no_poliza,
				nueva_renov,
				prima_suscrita,
				prima_cobrada,
				seleccionado)
		values(	_periodo_end,
				_cod_ramo,
				_cod_subramo,
				_no_poliza,
				_nueva_renov,
				_prima_suscrita,
				0,
				1);
	end

	begin
		on exception in(-239)
		end exception
		insert into tmp_polizas(no_poliza)
		values(	_no_poliza);
	end

	commit work;
end foreach

let _fase = 'C';

call sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,'*',a_codramo,'*')
returning v_filtros2;

foreach with hold
	select t.no_poliza,
		   t.no_remesa,
		   t.renglon,
		   sum(t.prima_neta)
	  into _no_poliza,
		   _no_remesa,
		   _renglon,
		   _prima_cobrada
	  from temp_det t, tmp_polizas p
	 where t.no_poliza = p.no_poliza
	   and seleccionado = 1
	 group by 1,2,3

	begin work;

	select periodo
	  into _periodo_cob
	  from cobremae
	 where no_remesa = _no_remesa;

	select nueva_renov,
		   cod_ramo,
		   cod_subramo		   
	  into _nueva_renov,
		   _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	begin
		on exception in(-239)
			update temp_produccion
			   set prima_cobrada = prima_cobrada + _prima_cobrada
			 where periodo = _periodo_cob
			   and cod_ramo = _cod_ramo
			   and cod_subramo = _cod_subramo
			   and no_poliza = _no_poliza
			   and nueva_renov = _nueva_renov;
		end exception

		insert into temp_produccion(
				periodo,
				cod_ramo,
				cod_subramo,
				no_poliza,
				nueva_renov,
				prima_suscrita,
				prima_cobrada,
				seleccionado)
		values(	_periodo_cob,
				_cod_ramo,
				_cod_subramo,
				_no_poliza,
				_nueva_renov,
				0,
				_prima_cobrada,
				1);
	end

	commit work;
end foreach

foreach
	select periodo,
		   nueva_renov,
		   cod_ramo,
		   sum(prima_suscrita),
		   sum(prima_cobrada)
	  into _periodo_end,
		   _nueva_renov,
		   _cod_ramo,
		   _prima_suscrita,
		   _prima_cobrada
	  from temp_produccion
	 where seleccionado = 1
	 group by 1,2,3
	 order by 1,2,3

	select nombre
	  into _desc_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _nueva_renov = 'N' then
		let _tipo_vigencia = 'Nueva';
	elif _nueva_renov = 'R' then
		let _tipo_vigencia = 'Renovada';
	end if

	return	_periodo_end,
			_tipo_vigencia,
			_desc_ramo,
			_prima_suscrita,
			_prima_cobrada with resume;
end foreach

end
end procedure;