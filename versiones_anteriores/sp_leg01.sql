-- Reporte de Demendas
-- Creado    : 21/07/2015 - Autor: Lic. Armando Moreno 
-- Modficado : 14/12/2015 - Autor: Román Gordón
-- execute procedure sp_leg01('001','001','01/08/2015',today,"*","*","*","*","*","*","*")

drop procedure sp_leg01;
create procedure "informix".sp_leg01(
a_compania			char(3),
a_agencia			char(3),
a_fecha				date,
a_fecha2			date,
a_abogado			char(255) default "*",
a_audiencia			char(255) default "*",
a_tipo_demanda		char(255) default "*",
a_depto				char(255) default "*",
a_estatus_actual	char(255) default "*",
a_instancia			char(255) default "*",
a_pronostico		char(255) default "*")
returning	char(50)		as Compania, 		--1	--v_compania_nombre,
			char(10)		as No_Demanda,		--2	--_no_demanda
			char(18)		as Nom_Demanda,		--3	--_n_demanda
			varchar(50)		as Demandante,		--4	--_demandante
			varchar(50)		as Demandado,		--5	--_demandado
			char(18)		as Num_Recla,		--6	--_numrecla
			char(10)		as Cod_Asegurado,	--7	--_cod_asegurado
			varchar(100)	as Nom_Asegurado,	--8	--v_nombre_aseg
			varchar(100)	as Conductor,		--9	--_conductor
			char(3)			as Cod_Abogado,		--10--_cod_abogado
			varchar(50)		as Nom_Abogado,		--11--v_nombre_abogado
			char(3)			as Cod_Depto,		--12--_cod_depto
			varchar(50)		as Nom_Depto,		--13--v_nombre_depto
			char(3)			as Cod_Juzgado,		--14--_juzgado
			varchar(50)		as Nom_Juzgado,		--15--v_nombre_juzgado
			char(8)			as Estatus_Actual,	--16--_n_estatus_actual
			char(20)		as Instancia,		--17--_n_instancia
			char(20)		as Expediente,		--18--_expediente
			char(15)		as Pronostico,		--19--_n_pronostico
			dec(16,2)		as Monto_Cuantia,	--20--_monto_cuantia
			dec(16,2)		as Honorario_Legal,	--21--_tot_honorario_legal
			dec(16,2)		as Reserva,			--22--_tot_reserva
			date			as Fecha_Anadido,	--23--_date_added
			char(255)		as Filtros;			--24--v_filtros


-- Para el nuevo proceso
define v_filtros			varchar(255);
define v_nombre_aseg		varchar(100);
define _conductor			varchar(100);
define v_compania_nombre	varchar(50);
define v_nombre_juzgado	    varchar(50);
define v_nombre_abogado     varchar(50);
define v_nombre_depto       varchar(50);
define _demandante			varchar(50);
define _demandado			varchar(50);
define _codigo				char(25);
define _n_instancia			char(20);
define _expediente			char(20);
define _n_demanda			char(18);
define _numrecla			char(18);
define _n_pronostico		char(15);
define _cod_asegurado		char(10);
define _no_demanda			char(10);
define _n_estatus_actual    char(8);
define _cod_abogado			char(3);
define _cod_depto			char(3);
define _juzgado				char(3);
define _tipo				char(1);
define _monto_cuantia		dec(16,2);
define _tot_honorario_legal	dec(16,2);
define _tot_reserva			dec(16,2);
define _estatus_actual		smallint;
define _tipo_demanda		smallint;
define _pronostico			smallint;
define _instancia			smallint;
define _date_added			date;

set isolation to dirty read;

--DROP TABLE tmp_prod;
create temp table tmp_prod(
no_demanda			char(10),
date_added			date,
demandante			varchar(50),
demandado			varchar(50),
numrecla			char(18),
cod_asegurado		char(10),
cod_abogado			char(3),
cod_depto		    char(3),
juzgado             char(3),
estatus_actual      smallint,
instancia           smallint,
expediente          char(20),
pronostico   	    smallint,
monto_cuantia		dec(16,2),
tot_honorario_legal	dec(16,2),
tot_reserva			dec(16,2),
tipo_demanda        smallint,
seleccionado   	    smallint  default 1 not null,
conductor			varchar(100)) with no log;

--CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
-- Nombre de la Compania

let v_compania_nombre = sp_sis01(a_compania);

foreach
	select no_demanda,
		   tipo_demanda,
		   demandante,
		   demandado,
		   numrecla,
		   cod_asegurado,
		   cod_abogado,
		   cod_depto,
		   juzgado,
		   estatus_actual,
		   instancia,
		   expediente,
		   pronostico,
		   monto_cuantia,
		   tot_honorario_legal,
		   tot_reserva,
		   date_added,
		   conductor
	  into _no_demanda,
		   _tipo_demanda,
		   _demandante,
		   _demandado,
		   _numrecla,
		   _cod_asegurado,
		   _cod_abogado,
		   _cod_depto,
		   _juzgado,
		   _estatus_actual,
		   _instancia,
		   _expediente,
		   _pronostico,
		   _monto_cuantia,
		   _tot_honorario_legal,
		   _tot_reserva,
		   _date_added,
		   _conductor
	  from legdeman
	 where date(date_added) >= a_fecha
	   and date(date_added) <= a_fecha2  

	insert into tmp_prod(
			no_demanda,
			tipo_demanda,
			demandante,
			demandado,
			numrecla,
			cod_asegurado,
			cod_abogado,
			cod_depto,
			juzgado,
			estatus_actual,
			instancia,
			expediente,
			pronostico,
			monto_cuantia,
			tot_honorario_legal,
			tot_reserva,
			date_added,
			conductor)
	values(	_no_demanda,
			_tipo_demanda,
			_demandante,
			_demandado,
			_numrecla,
			_cod_asegurado,
			_cod_abogado,
			_cod_depto,
			_juzgado,
			_estatus_actual,
			_instancia,
			_expediente,
			_pronostico,
			_monto_cuantia,
			_tot_honorario_legal,
			_tot_reserva,
			_date_added,
			_conductor);
end foreach;

-- Procesos para Filtros
let v_filtros = "";

if a_abogado <> "*" then
	let v_filtros = trim(v_filtros) || " Abogado: " ||  Trim(a_abogado);

	let _tipo = sp_sis04(a_abogado);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- (I) Incluir los Registros

	   update tmp_prod
	   	  set seleccionado = 0
		where seleccionado = 1
		  and cod_abogado not in (select codigo from tmp_codigos);
	else	        -- (E) Excluir estos Registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_abogado in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_audiencia <> "*" then
	let v_filtros = trim(v_filtros) || " Juzgado: " ||  TRIM(a_audiencia);

	let _tipo = sp_sis04(a_audiencia);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- (I) Incluir los Registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and juzgado not in (select codigo from tmp_codigos);
	else		        -- (E) Excluir estos Registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and juzgado in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_depto <> "*" then
	let v_filtros = trim(v_filtros) || " Depto.: " ||  trim(a_depto);

	let _tipo = sp_sis04(a_depto);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
	
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_depto not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_depto in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_tipo_demanda <> "*" then
	let _tipo = sp_sis04(a_tipo_demanda);  -- separa los valores del string en una tabla de codigos

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and tipo_demanda not in (select codigo from tmp_codigos);

    select codigo 
	  into _codigo
	  from tmp_codigos;
	  
	if _codigo = 0 then
		let _n_demanda = 'POR DEFINIR';
	elif _codigo = 1 then
		let _n_demanda = 'CIVIL';
	elif _codigo = 2 then
		let _n_demanda = 'PENAL';
	elif _codigo = 3 then
		let _n_demanda = 'ADMINISTRATIVA';
	end if
	
	let v_filtros = trim(v_filtros) || " Tipo Demanda: " ||  TRIM(_n_demanda);
	drop table tmp_codigos;
end if

if a_estatus_actual <> "*" then
	let _tipo = sp_sis04(a_estatus_actual);  -- separa los valores del string en una tabla de codigos

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and estatus_actual not in (select codigo from tmp_codigos);

    select codigo 
	  into _codigo
	  from tmp_codigos;
	  
	if _codigo = 1 then
		let _n_estatus_actual = 'EN CURSO';
	elif _codigo = 0 then
		let _n_estatus_actual = 'CERRADA';
	end if

	let v_filtros = TRIM(v_filtros) || " Tipo Demanda: " ||  trim(_n_estatus_actual);
	drop table tmp_codigos;
end if

if a_instancia <> "*" then
	let _tipo = sp_sis04(a_instancia);  -- separa los valores del string en una tabla de codigos

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and instancia not in (select codigo from tmp_codigos);

    select codigo 
	  into _codigo
	  from tmp_codigos;

	if _codigo = 1 then
		let _n_instancia = 'JUZGADO';
	elif _codigo = 2 then
		let _n_instancia = 'TRIBUNAL SUPERIOR';
	elif _codigo = 3 then
		let _n_instancia = 'CSJ';
	elif _codigo = 4 then
		let _n_instancia = 'MINISTERIO PUBLICO';
	end if	  
	let v_filtros = trim(v_filtros) || " Instancia: " ||  trim(_n_instancia);
	drop table tmp_codigos;
end if

if a_pronostico <> "*" then
	let _tipo = sp_sis04(a_pronostico);  -- separa los valores del string en una tabla de codigos

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and pronostico not in (select codigo from tmp_codigos);

    select codigo 
	  into _codigo
	  from tmp_codigos;
	  
	if _codigo = 1 then
		let _n_pronostico = 'FAVORABLE';
	elif _codigo = 2 then
		let _n_pronostico = 'RESERVADO';
	elif _codigo = 3 then
		let _n_pronostico = 'DESFAVORABLE';
	else
		let _n_pronostico = 'POR DEFINIR';
	end if

	let v_filtros = trim(v_filtros) || " Instancia: " ||  trim(_n_pronostico);
	drop table tmp_codigos;
end if

foreach
	select no_demanda,
		   tipo_demanda,
		   demandante,
		   demandado,
		   numrecla,
		   cod_asegurado,
		   cod_abogado,
		   cod_depto,
		   juzgado,
		   estatus_actual,
		   instancia,
		   expediente,
		   pronostico,
		   monto_cuantia,
		   tot_honorario_legal,
		   tot_reserva,
		   date_added,
		   conductor
	  into _no_demanda,
		   _tipo_demanda,
		   _demandante,
		   _demandado,
		   _numrecla,
		   _cod_asegurado,
		   _cod_abogado,
		   _cod_depto,
		   _juzgado,
		   _estatus_actual,
		   _instancia,
		   _expediente,
		   _pronostico,
		   _monto_cuantia,
		   _tot_honorario_legal,
		   _tot_reserva,
		   _date_added,
		   _conductor
	  from tmp_prod
	 where seleccionado = 1

	select nombre
	  into v_nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	  
	if _tipo_demanda = 0 then
		let _n_demanda = 'POR DEFINIR';
	elif _tipo_demanda = 1 then
		let _n_demanda = 'CIVIL';
	elif _tipo_demanda = 2 then
		let _n_demanda = 'PENAL';
	elif _tipo_demanda = 3 then
		let _n_demanda = 'ADMINISTRATIVA';
	end if
	  
	select nombre_abogado
	  into v_nombre_abogado
	  from recaboga
	 where cod_abogado = _cod_abogado;
	  
	foreach
		select upper(nombre)
		  into v_nombre_depto
		  from insdepto
		 where cod_depto = _cod_depto
		exit foreach;
	end foreach

	select nombre
	  into v_nombre_juzgado
	  from reclugci
	 where cod_lugci = _juzgado;
	  
	if _estatus_actual = 1 then
		let _n_estatus_actual = 'EN CURSO';
	elif _estatus_actual = 0 then
		let _n_estatus_actual = 'CERRADA';
	end if
	
	if _instancia = 1 then
		let _n_instancia = 'JUZGADO';
	elif _instancia = 2 then
		let _n_instancia = 'TRIBUNAL SUPERIOR';
	elif _instancia = 3 then
		let _n_instancia = 'CSJ';
	elif _instancia = 4 then
		let _n_instancia = 'PERSONERIA';
	end if
	
	if _pronostico = 1 then
		let _n_pronostico = 'FAVORABLE';
	elif _pronostico = 2 then
		let _n_pronostico = 'RESERVADO';
	elif _pronostico = 3 then
		let _n_pronostico = 'DESFAVORABLE';
	else
		let _n_pronostico = 'POR DEFINIR';
	end if

return  v_compania_nombre,		--1
		_no_demanda,			--2
  	    _n_demanda,				--3
  	    _demandante,			--4
  	    _demandado,				--5
  	    _numrecla,				--6
  	    _cod_asegurado,			--7
		v_nombre_aseg,			--8
		_conductor,				--9
  	    _cod_abogado,			--10
		v_nombre_abogado,		--11
		_cod_depto,				--12
		v_nombre_depto,			--13
		_juzgado,				--14
		v_nombre_juzgado,		--15
		_n_estatus_actual,		--16
		_n_instancia,			--17
		_expediente,			--18
		_n_pronostico,			--19
		_monto_cuantia,			--20
		_tot_honorario_legal,	--21
		_tot_reserva,			--22
		_date_added,			--23
		v_filtros with resume;	--24
end foreach;

drop table tmp_prod;
end procedure;