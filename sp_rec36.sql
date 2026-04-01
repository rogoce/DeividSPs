-- Procedimiento que Carga el Incurrido de Reclamos en un Periodo Dado
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec36;
create procedure "informix".sp_rec36(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255) default "*",
a_grupo		char(255) default "*",
a_ramo		char(255) default "*",
a_agente	char(255) default "*",
a_ajustador	char(255) default "*",
a_evento	char(255) default "*",
a_suceso	char(255) default "*")
returning	char(255);

define v_filtros			char(255);
define _doc_poliza			char(20);
define _numrecla			char(18);
define _transaccion			char(10);
define _cod_cliente			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_grupo			char(5);
define _ajust_interno		char(3);
define _cod_sucursal		char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_evento			char(3);
define _cod_suceso			char(3);
define _cod_ramo			char(3);
define _tipo				char(1);
define _deducible_total		dec(16,2);
define _deducible_bruto		dec(16,2);
define _deducible_neto		dec(16,2);
define _salvado_bruto		dec(16,2);
define _salvado_total		dec(16,2);
define _salvado_neto		dec(16,2);
define _monto_total			dec(16,2);
define _monto_bruto			dec(16,2);
define _monto_neto			dec(16,2);
define _porc_coas			dec;
define _porc_reas			dec;
define _posible_recobro		integer;
define _tipo_transaccion	smallint;

set isolation to dirty read;
-- seleccion del codigo de la compania lider
-- y del contrato de retencion

let _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal
--DROP TABLE tmp_sinis;

create temp table tmp_sinis(
no_reclamo           char(10)  not null,
no_poliza            char(10)  not null,
cod_sucursal         char(3)   not null,
cod_grupo			 char(5)   not null,
cod_ramo             char(3)   not null,
cod_subramo          char(3)   not null,
ajust_interno   	 char(3)   not null,
cod_evento     	     char(3)   not null,
cod_suceso     	     char(3),
cod_cliente          char(10)  not null,
periodo              char(7)   not null,
numrecla             char(18)  not null,
transaccion          char(10)  not null,
salvado_total        dec(16,2) not null,
salvado_bruto        dec(16,2) not null,
salvado_neto         dec(16,2) not null,
deducible_total      dec(16,2) not null,
deducible_bruto      dec(16,2) not null,
deducible_neto       dec(16,2) not null,
incurrido_total      dec(16,2) not null,
incurrido_bruto      dec(16,2) not null,
incurrido_neto       dec(16,2) not null,
posible_recobro		 int       not null,
seleccionado         smallint  default 1 not null,
doc_poliza           char(20)  not null,
primary key (no_reclamo,transaccion)) with no log;
create index xie01_tmp_sinis on tmp_sinis(cod_sucursal);
create index xie02_tmp_sinis on tmp_sinis(cod_grupo);
create index xie03_tmp_sinis on tmp_sinis(cod_ramo);
create index xie04_tmp_sinis on tmp_sinis(ajust_interno);
create index xie05_tmp_sinis on tmp_sinis(cod_evento);
create index xie06_tmp_sinis on tmp_sinis(cod_suceso);
create index xie07_tmp_sinis on tmp_sinis(no_poliza);

-- Pagos, Salvamentos, Recuperos y Deducibles
let _deducible_bruto = 0;
let _deducible_total = 0;
let _deducible_neto = 0;
let _salvado_bruto = 0;
let _salvado_total = 0;
let _salvado_neto = 0;
let _monto_total = 0;
let _monto_bruto = 0;
let _monto_neto = 0;

--SET DEBUG FILE TO 'sp_rec36.txt';
--TRACE ON;

foreach
	select a.no_reclamo,
		   a.transaccion,
		   a.monto,
		   a.cod_sucursal,
		   b.tipo_transaccion,
		   a.no_tranrec
	  into _no_reclamo,
		   _transaccion,
		   _monto_total,
		   _cod_sucursal,
		   _tipo_transaccion,
		   _no_tranrec
	  from rectrmae a,rectitra b
	 where a.cod_compania = a_compania
	   and a.actualizado = 1
	   and a.cod_tipotran = b.cod_tipotran
	   and b.tipo_transaccion in (5,6,7)
	   and a.periodo between a_periodo1 and a_periodo2
	   and a.monto <> 0

	-- Lectura de la Tablas de Reclamos
	select no_poliza,
	       periodo,
	       numrecla,
		   ajust_interno,
		   cod_evento,
		   cod_suceso,
		   posible_recobro
	  into _no_poliza,
	       _periodo,
	       _numrecla,
		   _ajust_interno,
		   _cod_evento,
		   _cod_suceso,
		   _posible_recobro
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	-- Informacion de Polizas
	select cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento
	  into _cod_ramo,
	       _cod_grupo,
	       _cod_subramo,
		   _cod_cliente,
		   _doc_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Informacion de Coseguro
	select porc_partic_coas
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coas is null then
		let _porc_coas = 0;
	end if

	-- Informacion de Reaseguro
	foreach
		select porc_partic_suma
		  into _porc_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1
		exit foreach;
	end foreach

	if _porc_reas is null then
		let _porc_reas = 0;
	end if;

	-- Calculos
    let _monto_bruto   = _monto_total   / 100 * _porc_coas;
	let _monto_neto    = _monto_bruto   / 100 * _porc_reas;

    if _tipo_transaccion = 5 or _tipo_transaccion = 6 then
       let _salvado_bruto = _monto_bruto;
       let _salvado_neto  = _monto_neto;
	   let _salvado_total = _monto_total;
	elif _tipo_transaccion = 7 then
       let _deducible_bruto = _monto_bruto; 
       let _deducible_neto  = _monto_neto;
       let _deducible_total = _monto_total;
	end if;
	
	{LET _monto_bruto = _monto_total / 100 * _porc_coas;
	LET _monto_neto  = _monto_bruto / 100 * _porc_reas;}

	-- Actualizacion del Movimiento
	begin
		on exception in(-239)
			update tmp_sinis
			   set salvado_total  = salvado_total + _salvado_total,
				   salvado_bruto  = salvado_bruto + _salvado_bruto,
				   salvado_neto   = salvado_neto  + _salvado_neto,
				   deducible_total  = deducible_total + _deducible_total,
				   deducible_bruto  = deducible_bruto + _deducible_bruto,
				   deducible_neto   = deducible_neto  + _deducible_neto
			 where no_reclamo    = _no_reclamo
			   and transaccion   = _transaccion;
		end exception;

		insert into tmp_sinis(
				salvado_total,
				salvado_bruto,
				salvado_neto,
				deducible_total,
				deducible_bruto,
				deducible_neto,
				incurrido_total,
				incurrido_bruto,
				incurrido_neto,
				no_reclamo,
				no_poliza,
				cod_ramo,
				periodo,
				numrecla,
				transaccion,
				cod_grupo,
				ajust_interno,
				cod_evento,
				cod_suceso,
				posible_recobro,
				cod_sucursal,
				cod_subramo,
				cod_cliente,
				doc_poliza)
		values(	_salvado_total,
				_salvado_bruto,
				_salvado_neto,
				_deducible_total,
				_deducible_bruto,
				_deducible_neto,
				_monto_total,
				_monto_bruto,
				_monto_neto,
				_no_reclamo,
				_no_poliza,
				_cod_ramo,
				_periodo,
				_numrecla,
				_transaccion,
				_cod_grupo,
				_ajust_interno,
				_cod_evento,
				_cod_suceso,
				_posible_recobro,
				_cod_sucursal,
				_cod_subramo,
				_cod_cliente,
				_doc_poliza);
	end

    let _deducible_total = 0;
    let _deducible_bruto = 0;
    let _deducible_neto  = 0;
    let _salvado_total = 0;
    let _salvado_bruto = 0;
    let _salvado_neto  = 0;
end foreach

-- actualizacion del incurrido
update tmp_sinis
   set incurrido_total = deducible_total + salvado_total,
       incurrido_bruto = deducible_bruto + salvado_bruto,
       incurrido_neto  = deducible_neto  + salvado_neto;

-- Procesos para Filtros
let v_filtros = "";

if a_sucursal <> "*" then
	let v_filtros = trim(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);
	let _tipo = sp_sis04(a_sucursal);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" THEN -- Incluir los Registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_grupo <> "*" then
	let v_filtros = trim(v_filtros) || " Grupo: " ||  TRIM(a_grupo);
	let _tipo = sp_sis04(a_grupo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_ramo <> "*" then
	let v_filtros = trim(v_filtros) || " Ramo: " ||  TRIM(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_ajustador <> "*" then
	let v_filtros = trim(v_filtros) || " Ajustador: " ||  trim(a_ajustador);
	let _tipo = sp_sis04(a_ajustador);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and ajust_interno not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and ajust_interno in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_evento <> "*" then
	let v_filtros = trim(v_filtros) || " Evento: " ||  TRIM(a_evento);
	let _tipo = sp_sis04(a_evento);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_evento not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_evento in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_suceso <> "*" then
	let v_filtros = trim(v_filtros) || " Suceso: " ||  trim(a_suceso);
	let _tipo = sp_sis04(a_suceso);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_suceso not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_suceso in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

return v_filtros;
end procedure;