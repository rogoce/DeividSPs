-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- Modificado: 13/01/2023 - Autor: Amado Perez -- Se agrega el campo factura_lider
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro556;

create procedure "informix".sp_pro556(a_cod_coasegur char(3),a_num_carga integer)
returning integer,
		  smallint,
		  char(30),
          char(100);

define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _no_poliza_coaseg	varchar(30);
define _nom_ramo			varchar(30);
define _cedula				varchar(30);
define _ramo				varchar(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _tipo_factura		char(3);
define _cod_sucursal		char(3);
define _cod_tipocan			char(3);
define _cod_ramo			char(3);
define _porc_partic_ancon	dec(7,4);
define _total_a_pagar		dec(16,2);
define _gastos_manejo		dec(16,2);
define _prima_ancon			dec(16,2);
define _prima_total			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_saldo				dec(16,2);
define _tot_polizas			smallint;
define _cnt_coaseg			smallint;
define _cnt_existe			smallint;
define _cnt_error			smallint;
define _tot_reg				smallint;
define _renglon				smallint;
define _existe				smallint;
define r_error				smallint;
define _no_modificacion		integer;
define _error_isam			integer;
define _error_excep			integer;
define _vigencia_inic_fe	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_factura		date;
define _fecha_hoy			date;
define _factura_lider       char(20);


--set debug file to "sp_pro556.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error_excep,_error_isam,_error_desc
	delete from equierroest 
	 where cod_coasegur	= a_cod_coasegur
	   and num_carga	= a_num_carga;

	drop table if exists tmp_emicacoami;
	return _error_excep,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
end exception

let _cod_ramo		= '';
let _cedula			= '';
let _no_poliza		= null;
let _renglon = 0;

select count(*)
  into _tot_reg
  from emicacoami
 where cod_coasegur	= a_cod_coasegur
   and num_carga	= a_num_carga;
 --group by no_poliza_coaseg,vigencia_inic;

update emicacoami
   set procesado = 0
 where cod_coasegur = a_cod_coasegur
   and num_carga = a_num_carga;
 
drop table if exists tmp_emicacoami;
select *
  from emicacoami
 where 1=2
  into temp tmp_emicacoami;

foreach
	select no_poliza_coaseg,
		   no_documento,
		   nom_cliente,
		   cedula,
		   tipo_factura,
		   ramo_coaseguro,
		   vigencia_inic,
		   vigencia_final,
		   porc_partic_ancon,
		   factura_lider,
		   sum(prima),
		   sum(impuesto),
		   sum(total_a_pagar)
	  into _no_poliza_coaseg,
		   _no_documento,
		   _nom_cliente,
		   _cedula,
		   _tipo_factura,
		   _ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _porc_partic_ancon,
		   _factura_lider,
		   _prima_total,
		   _impuesto,
		   _total_a_pagar
	  from emicacoami
	 where cod_coasegur = a_cod_coasegur
	   and num_carga = a_num_carga
	 group by no_poliza_coaseg,
		   no_documento,
		   nom_cliente,
		   cedula,
		   tipo_factura,
		   ramo_coaseguro,
		   vigencia_inic,
		   vigencia_final,
		   porc_partic_ancon,
		   factura_lider


	foreach
		select fecha_factura,
			   vigencia_inic_fe		   
		  into _fecha_factura,
			   _vigencia_inic_fe
		  from emicacoami
		 where cod_coasegur = a_cod_coasegur
		   and num_carga = a_num_carga
		   and no_poliza_coaseg = _no_poliza_coaseg
		exit foreach;
	end foreach

	let _renglon = _renglon + 1;
	let	_nom_cliente = sp_sis179(_nom_cliente);
	let	_ramo = sp_sis179(_ramo);
	let _prima_ancon = _prima_total * (_porc_partic_ancon/100);
	let r_error = 0;

	if _prima_ancon <= 0 then
		select count(*)
		  into _cnt_coaseg
		  from emipomae
		 where no_poliza_coaseg = _no_poliza_coaseg;

		if _cnt_coaseg is null then
			let _cnt_coaseg = 0;
		end if

		if _cnt_coaseg = 0 then
			{update emicacoami
			   set error = 1
			 where cod_coasegur	= a_cod_coasegur
			   and num_carga	= a_num_carga
			   and no_poliza_coaseg = _no_poliza_coaseg;

			continue foreach;}
			let r_error = 1; 
		end if
	end if

	insert into tmp_emicacoami(
			cod_coasegur,
			num_carga,
			no_poliza_coaseg,
			no_documento,
			nom_cliente,
			cedula,
			tipo_factura,
			fecha_factura,
			vigencia_inic_fe,
			ramo_coaseguro,
			vigencia_inic,
			vigencia_final,
			porc_partic_ancon,
			prima,
			impuesto,
			total_a_pagar,
			prima_ancon,
			error,
			procesado,
			renglon,
			factura_lider)
	values(	a_cod_coasegur,
			a_num_carga,
			_no_poliza_coaseg,
			_no_documento,
			_nom_cliente,
			_cedula,
			_tipo_factura,
			_fecha_factura,
			_vigencia_inic_fe,
			_ramo,
			_vigencia_inic,
			_vigencia_final,
			_porc_partic_ancon,
			_prima_total,
			_impuesto,
			_total_a_pagar,
			_prima_ancon,
			0,
			0,
			_renglon,
			_factura_lider);

	if _ramo is null then
		let _ramo = '';
	end if

	let _ramo = trim(_ramo);

	select cod_ramo
	  into _cod_ramo
	  from equiramoest
	 where cod_coasegur = a_cod_coasegur
	   and cod_ramo_coas = _ramo;

	if _cod_ramo is null or _cod_ramo = '' then
		insert into equierroest(
			   cod_coasegur,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia)
		values (a_cod_coasegur,
				a_num_carga,
				'cod_ramo',
				'No se encontro la Equivalencia para este Ramo.',
				_renglon,
				3);
				
		select count(*)
		  into _cnt_existe
		  from equiramoest
		 where cod_coasegur		= a_cod_coasegur
		   and cod_ramo_coas		= _cod_ramo;

		if _cnt_existe = 0 then 
			insert into equiramoest(
					cod_coasegur,
					cod_ramo,
					cod_ramo_coas)
			values	(a_cod_coasegur,
					null,
					_cod_ramo);
		end if
		
		let _cnt_existe = 0;		
	else
		update tmp_emicacoami
		   set cod_ramo		= _cod_ramo	
		 where cod_coasegur	= a_cod_coasegur
		   and num_carga	= a_num_carga
		   and renglon		= _renglon;
	end if

	if _nom_cliente is null or _nom_cliente = '' then
		insert into equierroest(
			   cod_coasegur,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia)
		values (a_cod_coasegur,
				a_num_carga,
				'cliente_nom',
			   'El Nombre del Cliente no puede ser dejado en blanco.',
			   _renglon,
			   3);		
	end if

	if _no_poliza_coaseg is null or _no_poliza_coaseg = '' then
		insert into equierroest(
			   cod_coasegur,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia)
		values (a_cod_coasegur,
				a_num_carga,
				'no_documento',
			   'El No. de Póliza es Requerido para Emitir la Póliza.',
			   _renglon,
			   3);
	end if 
	
	if _vigencia_inic is null or _vigencia_inic = '' then
		insert into equierroest(
			   cod_coasegur,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia)
		values (a_cod_coasegur,
				a_num_carga,
				'vigencia_inic',
			   'La Vigencia Inicial es requerida para Emitir la Póliza.',
			   _renglon,
			   3);
	end if 
	
	if _vigencia_final is null or _vigencia_final = '' then
		insert into equierroest(
			   cod_coasegur,
			   num_carga,
			   campo,
			   descripcion,
			   renglon,
			   importancia)
		values (a_cod_coasegur,
				a_num_carga,
				'vigencia_final',
			   'La Vigencia Final es requerida para Emitir la Póliza.',
			   _renglon,
			   3);
	end if

	select count(*)
	  into _existe
	  from equierroest
	 where campo in ('vigencia_final');
	
	if _existe is null then
		let _existe = 0;
	end if

	if _existe = 0 then
		if _vigencia_inic > _vigencia_final then
			insert into equierroest(
				   cod_coasegur,
				   num_carga,
				   campo,
				   descripcion,
				   renglon,
				   importancia)
			values (a_cod_coasegur,
					a_num_carga,
					'vigencia_inic',
					'La Vigencia Inicial no puede ser mayor a la Vigencia Final.',
					_renglon,
				   3);
				   
			insert into equierroest(
				   cod_coasegur,
				   num_carga,
				   campo,
				   descripcion,
				   renglon,
				   importancia)
			values (a_cod_coasegur,
					a_num_carga,
					'vigencia_final',
				   'La Vigencia Final no puede ser mayor a la Vigencia Inicial.',
				   _renglon,
				   3);	
		end if
	end if

	return 1,_tot_reg,'','' with resume;
end foreach
--trace off;

delete from emicacoami
 where cod_coasegur = a_cod_coasegur
   and num_carga = a_num_carga;

insert into emicacoami
select * from tmp_emicacoami;

select count(*)
  into _tot_polizas
  from emicacoami
 where cod_coasegur = a_cod_coasegur
   and num_carga = a_num_carga;

select count(*)
  into _cnt_error
  from equierroest
 where cod_coasegur	= a_cod_coasegur
   and num_carga	= a_num_carga
   and importancia	= 3;

if _cnt_error > 0 then   
	update prdcacoestm
	   set error = 1,
		   tot_registros	= _tot_polizas
	 where cod_coasegur	= a_cod_coasegur
	   and num_carga	= a_num_carga;
else
	update prdcacoestm
	   set tot_registros = _tot_polizas
	 where cod_coasegur = a_cod_coasegur 
	   and num_carga = a_num_carga;
end if
   
foreach
	select distinct renglon
	  into _renglon
	  from equierroest
	 where cod_coasegur	= a_cod_coasegur
	   and num_carga	= a_num_carga
	   and importancia	= 3

	update emicacoami
	   set error = 1
	 where cod_coasegur	= a_cod_coasegur
	   and num_carga	= a_num_carga
	   and renglon		= _renglon;	  
end foreach

--drop table equierroest;
drop table if exists tmp_emicacoami;

return 0,_tot_reg,'Verificacion Exitosa','';
end
end procedure	